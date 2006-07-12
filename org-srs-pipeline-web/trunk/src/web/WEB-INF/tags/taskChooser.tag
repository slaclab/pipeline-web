<%@tag description="Task Chooser" pageEncoding="UTF-8"%>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>

<%@attribute name="name" required="true"%>
<%@attribute name="selected" %>
<%@attribute name="allowNone" type="java.lang.Boolean" %>
<%@attribute name="useKey" type="java.lang.Boolean" %>

<sql:query var="tasks">
   select task,taskname from task where parenttask is null order by taskname
</sql:query>
<select size="1" name="${name}">
   <c:if test="${allowNone}">
      <option value="" ${empty selected ? "selected" : ""}>--</option>
   </c:if>
   <c:forEach var="row" items="${tasks.rows}">
      <option value="${useKey ? row.TASK : row.TASKNAME}" ${(useKey ? row.TASK : row.TASKNAME)==selected ? "selected" : ""}>${row.TASKNAME}</option>
   </c:forEach>
</select>