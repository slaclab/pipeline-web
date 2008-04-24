<%@tag description="put the tag description here" pageEncoding="UTF-8"%>
<%@taglib uri="http://www.servletsuite.com/servlets/jmxtag" prefix="jmx"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@attribute name="connection" required="true" type="javax.management.MBeanServerConnection" %>
<%@attribute name="mbean" required="true" %>
<%@attribute name="updateable" required="false" type="java.lang.Boolean"  %>

<c:if test="${param.mbeanTable=='Apply' && param.mbeanUpdate==mbean}">
   <jmx:forEachAttribute connection="${connection}" mbean="${mbean}" idWritable="writable">
      <c:if test="${writable}">
         <c:set var="paramName" value="mbeanTable.attribute.${attributeName}"/>
         <jmx:setAttribute mbean="${mbean}" connection="${connection}" attribute="${attributeName}">${empty param[paramName] ? false : param[paramName]}</jmx:setAttribute> 
      </c:if>
   </jmx:forEachAttribute>

</c:if>

<c:if test="${updateable}">
   <form>
</c:if>
<table class="mbeanAttributeTable">
   <thead>
      <tr><th>Name</th><th>Type</th><th>Value</th></tr>
   </thead>
   <tbody>
      <jmx:forEachAttribute connection="${connection}" mbean="${mbean}" idWritable="writable">
         <tr>
            <td>
               ${attributeName}
            </td>
            <td>
               ${attributeType}
            </td>
            <td>
               <c:choose>
                  <c:when test="${updateable && writable && attributeType=='boolean'}">
                     <input type="checkbox" name="mbeanTable.attribute.${attributeName}" value="true" ${attributeValue ? "checked" : ""}>
                     <c:set var="hasWritable" value="true"/>
                  </c:when>
                  <c:when test="${updateable && writable}">
                     <input type="text" name="mbeanTable.attribute.${attributeName}" value="${attributeValue}">
                     <c:set var="hasWritable" value="true"/>
                  </c:when>
                  <c:otherwise>
                     ${attributeValue}
                  </c:otherwise>
               </c:choose>
            </td>
         </tr>
      </jmx:forEachAttribute>
      <c:if test="${updateable && hasWritable}">
         <tr>
            <td colspan="2" align="left">
               <input type="submit" name="mbeanTable" value="Apply" >
               <input type="hidden" name="mbeanUpdate" value="${mbean}">
            </td>
         </tr>
      </c:if>   
   </tbody>
</table>
<c:if test="${updateable}">
   </form>
</c:if>
