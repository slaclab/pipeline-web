<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<html>
    <head>
        <title>Task Summary: ${taskName} </title>
    </head>
    <body>
        <!--
         <c:set var="title" value="Task Summary" />                         
        <img src="http://glast-ground.slac.stanford.edu/Commons/logoServlet.jsp?title=${title}"/>
        --> 
        <sql:query var="proc_stats">
            select PROCESSINGSTATUS from PROCESSINGSTATUS order by DISPLAYORDER
        </sql:query>
        
        <sql:query var="versions">
            select task, version, revision from task where taskName=? order by version, revision
            <sql:param value="${taskName}"/>
        </sql:query>        
        
        <c:if test="${versions.rowCount>0}">            
            <c:forEach var="row" items="${versions.rows}">
                <c:choose>
                    <c:when test="${row.task == task}">                        
                        <h2> Task Summary: ${taskNamePath} ${row.version}.${row.revision}
                            <c:if test="${!fn:contains(taskNamePath,'.')}">      
                                (<a href="xml.jsp?task=${task}">XML</a>)
                            </c:if>
                        </h2>        
                    </c:when>
                </c:choose>
            </c:forEach>
        </c:if>
        <c:if test="${!fn:contains(taskNamePath,'.')}">      
            <sql:query var="notation">
                select * from notation where task=?
                <sql:param value="${task}"/>
            </sql:query>              
            <c:if test="${notation.rowCount>0}">
                <p>Created by ${notation.rows[0].username} at ${notation.rows[0].notedate} with comment:  <i><c:out value="${notation.rows[0].comments}" escapeXml="true"/></i></p>
            </c:if>           
            <c:if test="${versions.rowCount>0}">
                <!-- Determing how many versions to display (last 5 or all) -->
                <c:choose>
                    <c:when test="${empty param.showAllVersions}">
                        <c:set var ="StartRowSpan" value="${versions.rowCount - 5}"/>
                    </c:when>
                    <c:otherwise>
                        <c:set var ="StartRowSpan" value="1"/>
                    </c:otherwise>
                </c:choose>                   
                <c:set var ="EndRowSpan" value="${versions.rowCount}"/>  
                <c:set var ="rowCounter" value="0"/>            
                Versions:  
                <c:forEach var="row" items="${versions.rows}">
                    <c:set var ="rowCounter" value="${rowCounter +1}"/>                
                    <c:if test="${rowCounter >= StartRowSpan and rowCounter <= EndRowSpan}">
                        <c:choose>
                            <c:when test="${row.task != task}">
                                <a href="task.jsp?task=${row.task}">(${row.version}.${row.revision})</a>
                            </c:when>
                            <c:otherwise>
                                <b>(${row.version}.${row.revision})</b> 
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                </c:forEach>
                <c:if test="${empty param.showAllVersions}">
                    <a href="task.jsp?task=${task}&showAllVersions=Y">....more versions </a>
                </c:if>
            </c:if>
        </c:if>                
        <sql:query var="subtasks"> 
            select task, taskname,parenttask, version,revision from task 
            start with task = ?  connect by  parenttask = prior task
            <sql:param value="${task}"/>
        </sql:query>        
        <c:if test="${subtasks.rowCount>0}">
            <c:forEach var="row" items="${subtasks.rows}">
                <!-- <br>  subtask ${row['task']}:  -->
                <a href="task.jsp?task=${row['task']}">${row["taskname"]}</a>
            </c:forEach>
        </c:if>        
        <c:if test="${results.rowCount>0}">
            <c:set var="gvOrientation" value="LR" scope="session"/> 
        </c:if> 
        <c:if test="${ ! empty param.gvOrientation }" >
            <c:set var="gvOrientation" value="${param.gvOrientation}" scope="session"/> 
        </c:if>
        <p><iframe width="100%"  frameborder="0"  height="200"   
                       src= "taskout.jsp?task=${task}&gvOrientation=${gvOrientation}  ">
        </iframe> </p>
        <p>
        <script type="text/javascript" language="JavaScript">function DoOrientationSubmission() { document.OrientationForm.submit(); }</script>
        
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
            &nbsp;.&nbsp;<a href="taskout.jsp?task=${task}&gvOrientation=${gvOrientation}">Full Diagram</a>          
            &nbsp;.&nbsp;<a href="http:TaskImageServlet?task=${task}&gvOrientation=${gvOrientation}&mode=source">Diagram source</a>   
        </form>
        <p>
        <pt:taskSummary streamCount="count"/>   <c:choose>
            <c:when test="${count == 0}">
                <p> No streams in this task.</p>
            </c:when>
            <c:otherwise>
                <p>To filter by status click on the count in the status column. To see all streams click on the name in the Name column.</p>   
                <p><a href="running.jsp?task=${task}">Show running jobs</a> . <a href="streams.jsp?task=${task}&status=0">Show streams</a> . <a href="P2stats.jsp?task=${task}">Summary plots</a></p>
                <p>
                    Show processes by status: 
                    <c:forEach var="row" items="${proc_stats.rows}">
                        &nbsp;<a href="process.jsp?task=${task}&status=${row.PROCESSINGSTATUS}">${pl:prettyStatus(row.PROCESSINGSTATUS)}</a>
                    </c:forEach>
                    &nbsp;<a href="process.jsp?task=${task}&status=0">[ALL]</a>                  
                    &nbsp;<a href="process.jsp?task=${task}&status=NOTSUCCESS">[All not SUCCESS]</a>
                </p>
                <sql:query var="test">select   SUM(1) "ALL",
                    <c:forEach var="row" items="${proc_stats.rows}">
                        SUM(case when PROCESSINGSTATUS='${row.PROCESSINGSTATUS}' then 1 else 0 end) "${row.PROCESSINGSTATUS}",                        
                    </c:forEach>
                    lev, lpad(' ',1+24*(lev -1),'&nbsp;')||taskname  taskname, task, version || '.' || revision as version, Initcap(ProcessType) type, processname, process,displayorder
                    from PROCESS 
                    join (               
                    SELECT task,taskname,version,revision,level lev FROM TASK
                    start with Task=? connect by prior Task = ParentTask
                    )  using (task)
                    join PROCESSINSTANCE using (PROCESS) 
                    where isLatest=1 and 0 not in (Select isLatest from stream start with stream = processinstance.stream connect by stream = prior parentstream and stream <> 0)           
                    group by lev,task, taskname, version, revision, process,PROCESSNAME,displayorder, processtype
                    order by task, process               
                    <sql:param value="${task}"/>
                </sql:query>
                <display:table class="datatable" name="${test.rows}" id="tableRow" varTotals="totals"  decorator="org.glast.pipeline.web.decorators.ProcessDecorator">
                    <display:column property="TaskName" title="Task"  class="leftAligned" group = "1" href="task.jsp" paramId="task" paramProperty="Task"/> 
                    <display:column property="Version" title="Version"  class="leftAligned" group = "1" href="task.jsp" paramId="task" paramProperty="Task"/>     
                    <display:column property="ProcessName" title="Process" sortable="true" headerClass="sortable" href="process.jsp?status=0" paramId="process" paramProperty="Process"/>
                    <display:column property="Type" sortable="true" headerClass="sortable" href="script.jsp" paramId="process" paramProperty="Process"/>
                    <c:forEach var="row" items="${proc_stats.rows}">
                        <display:column property="${row.PROCESSINGSTATUS}" total="true" title="<img src=\"img/${row.PROCESSINGSTATUS}.gif\" alt=\"${pl:prettyStatus(row.PROCESSINGSTATUS)}\" title=\"${pl:prettyStatus(row.PROCESSINGSTATUS)}\">" sortable="true" headerClass="sortable" href="process.jsp?status=${row.PROCESSINGSTATUS}" paramId="process" paramProperty="Process"/>
                    </c:forEach>
                    <display:column property="all" title="Total" total="true" href="process.jsp" paramId="process" paramProperty="Process" />
                    <display:column property="taskLinks" title="Links" />
                    <display:footer> 
                        <td></td> <!-- a little vertical padding -->
                        <tr>  <!-- summary row of totals -->
                        <td></td>  <!-- task name column -->
                        <td></td>  <!-- version column -->
                        <td></td>  <!-- Process name column -->
                        <td><strong>Totals</strong></td> <!-- Process type column, put our label here -->
                        <c:set var="colIndex" value="5" /> <!-- start at row 5 -->
                        <!-- do each of the status columns -->
                        <c:forEach var="stat" items="${proc_stats.rows}">
                           <c:set var="colName" value="column${colIndex}" />
                           <td><fmt:formatNumber type="number" value="${totals[colName]}" /></td>
                           <c:set var="colIndex" value="${colIndex + 1}" />
                        </c:forEach>
                        <!-- and a grand-total -->
                        <c:set var="colName" value="column${colIndex}" />
                        <td><strong><fmt:formatNumber type="number" value="${totals[colName]}" /></strong></td>
                        <tr>                       
                    </display:footer>                  
                </display:table>      
            </c:otherwise>
        </c:choose>
    </body>
</html>



