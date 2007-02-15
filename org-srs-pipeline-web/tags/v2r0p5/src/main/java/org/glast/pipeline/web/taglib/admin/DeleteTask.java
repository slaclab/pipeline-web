package org.glast.pipeline.web.taglib.admin;

import java.sql.Connection;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.SimpleTagSupport;
import org.glast.pipeline.client.PipelineClient;
import org.glast.pipeline.web.util.*;
import org.glast.pipeline.web.util.ConnectionManager;
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
         throw new JspException("Create stream failed",x);
      }
   }
   public void setTask(String task)
   {
      this.task = task;
   }
}
