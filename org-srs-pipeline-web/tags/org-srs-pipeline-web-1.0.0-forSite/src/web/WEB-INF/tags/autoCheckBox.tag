<%@tag description="A checkbox which reloads the page when clicked" pageEncoding="UTF-8"%>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<%@attribute name="name" type="java.lang.String" required="true" %>
<%@attribute name="value" type="java.lang.Boolean" %>
<%@attribute name="noHiddenParameters" type="java.lang.Boolean" %>

<script type="text/javascript" language="JavaScript">function Do${name}Submission() { document.${name}Form.submit(); }</script>
<form name="${name}Form" target="_self"> 
    <c:forEach var="parameter" items="${param}">
       <c:if test="${!fn:startsWith(parameter.key,name) && !fn:startsWith(parameter.key,'submit') && !noHiddenParameters}">
          <input type="hidden" name="${parameter.key}" value="${fn:escapeXml(parameter.value)}">
       </c:if>
    </c:forEach>
    <input type="hidden" name="${name}Changed" value="true">
    <input type="checkbox" name="${name}" onClick="Do${name}Submission();" value="true" ${value ? "checked" : ""}><jsp:doBody/>
    <noscript>
        <input type="submit" value="Update">
    </noscript>
</form>