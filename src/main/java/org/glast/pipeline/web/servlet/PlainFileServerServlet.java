package org.glast.pipeline.web.servlet;

import java.io.File;
import java.io.PrintWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URISyntaxException;
import java.net.URL;
import java.net.URLConnection;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * This servlet allows part of a web applications space to be mapped relative 
 * to a base URL. For example
 * 
 *     /Commons/Decorate/MootConfigReports -> file:/nfs/farm/g/glast/u03/ConfigReports
 * 
 * Files will be fetched from this URL and sent back to the requestor. 
 * 
 * If the URL represents a local file system (file://) then the following additional
 * features are supported:
 * 
 * If the file to be fetched represents a directory then servlet will first look
 * for an index.html file in this directory and if found return it. Otherwise it will 
 * look for a HEADER.html and return it if present, followed by an HTML representation of the directory. 
 */
/* TODO:
 * Currently the server is hardwired to use the jdbc/glastgen table decorator to control its mappings.
 * It would be more flexible if it could also be configured from the web.xml file.
 * 
 * It would be good to include an extra column in the database table representing a group name to which
 * access is meant to be restricted.
 * 
 * @author The FreeHEP team @ SLAC.
 *
 */
public class PlainFileServerServlet extends HttpServlet {

    private String urlBase;

    public static boolean isFile(Object obj) {
        return ! obj.toString().endsWith("/");
    }

    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        urlBase = config.getInitParameter("urlBase");
        if (urlBase == null) {
            throw new RuntimeException("Parameter urlBase must be provided to the PlainFileServer Servlet");
        }
    }

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {


        String href = "";
        if (request.getParameter("href") != null) {
            href = request.getParameter("href");
        }
        String path = "";
        if (request.getParameter("path") != null) {
            path = request.getParameter("path");
        }
        String queryString = "";
        if (request.getParameter("queryString") != null) {
            queryString = request.getParameter("queryString");
        }


        String[] pathInfo = request.getPathInfo().split("/");
        StringBuilder urlBuilder = new StringBuilder(urlBase);
        for (int i = 1; i < pathInfo.length; i++) {
            urlBuilder.append('/').append(pathInfo[i]);
        }


        String urlString = urlBuilder.toString();
        URL url = new URL(urlString);
        try {
            if ("file".equals(url.getProtocol())) {
                File file = new File(url.toURI());
                if (file.isDirectory()) {
                    response.setContentType("text/html");
                    PrintWriter writer = response.getWriter();

                    File[] children = file.listFiles();

                    for (File child : children) {
                        if (child.isHidden()) {
                            continue;
                        }
                        String name = child.getName();
                        String tmpPath = child.isDirectory() ? name + "/" : name;
                        tmpPath = path + tmpPath;
                        String tmpHref = href + "?path=" + tmpPath;
                        if ( ! queryString.equals("") )
                            tmpHref += "&"+queryString;
                        writer.println(String.format("<li><a href=\"%s\">%s</a></li>", tmpHref, name));
                    }
                    return;
                }
            }
        } catch (URISyntaxException x) {
            throw new ServletException("Error opening file", x);
        }

        boolean download = false;
        if (request.getParameter("download") != null) {
            response.setHeader("Content-Disposition", "attachment; filename=\"" + url.getFile() + "\"");
            response.setContentType("text/plain");
            download = true;
        }

        URLConnection connection = url.openConnection();
        String contentType = connection.getContentType();
        if ("text/plain".equals(contentType)) {
            response.setContentType("text/html");
            PrintWriter writer = response.getWriter();
            copyStream(writer, url);
            return;
        }
        response.setContentType(contentType);
        response.setContentLength(connection.getContentLength());
        ServletOutputStream out = response.getOutputStream();
        InputStream in = url.openStream();
        try {
            byte[] buffer = new byte[4096];
            for (;;) {
                int l = in.read(buffer);
                if (l < 0) {
                    break;
                }
                out.write(buffer, 0, l);
            }
        } finally {
            in.close();
        }
    }

    private void copyStream(PrintWriter writer, URL url) throws IOException {
        Reader in = new InputStreamReader(url.openStream());
        try {
            char[] buffer = new char[4096];
            for (;;) {
                int l = in.read(buffer);
                if (l < 0) {
                    break;
                }

                writer.write(buffer, 0, l);
            }

        } finally {
            in.close();
        }
    }
}
