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
        <h2>Task: ${name.rowsByIndex[0][0]}</h2>
       
        <c:set var="xmlURL" value="${param.xml}?task=${param.task}"/>
        <b>xml file:</b> (<a href="${xmlURL}">download</a>)
        <c:import var="xml" url="${xmlURL}" />
        <pre class="log"><c:out value="${xml}" escapeXml="true" /></pre>

    </body>
</html>
