<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@page import="org.apache.commons.fileupload.*"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>
<%@taglib prefix="p" uri="http://glast-ground.slac.stanford.edu/pipeline"%>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>
<%@taglib uri="http://glast-ground.slac.stanford.edu/GroupManager" prefix="gm" %>

<html>
   <head>
      <title>Pipeline: Upload</title>
   </head>
   <body>
      <c:if test="${!gm:isUserInGroup(userName,'PipelineAdmin')}">
         <c:redirect url="noPermission.jsp"/>
      </c:if>
      
      <p:serverInfo var="info"/>
      
      <c:if test="${empty info}">
         <p class="error">Server not running!</p>
      </c:if>      
      <c:if test="${!empty info}">
         <p class="info">Server version ${info.serverVersion} running on ${info.serverHost} since ${info.startTime}</p>
      
         <c:catch var="error">
            <c:choose>
               <c:when test="${param.submit=='Upload'}">
                  <p:upload user="${userName}" xml="${param.xml}"/>
               </c:when>
               <c:when test="${param.submit=='Create Stream'}">
                  <p:createStream task="${param.streamTask}" stream="${empty param.stream ? 0 : param.stream}" args="${param.args}"/>
               </c:when>
               <c:when test="${param.submit=='Restart Server'}">
                  <p:restartServer/>
               </c:when>
            </c:choose>
         </c:catch>
      
         <c:choose>
            <c:when test="${empty error && !empty param.submit}">
               <p class="message">${param.submit} successful!</p>
            </c:when>
            <c:when test="${!empty error}">
               <p class="error">${param.submit} failed!
               <p:reportError error="${error}"/></p>
            </c:when>
         </c:choose>        
        
         <h2>Upload</h2>

         <form method="POST" enctype="multipart/form-data">
            XML File: <input type="file" name="xml" value="" size="60" />
            <input type="submit" value="Upload" name="submit">
         </form>
      
         <h2>Create Stream</h2>
         <form method="POST">
            Task:&nbsp;<pt:taskChooser name="streamTask" selected="${param.streamTask}"/> 
            Stream:&nbsp;<input type="text" name="stream" value="" size="10" />
            Args:&nbsp;<input type="text" name="args" value="" size="50" />
            <input type="submit" value="Create Stream" name="submit">
         </form>    
    
         <h2>Restart Server</h2>
         <form method="POST">
            <input type="submit" value="Restart Server" name="submit">
         </form>    
      </c:if>
      
   </body>
</html>