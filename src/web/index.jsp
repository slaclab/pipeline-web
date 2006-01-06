<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>

<html>
    <head>
        <title>Pipeline status</title>  
    </head>
    <body>
        <c:choose>
            <c:when test="${!empty param.submit}">  
                <c:set var="taskFilter" value="${param.taskFilter}" scope="session"/>
                <c:set var="include" value="${param.include}" scope="session"/>
            </c:when>
            <c:when test="${!empty param.clear}">
                <c:set var="taskFilter" value="" scope="session"/>
                <c:set var="include" value="" scope="session"/>
            </c:when>
        </c:choose>
        
        <sql:query var="run_stats">
            select RUNSTATUS_PK "rsPK", RUNSTATUSNAME "rsName" from RUNSTATUS
        </sql:query>
        
        <sql:query var="test">
            select * from (
            select SUM(case when RUNSTATUS_FK!=0 then 1 else 0 end) "ALL",
            <c:forEach var="row" items="${run_stats.rows}">
                SUM(case when RUNSTATUS_FK=${row.rsPK} then 1 else 0 end) "${row.rsName}",
            </c:forEach>
            TASK_PK "Id", TASKNAME "Task"
            from RUN r right outer join TASK t on r.TASK_FK=t.TASK_PK
            GROUP BY TASK_PK, TASKNAME ) TABLE_A left outer join ( 
            select T.Task_PK, GREATEST(MAX(TPI.Started), MAX(TPI.submitted), MAX(TPI.ended)) AS "Last Active" 
            from Task T 
            join TaskProcess TP on T.Task_PK = TP.Task_FK
            join TPInstance TPI on TP.TaskProcess_PK = TPI.TaskProcess_FK 
            group by T.Task_PK, T.TaskName
            ) TABLE_B 
            on  TABLE_A."Id" = TABLE_B.Task_PK where "Id">0          
            <c:if test="${!empty taskFilter}">
                and lower("Task") like lower('%${taskFilter}%')
            </c:if>
            <c:if test="${include=='runs'}">
                and "ALL">0
            </c:if>
            <c:if test="${include=='noruns'}">
                and "ALL"=0
            </c:if>
            <c:if test="${include=='active'}">
                and ("RUNNING">0 or "WAITING">0 or "FINALIZING">0)
            </c:if>
            <c:if test="${include=='last30'}">
                and SYSDATE-"Last Active"<30 
            </c:if>
        </sql:query>    

        <h2>Task Summary</h2>

        <p>This is the web interface to the pipeline. This version includes support for viewing log files, sorting columns, and filtering of results. Feedback and suggestions
        are welcome.</p>
        
        <form name="DateForm">
            <table class="filterTable">
                <tr valign="top">
                  <td>Task Filter: <input type="text" name="taskFilter" value="${taskFilter}"></td>
                  <td><select name="include">
                      <option value="all" ${include=='all' ? "selected" : ""}>All tasks</option>
                      <option value="runs" ${include=='runs' ? "selected" : ""}>Tasks with Runs</option>
                      <option value="noruns" ${include=='noruns' ? "selected" : ""}>Tasks without Runs</option>
                      <option value="active" ${include=='active' ? "selected" : ""}>Tasks with Active Runs</option>
                      <option value="last30" ${include=='last30' ? "selected" : ""}>Active in Last 30 days</option>
                  </select></td>
                  <td><input type="submit" value="Filter" name="submit">&nbsp;<input type="submit" value="Clear" name="clear"></td>
                </tr>
            </table>
        </form>       
        
        <display:table class="dataTable" name="${test.rows}" defaultsort="1" defaultorder="descending" decorator="org.glast.pipeline.web.decorators.ProcessDecorator">
           <display:column property="lastActive" title="Last Active" sortable="true" headerClass="sortable" />
           <display:column property="Task" sortable="true" headerClass="sortable" href="task.jsp" paramId="task" paramProperty="id"/>
             <c:forEach var="row" items="${run_stats.rows}">
                <display:column property="${row.rsName}" title="${pl:prettyStatus(row.rsName)}" sortable="true" headerClass="sortable" />
            </c:forEach>
        </display:table>
    </body>
</html>
