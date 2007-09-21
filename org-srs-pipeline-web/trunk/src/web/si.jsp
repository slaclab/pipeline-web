<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/GroupManager" prefix="gm" %>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 

<html>
<head>
    <title>Pipeline status</title>
</head>
<body>

<h2>Task ${taskName} Stream ${streamIdPath}</h2>

<c:set var="showLatest" value="${!empty param.showLatestChanged ? !empty param.showLatest : empty showLatest ? true : showLatest}" scope="session"/>

<sql:query var="rs1">
    select stream.*,PII.GetStreamIsLatestPath(stream) isLatestPath from stream 
    where stream=?
    <sql:param value="${param.stream}"/>
</sql:query>
<c:set var="data" value="${rs1.rows[0]}"/>

<table>        
<tr><td>Stream</td><td>${pl:linkToStreams(streamIdPath,streamPath,".","si.jsp?stream=")}</td></tr>   
<tr><td>Execution</td></td><td>${data.executionNumber}</td></tr>
<tr><td>Is Latest</td><td>${data.isLatestPath}</td></tr>
<tr><td>Status</td><td>${pl:prettyStatus(data.streamStatus)}</td></tr>
<tr><td>Submitted</td><td>${pl:formatTimestamp(data.createDate)}</td></tr>          
<tr><td>Started</td><td>${pl:formatTimestamp(data.startDate)}</td></tr>                   
<tr><td>Ended</td><td>${pl:formatTimestamp(data.endDate)}</td></tr>                                                
</table>

<h3>Variables</h3>

<sql:query var="rs">
    select varname, Initcap(vartype) vartype, value from streamvar
    where stream=?
    <sql:param value="${param.stream}"/>
</sql:query>      

<display:table class="datatable" name="${rs.rows}" defaultsort="1" defaultorder="ascending">
    <display:column property="varname" title="Name" sortable="true" headerClass="sortable" />
    <display:column property="vartype" title="Type" sortable="true" headerClass="sortable"/>
    <display:column property="value" title="Value" sortable="true" headerClass="sortable"/>
</display:table>   

<h3>Stream Processes</h3>
<pt:autoCheckBox name="showLatest" value="${showLatest}">Show only latest execution</pt:autoCheckBox><br>

<sql:query var="testprocess">
    select processinstance, process, stream, processName, Initcap(processingStatus) status, Initcap(ProcessType) ProcessType, CreateDate, SubmitDate, StartDate,
    EndDate, jobid, cpuSecondsUsed, executionHost, executionNumber, isLatest from processinstance
    join process using (process)
    where stream = ?		
    <c:if test="${showLatest}"> 
        and isLatest=1
    </c:if >
    order by displayorder
    <sql:param value="${param.stream}"/>    
</sql:query>   

<display:table class="datatable" name="${testprocess.rows}" id="row" sort="list" pagesize="${test.rowCount>50 && empty param.showAll ? 20 : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator">
    <display:column property="ProcessName" title="Process" sortable="true" headerClass="sortable" href="pi.jsp" paramId="pi" paramProperty="ProcessInstance"/>
    <display:column property="Status" title="Status" sortable="true" headerClass="sortable"/>
    <c:if test="${!showLatest}">
        <display:column title="#">
            ${row.executionNumber}${row.isLatest>0 ? "(*)" : ""}
        </display:column>
    </c:if>
    <display:column property="ProcessType" title="Type" sortable="true" headerClass="sortable" href="script.jsp" paramId="process" paramProperty="Process"/>
    <display:column property="CreateDate" title="Created" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
    <display:column property="SubmitDate" title="Submitted" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
    <display:column property="StartDate" title="Started" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
    <display:column property="EndDate" title="Ended" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
    <display:column property="job" title="Job Id" sortable="true" headerClass="sortable"/>
    <display:column property="cpuSecondsUsed" title="CPU" sortable="true" headerClass="sortable"/>
    <display:column property="executionHost" title="Host" sortable="true" headerClass="sortable"/>
    <display:column property="links" title="Links" class="leftAligned"/>
</display:table>   

<h3>Substreams</h3>

