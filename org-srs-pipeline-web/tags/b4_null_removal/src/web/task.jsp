<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>

<html>
    <head>
        <title>Pipeline status</title>
    </head>
    <body>
        
        <sql:query var="proc_stats">
            select PROCESSINGSTATUS from PROCESSINGSTATUS
        </sql:query>
        
        <h2>Task Summary: ${taskNamePath}</h2> 
        
        <sql:query var="versions">
           select task, version, revision from task where taskName=? and task<>?
           <sql:param value="${taskName}"/>
           <sql:param value="${task}"/>
        </sql:query>        

        <c:if test="${versions.rowCount>0}">
           Other versions:  
           <c:forEach var="row" items="${versions.rows}">
              <a href="task.jsp?task=${row['task']}">(${row["version"]}.${row["revision"]})</a>
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
        
        <p><img src="TaskImageServlet?task=${task}"/></p>
        
        <pt:taskSummary streamCount="count"/>
        
        <c:choose>
            <c:when test="${count == 0}">
                <p> No runs in this task.</p>
            </c:when>
            <c:otherwise>
                <p>To filter by status click on the count in the status column. To see all runs click on the name in the Name column.</p>   
                <p><b>*NEW*</b> <a href="running.jsp?task=${task}">Show running jobs</a> . <a href="stats.jsp?task=${task}&process=0">Show summary stats</a></p>
                
                <sql:query var="test">select 
                    <c:forEach var="row" items="${proc_stats.rows}">
                        SUM(case when PROCESSINGSTATUS='${row.PROCESSINGSTATUS}' then 1 else 0 end) "${row.PROCESSINGSTATUS}",
                    </c:forEach>
                    ProcessName,Process, Initcap(ProcessType) type
                    from PROCESS
                    join PROCESSINSTANCE using (PROCESS) 
                    where TASK=?
                    group by PROCESS, PROCESSNAME, PROCESSTYPE
                    <sql:param value="${task}"/>
                </sql:query>

                <display:table class="dataTable" name="${test.rows}" defaultsort="1" defaultorder="ascending" decorator="org.glast.pipeline.web.decorators.ProcessDecorator">
                    <display:column property="ProcessName" title="Name" sortable="true" headerClass="sortable" href="process.jsp?status=0" paramId="process" paramProperty="Process"/>
                    <display:column property="Type" sortable="true" headerClass="sortable" href="script.jsp" paramId="process" paramProperty="Process"/>
                    <c:forEach var="row" items="${proc_stats.rows}">
                        <display:column property="${row.PROCESSINGSTATUS}" title="${pl:prettyStatus(row.PROCESSINGSTATUS)}" sortable="true" headerClass="sortable" href="process.jsp?status=${row.PROCESSINGSTATUS}" paramId="process" paramProperty="Process"/>
                    </c:forEach>
                    <display:column property="taskLinks" title="Links (<a href=help.html>?</a>)" />
                </display:table>
            </c:otherwise>
        </c:choose>
    </body>
</html>
