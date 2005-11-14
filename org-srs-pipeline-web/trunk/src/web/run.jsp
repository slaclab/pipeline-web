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
    <%--
        <sql:query var="name">
            select TASKNAME from TASK where TASK_PK=?
            <sql:param value="${param.task}"/>           
        </sql:query>
         <sql:query var="name2">
            select TASKPROCESSNAME from TASKPROCESS where TASKPROCESS_PK=?
            <sql:param value="${param.process}"/>           
        </sql:query>  
       
        <div id="breadCrumb"> 
            <a href="index.jsp">status</a> /
            <a href="task.jsp?task=${param.task}">${name.rowsByIndex[0][0]}</a> /
            <a href="process.jsp?task=${param.task}&process=${param.process}&status=${param.status}">${name2.rowsByIndex[0][0]}</a> /
        </div> 
    --%>
         <sql:query var="name">
            select RUNNAME,BATCHLOGFILEPATH from TPINSTANCE,RUN where TPINSTANCE_PK=? and RUN_PK=RUN_FK
            <sql:param value="${param.run}"/>           
        </sql:query>
        <c:set var="logURL" value="${fn:replace(name.rowsByIndex[0][1],'/nfs/farm/g/glast/','ftp://ftp-glast.slac.stanford.edu/glast.')}"/>
        <c:redirect url="${logURL}"/>
    <%--
        <h2>Run: ${name.rowsByIndex[0][0]}</h2>
       

        <b>Log file:</b> <font class="logFile">${name.rowsByIndex[0][1]}</font> (<a href="${logURL}">download</a>)
        <pre class="log">
            <c:import url="${logURL}"/>
        </pre>
    --%>
    </body>
</html>
