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

        <c:set var="logName" value="/nfs/farm/g/glast/${mode=='Test' ? 'u12/pipelinetest' : 'u25/pipeline'}/cb_log/${param.run}.${param.type=='err' ? 'err' : 'out'}.log"/>
        <c:set var="logURL" value="${fn:replace(logName,'/nfs/farm/g/glast/','ftp://ftp-glast.slac.stanford.edu/glast.')}"/>

        <h2>Run: ${name.rowsByIndex[0][0]}</h2>

        <b>Log file:</b> <font class="logFile">${logName}</font> (<a href="${logURL}">download</a>)
        <pre class="log">
            <c:import url="${logURL}" var="logFile"/>
            <c:out value="${logFile}" escapeXml="true"/>
        </pre>

    </body>
</html>
