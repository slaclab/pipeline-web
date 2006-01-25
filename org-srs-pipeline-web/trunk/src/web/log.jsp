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
         select BATCHLOGFILEPATH,BATCHLOGFILENAME from TPINSTANCE,RUN where TPINSTANCE_PK=? and RUN_PK=RUN_FK
         <sql:param value="${param.run}"/>           
      </sql:query>
      <c:set var="logName" value="${name.rows[0]['BATCHLOGFILEPATH']}/${name.rows[0]['BATCHLOGFILENAME']}"/>
      <c:set var="logURL" value="${fn:replace(logName,'/nfs/farm/g/glast/','ftp://ftp-glast.slac.stanford.edu/glast.')}"/>

      <h2>Run: ${name.rowsByIndex[0][0]}</h2>
       

      <b>Log file:</b> <font class="logFile">${logName}</font> (<a href="${logURL}">download</a>)
      <pre class="log">
         <c:import url="${logURL}" var="logFile"/>
         <c:out value="${logFile}" escapeXml="true"/>
      </pre>

   </body>
</html>
