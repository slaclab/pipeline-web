package org.glast.pipeline.web.taglib.jmx;

import java.io.IOException;
import javax.management.MBeanServerConnection;
import javax.management.remote.JMXConnector;
import javax.management.remote.JMXConnectorFactory;
import javax.management.remote.JMXServiceURL;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.SimpleTagSupport;

/**
 * @author tonyj
 * @version $Id: JMXConnect.java,v 1.1 2008-04-24 00:34:22 tonyj Exp $
 */

public class JMXConnect extends SimpleTagSupport
{

   /**
    * Initialization of serverURL property.
    */
   private String serverURL;

   /**
    * Initialization of var property.
    */
   private String var;
   
   /**Called by the container to invoke this tag.
    */
   public void doTag() throws JspException
   {      
      try
      {
         JMXServiceURL serviceURL = new JMXServiceURL(serverURL);
         JMXConnector c = JMXConnectorFactory.connect(serviceURL);
         MBeanServerConnection server = c.getMBeanServerConnection();
         getJspContext().setAttribute(var,server); 
         getJspBody().invoke(getJspContext().getOut());
         c.close();
      }
      catch (IOException x)
      {
         throw new JspException("Error connecting to JMX server",x);
      }      
   }

   /**
    * Setter for the serverURL attribute.
    */
   public void setServerURL(java.lang.String value)
   {
      this.serverURL = value;
   }

   /**
    * Setter for the var attribute.
    */
   public void setVar(java.lang.String value)
   {
      this.var = value;
   }
}
