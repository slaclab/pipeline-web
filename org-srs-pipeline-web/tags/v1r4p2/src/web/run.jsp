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
         select RUNNAME,BATCHLOGFILEPATH from TPINSTANCE,RUN where TPINSTANCE_PK=? and RUN_PK=RUN_FK
         <sql:param value="${param.run}"/>           
      </sql:query>
      <c:set var="logURL" value="${fn:replace(name.rowsByIndex[0][1],'/nfs/farm/g/glast/','ftp://ftp-glast.slac.stanford.edu/glast.')}"/>
      <c:redirect url="${logURL}"/>

   </body>
</html>
