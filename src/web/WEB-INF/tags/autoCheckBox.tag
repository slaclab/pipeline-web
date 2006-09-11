<%@tag description="A checkbox which reloads the page when clicked" pageEncoding="UTF-8"%>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%@attribute name="name" type="java.lang.String" required="true" %>
<%@attribute name="value" type="java.lang.Boolean" %>


<script type="text/javascript" language="JavaScript">function Do${name}Submission() { document.${name}Form.submit(); }</script>
<form name="${name}Form" target="_self"> 
    <input type="hidden" name="${name}Changed" value="true">
    <c:forEach var="parameter" items="${param}">
       <input type="hidden" name="${parameter.key}" value="${parameter.value}">
    </c:forEach>
    <input type="checkbox" name="${name}" onClick="Do${name}Submission();" value="true" ${value ? "checked" : ""}><jsp:doBody/>
    <noscript>
        <input type="submit" value="Update">
    </noscript>
</form>