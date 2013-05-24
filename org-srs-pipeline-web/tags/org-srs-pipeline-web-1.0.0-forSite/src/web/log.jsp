<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="logFilesUtils" uri="http://srs.slac.stanford.edu/fileUtils" %>

<%@taglib prefix="login" uri="http://srs.slac.stanford.edu/login" %>

<html>
    <head>
        <title>Pipeline status</title>
    </head>
    <body>

        <login:requireLogin/>

        <h2>Task ${taskName} Process ${processName} Stream ${streamIdPath}</h2>

        <sql:query var="name">
            select LOGFILE, JOBSITE, WORKINGDIR||'/logFile.txt' WORKINGDIR from PROCESSINSTANCE where PROCESSINSTANCE=?
            <sql:param value="${processInstance}"/>
        </sql:query>
        <c:set var="row" value="${name.rows[0]}"/>
        <c:set var="logName" value="${row['LOGFILE']}"/>
        <c:if test="${row['JOBSITE']=='LYON' || row['JOBSITE']=='LYONGRID'}">
            <c:set var="logName" value="${fn:replace(row['WORKINGDIR'],'/sps/glast/Pipeline2/MC-tasks','/nfs/farm/g/glast/u44/IN2P3/MC-tasks')}"/>
            <c:set var="logName" value="${fn:replace(row['WORKINGDIR'],'/sps/hep/glast/Pipeline2/MC-tasks','/nfs/farm/g/glast/u44/IN2P3/MC-tasks')}"/>
        </c:if>
       
        <c:set var="mountPoint" value="${ logFilesUtils:getMatchMountPoint(initParam.pipelineLogFileServletDb, initParam.pipelineLogFileServletDecoratorGroup, logName, appVariables.experiment) }"/>

        <c:choose>
            <c:when test="${mountPoint.mountPoint == '/'}">
                <c:set var="logURL" value="${pageContext.request.requestURL}${logName}"/>                                
            </c:when>
            <c:otherwise>
                <c:set var="logURL" value="${fn:replace(logName,mountPoint.mountPoint, pageContext.request.requestURL)}"/>                
            </c:otherwise>
        </c:choose>
        
        
        <c:set var="logFilesServlet" value="PipelineLogFiles/${mountPoint.decorator}/" />
        <c:set var="logURL" value="${fn:replace(logURL,'log.jsp', logFilesServlet)}"/>

        <c:set var="contextPathInfo" value="/${fn:substring(logURL,fn:indexOf(logURL,logFilesServlet),-1)}"/>

        <c:set var="path" value="${fn:replace(param.path,'..','')}"/>
        <c:set var="path" value="${fn:replace(path,'//','/')}"/>


        <c:set var="logURL" value="${contextPathInfo}?href=log.jsp&queryString=pi=${processInstance}&path=${path}&contextPathInfo=${contextPathInfo}"/>

        <c:choose>
            <c:when test="${! empty param.download}">
                <c:redirect url="${logURL}&download=true"/>
            </c:when>
            <c:otherwise>
                <c:import url="${logURL}"/>
            </c:otherwise>
        </c:choose>

    </body>
</html>
