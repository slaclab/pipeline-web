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
    </head>
    <body>
        
        <sql:query var="proc_stats">
            select PROCESSINGSTATUS from PROCESSINGSTATUS order by DISPLAYORDER
        </sql:query>
        
        <h2>Task Summary: ${taskNamePath} 
        <c:if test="${!fn:contains(taskNamePath,'.')}">      
            (<a href="xml.jsp?task=${task}">XML</a>)
        </c:if>
        </h2> 
        
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
        
        <sql:query var="subtasks">
           select task, taskname from task where parenttask=?
           <sql:param value="${task}"/>
        </sql:query>

        <c:if test="${subtasks.rowCount>0}">
           Subtasks: 
           <c:forEach var="row" items="${subtasks.rows}">
              <a href="task.jsp?task=${row['task']}">${row["taskname"]}</a>
           </c:forEach>
        </c:if>
        
        <p><pl:taskMap task="${task}"/></p>
        
        <pt:taskSummary streamCount="count"/>
        
        <c:choose>
            <c:when test="${count == 0}">
                <p> No runs in this task.</p>
            </c:when>
            <c:otherwise>
                <p>To filter by status click on the count in the status column. To see all runs click on the name in the Name column.</p>   
                <p><a href="running.jsp?task=${task}">Show running jobs</a> . <a href="streams.jsp?task=${task}">Show streams</a> . <a href="P2stats.jsp?task=${task}">Summary plots</a></p>
                
                <sql:query var="test">select 
                    <c:forEach var="row" items="${proc_stats.rows}">
                        SUM(case when PROCESSINGSTATUS='${row.PROCESSINGSTATUS}' then 1 else 0 end) "${row.PROCESSINGSTATUS}",
                    </c:forEach>
                    ProcessName,Process, Initcap(ProcessType) type
                    from PROCESS
                    join PROCESSINSTANCE using (PROCESS) 
                    join STREAMPATH using (STREAM)
                    where TASK=? and isLatest=1 and isLatestPath=1 
                    group by PROCESS, PROCESSNAME, PROCESSTYPE
                    <sql:param value="${task}"/>
                </sql:query>

                <display:table class="dataTable" name="${test.rows}" defaultsort="1" defaultorder="ascending" decorator="org.glast.pipeline.web.decorators.ProcessDecorator">
                    <display:column property="ProcessName" title="Name" sortable="true" headerClass="sortable" href="process.jsp?status=0" paramId="process" paramProperty="Process"/>
                    <display:column property="Type" sortable="true" headerClass="sortable" href="script.jsp" paramId="process" paramProperty="Process"/>
                    <c:forEach var="row" items="${proc_stats.rows}">
                        <display:column property="${row.PROCESSINGSTATUS}" title="<img src=\"img/${row.PROCESSINGSTATUS}.gif\" alt=\"${pl:prettyStatus(row.PROCESSINGSTATUS)}\" title=\"${pl:prettyStatus(row.PROCESSINGSTATUS)}\">" sortable="true" headerClass="sortable" href="process.jsp?status=${row.PROCESSINGSTATUS}" paramId="process" paramProperty="Process"/>
                    </c:forEach>
                    <display:column property="taskLinks" title="Links (<a href=help.html>?</a>)" />
                </display:table>
            </c:otherwise>
        </c:choose>
    </body>
</html>
