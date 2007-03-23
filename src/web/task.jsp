<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>

<html>
   <head>
      <title>Pipeline status</title>
      <style type="text/css">
<!--
.style1 {color: #0000FF}
-->
      </style>
   </head>
   <body>
      
      <sql:query var="proc_stats">
         select PROCESSINGSTATUS from PROCESSINGSTATUS
      </sql:query>
      
      <h2>Task Summary: ${taskNamePath} 
         <c:if test="${!fn:contains(taskNamePath,'.')}">      
            (<a href="xml.jsp?task=${task}">XML</a>)
         </c:if>
      </h2> 
      
      <c:if test="${!fn:contains(taskNamePath,'.')}">      
         <sql:query var="notation">
            select * from notation where task=?
            <sql:param value="${task}"/>
         </sql:query>  
         
         
         <c:if test="${notation.rowCount>0}">
            <p>Created by ${notation.rows[0].username} at ${notation.rows[0].notedate} with comment:  <i><c:out value="${notation.rows[0].comments}" escapeXml="true"/></i></p>
         </c:if>
         
         
         <sql:query var="versions">
            select task, version, revision from task where taskName=? order by version, revision
            <sql:param value="${taskName}"/>
         </sql:query>        
         
         <c:if test="${versions.rowCount>0}">
            Versions:  
            <c:forEach var="row" items="${versions.rows}">
               <c:choose>
                  <c:when test="${row.task != task}">
                     <a href="task.jsp?task=${row.task}">(${row.version}.${row.revision})</a>
                  </c:when>
                  <c:otherwise>
                     <b>(${row.version}.${row.revision})</b> 
                  </c:otherwise>
               </c:choose>
            </c:forEach>
         </c:if>
      </c:if>
      
      <sql:query var="subtasks"> 
		  select task, taskname,parenttask  from task 
	start with task = ?  connect by  parenttask = prior task
         <sql:param value="${task}"/>
      </sql:query>
  
      <c:if test="${subtasks.rowCount>0}">
         <c:forEach var="row" items="${subtasks.rows}">
		<!-- <br>  subtask ${row['task']}:  -->
            <a href="task.jsp?task=${row['task']}">${row["taskname"]}</a>
         </c:forEach>
      </c:if>
      
      <c:if test="${ empty gvOrientation }" >
         <c:set var="gvOrientation" value="LR" scope="session"/> 
      </c:if> 
      <c:if test="${ ! empty param.gvOrientation }" >
         <c:set var="gvOrientation" value="${param.gvOrientation}" scope="session"/> 
      </c:if>

      <p><pl:taskMap task="${task}" gvOrientation="${gvOrientation}"/></p>
      
      <script type="text/javascript" language="JavaScript">function DoOrientationSubmission() { document.OrientationForm.submit(); }</script>
      <p>
   <form name="OrientationForm"> 
            <c:forEach var="parameter" items="${param}">
               <c:if test="${parameter.key!='gvOrientation'}">
                  <input type="hidden" name="${parameter.key}" value="${fn:escapeXml(parameter.value)}">
               </c:if>
            </c:forEach>
            
            Graph Oriention: 
            <c:choose>
               <c:when test="${gvOrientation=='LR'}">
                  <input type="radio" name="gvOrientation" value="LR" checked>Left/Right</input>
                  <input type="radio" name="gvOrientation" value="TB" onClick="DoOrientationSubmission();">Top/Bottom</input>
               </c:when>
               <c:otherwise>
                  <input type="radio" name="gvOrientation" value="LR" onClick="DoOrientationSubmission();">Left/Right</input>
                  <input type="radio" name="gvOrientation" value="TB" checked>Top/Bottom</input>
               </c:otherwise>
            </c:choose>
   </form>
      </p>
            
      <pt:taskSummary streamCount="count"/>   <c:choose>
         <c:when test="${count == 0}">
            <p> No streams in this task.</p>
         </c:when>
         <c:otherwise>
            <p>To filter by status click on the count in the status column. To see all streams click on the name in the Name column.</p>   
            <p><a href="running.jsp?task=${task}">Show running jobs</a> . <a href="streams.jsp?task=${task}">Show streams</a> . <a href="P2stats.jsp?task=${task}">Summary plots</a></p>
            
            <sql:query var="test">select 
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
      join STREAMPATH using (STREAM)
      where isLatest=1 and isLatestPath=1 
   group by lev,task, taskname,process,PROCESSNAME,displayorder, processtype
   order by task, displayorder,  process

               <sql:param value="${task}"/>
            </sql:query>          		  		    
            <display:table class="dataTable" name="${test.rows}"  decorator="org.glast.pipeline.web.decorators.ProcessDecorator">
                 <display:column property="TaskName" title="Task"  class="leftAligned"  href="task.jsp" paramId="task" paramProperty="Task"/>     
			  <display:column property="ProcessName" title="Process" href="process.jsp?status=0" paramId="process" paramProperty="Process"/>
               <display:column property="Type" href="script.jsp" paramId="process" paramProperty="Process"/>
               <c:forEach var="row" items="${proc_stats.rows}">
                  <display:column property="${row.PROCESSINGSTATUS}" title="<img src=\"img/${row.PROCESSINGSTATUS}.gif\" alt=\"${pl:prettyStatus(row.PROCESSINGSTATUS)}\" title=\"${pl:prettyStatus(row.PROCESSINGSTATUS)}\">" sortable="true" headerClass="sortable" href="process.jsp?status=${row.PROCESSINGSTATUS}" paramId="process" paramProperty="Process"/>
            </c:forEach>
               <display:column property="taskLinks" title="Links (<a href=help.html>?</a>)" />
            </display:table>
         </c:otherwise>
      </c:choose>
   </body>
</html>
