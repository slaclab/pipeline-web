<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
   <head>
      <title>Redirect to processing data</title>
   </head>
   <body> 
     
      <c:choose>
         <c:when test = "${param.show == 'stream'}">   
            <sql:query var="data">       
               select stream from stream 
               join task using (task)
               join taskpath using (task)
               where taskversion like ? 
               and streamid = ?
               order by version desc,revision desc, islatest desc
               <sql:param value="${param.taskname}%"/>
               <sql:param value="${param.streamid}"/>
            </sql:query>
            <c:redirect url="si.jsp?&stream=${data.rows[0].stream}"/>
         </c:when>         
           <c:when test = "${param.show =='streams'}">
             <sql:query var="data">
                  select task
                  from task 
                  where taskName=? 
                  order by version, revision                 
                 <sql:param value="${param.taskname}%"/>
             </sql:query>
           <c:redirect url="streams.jsp?task=${data.rows[0].task}&taskname=${param.taskname}"/>
         </c:when>
         <c:otherwise>
            Unrecognized request type show=${param.show}
         </c:otherwise> 
      </c:choose>
   </body>
</html>
