<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="logFilesUtils" uri="http://srs.slac.stanford.edu/fileUtils" %>

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


        <%-- This will have to be changed in the future. It is here for backward compatibility with Fermi's pipeline --%>
        <c:if test="${name.rows[0]['JOBSITE']=='LYON'}">
            <c:set var="logName" value="${fn:replace(name.rows[0]['WORKINGDIR'],'/sps/glast/Pipeline2/MC-tasks','/nfs/farm/g/glast/u44/IN2P3/MC-tasks')}"/>
        </c:if>

        <c:set var="decorator" value="${appVariables.experiment}LogFiles"/>
        <c:set var="mountPoint" value="${ logFilesUtils:getDecoratorMountPoint(initParam.pipelineLofFileServletDb, decorator, appVariables.experiment) }"/>


        <c:set var="logURL" value="${fn:replace(logName,mountPoint, pageContext.request.requestURL)}"/>

        <c:set var="logFilesServlet" value="PipelineLogFiles/${decorator}/" />
        <c:set var="logURL" value="${fn:replace(logURL,'log.jsp', logFilesServlet)}"/>

        <c:catch var="error">
            <c:import url="${logURL}?skipHtml=true&experiment=${appVariables.experiment}" var="logFile" />
            <b>Log file:</b> <font class="logFile">${logName}</font> (<a href="${logURL}?download=true">download</a>)
            <pre class="log"><c:out value="${logFile}" escapeXml="true"/></pre>
        </c:catch>
        <c:if test="${!empty error}">
            <p>Log file not found.</p>
            <pre>
             ${error}
            </pre>
        </c:if>

            
    </body>
</html>
