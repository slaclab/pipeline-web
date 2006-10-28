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
         select WORKINGDIR from PROCESSINSTANCE where PROCESSINSTANCE=?
         <sql:param value="${processInstance}"/>           
      </sql:query>
      <c:set var="logURL" value="${fn:replace(name.rows[0]['WORKINGDIR'],'/nfs/farm/g/glast/','ftp://ftp-glast.slac.stanford.edu/glast.')}"/>
      <c:if test="${!empty logURL}">
         <c:redirect url="${logURL}"/>
      </c:if>

      <p>Working directory not found.</p>
      
   </body>
</html>
