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
    <title>Status Sums: Task ${taskName} Stream ${streamIdPath}</title>
</head>
<body>

 <h2>Status Sums: Task ${taskName} Stream ${streamIdPath}</h2>
 
 <sql:query var="proc_stats">
    select PROCESSINGSTATUS from PROCESSINGSTATUS order by DISPLAYORDER
</sql:query>

 
 <sql:query var="streamset">select 
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
    <sql:param value="${param.task}"/>    
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

 <display:table class="datatable" name="${streamset.rows}" id="tableRow" sort="list" defaultsort="1"  defaultorder="descending" pagesize="${test.rowCount>50 && empty param.showAll ? 20 : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >    
       <display:column property="ProcessStream" title="ProcessStream" class="leftAligned" sortable="true" group = "1" headerClass="sortable"  /> 
    <display:column property="Taskname" title="Task" class="leftAligned" sortable="true" group = "1" headerClass="sortable"  href="task.jsp" paramId="task" paramProperty="Task" />              			       
    <display:column property="Processname" title="Process" sortable="true" group = "1" headerClass="sortable" href="process.jsp?status=0" paramId="process" paramProperty="Process" />              	    
    <c:forEach var="row" items="${proc_stats.rows}">
        <display:column sortProperty="${row.PROCESSINGSTATUS}" title="<img src=\"img/${row.PROCESSINGSTATUS}.gif\" alt=\"${pl:prettyStatus(row.PROCESSINGSTATUS)}\" title=\"${pl:prettyStatus(row.PROCESSINGSTATUS)}\">" sortable="true"  headerClass="sortable"  >
            <a href="process.jsp?status=${row.PROCESSINGSTATUS}&stream=${tableRow.ProcessStream}&process=${tableRow.Process}">${tableRow[row.PROCESSINGSTATUS]}</a>     
        </display:column>
    </c:forEach>   
  <display:footer>
    <tr><td>Summary</td><td></td><td></td>   
        <td>${waitingSum} </td><td>${readySum}</td> <td>${queuedSum}</td><td> ${submittedSum}</td>
        <td> ${runningSum}</td><td>${successSum}</td><td>${failedSum}</td><td>${cancelledSum}</td>
           <td>${terminatedSum}</td>  <td>${skippedSum}</td> <tr>    
  </display:footer>
</display:table>
 
 
 waitingSum:    ${waitingSum} <br>
 readySum:      ${readySum} <br>
 queuedSum:     ${queuedSum} <br>
 submittedSum:  ${submittedSum} <br>
 
 successSum:    ${successSum} <br>
 failedSum:     ${failedSum}  <br>
 cancelledSum:  ${cancelledSum} <br>
 terminatedSum  ${terminatedSum} <br>
 skippedSum     ${skippedSum} <br>


 
</body>
</html>
 