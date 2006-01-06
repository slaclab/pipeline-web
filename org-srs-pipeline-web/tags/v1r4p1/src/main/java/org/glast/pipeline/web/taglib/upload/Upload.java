package org.glast.pipeline.web.taglib.upload;

import org.glast.pipeline.upload.Importer;
import org.glast.pipeline.web.util.ConnectionManager;
import java.io.Reader;
import java.io.StringReader;
import java.sql.Connection;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.SimpleTagSupport;
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
         Connection connection = ConnectionManager.getConnection((PageContext) getJspContext(),null);
         connection.setAutoCommit(false);
         try
         {
            Importer importer = new Importer();
            Reader in = new StringReader(xml);
            importer.execute(connection,user,in);
            connection.commit();
         }
         catch (Exception x)
         {
            connection.rollback();
            throw x;
         }
         finally
         {
            connection.setAutoCommit(true);
            connection.close();
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