<%@tag description="put the tag description here" pageEncoding="UTF-8"%>
<%@taglib uri="http://www.servletsuite.com/servlets/jmxtag" prefix="jmx"%>
<%@taglib tagdir="/WEB-INF/tags" prefix="mbean"%>

<%@attribute name="connection" required="true" type="javax.management.MBeanServerConnection" %>
<%@attribute name="mbean" required="true" %>

<%-- Note, due to a limitation with the JMX library, this method does not work properly
     if there are two operations with the same name but different signatures --%>

<table class="mbeanOperationTable">
   <jmx:forEachOperation connection="${connection}" mbean="${mbean}" idName="opName">
      <tr>
         <td>
            <mbean:mbeanOperationForm connection="${connection}" mbean="${mbean}" method="${opName}"/>
         </td>
      </tr>
   </jmx:forEachOperation>
</table>

