<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>

<html>
   <head>
      <title>Pipeline status</title>
   </head>
   <body>
      
      <h2>Task ${taskName} Process ${processName} Stream ${streamIdPath}</h2>
      
      <sql:query var="rs">
         select * from processinstance
         join process using (process)
         where processinstance=?
         <sql:param value="${param.pi}"/>
      </sql:query>
      <c:set var="data" value="${rs.rows[0]}"/>
      
      <table>
         <tr><td>Type</td><td>${data.processtype}</td></tr>
         <tr><td>Status</td><td>${pl:prettyStatus(data.processingstatus)}</td></tr>          
         <tr><td>CreateDate</td><td>${pl:formatTimestamp(data.createDate)}</td></tr>          
         <tr><td>SubmitDate</td><td>${pl:formatTimestamp(data.submitDate)}</td></tr>          
         <tr><td>StartDate</td><td>${pl:formatTimestamp(data.startDate)}</td></tr>                   
         <tr><td>EndDate</td><td>${pl:formatTimestamp(data.endDate)}</td></tr>                                     
         <tr><td>CPU Used</td><td>${data.CpuSecondsUsed}</td></tr>      
         <tr><td>Memory Used</td><td>${data.MemoryUsed}</td></tr>                                     
         <tr><td>Swap Used</td><td>${data.SwapUsed}</td></tr>                                     
         <tr><td>Execution Host</td><td>${data.ExecutionHost}</td></tr>                                     
         <tr><td>Exit Code</td><td>${data.ExitCode}</td></tr>    
         <tr><td>Working Dir</td><td><a href="run.jsp?pi=${param.pi}">${data.WorkingDir}</a></td></tr>
         <tr><td>Log File</td><td><a href="log.jsp?pi=${param.pi}">${data.LogFile}</a></td></tr>
         <tr><td>Execution Number</td><td>${data.ExecutionNumber}</td></tr>
         <tr><td>Is Latest</td><td>${data.IsLatest}</td></tr>   
         <tr><td>Batch Job ID</td><td><a href="job.jsp?id=${data.JobId}">${data.JobId}</a></td></tr>                                     
      </table>
      
      <p>Links: <a href="logViewer.jsp?pi=${param.pi}&severity=500&minDate=None&maxDate=None">View Messages</a></p>
      
      <h3>Variables</h3>
      <sql:query var="rs">
         select * from processinstancevar
         where processinstance=?
         <sql:param value="${param.pi}"/>
      </sql:query>      
      
      <display:table class="datatable" name="${rs.rows}" defaultsort="1" defaultorder="ascending">
         <display:column property="varname" title="Name" sortable="true" headerClass="sortable" />
         <display:column property="vartype" title="Type" sortable="true" headerClass="sortable"/>
         <display:column property="value" title="Value" sortable="true" headerClass="sortable"/>
      </display:table>      
      
   </body>
</html>
