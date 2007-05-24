<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>
<html>
    <head>
        <title>Pipeline status</title>
    </head>
    <body>
        <h2>Task: ${taskName}</h2>
       
	   <sql:query var="xml">
			select  dbms_lob.substr(xmlsource) xmlsource from task where task=?
			and xmlsource is not null
			<sql:param value="${task}"/>
		</sql:query>  
		
	
		<c:choose>
			<c:when test="${xml.rowCount>0}">  
        		<c:set var="xmlURL" value="getXMLclob.jsp?task=${task}"/>		
			</c:when>
			<c:otherwise>
				<c:set var="xmlURL" value="DumpTaskServlet?task=${task}"/>
			</c:otherwise>
		</c:choose>
				
        <b>xml file:</b> (<a href="${xmlURL}">download</a>)
        <c:import var="xml" url="${xmlURL}" />
        <pre class="log"><c:out value="${xml}" escapeXml="true" /></pre>

    </body>
</html>
