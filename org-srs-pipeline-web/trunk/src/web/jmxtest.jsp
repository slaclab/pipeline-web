<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://www.servletsuite.com/servlets/jmxtag" prefix="jmx"%> 
<%@page import="javax.management.remote.*"%>
<%@page import="javax.management.*"%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Pipeline JMX Page</title>
    </head>
    <body>

    <h1>JSP Page</h1>
    
<%
JMXServiceURL serviceURL = new JMXServiceURL("service:jmx:rmi:///jndi/rmi://glastlnx12:8098/jmxrmi");
JMXConnector c = JMXConnectorFactory.connect(serviceURL);
MBeanServerConnection server = c.getMBeanServerConnection();
pageContext.setAttribute("server",server);
%>

    <jmx:forEachMBean connection="${server}" id="site" pattern="org.glast.pipeline.*:*">
   Mbean: ${site} <br>
   <jmx:forEachAttribute connection="${server}" mbean="${site}" >
      ${attributeName}=${attributeValue} (${attributeWritable})<br>
   </jmx:forEachAttribute>
</jmx:forEachMBean> 
<%
c.close();
%>
    
    </body>
</html>
