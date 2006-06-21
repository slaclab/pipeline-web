package org.glast.pipeline.web.servlet;

import java.io.*;
import java.net.URL;
import java.sql.Connection;
import javax.naming.InitialContext;
import javax.naming.NamingException;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.jstl.core.Config;
import javax.sql.DataSource;
import org.glast.pipeline.web.util.Task;
import org.glast.pipeline.web.util.GraphViz;

/**
 * A servlet to create pictures of tasks
 * @author tonyj, dflath
 * @version $Id: TaskImageServlet.java,v 1.3 2006-06-21 06:26:27 tonyj Exp $
 */
public class TaskImageServlet extends HttpServlet
{
   
   private InitialContext initialContext;
   private String dotCommand;
   
   /** Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
    * @param request servlet request
    * @param response servlet response
    */
   protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
   {
      try
      {
         int task_id = Integer.parseInt(request.getParameter("task"));
         HttpSession session = request.getSession();
         Object dataSourceName = Config.get(session, Config.SQL_DATA_SOURCE);
         if (dataSourceName == null) dataSourceName = session.getServletContext().getInitParameter("javax.servlet.jsp.jstl.sql.dataSource");
         DataSource dataSource = (DataSource) initialContext.lookup("java:comp/env/"+dataSourceName);
         Connection connection = dataSource.getConnection();
         
         InputStream in = createTaskImage(task_id,connection);
         if (in == null) in = new URL("http://itls.saisd.net/tateks/sub_pages/projects/flipbooks/Broken.gif").openStream();
         
         try
         {
            response.setContentType("image/gif");
            OutputStream out = response.getOutputStream();
            byte[] buffer = new byte[4096];
            for (;;)
            {
               int l = in.read(buffer);
               if (l<0) break;
               out.write(buffer,0,l);
            }
            in.close();
            out.close();
         }
         finally
         {
            connection.close();
         }
      }
      catch (Exception x)
      {
         throw new ServletException("Error in servlet",x);
      }
   }
   
   // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
   /** Handles the HTTP <code>GET</code> method.
    * @param request servlet request
    * @param response servlet response
    */
   protected void doGet(HttpServletRequest request, HttpServletResponse response)
   throws ServletException, IOException
   {
      processRequest(request, response);
   }
   
   /** Handles the HTTP <code>POST</code> method.
    * @param request servlet request
    * @param response servlet response
    */
   protected void doPost(HttpServletRequest request, HttpServletResponse response)
   throws ServletException, IOException
   {
      processRequest(request, response);
   }
   
   /** Returns a short description of the servlet.
    */
   public String getServletInfo()
   {
      return "Short description";
   }
   // </editor-fold>
   
 
   public void init(ServletConfig config) throws ServletException
   {
      super.init(config);
      dotCommand = config.getInitParameter("dotCommand");
      try
      {
         initialContext = new InitialContext();
      }
      catch (NamingException x)
      {
         throw new ServletException("Error initializing PipelineFilter",x);
      }
   }
   
   public void destroy()
   {
      super.destroy();
      try
      {
         initialContext.close();
      }
      catch (NamingException x)
      {
         throw new RuntimeException("Error destroying PipelineFilter",x);
      }
   }

   private InputStream createTaskImage(int task_id, Connection connection) throws Exception, ServletException
   {
      InputStream is = null;
      try {
         Task t = new Task(task_id, connection);
         GraphViz gv = new GraphViz(dotCommand);
         StringWriter sw = new StringWriter();
         t.draw(sw);
         System.out.println(sw.toString());
         System.out.println(sw.toString());
//         throw new ServletException(sw.toString());
         byte[] graphData = gv.getGraph(sw.toString());
         System.out.print("graph data (length=" + graphData.length + ") is [");
         for (byte _b: graphData) {
            Byte b = new Byte(_b);
            System.out.print(b.toString() + ",");
         }
         System.out.println("]");
         return new ByteArrayInputStream(graphData);
      } catch (Exception ex) {
         System.out.println("exception in creatTaskImage");
         ex.printStackTrace();
//         throw ex;
         return null;
      }
   }
}
