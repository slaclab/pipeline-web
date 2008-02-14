<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/GroupManager" prefix="gm" %>
<%@taglib tagdir="/WEB-INF/tags" prefix="pt"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/utils" prefix="utils" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
    <head>
        <title>Pipeline status</title>  
    </head>
    <body>    
        
        <!-- If userPrefInput is empty then we know to initialize their preferences and we set
       the value to 'true'.
       --> 
        <c:if test="${empty userPrefInput}">
            <c:set var="userPrefInput" value="true" scope="session"/>
        </c:if>
        
        <c:choose>
            <c:when test="${!empty param.submit}"> 
                <c:set var="taskFilter" value="${param.taskFilter}" scope="session"/>
                <c:set var="include" value="${param.include}" scope="session"/>
                <c:set var="regExp" value="${!empty param.regExp}" scope="session"/>
                <c:set var="versionGroup" value="${param.versionGroup}" scope="session"/>
                <c:set var="userPrefInput" value="false" scope="session"/>
            </c:when>
            
            <c:when test="${!empty param.clear}">
                <c:set var="taskFilter" value="" scope="session"/>
                <c:set var="userPrefInput" value="true" scope="session"/>
            </c:when>
        </c:choose>
        
        <c:if test="${userPrefInput}">
            <c:set var="versionGroup" value="${preferences.taskVersion}" scope="session"/>
            <c:set var="include" value="${preferences.task}" scope="session"/>
        </c:if>
        
        <sql:query var="stream_stats">
            select STREAMSTATUS from STREAMSTATUS order by DISPLAYORDER
        </sql:query>
        
        <sql:query var="test">
            select * from (
            select 
            SUM(1) "ALL",
            <c:forEach var="row" items="${stream_stats.rows}">
                SUM(case when STREAMSTATUS='${row.STREAMSTATUS}' then 1 else 0 end) "${row.STREAMSTATUS}",
            </c:forEach>
             
            taskname, tasktype, lastactive, 
            <c:if test="${versionGroup != 'allVersions'}">
                Max(t.TASK) Task
            </c:if>
            <c:if test="${versionGroup == 'allVersions'}">
                t.TASK,VERSION,REVISION 
            </c:if>		
            from TASK t
            left outer join STREAM s on s.TASK=t.TASK and s.isLatest=1
            where PARENTTASK = 0
            <c:if test="${versionGroup == 'latestVersions'}">
                and t.version = 
                (select distinct max(version) from  task t1 where t1.taskname = t.taskname)
                and t.revision = 
                (select max(revision) from task t2  where t2.taskname = t.taskname  and t2.version = t.version)
                
            </c:if>
            group by 
            <c:if test="${versionGroup == 'mergeVersions'}">
                TaskName, TaskType, LastActive
            </c:if>
            <c:if test="${versionGroup != 'mergeVersions'}">
                TaskName, TaskType, LastActive, t.TASK,VERSION,REVISION
            </c:if>
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
            <c:if test="${include=='last30'}">
                and SYSDATE-LastActive<interval '30' day 
            </c:if>   
        </sql:query>    
        
        <h2>Task Summary </h2>
        <br>
        <form name="DateForm">
            <table class="filtertable">
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
                    <td><select name="versionGroup">
                            <option value="latestVersions" ${versionGroup=='latestVersions' ? "selected" : ""}>Latest Task Versions</option>
                            <option value="allVersions" ${versionGroup=='allVersions' ? "selected" : ""}>All Task Versions</option>
                            <option value="mergeVersions" ${versionGroup=='mergeVersions' ? "selected" : ""}>Merge Task Versions</option>
                    </select></td>
                    <td><input type="submit" value="Filter" name="submit">&nbsp;<input type="submit" value="Reset Defaults" name="reset"></td>
                </tr>
            </table>
        </form>      
        <br> 
        <utils:listFilter var="filtered" items="${test.rows}">
           <utils:accept test="${item.taskType=='MC'}"/>
        </utils:listFilter>
        
        
        <display:table class="datatable" name="${filtered}"  id="tableRow" varTotals="totals"  defaultsort="${preferences.defaultSort}" defaultorder="${empty preferences.defaultOrder ? 'descending' : preferences.defaultOrder}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator">
            <display:column property="lastActive" title="Last Active" sortable="true" headerClass="sortable" />
            <display:column property="taskWithVersion" title="Task Name" sortable="true" headerClass="sortable" href="task.jsp" paramId="task" paramProperty="task"/>
            <display:column property="taskType" title="Type" sortable="true" headerClass="sortable" />
            <c:if test="${versionGroup == 'mergeVersions'}">
                <c:forEach var="row" items="${stream_stats.rows}">
                    <display:column property="${row.STREAMSTATUS}" 
                                    title="<img src=\"img/${row.STREAMSTATUS}.gif\" alt=\"${pl:prettyStatus(row.STREAMSTATUS)}\" title=\"${pl:prettyStatus(row.STREAMSTATUS)}\">" 
                                    total="true" sortable="true" headerClass="sortable" />             
                </c:forEach> 
            </c:if>
            
            <c:if test="${versionGroup != 'mergeVersions'}">
                <c:forEach var="row" items="${stream_stats.rows}">
                    <display:column property="${row.STREAMSTATUS}"  
                                    title="<img src=\"img/${row.STREAMSTATUS}.gif\" alt=\"${pl:prettyStatus(row.STREAMSTATUS)}\" title=\"${pl:prettyStatus(row.STREAMSTATUS)}\">" 
                                    total="true" sortable="true" headerClass="sortable"   href="streams.jsp?status=${row.streamSTATUS}" paramId="task" paramProperty="task" />             
                </c:forEach> 
            </c:if>
          
         <display:column property="all" title="Total Streams" sortable="true" headerClass="sortable" />
         
            <display:footer>  
                <tr> <strong> <td></td><td></td><td><strong>Totals</strong></td>              
                    <td>< fmt:formatNumber type="number" value="${totals.column4}" /> </td>
                    <td><fmt:formatNumber type="number" value="${totals.column5}" /></td>
                    <td><fmt:formatNumber type="number" value="${totals.column6}" /></td>
                    <td><fmt:formatNumber type="number" value="${totals.column7}" /></td>
                    <td><fmt:formatNumber type="number" value="${totals.column8}" /></td>
                    <td><fmt:formatNumber type="number" value="${totals.column9}" /></td>
                    <td><fmt:formatNumber type="number" value="${totals.column10}" /></td>
                    <td><fmt:formatNumber type="number" value="${totals.column11}" /></td>
                <td><fmt:formatNumber type="number" value="${totals.column12}" /></td></tr>   
            </display:footer> 
        </display:table>
    </body>
</html>
