<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@page import="org.apache.commons.fileupload.*"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>
<%@taglib prefix="p" uri="http://glast-ground.slac.stanford.edu/pipeline"%>
<%@taglib uri="http://glast-ground.slac.stanford.edu/GroupManager" prefix="gm" %>

<html>
   <head>
      <title>Pipeline: Upload</title>
   </head>
   <body>
      <c:if test="${!gm:isUserInGroup(userName,'PipelineAdmin')}">
         <c:redirect url="noPermission.jsp"/>
      </c:if>
      
      <c:catch var="error">
         <c:choose>
            <c:when test="${param.submit=='Upload'}">
               <p:upload user="${userName}" xml="${param.xml}"/>
            </c:when>
            <c:when test="${param.submit=='Create Stream'}">
               <p:createStream task="${param.streamTask}" stream="${param.stream}"/>
            </c:when>
         </c:choose>
      </c:catch>
      
      <c:choose>
         <c:when test="${empty error && !empty param.submit}">
            ${param.submit} successful!
         </c:when>
         <c:when test="${!empty error}">
            ${param.submit} failed!
            <p:reportError error="${error}"/>
         </c:when>
      </c:choose>        
        
      <h2>Upload</h2>

      <form method="POST" enctype="multipart/form-data">
         XML File: <input type="file" name="xml" value="" width="60" />
         <input type="submit" value="Upload" name="submit">
      </form>

      <sql:query var="tasks">
      select taskname from task where parenttask is null order by taskname
      </sql:query>
      
      <h2>Create Stream</h2>
      <form method="POST">
         Task: <select size="1" name="streamTask">
                    <c:forEach var="row" items="${tasks.rows}">
                        <option value="${row.TASKNAME}" ${param.streamTask==row.TASKNAME ? "selected" : ""}>${row.TASKNAME}</option>
                    </c:forEach>
                </select>
         Stream: <input type="text" name="stream" value="" width="40" />
         <input type="submit" value="Create Stream" name="submit">
      </form>        
   </body>
</html>
