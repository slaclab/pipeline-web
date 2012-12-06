package org.srs.pipeline.web.taglib.admin;

import java.sql.Connection;
import java.util.logging.Logger;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.SimpleTagSupport;
import org.srs.groupmanager.GroupManagerWeb;
import org.srs.groupmanager.UserInfo;
import org.srs.pipeline.client.PipelineClient;
import org.srs.pipeline.web.util.ConnectionManager;
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
            UserInfo info = GroupManagerWeb.getUserInfo((PageContext) getJspContext());
            long t1 = System.currentTimeMillis();
            Logger.getLogger(Rollback.class.getName()).info(info.getSlacId() + " requests rollback of streams: " + streams.toString() + " and processes: " + processes.toString() + " with args: " + args);
            PipelineClient client = new PipelineClient(conn);
            client.rollback(streams.toString(), processes.toString(), args);
            long secs = (System.currentTimeMillis() - t1) / 1000;
            Logger.getLogger(Rollback.class.getName()).info("Rollback finished and took " + secs + " seconds.");
         }
         finally
         {
            conn.close();
         }
      }
      catch (Exception x)
      {
         Logger.getLogger(Rollback.class.getName()).info("Rollback failed.");
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
