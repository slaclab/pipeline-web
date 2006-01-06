<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:choose>
   <c:when test="${param.mode=='prod'}">
      <sql:setDataSource dataSource="jdbc/pipeline" scope="session"/>
      <c:set var="mode" value="Prod" scope="session"/>
   </c:when>
   <c:when test="${param.mode=='dev'}">
      <sql:setDataSource dataSource="jdbc/pipeline-dev" scope="session"/>
      <c:set var="mode" value="Dev" scope="session"/>
   </c:when>
   <c:when test="${param.mode=='test'}">
      <sql:setDataSource dataSource="jdbc/pipeline-test" scope="session"/>
      <c:set var="mode" value="Test" scope="session"/>
   </c:when>
</c:choose>

<table class="pageHeader">
   <tr>
      <td valign="top" rowspan="2">
         <a href="index.jsp"><img src="img/pipeline.png"></a>
      </td>
      <td align="right" valign="top">
         <a href="releasenotes.jsp">Version 1.4.1</a>
         |
         <a href="http://jira.slac.stanford.edu/browse/PFE">Jira</a>
         |
         <a href="help.html">Help</a>
      </td>
   </tr>
   <tr>
      <td align="right" valign="bottom"><p>Mode: <b><c:out value="${mode}" default="Prod"/></b> Switch to: [ <a href="index.jsp?mode=prod">Prod</a> | <a href="index.jsp?mode=dev">Dev</a> | <a href="index.jsp?mode=test">Test</a> ]</p>
         <p>*NEW* <a href="upload.jsp">Upload configuration file</a></p> 
      </td>        
   </tr>
</table>

<c:if test="${!empty param.task}">
   <sql:query var="name">
      select TASKNAME from TASK where TASK_PK=?
      <sql:param value="${param.task}"/>           
   </sql:query>
   <c:set var="taskName" value="${name.rows[0].TASKNAME}"/>
        
   <c:if test="${!empty param.process}">
      <sql:query var="name">
         select TASKPROCESSNAME from TASKPROCESS where TASKPROCESS_PK=?
         <sql:param value="${param.process}"/>           
      </sql:query>  
      <c:set var="processName" value="${name.rows[0].TASKPROCESSNAME}"/>
   </c:if>
        
   <div class="breadCrumb"> 
      <a href="index.jsp">summary</a> 
      / <a href="task.jsp?task=${param.task}">${taskName}</a>
      <c:if test="${!empty processName}">/ <a href="process.jsp?task=${param.task}&process=${param.process}">${processName}</a> </c:if>
   </div> 
</c:if>