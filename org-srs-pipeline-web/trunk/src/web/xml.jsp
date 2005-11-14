<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 

<html>
    <head>
        <title>Pipeline status</title>
        <link rel="stylesheet" href="css/screen.css" type="text/css" media="screen, print" />
    </head>
    <body>
        <c:import url="header.jsp"/>
        <sql:query var="name">
            select TASKNAME from TASK where TASK_PK=?
            <sql:param value="${param.task}"/>           
        </sql:query>
       
        <div id="breadCrumb"> 
            <a href="index.jsp">status</a> /
            <a href="task.jsp?task=${param.task}">${name.rowsByIndex[0][0]}</a> /
        </div> 

        <h2>Task: ${name.rowsByIndex[0][0]}</h2>
       
        <c:set var="xmlURL" value="${param.xml}?task=${param.task}"/>
        <b>xml file:</b> (<a href="${xmlURL}">download</a>)
        <c:import var="xml" url="${xmlURL}" />
        <pre class="log"><c:out value="${xml}" escapeXml="true" /></pre>

    </body>
</html>
