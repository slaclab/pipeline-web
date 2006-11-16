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
        <script language="JavaScript" src="http://glast-ground.slac.stanford.edu/Commons/scripts/FSdateSelect.jsp"></script>
        <link rel="stylesheet" href="http://glast-ground.slac.stanford.edu/Commons/css/FSdateSelect.css" type="text/css">        
    </head>
    <body>        
        <h2>Running jobs for: ${taskName}</h2>

        <sql:query var="test">
                    select streampath, streamIdPath, jobid, process, processname, processinstance from processinstance
                                 join streampath using (stream)
                                 join process using (process)
                                 where processingstatus='RUNNING' and task=? 
            <sql:param value="${param.task}"/>
        </sql:query>  
        
        <display:table class="dataTable" name="${test.rows}" sort="list" defaultsort="1" defaultorder="ascending" pagesize="${test.rowCount>50 && empty param.showAll ? 20 : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >
            <display:column property="streamIdPath" title="Stream" sortable="true" headerClass="sortable" comparator="org.glast.pipeline.web.decorators.StreamPathComparator" href="pi.jsp" paramId="pi" paramProperty="processinstance"/>
            <display:column property="processName" title="Process" sortable="true" headerClass="sortable" href="process.jsp" paramId="process" paramProperty="process"/>
            <display:column property="job" title="Job Id" sortable="true" headerClass="sortable"/> 
            <display:column property="started" title="Started" sortable="true" headerClass="sortable"/>  
            <display:column property="host" title="Host" sortable="true" headerClass="sortable"/>  
            <display:column property="cpuUsed" title="CPU (secs)" sortable="true" headerClass="sortable"/> 
            <display:column property="memoryUsed" title="Memory (MB)" sortable="true" headerClass="sortable"/>          
            <display:column property="swapUsed" title="Swap (MB)" sortable="true" headerClass="sortable"/>               
        </display:table>

    </body>
</html>
