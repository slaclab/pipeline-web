<%@tag description="Process Chooser" pageEncoding="UTF-8"%>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>

<%@attribute name="name" required="true"%>
<%@attribute name="selected" type="java.lang.Integer"%>
<%@attribute name="allowNone" type="java.lang.Boolean" %>
<%@attribute name="task" type="java.lang.Integer" %>

<sql:query var="processes">
     select process,processname from process where task=? order by processname
     <sql:param value="${task}"/>
</sql:query>
<select size="1" name="${name}">
    <c:if test="${allowNone}">
        <option value="" ${empty selected ? "selected" : ""}>--</option>
    </c:if>
    <c:forEach var="row" items="${processes.rows}">
        <option value="${row.process}" ${row.process==selected ? "selected" : ""}>${row.processname}</option>
    </c:forEach>
</select>
