<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 

<html>
   <head>
      <title>Pipeline status</title>
   </head>
   <body>

      <sql:query var="name">
         select WORKINGDIR from PROCESSINSTANCE where PROCESSINSTANCE=?
         <sql:param value="${param.pi}"/>           
      </sql:query>
      <c:set var="logURL" value="${fn:replace(name.rows[0]['WORKINGDIR'],'/nfs/farm/g/glast/','ftp://ftp-glast.slac.stanford.edu/glast.')}"/>
      <c:redirect url="${logURL}"/>

   </body>
</html>
