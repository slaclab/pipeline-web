<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>

<html>
    <head>
        <title>Redirect to processing data</title>
    </head>
    <body> 
         
          <c:if test = "${param.get == 'streaminst'}">   
         <sql:query var="data">       
            select distinct stream from stream 
            join task using (task)
            join process using (task)
            where  taskname = ? 
            and streamid=?
            <sql:param value="${param.taskname}"/>
            <sql:param value="${param.streamid}"/>
	 </sql:query>  
         </c:if>         
      
       <c:forEach var="row" items="${data.rows}">           
          <c:redirect url="si.jsp?&stream=${row.stream}"/>
       </c:forEach>  
       
       </body>
</html>
