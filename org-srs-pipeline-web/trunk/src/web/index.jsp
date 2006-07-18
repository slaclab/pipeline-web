<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/GroupManager" prefix="gm" %>

<html>
    <head>
        <title>Pipeline status</title>  
    </head>
    <body>
        <c:choose>
            <c:when test="${!empty param.submit}">  
                <c:set var="taskFilter" value="${param.taskFilter}" scope="session"/>
                <c:set var="include" value="${param.include}" scope="session"/>
                <c:set var="regExp" value="${!empty param.regExp}" scope="session"/>
            </c:when>
            <c:when test="${!empty param.clear}">
                <c:set var="taskFilter" value="" scope="session"/>
                <c:set var="include" value="" scope="session"/>
            </c:when>
        </c:choose>
        
        <sql:query var="stream_stats">
            select STREAMSTATUS from STREAMSTATUS
        </sql:query>
        
        <sql:query var="test">
           select * from (
           select 
              SUM(1) "ALL",
              <c:forEach var="row" items="${stream_stats.rows}">
                SUM(case when STREAMSTATUS='${row.STREAMSTATUS}' then 1 else 0 end) "${row.STREAMSTATUS}",
             </c:forEach>
           t.TASKNAME, t.TASK
           from TASK t
           join STREAM s on s.TASK=t.TASK
           where t.PARENTTASK is null
           group by t.TASK, t.TASKNAME
           )
           where TASK>0 
            <c:if test="${!empty taskFilter && !regExp}">
                and lower("TASKNAME") like lower(?)
                <sql:param value="%${taskFilter}%"/>
            </c:if>
            <c:if test="${!empty taskFilter && regExp}">
                and regexp_like("TASKNAME",?)
                <sql:param value="${taskFilter}"/>
            </c:if>
            <c:if test="${include=='runs'}">
                and "ALL">0
            </c:if>
            <c:if test="${include=='noruns'}">
                and "ALL"=0
            </c:if>
            <c:if test="${include=='active'}">
                and ("RUNNING">0 or "QUEUED">0 or "WAITING">0)
            </c:if>     
        </sql:query>    

        <h2>Task Summary</h2>

        <p>This is the web interface to the pipeline. This version includes support for viewing log files, sorting columns, and filtering of results. Feedback and suggestions
        are welcome.</p>
        
        <form name="DateForm">
            <table class="filterTable">
                <tr valign="top">
                  <td>Task Filter: <input type="text" name="taskFilter" value="${taskFilter}"></td>
                  <td><input type="checkbox" name="regExp" ${regExp ? 'checked' : ''}> Regular Expression (<a href="http://www.oracle.com/technology/oramag/webcolumns/2003/techarticles/rischert_regexp_pt1.html">?</a>)</td>
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
           <display:column property="taskname" title="Task Name" sortable="true" headerClass="sortable" href="task.jsp" paramId="task" paramProperty="task"/>
             <c:forEach var="row" items="${stream_stats.rows}">
                <display:column property="${row.STREAMSTATUS}" title="${pl:prettyStatus(row.STREAMSTATUS)}" sortable="true" headerClass="sortable" />
            </c:forEach>
        </display:table>
    </body>
</html>
