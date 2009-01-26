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
<script language="JavaScript" type="text/javascript">
         function subStreamShowAll(set) {
           for (var i = 0; i < document.subStreamSelectForm.elements.length; i++) {
             if(document.subStreamSelectForm.elements[i].type == 'checkbox'){
               document.subStreamSelectForm.elements[i].checked = set;
             }
           }
         }
         function subStreamToggleAll() {
           for (var i = 0; i < document.subStreamSelectForm.elements.length; i++) {
             if(document.subStreamSelectForm.elements[i].type == 'checkbox'){
               document.subStreamSelectForm.elements[i].checked = !(document.subStreamSelectForm.elements[i].checked);
             }
           }
         }
         function piShowAll(set) {
           for (var i = 0; i < document.piSelectForm.elements.length; i++) {
             if(document.piSelectForm.elements[i].type == 'checkbox'){
               document.piSelectForm.elements[i].checked = set;
             }
           }
         }
         function piToggleAll() {
           for (var i = 0; i < document.piSelectForm.elements.length; i++) {
             if(document.piSelectForm.elements[i].type == 'checkbox'){
               document.piSelectForm.elements[i].checked = !(document.piSelectForm.elements[i].checked);
             }
           }
         }
        </script>   

<c:set var="showLatest" value="${!empty param.showLatestChanged ? !empty param.showLatest : empty showLatest ? true : showLatest}" scope="session"/>
<c:set var="adminMode" value="${gm:isUserInGroup(userName,'PipelineAdmin')}"/>
    <h2>Task ${taskName} Stream ${streamIdPath}</h2>
    <c:if test="${adminMode}">        
        <form name="RollBackStreamForm" action="confirm.jsp" method="post">
            <input type="hidden" name="stream" value="${param.stream}">
            <input type="hidden" name="task" value="${task}">
            <input type="hidden" name="select" value="${param.stream}">
            <input type="submit" value="Rollback Stream" name="submit">
        </form>
    </c:if>

<sql:query var="rs1">
    select stream.*,PII.GetStreamIsLatestPath(stream) isLatestPath from stream 
    where stream=?
    <sql:param value="${param.stream}"/>
</sql:query>
<c:set var="data" value="${rs1.rows[0]}"/>

<sql:query var="executions">
   select executionnumber, stream from stream
   join task using (task)
   where task=? and streamId=? and ExecutionNumber != ?
   <sql:param value="${data.task}"/>
   <sql:param value="${data.streamId}"/>
   <sql:param value="${data.ExecutionNumber}"/>
</sql:query>


<table>        
<tr><td>Stream</td><td>${pl:linkToStreams(streamIdPath,streamPath,".","si.jsp?stream=")}</td></tr>   
<tr>
   <td>Execution</td>
   <td><b>${data.executionNumber}</b>
      <c:forEach var="row" items="${executions.rows}">
         ,&nbsp;<a href="si.jsp?stream=${row.stream}">${row.executionnumber}</a>
      </c:forEach>
   </td>
</tr>
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
    EndDate, jobid, jobsite, cpuSecondsUsed, executionHost, executionNumber, autoRetryNumber, autoRetryMaxAttempts, isLatest from processinstance
    join process using (process)
    where stream = ?		
    <c:if test="${showLatest}"> 
        and isLatest=1
    </c:if >
    order by displayorder
    <sql:param value="${param.stream}"/>    
</sql:query>   

<form name="piSelectForm" action="confirm.jsp" method="post">
    <display:table class="datatable" name="${testprocess.rows}" id="row" sort="list" pagesize="${test.rowCount>50 && empty param.showAll ? 20 : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator">
        <display:column property="ProcessName" title="Process" sortable="true" headerClass="sortable" href="pi.jsp" paramId="pi" paramProperty="ProcessInstance"/>
        <display:column property="Status" title="Status" sortable="true" headerClass="sortable"/>
        <c:if test="${!showLatest}">
            <display:column title="#">
                ${row.executionNumber}(${row.autoRetryNumber}/${row.autoRetryMaxAttempts})${row.isLatest>0 ? "(*)" : ""}
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
        
        <c:if test="${adminMode}">
            
            <display:column property="selector" title=" " class="admin"/>
        </c:if>    
        <display:footer>
            
            <c:if test="${adminMode}">        
                <tr>
                    <td colspan="20" class="admin">                
                        <a href="javascript:void(0)" onClick="piShowAll(true);">Select all</a>&nbsp;.&nbsp;
                        <a href="javascript:void(0)" onClick="piShowAll(false);">Deselect all</a>&nbsp;.&nbsp;
                        <a href="javascript:void(0)" onClick="piToggleAll();">Toggle selection</a>
                        <input type="hidden" name="stream" value="${param.stream}">
                        <input type="hidden" name="task" value="${task}">
                        <input type="submit" value="Rollback Selected" name="submit">
                    </td>
                </tr> 
            </c:if>
        </display:footer>
    </display:table>   
