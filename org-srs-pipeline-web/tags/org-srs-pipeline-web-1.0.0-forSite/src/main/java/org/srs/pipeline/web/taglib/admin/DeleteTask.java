package org.srs.pipeline.web.taglib.admin;

import java.sql.Connection;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.SimpleTagSupport;
import org.srs.pipeline.client.PipelineClient;
import org.srs.pipeline.web.util.*;
import org.srs.pipeline.web.util.ConnectionManager;
/**
 * A tag for uploading xml files to the pipeline database
 * @author tonyj
 */
public class DeleteTask extends SimpleTagSupport
{
   private String task;
   
   public void doTag() throws JspException
   {
      try
      {
         Connection conn = ConnectionManager.getConnection((PageContext) getJspContext(), null);
         try
         {
            PipelineClient client = new PipelineClient(conn);
            client.deleteTask(task);
         }
         finally
         {
            conn.close();
         }
      }
      catch (Exception x)
      {
         throw new JspException("Delete task failed",x);
      }
   }
   public void setTask(String task)
   {
      this.task = task;
   }
}
