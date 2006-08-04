package org.glast.pipeline.web.taglib.sql;

import java.io.IOException;
import java.io.StringWriter;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspTagException;
import javax.servlet.jsp.tagext.JspFragment;
import javax.servlet.jsp.tagext.SimpleTagSupport;

/**
 * Result tag for use with Call tag
 * @author tonyj
 */
public class Result extends SimpleTagSupport
{
   private String scopeName = "page";
   private String varName;
   private String typeName;
   
   public void doTag() throws JspException, IOException
   {
      Call parent = (Call) findAncestorWithClass(this, Call.class);
      if (parent == null)
      {
         throw new JspTagException("Invalid use or Result tag output Call tag");
      }
       
      parent.addResult(varName, scopeName, typeName);
   }
   public void setScope(String scopeName)
   {
      this.scopeName = scopeName;
   }
   public void setVar(String varName)
   {
      this.varName = varName;
   }
   public void setType(String typeName)
   {
      this.typeName = typeName;
   }
}