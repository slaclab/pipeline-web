<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 

<html>
   <head>
      <title>Task ${taskName} Process ${processName} Stream ${streamIdPath</title>
   </head>
   <body>

      <h2>Task ${taskName} Process ${processName} Stream ${streamIdPath}</h2>

      <sql:query var="name">
         select WORKINGDIR,JOBSITE from PROCESSINSTANCE where PROCESSINSTANCE=?
         <sql:param value="${processInstance}"/>           
      </sql:query>
      <c:set var="workingDir" value="${name.rows[0]['WORKINGDIR']}"/>
      <c:if test="${name.rows[0]['JOBSITE']=='LYON'}">
         <c:set var="workingDir" value="${fn:replace(workingDir,'/sps/glast/Pipeline2/MC-tasks','/nfs/farm/g/glast/u44/IN2P3/MC-tasks')}"/>
      </c:if>
      <c:set var="logURL" value="${fn:replace(workingDir,'/nfs/farm/g/glast/','ftp://ftp-glast.slac.stanford.edu/glast.')}"/>
      <c:if test="${!empty logURL}">
         <c:redirect url="${logURL}"/>
      </c:if>

      <p>Working directory not found.</p>
      
   </body>
</html>