<sql:query var="test">SELECT taskname, stream, streamid, Initcap(streamstatus) streamStatus, createDate, StartDate, EndDate FROM stream 
    join task using (task)
    where  parentstream = ? 
    order by task, streamid
    <sql:param value="${param.stream}"/>    
</sql:query>


<display:table class="datatable" name="${test.rows}" sort="list" defaultsort="1" defaultorder="ascending" pagesize="${test.rowCount>50 && empty param.showAll ? 20 : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >
    <display:column property="Taskname" title="taskname" sortable="true" group = "1" headerClass="sortable" />              			    
    <display:column property="StreamId" title="Stream" sortable="true" headerClass="sortable" href="si.jsp" paramId="stream" paramProperty="stream"/>                  
    <display:column property="StreamStatus" title="Status" sortable="true" headerClass="sortable"/>
    <display:column property="CreateDate" title="Created" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator"/>
    <display:column property="StartDate" title="Started" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator"/>
    <display:column property="EndDate" title="Ended" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator"/>
</display:table>

<h3>All Substreams</h3>
<!--
Show all substreams summaries for the task in table form
-->
<sql:query var="proc_stats">
    select PROCESSINGSTATUS from PROCESSINGSTATUS order by DISPLAYORDER
</sql:query>

<sql:query var="streamset">
    select
    <c:forEach var="row" items="${process_stats.rows}">
        SUM(case when STREAMSTATUS='${row.STREAMSTATUS}' then 1 else 0 end) "${row.STREAMSTATUS}",
    </c:forEach>
    taskname,task,processname,process
    from stream
    join task using (task)
    join process using (task)
    where stream in  (
    SELECT stream
    FROM stream 
    start with stream  = ?
    connect by prior stream = parentstream)
    GROUP BY taskname, TASK, processname,process
    order by task
    
    <sql:param value="${param.stream}"/>    
</sql:query>

<sql:query var="streamset">select 
    <c:forEach var="row" items="${proc_stats.rows}">
        SUM(case when PROCESSINGSTATUS='${row.PROCESSINGSTATUS}' then 1 else 0 end) "${row.PROCESSINGSTATUS}",
    </c:forEach>
    lev, lpad(' ',1+24*(lev -1),'&nbsp;')||taskname  taskname, task, Initcap(ProcessType) type, processname, process,displayorder
    from PROCESS 
    join (               
    SELECT task,taskname,level lev FROM TASK
    start with Task=? connect by prior Task = ParentTask
    )  using (task)
    join PROCESSINSTANCE using (PROCESS) 
    where isLatest=1 and PII.GetStreamIsLatestPath(stream)=1 
    and stream in (
    SELECT stream
    FROM stream 
    start with stream  = ?
    connect by prior stream = parentstream)
    group by lev,task, taskname,process,PROCESSNAME,displayorder, processtype
    order by task, process
    <sql:param value="${task}"/>    
    <sql:param value="${param.stream}"/>    
</sql:query>    

<display:table class="datatable" name="${streamset.rows}" sort="list" defaultsort="1" defaultorder="descending" pagesize="${test.rowCount>50 && empty param.showAll ? 20 : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >    
    <display:column property="Taskname" title="Task" class="leftAligned" sortable="true" group = "1" headerClass="sortable"  href="task.jsp" paramId="task" paramProperty="Task" />              			       
    <display:column property="Processname" title="Process" sortable="true" group = "1" headerClass="sortable" href="process.jsp?status=0" paramId="process" paramProperty="Process" />              	    
    <c:forEach var="row" items="${proc_stats.rows}">
        <display:column property="${row.PROCESSINGSTATUS}" title="<img src=\"img/${row.PROCESSINGSTATUS}.gif\" alt=\"${pl:prettyStatus(row.PROCESSINGSTATUS)}\" title=\"${pl:prettyStatus(row.PROCESSINGSTATUS)}\">" sortable="true" headerClass="sortable" href="process.jsp?status=${row.PROCESSINGSTATUS}" paramId="process" paramProperty="Process"/>
    </c:forEach>   
</display:table>

</body>
</html>
