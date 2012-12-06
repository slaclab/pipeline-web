package org.srs.pipeline.web.filters;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;

/**
 *
 * @author tonyj
 */
public class BlankLineFilter implements Filter
{
   public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws java.io.IOException, javax.servlet.ServletException
   {
      final StringWriter pageBuffer = new StringWriter();
      HttpServletResponseWrapper wrap = new HttpServletResponseWrapper((HttpServletResponse) servletResponse)
      {
         public PrintWriter getWriter() throws IOException
         {
            return new PrintWriter(pageBuffer);
         }
         public void setContentLength(int length)
         {
         }
      };
      filterChain.doFilter(servletRequest,wrap);
      PrintWriter out = servletResponse.getWriter();

      BufferedReader reader = new BufferedReader(new StringReader(pageBuffer.toString()));
      for (;;)
      {
         String line = reader.readLine();
         if (line == null) break;
         if (line.trim().length() == 0) continue;
         out.println(line);
      }
      out.close();
   }
   
   public void init(FilterConfig filterConfig) throws ServletException
   {
   }
   
   public void destroy()
   {
   }
}
