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
         <c:when test="${param.submit == 'Rollback Selected SubStreams'}">
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
         <c:when test="${param.submit == 'Delete Task'}">
            <sql:query var="notation">
             select * from notation where task=?
              <sql:param value="${task}"/>
            </sql:query>  
            <sql:query var="datasets">
            select count(*) count from dataset
                         join processinstance using (processinstance)
                         join process using (process)
                         join ( select task from task start with Task=? connect by prior Task = ParentTask) using (task)
               <sql:param value="${task}"/>
            </sql:query> 
            <p class="warning">
            You have requested to delete task <i>${taskVersion}</i>.</p> 
            <c:if test="${notation.rowCount>0}">
               <p>Created by ${notation.rows[0].username} at ${notation.rows[0].notedate} with comment:  <i><c:out value="${notation.rows[0].comments}" escapeXml="true"/></i></p>
            </c:if>
            <pt:taskSummary streamCount="count"/>
            <p>This operation cannot be undone!</p>
            <c:if test="${datasets.rows[0].count>0}">
               <p class="warning">Warning: ${datasets.rows[0].count} Datasets associated with this Task will be removed from the Data Catalog!</p>
            </c:if>
            <form method="post">
               <input type="hidden" name="deleteTask" value="${taskVersion}">
               <input type="submit" value="Confirm Delete!" name="submit">
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
         <c:when test="${param.submit=='Confirm Delete!'}">
            <p:deleteTask task="${param.deleteTask}"/>
            <p class="message">Delete completed successfully.</a>
         </c:when>
      </c:choose>
      
   </body>
</html>
