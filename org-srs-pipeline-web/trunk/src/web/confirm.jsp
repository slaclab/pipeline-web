<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>

<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>
<%@taglib prefix="p" uri="http://glast-ground.slac.stanford.edu/pipeline"%>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>
<%@taglib uri="http://glast-ground.slac.stanford.edu/GroupManager" prefix="gm" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html>
   <head>
      <title>Pipeline: Confirm</title>
   </head>
   <body>
      <c:if test="${!gm:isUserInGroup(userName,'PipelineAdmin')}">
         <c:redirect url="noPermission.jsp"/>
      </c:if>
      
      <c:choose>
         <c:when test="${param.submit == 'CANCEL'}">
            <c:redirect url="index.jsp"/>
         </c:when>
         <c:when test="${param.submit == 'Rollback Selected'}">
            <p class="warning">
            You have requested to rollback ${fn:length(paramValues["select"])} processes 
            from task <i>${taskName}</i> process <i>${processName}</i>. 
            This operation cannot be undone!</p>

            <form method="post">
               <input type="hidden" name="process" value="${process}">
               <c:forEach var="item" items="${paramValues['select']}">
                  <input type="hidden" name="select" value="${item}">
               </c:forEach>
               <input type="submit" value="Confirm Rollback!" name="submit">
               <input type="submit" value="CANCEL" name="submit">
            </form>
         </c:when>
         <c:when test="${param.submit == 'Rollback Selected Streams'}">
            <p class="warning">
            You have requested to rollback ${fn:length(paramValues["select"])} streams 
            from task <i>${taskName}</i>. 
            This operation cannot be undone!</p>

            <form method="post">
               <input type="hidden" name="task" value="${task}">
               <c:forEach var="item" items="${paramValues['select']}">
                  <input type="hidden" name="select" value="${item}">
               </c:forEach>
               Arguments to add or override:&nbsp;<input type="text" name="args" value="" size="50" />
               <input type="submit" value="Confirm Stream Rollback!" name="submit">
               <input type="submit" value="CANCEL" name="submit">
            </form>
         </c:when>
         <c:when test="${param.submit == 'Confirm Rollback!'}">
            <p:rollback processes="${paramValues['select']}"/> 
            <p class="message">Rollback completed successfully.</a>
         </c:when>
         <c:when test="${param.submit == 'Confirm Stream Rollback!'}">
            <p:rollback streams="${paramValues['select']}" args="${param.args}"/>    
             <p class="message">Rollback completed successfully.</a>
         </c:when>
      </c:choose>
      
   </body>
</html>