</form>

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

<form name="subStreamSelectForm" action="confirm.jsp" method="post">
    
    <display:table class="datatable" name="${test.rows}" sort="list" defaultsort="1" defaultorder="ascending" pagesize="${test.rowCount>50 && empty param.showAll ? 20 : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >
        <display:column property="Taskname" title="taskname" sortable="true" group = "1" headerClass="sortable" />              			    
        <display:column property="StreamId" title="Stream" sortable="true" headerClass="sortable" href="si.jsp" paramId="stream" paramProperty="stream"/>                  
        <display:column property="StreamStatus" title="Status" sortable="true" headerClass="sortable"/>
        <display:column property="CreateDate" title="Created" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator"/>
        <display:column property="StartDate" title="Started" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator"/>
        <display:column property="EndDate" title="Ended" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator"/>
        <c:if test="${adminMode}">
            
            <display:column property="streamSelector" title=" " class="admin"/>
        </c:if>    
        <display:footer>
            
            <c:if test="${adminMode}">        
                <tr>
                    <td colspan="20" class="admin">                
                        <a href="javascript:void(0)" onClick="subStreamShowAll(true);">Select all</a>&nbsp;.&nbsp;
                        <a href="javascript:void(0)" onClick="subStreamShowAll(false);">Deselect all</a>&nbsp;.&nbsp;
                        <a href="javascript:void(0)" onClick="subStreamToggleAll();">Toggle selection</a>
                        <input type="hidden" name="stream" value="${param.stream}">
                        <input type="hidden" name="task" value="${task}">
                        <input type="submit" value="Rollback Selected SubStreams" name="submit">
                    </td>
                </tr> 
            </c:if>
        </display:footer>
    </display:table>
</form>

<h3>All Substreams</h3>
 
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

<!-- count 'em up.  This handles any number of statuses gracefully -->
<jsp:useBean id="totals" class="java.util.HashMap"/>
<c:forEach var="row" items="${proc_stats.rows}">
   <c:set target="${totals}" property="${row.PROCESSINGSTATUS}" value="0"/>
</c:forEach>
<c:forEach var="row" items="${streamset.rows}">
   <c:forEach var="stat" items="${proc_stats.rows}">
      <c:set target="${totals}" property="${stat.PROCESSINGSTATUS}" value="${totals[stat.PROCESSINGSTATUS]+row[stat.PROCESSINGSTATUS]}"/>
   </c:forEach>
</c:forEach>  

<form name="selectForm" action="confirm.jsp" method="post">
<display:table class="datatable" name="${streamset.rows}" id="tableRow" sort="list" defaultsort="1" defaultorder="descending" pagesize="${test.rowCount>50 && empty param.showAll ? 20 : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >    
<display:column property="Taskname" title="Task" class="leftAligned" sortable="true" group = "1" headerClass="sortable"  href="task.jsp" paramId="task" paramProperty="Task" />              			       
<display:column property="Processname" title="Process" sortable="true" group = "1" headerClass="sortable" href="process.jsp?status=0&pstream=${param.stream}" paramId="process" paramProperty="Process" />              	    
<c:forEach var="row" items="${proc_stats.rows}">
    <display:column sortProperty="${row.PROCESSINGSTATUS}" title="<img src=\"img/${row.PROCESSINGSTATUS}.gif\" alt=\"${pl:prettyStatus(row.PROCESSINGSTATUS)}\" title=\"${pl:prettyStatus(row.PROCESSINGSTATUS)}\">" sortable="true"  headerClass="sortable"  >
        <a href="process.jsp?status=${row.PROCESSINGSTATUS}&pstream=${param.stream}&process=${tableRow.Process}">${tableRow[row.PROCESSINGSTATUS]}</a>      
    </display:column>
</c:forEach>   
<display:column property="all" title="Total" />

<display:footer>
   <tr /> <!-- a little vertical padding -->
   <tr>
      <td></td> <!-- task name column -->
      <td><strong>Totals</strong></td>
      
      <c:set var="grandTotal" value="0" />
      <c:forEach var="stat" items="${proc_stats.rows}">
         <td>${totals[stat.PROCESSINGSTATUS]}</td>
         <c:set var="grandTotal" value="${grandTotal + totals[stat.PROCESSINGSTATUS]}" />
      </c:forEach>
      
      <td><strong>${grandTotal}</strong><td>
    </tr>  
     
</display:footer>
</display:table>
</form>

</body>
</html>
