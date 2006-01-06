<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://www.opensymphony.com/sitemesh/decorator" prefix="decorator" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
   <head>
      <title><decorator:title default="Glast Pipeline" /></title>
      <link href="${pageContext.request.contextPath}/css/screen.jsp" rel="stylesheet" type="text/css">
      <decorator:head />
   </head>
   <body>
      <c:import url="header.jsp"/>
      <div class="pageBody">
         <decorator:body />
      </div>
   </body>
</html>
