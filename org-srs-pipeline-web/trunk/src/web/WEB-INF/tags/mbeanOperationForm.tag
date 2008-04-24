<%@tag description="put the tag description here" pageEncoding="UTF-8"%>
<%@taglib uri="http://www.servletsuite.com/servlets/jmxtag" prefix="jmx"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@attribute name="connection" required="true" type="javax.management.MBeanServerConnection" %>
<%@attribute name="mbean" required="true" %>
<%@attribute name="method" required="true" %>

<c:if test="${param.mbeanInvoke==mbean && param.method==method}">
   <c:catch var="x">
      <jmx:invoke connection="${connection}" mbean="${mbean}" method="${method}" id="result">
         <c:forEach begin="0" end="${fn:length(paramValues['p'])-1}" var="i">
            <jmx:setParameter type="${paramValues['t'][i]}">${paramValues['p'][i]}</jmx:setParameter>
         </c:forEach>
      </jmx:invoke>   
   </c:catch>
   <c:set var="status" value="${empty x ? 'OK' : x}"/>
</c:if>

<form>
   <input type="hidden" name="mbeanInvoke" value="${mbean}">
   <input type="submit" name="method" value="${method}">
   (
   <jmx:forEachParameter connection="${connection}" mbean="${mbean}" method="${method}" idIndex="i">
      ${i == 1 ? '' : ','}
      ${parameterName} 
      <input name="p" value="${empty status ? parameterType : paramValues['p'][i-1]}"> 
      <input name="t" value="${parameterType}" type="hidden">
   </jmx:forEachParameter>
   )
   <b class="mbeanOperationResult">${empty result ? '' : '='} ${result} ${status}</b>
</form>

