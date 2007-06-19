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

      <sql:query var="code">
         select exception from log where log=?
         <sql:param value="${param.log}"/>
      </sql:query>

      <h2>Log detail</h2>
      
      <pre class="log"><c:out value="${code.rows[0]['exception'].characterStream}" escapeXml="true"/></pre>

   </body>
</html>
