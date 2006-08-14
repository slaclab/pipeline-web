<%@tag description="Task Chooser" pageEncoding="UTF-8"%>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>

<%@attribute name="name" required="true"%>
<%@attribute name="selected" %>
<%@attribute name="allowNone" type="java.lang.Boolean" %>
<%@attribute name="useKey" type="java.lang.Boolean" %>
<%@attribute name="showAllVersions" type="java.lang.Boolean" %>

<sql:query var="tasks">
    <c:choose>
        <c:when test="${showAllVersions}">
            select taskname||'('||version||'.'||revision||')' taskname,task from task where parenttask = 0 order by taskname,version desc,revision desc
        </c:when>
        <c:otherwise>
            select taskname,max(task) task from task where parenttask = 0 group by taskname order by taskname
        </c:otherwise>
    </c:choose>
</sql:query>
<select size="1" name="${name}">
    <c:if test="${allowNone}">
        <option value="" ${empty selected ? "selected" : ""}>--</option>
    </c:if>
    <c:forEach var="row" items="${tasks.rows}">
        <option value="${useKey ? row.TASK : row.TASKNAME}" ${(useKey ? row.TASK : row.TASKNAME)==selected ? "selected" : ""}>${row.TASKNAME}</option>
    </c:forEach>
</select>
