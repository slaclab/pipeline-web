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
<%@taglib prefix="utils" uri="http://glast-ground.slac.stanford.edu/utils" %>

<html>
<head>
    <title>Task ${taskName} Stream ${streamIdPath}</title>
    
</head>
<body>

<h2>Task ${taskName} Stream ${streamIdPath}</h2>
<c:set var="showLatest" value="${!empty param.showLatestChanged ? !empty param.showLatest : empty showLatest ? true : showLatest}" scope="session"/>
<c:set var="adminMode" value="${gm:isUserInGroup(userName,'PipelineAdmin')}"/>

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
    EndDate, jobid, jobsite, cpuSecondsUsed, executionHost, executionNumber, isLatest from processinstance
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
    <c:if test="${showLatest}"> 
        and isLatest=1
    </c:if >
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
 <script language="JavaScript" type="text/javascript">
         function ShowAll(set) {
           for (var i = 0; i < document.selectForm.elements.length; i++) {
             if(document.selectForm.elements[i].type == 'checkbox'){
               document.selectForm.elements[i].checked = set;
             }
           }
         }
         function ToggleAll() {
           for (var i = 0; i < document.selectForm.elements.length; i++) {
             if(document.selectForm.elements[i].type == 'checkbox'){
               document.selectForm.elements[i].checked = !(document.selectForm.elements[i].checked);
             }
           }
         }
        </script>   

<!--
Show all substreams summaries for the task in table form
-->
<sql:query var="proc_stats">
    select PROCESSINGSTATUS from PROCESSINGSTATUS order by DISPLAYORDER
</sql:query>

<sql:query var="streamset">select SUM(1) "ALL",
    <c:forEach var="row" items="${proc_stats.rows}">
        SUM(case when PROCESSINGSTATUS='${row.PROCESSINGSTATUS}' then 1 else 0 end) "${row.PROCESSINGSTATUS}",
    </c:forEach>
    lev, lpad(' ',1+24*(lev -1),'&nbsp;')||taskname  taskname, task,
    Initcap(ProcessType) type, processname, process,displayorder,max(stream) ProcessStream
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

<c:set var="waitingSum" value = "0"/>
<c:set var="readySum" value = "0"/>
<c:set var="queuedSum" value = "0"/>
<c:set var="submittedSum" value = "0"/>
<c:set var="runningSum" value = "0"/>
<c:set var="successSum" value = "0"/>
<c:set var="failedSum" value = "0"/>
<c:set var="cancelledSum" value = "0"/>
<c:set var="terminatedSum" value = "0"/>
<c:set var="skippedSum" value = "0"/>

<c:forEach var="row" items="${streamset.rows}">
    <c:set var="waitingSum" value = "${row.waiting + waitingSum}"/>
    <c:set var="readySum" value = "${row.ready + readySum}"/>
    <c:set var="queuedSum" value = "${row.queued + queuedSum}"/>
    <c:set var="submittedSum" value = "${row.submitted + submittedSum}"/>
    <c:set var="runningSum" value ="${row.running + runningSum}"/>
    <c:set var="successSum" value ="${row.success + successSum}"/>
    <c:set var="failedSum" value ="${row.failed + failedSum}"/>
    <c:set var="cancelledSum" value = "${row.cancelled + cancelledSum}"/>
    <c:set var="terminatedSum" value = "${row.terminated + terminatedSum}"/>
    <c:set var="skippedSum" value = "${row.skipped + skippedSum}"/> 
</c:forEach>  
<form name="selectForm" action="confirm.jsp" method="post">
<display:table class="datatable" name="${streamset.rows}" id="tableRow" sort="list" defaultsort="1"  defaultorder="descending" pagesize="${test.rowCount>50 && empty param.showAll ? 20 : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >    
<display:column property="Taskname" title="Task" class="leftAligned" sortable="true" group = "1" headerClass="sortable"  href="task.jsp" paramId="task" paramProperty="Task" />              			       
<display:column property="Processname" title="Process" sortable="true" group = "1" headerClass="sortable" href="process.jsp?status=0" paramId="process" paramProperty="Process" />              	    
<c:forEach var="row" items="${proc_stats.rows}">
    <display:column sortProperty="${row.PROCESSINGSTATUS}" title="<img src=\"img/${row.PROCESSINGSTATUS}.gif\" alt=\"${pl:prettyStatus(row.PROCESSINGSTATUS)}\" title=\"${pl:prettyStatus(row.PROCESSINGSTATUS)}\">" sortable="true"  headerClass="sortable"  >
        <a href="process.jsp?status=${row.PROCESSINGSTATUS}&pstream=${param.stream}&process=${tableRow.Process}">${tableRow[row.PROCESSINGSTATUS]}</a>      
    </display:column>
</c:forEach>   
<display:column property="all" title="Total" />
<c:if test="${adminMode}">
    
      <display:column property="streamSelector" title=" " class="admin"/>
</c:if>    

<display:footer>
    </td><td></td><td><strong>Totals</strong></td>   
    <td>${waitingSum} </td><td>${readySum}</td> <td>${queuedSum}</td><td> ${submittedSum}</td>
    <td> ${runningSum}</td><td>${successSum}</td><td>${failedSum}</td><td>${terminatedSum}</td>
    <td>${cancelledSum}</td>  <td>${skippedSum}</td> <tr>       
    <c:if test="${adminMode}">        
        <tr>
            <td colspan="20" class="admin">                
                <a href="javascript:void(0)" onClick="ShowAll(true);">Select all</a>&nbsp;.&nbsp;
                <a href="javascript:void(0)" onClick="ShowAll(false);">Deselect all</a>&nbsp;.&nbsp;
                <a href="javascript:void(0)" onClick="ToggleAll();">Toggle selection</a>
                <input type="hidden" name="stream" value="${param.stream}">
                <input type="hidden" name="task" value="${task}">
                <input type="submit" value="Rollback Selected" name="submit">
            </td>
        </tr> 
    </c:if>
</display:footer>
</display:table>
</form>

</body>
</html>
