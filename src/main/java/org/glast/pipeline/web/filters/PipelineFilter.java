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
            String mode = servletRequest.getParameter("mode");
            StringBuilder options = new StringBuilder();
            
            if (mode != null)
            {
               String modeString;
               String dataSource;
               
//               if ("dev".equals(mode))
//               {
//                  dataSource = "jdbc/pipeline-dev";
//                  modeString = "Dev";
//                  
//               }
//               else if ("test".equals(mode))
//               {
//                  dataSource = "jdbc/pipeline-test";
//                  modeString = "Test";
//               }
//               else // if ("prod".equals(mode))
//               {
//                  dataSource = "jdbc/pipeline";
//                  modeString = "Prod";
//               }
               dataSource = "jdbc/pipeline-ii";
               modeString = "Test";
               Config.set(session, Config.SQL_DATA_SOURCE, dataSource);
               session.setAttribute("mode", modeString);
            }
            
            String taskId = servletRequest.getParameter("task");
            if (taskId != null)
            {
               options.append("&task=").append(taskId);
               Object dataSourceName = Config.get(session, Config.SQL_DATA_SOURCE);
               if (dataSourceName == null) dataSourceName = session.getServletContext().getInitParameter("javax.servlet.jsp.jstl.sql.dataSource");
               DataSource dataSource = (DataSource) initialContext.lookup("java:comp/env/"+dataSourceName);
               Connection connection = dataSource.getConnection();
               try
               {
                  servletRequest.setAttribute("taskName",idToName(connection,taskId,"select TASKNAME from TASK where TASK=?"));
                  String processId = servletRequest.getParameter("process");

                  if (processId != null)
                  {
                     options.append("&process=").append(processId);
                     if (!"0".equals(processId)) servletRequest.setAttribute("processName",idToName(connection,processId,"select PROCESSNAME from PROCESS where PROCESS=?"));
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
   private String idToName(Connection connection, String id, String sql) throws SQLException
   {
      PreparedStatement preparedStatement = connection.prepareStatement(sql);
      preparedStatement.setInt(1,Integer.parseInt(id));
      ResultSet rs = preparedStatement.executeQuery();
      rs.next();
      String name = rs.getString(1);
      rs.close();
      return name;
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
