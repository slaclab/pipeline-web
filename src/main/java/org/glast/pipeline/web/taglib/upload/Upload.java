package org.glast.pipeline.web.taglib.upload;

import java.sql.Connection;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.SimpleTagSupport;
import org.glast.pipeline.client.PipelineClient;
import org.glast.pipeline.web.util.ConnectionManager;
/**
 * A tag for uploading xml files to the pipeline database
 * @author tonyj
 */
public class Upload extends SimpleTagSupport
{
   private String xml;
   private String user;
   
   public void doTag() throws JspException
   {
      try
      {
         Connection conn = ConnectionManager.getConnection((PageContext) getJspContext(), null);
         try
         {
            PipelineClient client = new PipelineClient(conn);
            client.createTaskFromXML(xml,user);
         }
         finally
         {
            conn.close();
         }
      }
      catch (Exception x)
      {
         throw new JspException("File upload failed",x);
      }
   }
   public void setUser(String user)
   {
      this.user = user;
   }
   public void setXml(String xml)
   {
      this.xml = xml;
   }
}
