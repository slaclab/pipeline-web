<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
   <head>
      <title>Pipeline status</title>
   </head>
   <body>
      <h2>Task: ${taskName}</h2>

      <c:set var="xmlURL" value="DumpTaskServlet?task=${task}&fromDB=${param.fromDB}&asFile=${taskName}.xml"/>
      <b>xml file:</b> (<a href="${xmlURL}">download</a>)
      <c:import var="xml" url="${xmlURL}" />
      <pre class="log"><c:out value="${xml}" escapeXml="true" /></pre>
      
   </body>
</html>
