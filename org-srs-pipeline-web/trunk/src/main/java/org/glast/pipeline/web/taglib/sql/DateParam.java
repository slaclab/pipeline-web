package org.glast.pipeline.web.taglib.sql;

import java.io.IOException;
import java.io.StringWriter;
import java.util.Date;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspTagException;
import javax.servlet.jsp.jstl.sql.SQLExecutionTag;
import javax.servlet.jsp.tagext.JspFragment;
import javax.servlet.jsp.tagext.SimpleTagSupport;

/**
 * Result tag for use with Call tag
 * @author tonyj
 */
public class DateParam extends SimpleTagSupport
{
   private Date value;
   private String type;
   
   public void doTag() throws JspException, IOException
   {    
      SQLExecutionTag parent = (SQLExecutionTag) findAncestorWithClass(this, SQLExecutionTag.class);
      if (parent == null)
      {
         throw new JspTagException("Invalid use of DateParam tag");
      }
       
      parent.addSQLParameter(new java.sql.Date(value.getTime()));
   }

   public void setValue(Date value)
   {
      this.value = value;
   }
   public void setType(String type)
   {
      this.type = type;
   }
}