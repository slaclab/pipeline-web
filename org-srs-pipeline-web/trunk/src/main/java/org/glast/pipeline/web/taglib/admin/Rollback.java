package org.glast.pipeline.web.taglib.admin;

import java.sql.Connection;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.SimpleTagSupport;
import org.srs.pipeline.client.PipelineClient;
import org.glast.pipeline.web.util.ConnectionManager;
/**
 * A tag for uploading xml files to the pipeline database
 * @author tonyj
 */
public class Rollback extends SimpleTagSupport
{
   private StringBuilder streams = new StringBuilder();
   private StringBuilder processes = new StringBuilder();
   private String args = "";
   public void doTag() throws JspException
   {
      try
      {
         Connection conn = ConnectionManager.getConnection((PageContext) getJspContext(), null);
         try
         {
            PipelineClient client = new PipelineClient(conn);
            client.rollback(streams.toString(), processes.toString(), args);
         }
         finally
         {
            conn.close();
         }
      }
      catch (Exception x)
      {
         throw new JspException("Rollback failed",x);
      }
   }
   public void setProcesses(String[] processStrings)
   {
      for (String process : processStrings)
      {
         if (processes.length() > 0) processes.append(',');
         processes.append(process);
      }
   }
   public void setStreams(String[] streamStrings)
   {
      for (String stream : streamStrings)
      {
         if (streams.length() > 0) streams.append(',');
         streams.append(stream);
      }
   }
   public void setArgs(String args)
   {
      this.args = args;
   }
}
