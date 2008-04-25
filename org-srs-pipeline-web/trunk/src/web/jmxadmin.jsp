<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://www.servletsuite.com/servlets/jmxtag" prefix="jmx"%> 
<%@taglib tagdir="/WEB-INF/tags" prefix="bean"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/GroupManager" prefix="gm" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>
<%@taglib prefix="p" uri="http://glast-ground.slac.stanford.edu/pipeline"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<html>
   <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
      <title>Pipeline JMX Admin</title>
   </head>
   <body>
      
      <h1>Pipeline JMX Admin</h1>
      <c:set var="admin" value="${gm:isUserInGroup(userName,'PipelineAdmin')}"/>
      <sql:query var="result">
         select HOST,PORT from ServerStatus
      </sql:query>
      <p:JMXConnect var="server" serverURL="service:jmx:rmi:///jndi/rmi://${result.rows[0].host}:${result.rows[0].port}/jmxrmi">
         
         <h2>Control</h2>
         <bean:mbeanAttributesTable connection="${server}" mbean="org.glast.pipeline.server:type=Main" updateable="${admin}"/>  
         
         <table>
            <tr>
               <jmx:forEachMBean connection="${server}" id="bean" pattern="org.glast.pipeline.server:type=Scheduler,name=*">
                  <td>
                     <h3>${fn:substringAfter(bean,"name=")}</h3>
                     <bean:mbeanAttributesTable connection="${server}" mbean="${bean}" updateable="${admin}"/>    
                  </td>
               </jmx:forEachMBean>  
            </tr>
         </table>
         
         <h2>Batch Submission Engines</h2>
         <jmx:forEachMBean connection="${server}" id="bean" pattern="org.glast.pipeline.server.batch:type=BatchManager,name=*">
            
            <h3><jmx:getAttribute connection="${server}" mbean="${bean}" attribute="Site"/></h3>
            <bean:mbeanAttributesTable connection="${server}" mbean="${bean}" updateable="${admin}"/>   
            <bean:mbeanOperationsTable connection="${server}" mbean="${bean}"/>         
            
         </jmx:forEachMBean>   
         
         
         <h2>Logger</h2>
         <bean:mbeanAttributesTable connection="${server}" mbean="org.glast.pipeline.server.logger:type=JDBCHandler"/>              

         <h2>Mail Processing</h2>
         <c:catch var="x">
            <bean:mbeanAttributesTable connection="${server}" mbean="org.glast.pipeline.server:type=MailReceiver"/>              
         </c:catch>
      
      </p:JMXConnect>
      
   </body>
</html>
