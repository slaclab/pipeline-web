package org.glast.pipeline.web.taglib.upload;

import java.io.FilterWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.SimpleTagSupport;
/**
 * A tag for uploading xml files to the pipeline database
 * @author tonyj
 */
public class ReportError extends SimpleTagSupport
{
   private Throwable error;
   private boolean brief;
   
   public void doTag() throws JspException, IOException
   {
      JspWriter writer = getJspContext().getOut();
      writer.print("<pre>");
      if (error instanceof JspException && (( JspException) error).getRootCause() != null) error = ((JspException) error).getRootCause();
      error.printStackTrace(new PrintWriter(new BriefWriter(writer,brief)));
      writer.print("</pre>");
   }
   
   public void setError(Throwable error)
   {
      this.error = error;
   }
   public void setBrief(boolean brief)
   {
      this.brief = brief;
   }
   private static class BriefWriter extends FilterWriter
   {
      private boolean filter;
      private boolean newLine = false;
      private boolean suppress = false;
      
      BriefWriter(Writer writer, boolean filter)
      {
         super(writer);
         this.filter = filter;
      }
      
      public void write(int c) throws IOException
      {
         if (c == '\n')
         {
            newLine = true;
         }
         else if (newLine)
         {
            if (c == '\t') suppress = true;
            else suppress = false;
            newLine = false;
         }
         if (!suppress || !filter) super.write(c);
      }

      public void write(char[] cbuf, int off, int len) throws IOException
      {
         for (int i=0; i<len; i++) write(cbuf[i+off]);
      }

      public void write(String str, int off, int len) throws IOException
      {
         for (int i=0; i<len; i++) write(str.charAt(i+off));
      }
      
   }
}