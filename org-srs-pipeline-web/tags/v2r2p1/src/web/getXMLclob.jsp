<%@page contentType="text/xml"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>


		<sql:query var="xml">
			select task, dbms_lob.substr(xmlsource) xmlsource from task where task=?
			<sql:param value="${task}"/>
		</sql:query>  
 
        ${xml.rows[0].xmlsource}  		

