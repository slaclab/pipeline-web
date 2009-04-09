<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="pipeline" uri="http://glast-ground.slac.stanford.edu/pipeline" %>
<%@taglib prefix="utils" uri="http://glast-ground.slac.stanford.edu/utils" %>
<%@taglib prefix="gm" uri="http://glast-ground.slac.stanford.edu/GroupManager" %>

<html>
    <head>
        <title>Files: Task ${taskName} Process ${processName} Stream ${streamIdPath}</title>
    </head>
    <body>

        <utils:requireLogin/>

        <c:choose>
            <c:when test="${gm:isUserInGroup(userName,'GlastUser')}">
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

                <c:set var="logURL" value="${fn:replace(workingDir,'/nfs/farm/g/glast/', pageContext.request.requestURL)}"/>
                <c:set var="logURL" value="${fn:replace(logURL,'run.jsp', 'PipelineLogFiles/')}"/>

                <c:set var="queryString" value="${pageContext.request.queryString}"/>
                <c:if test="${fn:startsWith(queryString,'&')}" >
                    <c:set var="queryString" value="${fn:substringAfter(queryString,'&')}"/>
                </c:if>

                <c:set var="logURL" value="${logURL}?href=run.jsp&queryString=${queryString}"/>


                <c:catch var="error">
                    <c:import url="${logURL}" var="logFile"/>
                    <c:choose>
                        <c:when test="${pipeline:isFile(workingDir)}">
                            <b>File:</b> <font class="logFile">${workingDir}</font> (<a href="${logURL}?download=true">download</a>)
                            <pre class="log"><c:out value="${logFile}" escapeXml="true"/></pre>
                        </c:when>
                        <c:otherwise>
                            <c:out value="${logFile}" escapeXml="false"/>
                        </c:otherwise>
                    </c:choose>
                </c:catch>

                <c:if test="${!empty error}">
                    <p>Working directory not found.</p>
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
