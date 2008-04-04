<%@tag description="Task Summary" pageEncoding="UTF-8"%>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>

<%@attribute name="streamCount" rtexprvalue="false" required="true"%>
<%@variable alias="count" name-from-attribute="streamCount" variable-class="int" scope="AT_BEGIN" %>

<sql:query var="stream_stats">
  select STREAMSTATUS from STREAMSTATUS 
</sql:query>

<sql:query var="summary">
  select            
  <c:forEach var="row" items="${stream_stats.rows}" varStatus="status">
     SUM(case when STREAMSTATUS='${row.STREAMSTATUS}' then 1 else 0 end) "${row.STREAMSTATUS}",
  </c:forEach>
  SUM(1) "ALL"
  from TASK
  join STREAM using (TASK)
  where TASK=? and isLatest=1 
  <sql:param value="${task}"/>           
</sql:query> 

<c:set var="count" value="${empty summary.rows[0]['ALL'] ? 0 : summary.rows[0]['ALL']}"/>

<c:if test="${count > 0}">
   <div class="taskSummary">Task Summary: 
     <c:forEach var="row" items="${stream_stats.rows}" varStatus="status">
         ${pl:prettyStatus(row.STREAMSTATUS)}:&nbsp;${summary.rowsByIndex[0][status.index]},
     </c:forEach>
     Total:&nbsp;${summary.rows[0]["ALL"]}
   </div>
</c:if>