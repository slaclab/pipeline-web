package org.glast.pipeline.web.taglib.sql;

import java.io.IOException;
import java.io.StringWriter;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspTagException;
import javax.servlet.jsp.jstl.sql.SQLExecutionTag;
import javax.servlet.jsp.tagext.JspFragment;
import javax.servlet.jsp.tagext.SimpleTagSupport;

/**
 * Result tag for use with Call tag
 * @author tonyj
 */
public class Param extends SimpleTagSupport
{
   private Object value;
   
   public void doTag() throws JspException, IOException
   {
      StringWriter writer = new StringWriter();
      JspFragment fragment = getJspBody();
      if (fragment != null) fragment.invoke(writer);
      
      if (value == null) 
      {
         String body = writer.toString().trim();
         if (body.length() == 0) body = null;
         value = body;
      }
      
      SQLExecutionTag parent = (SQLExecutionTag) findAncestorWithClass(this, SQLExecutionTag.class);
      if (parent == null)
      {
         throw new JspTagException("Invalid use of Param tag");
      }
       
      parent.addSQLParameter(value);
   }

   public void setValue(Object value)
   {
      this.value = value;
   }
}