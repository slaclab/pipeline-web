<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<table class="pageHeader">
   <tr>
      <td valign="top" rowspan="2">
         <a href="index.jsp"><img src="img/pipeline.png"></a>
      </td>
      <td align="right" valign="top">    
         <a href="releasenotes.jsp">Version 1.4.4</a>
         |
         <a href="http://jira.slac.stanford.edu/browse/PFE">Jira</a>
         |
         <a href="help.html">Help</a>
      </td>
   </tr>
   <tr>
      <td align="right" valign="bottom">
         <p><jsp:useBean id="now" class="java.util.Date" /> 
         Page updated: <fmt:formatDate value="${now}" pattern="MM/dd/yyyy HH:mm:ss"/> </p>
         <c:choose>
            <c:when test="${empty userName}">
               <p><a href="?login=true${optionString}">Login</a></p>
            </c:when>

            <c:otherwise>
               <p>User: ${userName}&nbsp;.&nbsp;<a href="?login=false">Logout</a></p>
            </c:otherwise>
         </c:choose>
         <p>Mode: <b><c:out value="${mode}" default="Prod"/></b> Switch to: [ <a href="index.jsp?mode=prod">Prod</a> | <a href="index.jsp?mode=dev">Dev</a> | <a href="index.jsp?mode=test">Test</a> ]</p>
         <p><a href="jobBYhour.jsp">Summary job stats</a>&nbsp;.&nbsp;<a href="upload.jsp?login=true">Upload configuration file</a></p>
      </td>        
   </tr>
</table>

<c:if test="${!empty param.task}">   
   <div class="breadCrumb"> 
      <a href="index.jsp">summary</a> 
      / <a href="task.jsp?task=${param.task}">${taskName}</a>
      <c:if test="${!empty processName}">/ <a href="process.jsp?task=${param.task}&process=${param.process}">${processName}</a> </c:if>
   </div> 
</c:if>