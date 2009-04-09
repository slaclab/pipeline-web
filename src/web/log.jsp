<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 
<%@taglib prefix="utils" uri="http://glast-ground.slac.stanford.edu/utils" %>
<%@taglib prefix="gm" uri="http://glast-ground.slac.stanford.edu/GroupManager" %>

<html>
    <head>
        <title>Pipeline status</title>
    </head>
    <body>
        
        <utils:requireLogin/>
        
        <c:choose>
            <c:when test="${gm:isUserInGroup(userName,'GlastUser')}">
                <h2>Task ${taskName} Process ${processName} Stream ${streamIdPath}</h2>
                
                <sql:query var="name">
                    select LOGFILE, JOBSITE, WORKINGDIR||'/logFile.txt' WORKINGDIR from PROCESSINSTANCE where PROCESSINSTANCE=?
                    <sql:param value="${processInstance}"/>
                </sql:query>
                <c:set var="logName" value="${name.rows[0]['LOGFILE']}"/>
                <c:if test="${name.rows[0]['JOBSITE']=='LYON'}">
                    <c:set var="logName" value="${fn:replace(name.rows[0]['WORKINGDIR'],'/sps/glast/Pipeline2/MC-tasks','/nfs/farm/g/glast/u44/IN2P3/MC-tasks')}"/>
                </c:if>
                
                <c:set var="logURL" value="${fn:replace(logName,'/nfs/farm/g/glast/', pageContext.request.requestURL)}"/>
                <c:set var="logURL" value="${fn:replace(logURL,'log.jsp', 'PipelineLogFiles/')}"/>
                
                
                <c:catch var="error">
                    <c:import url="${logURL}" var="logFile"/>
                    <b>Log file:</b> <font class="logFile">${logName}</font> (<a href="${logURL}?download=true">download</a>)
                    <pre class="log"><c:out value="${logFile}" escapeXml="true"/></pre>
                </c:catch>
                <c:if test="${!empty error}">
                    <p>Log file not found.</p>
                    <pre>
             ${error}
                    </pre>
                </c:if>
            </c:when>
            <c:otherwise>
                <h3>You have to be a GLAST user in order to view this page</h3>
            </c:otherwise>
        </c:choose>
        
    </body>
</html>
