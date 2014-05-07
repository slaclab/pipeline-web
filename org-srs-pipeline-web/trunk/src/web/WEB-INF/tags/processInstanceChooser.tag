<%@tag description="Process Instance Chooser" pageEncoding="UTF-8"%>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>

<%@attribute name="name" required="true"%>
<%@attribute name="selected" type="java.lang.Integer"%>
<%@attribute name="allowNone" type="java.lang.Boolean" %>
<%@attribute name="processInstance" type="java.lang.Long" %>

<sql:query var="instances">
    select pi_avail.processinstance, avail.streamid
          from processinstance pi_sel
          join stream s_sel on (s_sel.stream = pi_sel.stream)
          join stream avail on (s_sel.task = avail.task and s_sel.parentstream = avail.parentstream)
          join processinstance pi_avail on (pi_sel.process = pi_avail.process and avail.stream = pi_avail.stream)
          where pi_sel.processinstance = ? 
          and avail.islatest = 1 and s_sel.islatest = 1 and pi_avail.islatest = 1
          order by avail.streamid
     <sql:param value="${processInstance}"/>
</sql:query>
<select size="1" name="${name}">
    <c:if test="${allowNone}">
        <option value="" ${empty selected ? "selected" : ""}>--</option>
    </c:if>
    <c:forEach var="row" items="${instances.rows}">
        <option value="${row.processinstance}" ${row.processinstance==selected ? "selected" : ""}>${row.streamid}</option>
    </c:forEach>
</select>
