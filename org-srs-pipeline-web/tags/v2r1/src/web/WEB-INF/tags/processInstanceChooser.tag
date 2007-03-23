<%@tag description="Process Instance Chooser" pageEncoding="UTF-8"%>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>

<%@attribute name="name" required="true"%>
<%@attribute name="selected" type="java.lang.Integer"%>
<%@attribute name="allowNone" type="java.lang.Boolean" %>
<%@attribute name="process" type="java.lang.Integer" %>

<sql:query var="instances">
     select processinstance,streamid from processinstance join stream using (stream) where process=? order by streamid
     <sql:param value="${process}"/>
</sql:query>
<select size="1" name="${name}">
    <c:if test="${allowNone}">
        <option value="" ${empty selected ? "selected" : ""}>--</option>
    </c:if>
    <c:forEach var="row" items="${instances.rows}">
        <option value="${row.processinstance}" ${row.processinstance==selected ? "selected" : ""}>${row.streamid}</option>
    </c:forEach>
</select>
