<%@page contentType="application/x-javascript"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
/* user-agent: ${header['user-agent']}*/
<c:choose>
   <c:when test="${fn:contains(header['user-agent'],'Safari')}">
      <c:import url="FSdateSelect-UTF8.safari.js"/>
   </c:when>
   <c:otherwise>
      <c:import url="FSdateSelect-UTF8.js"/>
   </c:otherwise>
</c:choose>