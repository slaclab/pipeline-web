<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html>
    <head>
        <title>Pipeline status</title>
        <script language="JavaScript" src="scripts/FSdateSelect-UTF8.js"></script>
        <link rel="stylesheet" href="css/FSdateSelect.css" type="text/css">        
    </head>
    <body>        
        <h2>Running jobs for: ${taskName}</h2>
        
        <c:set var="runNumber" value="to_number(RUNNAME)"/>
        <c:if test="${fn:contains(taskName,'b33')}">
            <c:set var="runNumber" value="RUNNAME"/>
        </c:if>

        <sql:query var="test">select TPINSTANCE_PK "Id", ${runNumber} "Run", i.PID, t.TASKPROCESSNAME "Process",t.TASKPROCESS_PK "ProcessID", t.TASKPROCESSNAME "Process"from TPINSTANCE i, RUN r, PROCESSINGSTATUS s, TASKPROCESS t where t.TASK_FK=? and s.PROCESSINGSTATUSNAME='RUNNING' and i.RUN_FK=r.RUN_PK and i.PROCESSINGSTATUS_FK=s.PROCESSINGSTATUS_PK and t.TASKPROCESS_PK=i.TASKPROCESS_FK 
            <sql:param value="${param.task}"/>
        </sql:query>  
        
        <display:table class="dataTable" name="${test.rows}" sort="list" defaultsort="1" defaultorder="ascending" pagesize="${test.rowCount>50 && empty param.showAll ? 20 : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >
            <display:column property="Run" sortable="true" headerClass="sortable" />
            <display:column property="Process" sortable="true" headerClass="sortable" />
            <display:column property="job" title="Job Id" sortable="true" headerClass="sortable"/> 
            <display:column property="started" title="Started" sortable="true" headerClass="sortable"/>  
            <display:column property="host" title="Host" sortable="true" headerClass="sortable"/>  
            <display:column property="cpuUsed" title="CPU (secs)" sortable="true" headerClass="sortable"/> 
            <display:column property="memoryUsed" title="Memory (MB)" sortable="true" headerClass="sortable"/>          
            <display:column property="swapUsed" title="Swap (MB)" sortable="true" headerClass="sortable"/>               
            <display:column property="links" title="Links (<a href=help.html>?</a>)" />
        </display:table>

    </body>
</html>
