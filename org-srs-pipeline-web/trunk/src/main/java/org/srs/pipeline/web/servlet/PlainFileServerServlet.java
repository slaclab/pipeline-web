package org.srs.pipeline.web.servlet;

public class PlainFileServerServlet  {


    public static boolean isFile(Object obj) {
        return ! obj.toString().endsWith("/");
    }
}
