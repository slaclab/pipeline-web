package org.glast.pipeline.web.servlet;

import java.io.*;
import java.sql.Connection;
import java.sql.SQLException;
import javax.naming.InitialContext;

import javax.servlet.*;
import javax.servlet.http.*;
import org.glast.pipeline.web.util.ConnectionManager;
import org.glast.pipeline.web.util.Task;
import org.glast.pipeline.web.util.GraphViz;

/**
 * A servlet to create pictures of tasks
 * @author tonyj, dflath
 * @version $Id: TaskImageServlet.java,v 1.6 2006-10-03 19:43:07 tonyj Exp $
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
            Connection connection = ConnectionManager.getConnection(request);
            try
            {
                ByteArrayOutputStream bytes = createTaskImage(task_id,connection);
                response.setContentType("image/gif");
                bytes.writeTo(response.getOutputStream());
            }
            finally
            {
                connection.close();
            }
        }
        catch (SQLException x)
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
    }
    
    private ByteArrayOutputStream createTaskImage(int task_id, Connection connection) throws ServletException
    {
        try
        {
            Task t = new Task(task_id, connection);
            GraphViz gv = new GraphViz(dotCommand);
            StringWriter sw = new StringWriter();
            t.draw(sw);
            return gv.getGraph(sw.toString());
        }
        catch (Exception ex)
        {
            throw new ServletException("Error creating task image",ex);
        }
    }
}
