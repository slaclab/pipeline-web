<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 

<html>
   <head>
      <title>Pipeline status</title>
   </head>
   <body>

      <h2>Task ${taskName} Process ${processName} Stream ${streamIdPath}</h2>

      <sql:query var="name">
         select LOGFILE, JOBSITE, WORKINGDIR||'/logFile.txt' WORKINGDIR from PROCESSINSTANCE where PROCESSINSTANCE=?
         <sql:param value="${processInstance}"/>           
      </sql:query>
      <c:set var="logName" value="${name.rows[0]['LOGFILE']}"/>
      <c:if test="${name.rows[0]['JOBSITE']=='LYON'}">
         <c:set var="logName" value="${fn:replace(name.rows[0]['WORKINGDIR'],'/sps/glast/Pipeline2/MC-tasks','/nfs/farm/g/glast/u44/IN2P3/MC-tasks')}"/>
      </c:if>
      <c:set var="logURL" value="${fn:replace(logName,'/nfs/farm/g/glast/','ftp://ftp-glast.slac.stanford.edu/glast.')}"/>
       
      <c:catch var="error">
         <c:import url="${logURL}" var="logFile"/>
         <b>Log file:</b> <font class="logFile">${logName}</font> (<a href="${logURL}">download</a>)
         <pre class="log"><c:out value="${logFile}" escapeXml="true"/></pre>
      </c:catch>
      <c:if test="${!empty error}">
         <p>Log file not found.</p>
      </c:if>
   </body>
</html>
