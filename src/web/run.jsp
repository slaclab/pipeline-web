<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="pipeline" uri="http://glast-ground.slac.stanford.edu/pipeline" %>
<%@taglib prefix="srs_utils" uri="http://srs.slac.stanford.edu/utils" %>
<%@taglib prefix="logFilesUtils" uri="http://srs.slac.stanford.edu/fileUtils" %>

<html>
    <head>
        <title>Files: Task ${taskName} Process ${processName} Stream ${streamIdPath}</title>
    </head>
    <body>


        <h2>Task ${taskName} Process ${processName} Stream ${streamIdPath}</h2>

        <sql:query var="name">
            select WORKINGDIR,JOBSITE from PROCESSINSTANCE where PROCESSINSTANCE=?
            <sql:param value="${processInstance}"/>
        </sql:query>
        <c:set var="workingDir" value="${name.rows[0]['WORKINGDIR']}"/>
        <c:if test="${name.rows[0]['JOBSITE']=='LYON'}">
            <c:set var="workingDir" value="${fn:replace(workingDir,'/sps/glast/Pipeline2/MC-tasks','/nfs/farm/g/glast/u44/IN2P3/MC-tasks')}"/>
        </c:if>

        <c:if test="${pipeline:isFile(workingDir)}">
            <c:set var="workingDir" value="${workingDir}/"/>
        </c:if>
        <c:set var="workingDir" value="${workingDir}${param.path}"/>


        <c:set var="mountPoint" value="${ logFilesUtils:getMatchMountPoint(initParam.pipelineLogFileServletDb, initParam.pipelineLogFileServletDecoratorGroup, workingDir, appVariables.experiment) }"/>


        <c:set var="logURL" value="${fn:replace(workingDir,mountPoint.mountPoint, pageContext.request.requestURL)}"/>
        <c:set var="logFilesServlet" value="PipelineLogFiles/${mountPoint.decorator}/" />
        <c:set var="logURL" value="${fn:replace(logURL,'run.jsp', logFilesServlet)}"/>


        <c:catch var="error">
            <c:redirect url="${logURL}" />
        </c:catch>
        <c:if test="${!empty error}">
            <p>Working directory not found.</p>
            <pre>
             ${error}
            </pre>
        </c:if>


    </body>
</html>
