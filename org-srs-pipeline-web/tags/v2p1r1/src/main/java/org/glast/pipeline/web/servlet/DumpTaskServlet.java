package org.glast.pipeline.web.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.glast.pipeline.web.util.ConnectionManager;
import org.glast.pipeline.web.xml.Exporter;

/**
 * A tag for uploading xml files to the pipeline database
 * @author tonyj
 */
public class DumpTaskServlet extends HttpServlet
{
   private InitialContext initialContext;
   
   protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
   {
      try
      {
         Connection connection = ConnectionManager.getConnection(request);
         try
         {
            int task = Integer.valueOf(request.getParameter("task"));
            Exporter exporter = new Exporter(connection);
            exporter.export(response.getWriter(),task);
            exporter.close();
         }
         finally
         {
            connection.close();
         }
      }
      catch (SQLException x)
      {
         throw new ServletException("Error exporting XML",x);
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
   
}