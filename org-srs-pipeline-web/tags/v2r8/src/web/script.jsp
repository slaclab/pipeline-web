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
         select processcode from scriptprocess where process=?     
         <sql:param value="${param.process}"/>           
      </sql:query>

      <h2>Script ${processName}</h2>
       
      <pre class="log"><c:out value="${code.rows[0]['processcode'].characterStream}" escapeXml="true"/></pre>

   </body>
</html>
