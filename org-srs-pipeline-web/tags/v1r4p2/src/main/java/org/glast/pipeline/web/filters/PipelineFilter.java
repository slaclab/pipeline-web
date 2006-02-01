package org.glast.pipeline.web.filters;

import edu.yale.its.tp.cas.client.ServiceTicketValidator;
import java.io.IOException;
import java.net.URLEncoder;
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
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.jsp.jstl.core.Config;
import javax.sql.DataSource;
import javax.xml.parsers.ParserConfigurationException;
import org.xml.sax.SAXException;

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
         // FixMe: Need something better here!
         if (!((HttpServletRequest) servletRequest).getRequestURL().toString().endsWith(".xsd"))
         {
            String login = servletRequest.getParameter("login");
            if ("true".equals(login) || "maybe".equals(login))
            {
               doLogin((HttpServletRequest) servletRequest, (HttpServletResponse) servletResponse,login);
            }
            else if ("false".equals(login))
            {
               doLogout((HttpServletRequest) servletRequest, (HttpServletResponse) servletResponse);
            }
            else
            {
               doCheckIfAlreadyLoggedIn((HttpServletRequest) servletRequest, (HttpServletResponse) servletResponse);
            }
            
            HttpSession session = ((HttpServletRequest) servletRequest).getSession();
            String mode = servletRequest.getParameter("mode");
            
            if (mode != null)
            {
               String modeString;
               String dataSource;
               
               if ("dev".equals(mode))
               {
                  dataSource = "jdbc/pipeline-dev";
                  modeString = "Dev";
                  
               }
               else if ("test".equals(mode))
               {
                  dataSource = "jdbc/pipeline-test";
                  modeString = "Test";
               }
               else // if ("prod".equals(mode))
               {
                  dataSource = "jdbc/pipeline";
                  modeString = "Prod";
               }
               Config.set(session, Config.SQL_DATA_SOURCE, dataSource);
               session.setAttribute("mode", modeString);
            }
            
            String taskId = servletRequest.getParameter("task");
            if (taskId != null)
            {
               Object dataSourceName = Config.get(session, Config.SQL_DATA_SOURCE);
               if (dataSourceName == null) dataSourceName = session.getServletContext().getInitParameter("javax.servlet.jsp.jstl.sql.dataSource");
               DataSource dataSource = (DataSource) initialContext.lookup("java:comp/env/"+dataSourceName);
               Connection connection = dataSource.getConnection();
               try
               {
                  servletRequest.setAttribute("taskName",idToName(connection,taskId,"select TASKNAME from TASK where TASK_PK=?"));
                  
                  String processId = servletRequest.getParameter("process");
                  if (processId != null && !processId.equals("0")) servletRequest.setAttribute("processName",idToName(connection,processId,"select TASKPROCESSNAME from TASKPROCESS where TASKPROCESS_PK=?"));
               }
               finally
               {
                  connection.close();
               }
            }
         }
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
   private void doLogin(HttpServletRequest request, HttpServletResponse response, String mode) throws IOException, SAXException, ParserConfigurationException, ServletException
   {
      String ticket = request.getParameter("ticket");
      if (ticket == null)
      {
         if ("true".equals(mode))
         {
            String here = URLEncoder.encode(request.getRequestURL().toString()+"?login=true","UTF-8");
            response.sendRedirect("https://glast-ground.slac.stanford.edu/cas/login?service="+here);
         }
      }
      else
      {
         ServiceTicketValidator sv = new ServiceTicketValidator();
         
         /* set its parameters */
         sv.setCasValidateUrl("https://glast-ground.slac.stanford.edu/cas/proxyValidate");
         sv.setService(request.getRequestURL().toString()+"?login="+mode);
         sv.setServiceTicket(ticket);
         
         /* contact CAS and validate */
         sv.validate();
         
         /* read the response */
         
         // Yes, this method is misspelled in this way
         // in the ServiceTicketValidator implementation.
         // Sorry.
         if(sv.isAuthenticationSuccesful())
         {
            request.getSession().setAttribute("userName", sv.getUser());
         }
         else
         {
            throw new ServletException("CAS Validation error: "+sv.getErrorCode()+" "+sv.getErrorMessage());
         }
      }
   }
   private void doLogout(HttpServletRequest request, HttpServletResponse response) throws IOException
   {
      request.getSession().removeAttribute("userName");
      response.sendRedirect("https://glast-ground.slac.stanford.edu/cas/logout");
   }
   private void doCheckIfAlreadyLoggedIn(HttpServletRequest request, HttpServletResponse response) throws IOException
   {
      HttpSession session = request.getSession();
      if (session.getAttribute("loginChecked") == null)
      {
         session.setAttribute("loginChecked","true");
         String here = URLEncoder.encode(request.getRequestURL().toString()+"?login=maybe","UTF-8");
         response.sendRedirect("https://glast-ground.slac.stanford.edu/cas/login?gateway=true&service="+here);
      }
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
