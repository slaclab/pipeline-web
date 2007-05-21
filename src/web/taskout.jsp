<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>


<html>
   <head>
      <title>Task Map</title>
 
   </head>
   <body>
 
      

      <c:if test="${ empty gvOrientation }" >
         <c:set var="gvOrientation" value="LR" scope="session"/> 
      </c:if> 
      <c:if test="${ ! empty param.gvOrientation }" >
         <c:set var="gvOrientation" value="${param.gvOrientation}" scope="session"/> 
      </c:if>

	 <pl:taskMap task="${task}" gvOrientation="${gvOrientation}"/>

    
     <p>
  
   </body>
</html>


  
        