<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 

<html>
    <head>
        <title>Pipeline Message Viewer Detail</title>
    </head>
    <body>
        
        <sql:query var="code">
            select log, log_level, message, timeentered, processInstance, process, processname, taskPath, taskNamePath,exception,
            PII.GetStreamIdPath(stream) streamIdPath
            from log l
            left outer join processinstance i using (processinstance)
            left outer join process p using (process)
            left outer join taskpath t using (task)
            where log=? 
            <sql:param value="${param.log}"/>
        </sql:query>
        
        <h2>Message detail</h2> 
        <display:table class="datatable" name="${code.rows}" decorator="org.glast.pipeline.web.decorators.LogTableDecorator">
            <display:column property="timeentered" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" title="Time"/>
            <display:column property="log_level" decorator="org.glast.pipeline.web.decorators.LogLevelColumnDecorator" title="Level" />
            <display:column property="taskLinkPath" title="Task" />
            <display:column property="processname" title="Process" sortable="true" href="process.jsp" paramId="process" paramProperty="process"/>
            <display:column property="streamIdPath" title="Stream" href="pi.jsp" paramId="pi" paramProperty="processinstance" />
            <display:column property="message" title="Message" class="leftAligned" />
        </display:table>
               
        <pre class="log"><c:out value="${code.rows[0]['exception'].characterStream}" escapeXml="true"/></pre>
        
    </body>
</html>
