package org.glast.pipeline.web.filters;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.servlet.jsp.jstl.core.Config;
import javax.sql.DataSource;

/**
 * A filter which serves to perform preprocessing on all requests.
 * @author tonyj
 */
public class PipelineFilter implements Filter
{
   private InitialContext initialContext;
   /** Creates a new instance of PipelineFilter */
   public PipelineFilter()
   {
   }
   
   public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException
   {
      try
      {
         HttpSession session = ((HttpServletRequest) servletRequest).getSession();
         StringBuilder options = new StringBuilder();
         
         Object dataSourceName = Config.get(session, Config.SQL_DATA_SOURCE);
         if (dataSourceName == null) dataSourceName = session.getServletContext().getInitParameter("javax.servlet.jsp.jstl.sql.dataSource");
         DataSource dataSource = (DataSource) initialContext.lookup("java:comp/env/"+dataSourceName);
         
         String piId = servletRequest.getParameter("pi");
         String taskId = servletRequest.getParameter("task");
         String processId = servletRequest.getParameter("process");
         if (piId != null && piId.length() > 0 && !piId.equals("0"))
         {
            options.append("&pi=").append(piId);
            Connection connection = dataSource.getConnection();
            try
            {
               String sql = "select process,streampath,streamidPath,processname,taskpath,taskNamePath,taskname,task "+
                       "from processinstance join streampath using (stream) "+
                       "join process using (process) "+
                       "join taskpath using (task) "+
                       "join task using (task) "+
                       "where processinstance=?";
               PreparedStatement preparedStatement = connection.prepareStatement(sql);
               try
               {
                  int processInstance = Integer.parseInt(piId);
                  preparedStatement.setInt(1,processInstance);
                  ResultSet rs = preparedStatement.executeQuery();
                  rs.next();
                  servletRequest.setAttribute("processInstance",processInstance);
                  servletRequest.setAttribute("process",rs.getInt(1));
                  servletRequest.setAttribute("streamPath",rs.getString(2));
                  servletRequest.setAttribute("streamIdPath",rs.getString(3));
                  servletRequest.setAttribute("processName",rs.getString(4));
                  servletRequest.setAttribute("taskPath",rs.getString(5));
                  servletRequest.setAttribute("taskNamePath",rs.getString(6));
                  servletRequest.setAttribute("taskName",rs.getString(7));
                  servletRequest.setAttribute("task",rs.getInt(8));
                  rs.close();
               }
               finally
               {
                  preparedStatement.close();
               }
            }
            finally
            {
               connection.close();
            }
         }
         else if (processId != null && processId.length() > 0 && !processId.equals("0"))
         {
            options.append("&process=").append(processId);
            Connection connection = dataSource.getConnection();
            try
            {
               String sql = "select processname,taskpath,taskNamePath,taskname,task "+
                       "from process "+
                       "join taskpath using (task) "+
                       "join task using (task) "+
                       "where process=?";
               PreparedStatement preparedStatement = connection.prepareStatement(sql);
               try
               {
                  int process = Integer.parseInt(processId);
                  preparedStatement.setInt(1,process);
                  ResultSet rs = preparedStatement.executeQuery();
                  rs.next();
                  servletRequest.setAttribute("process",process);
                  servletRequest.setAttribute("processName",rs.getString(1));
                  servletRequest.setAttribute("taskPath",rs.getString(2));
                  servletRequest.setAttribute("taskNamePath",rs.getString(3));
                  servletRequest.setAttribute("taskName",rs.getString(4));
                  servletRequest.setAttribute("task",rs.getInt(5));
                  rs.close();
               }
               finally
               {
                  preparedStatement.close();
               }
            }
            finally
            {
               connection.close();
            }
         }
         else if (taskId != null && taskId.length() > 0 && !taskId.equals("0"))
         {
            options.append("&task=").append(taskId);
            Connection connection = dataSource.getConnection();
            try
            {
               String sql = "select taskpath,taskNamePath,taskname,taskversion "+
                       "from taskpath "+
                       "join task using (task) "+
                       "where task=?";
               PreparedStatement preparedStatement = connection.prepareStatement(sql);
               try
               {
                  int task = Integer.parseInt(taskId);
                  preparedStatement.setInt(1,task);
                  ResultSet rs = preparedStatement.executeQuery();
                  rs.next();
                  servletRequest.setAttribute("task",task);
                  servletRequest.setAttribute("taskPath",rs.getString(1));
                  servletRequest.setAttribute("taskNamePath",rs.getString(2));
                  servletRequest.setAttribute("taskName",rs.getString(3));
                  servletRequest.setAttribute("taskVersion",rs.getString(4));
                  rs.close();
               }
               finally
               {
                  preparedStatement.close();
               }
            }
            finally
            {
               connection.close();
            }
         }
         servletRequest.setAttribute("optionString",options.toString());
         
      }
      catch (Exception x)
      {
         throw new ServletException("Error in PipelineFilter",x);
      }
      filterChain.doFilter(servletRequest,servletResponse);
   }
   
   public void init(FilterConfig filterConfig) throws ServletException
   {
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
      try
      {
         initialContext.close();
      }
      catch (NamingException x)
      {
         throw new RuntimeException("Error destroying PipelineFilter",x);
      }
   }
}
