<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>


<html>
   <head>
      <title>Task Map</title> 
      <BASE TARGET="_top">
   </head>
   <body> 
      <pl:taskMap task="${task}" gvOrientation="${param.gvOrientation}"/>
   </body>
</html>