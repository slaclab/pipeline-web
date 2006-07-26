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

      <sql:query var="name">
         select LOGFILE from PROCESSINSTANCE where PROCESSINSTANCE=?
         <sql:param value="${processInstance}"/>           
      </sql:query>
      <c:set var="logName" value="${name.rows[0]['LOGFILE']}"/>
      <c:set var="logURL" value="${fn:replace(logName,'/nfs/farm/g/glast/','ftp://ftp-glast.slac.stanford.edu/glast.')}"/>

      <h2>Task ${taskName} Process ${processName} Stream ${streamPath}</h2>

      <b>Log file:</b> <font class="logFile">${logName}</font> (<a href="${logURL}">download</a>)
      <c:import url="${logURL}" var="logFile"/>
      <pre class="log"><c:out value="${logFile}" escapeXml="true"/></pre>
   </body>
</html>
