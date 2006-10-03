package org.glast.pipeline.web.util;

import java.sql.Connection;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspTagException;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.jstl.core.Config;
import javax.sql.DataSource;
import org.apache.taglibs.standard.tag.common.sql.DataSourceWrapper;

/**
 *
 * @author tonyj
 */
public class ConnectionManager
{
   private static final String ESCAPE = "\\";
   private static final String TOKEN = ",";
   
   public static Connection getConnection(HttpServletRequest request) throws ServletException
   {
      HttpSession session = request.getSession();
      Object dataSourceName = Config.get(session, Config.SQL_DATA_SOURCE);
      if (dataSourceName == null) dataSourceName = session.getServletContext().getInitParameter("javax.servlet.jsp.jstl.sql.dataSource");
      try
      {
         DataSource dataSource = getDataSource(dataSourceName,null);
         return dataSource.getConnection();
      }
      catch (Exception ex)
      {
         throw new ServletException("Invalid Datasource",ex);
      }
   }
   
   public static Connection getConnection(PageContext context, Object rawDataSource) throws JspException
   {
      DataSource dataSource = getDataSource(rawDataSource,context);
      try
      {
         return dataSource.getConnection();
      }
      catch (Exception ex)
      {
         throw new JspException("Invalid Datasource",ex);
      }
   }
   private static DataSource getDataSource(Object rawDataSource, PageContext pc) throws JspException
   {
      DataSource dataSource = null;
      
      if (rawDataSource == null)
      {
         rawDataSource = Config.find(pc, Config.SQL_DATA_SOURCE);
      }
      
      if (rawDataSource == null)
      {
         return null;
      }
      
        /*
         * If the 'dataSource' attribute's value resolves to a String
         * after rtexpr/EL evaluation, use the string as JNDI path to
         * a DataSource
         */
      if (rawDataSource instanceof String)
      {
         try
         {
            Context ctx = new InitialContext();
            // relative to standard JNDI root for J2EE app
            Context envCtx = (Context) ctx.lookup("java:comp/env");
            dataSource = (DataSource) envCtx.lookup((String) rawDataSource);
         }
         catch (NamingException ex)
         {
            dataSource = getDataSource((String) rawDataSource);
         }
      }
      else if (rawDataSource instanceof DataSource)
      {
         dataSource = (DataSource) rawDataSource;
      }
      else
      {
         throw new JspException("Invalid data source");
      }
      
      return dataSource;
   }
   private static DataSource getDataSource(String params) throws JspException
   {
      DataSourceWrapper dataSource = new DataSourceWrapper();
      
      String[] paramString = new String[4];
      int escCount = 0;
      int aryCount = 0;
      int begin = 0;
      
      for(int index=0; index < params.length(); index++)
      {
         char nextChar = params.charAt(index);
         if (TOKEN.indexOf(nextChar) != -1)
         {
            if (escCount == 0)
            {
               paramString[aryCount] = params.substring(begin,index).trim();
               begin = index + 1;
               if (++aryCount > 4)
               {
                  throw new JspTagException("Invalid jdbc parameter count");
               }
            }
         }
         if (ESCAPE.indexOf(nextChar) != -1)
         {
            escCount++;
         }
         else
         {
            escCount = 0;
         }
      }
      paramString[aryCount] = params.substring(begin).trim();
      
      // use the JDBC URL from the parameter string
      dataSource.setJdbcURL(paramString[0]);
      
      // try to load a driver if it's present
      if (paramString[1] != null)
      {
         try
         {
            dataSource.setDriverClassName(paramString[1]);
         }
         catch (Exception ex)
         {
            throw new JspTagException("Invalid driver class: "+ paramString[1],ex);
            
         }
      }
      
      // set the username and password
      dataSource.setUserName(paramString[2]);
      dataSource.setPassword(paramString[3]);
      
      return dataSource;
   }
   
}
