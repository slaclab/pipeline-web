<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="aida" uri="http://aida.freehep.org/jsp20" %>
<%@taglib prefix="tab" uri="http://java.freehep.org/tabs-taglib" %>

<html>
   <head>
      <title>Performance Plots</title>
   </head>
   <body>
     
<sql:query var="processes" dataSource="jdbc/pipeline-ii">
 	select p.PROCESS,p.PROCESSNAME from PROCESS p   
 	where p.TASK= ${param.task}
 	order by p.process         
</sql:query> 		
		 
<c:forEach var="row" items="${processes.rows}">
		 
<sql:query var="data">
	select enddate,startdate,
	(to_date(to_char(PI.startdate,'dd-mon-yyyy hh24:mi:ss '),'dd-mon-yyyy hh24:mi:ss')-
	to_date(to_char(PI.submitdate,'dd-mon-yyyy hh24:mi:ss '),'dd-mon-yyyy hh24:mi:ss'))*24*60 "WaitTime",
	(to_date(to_char(PI.enddate,'dd-mon-yyyy hh24:mi:ss '),'dd-mon-yyyy hh24:mi:ss') - 
	to_date(to_char(PI.startdate,'dd-mon-yyyy hh24:mi:ss '),'dd-mon-yyyy hh24:mi:ss') ) *24*60*60 "WallClock"
 	from processinstance PI
 	where PI.process = ?
	and PI.processingstatus = 'SUCCESS'
	order by PI.process,PI.processinstance
<sql:param value="${row.PROCESS}"/>
</sql:query>  
               <aida:tuple var="tuple" query="${data}" />        
              
               <aida:tupleProjection var="waitPlot" tuple="${tuple}" xprojection="WaitTime"/>
               <aida:tupleProjection var="wallPlot" tuple="${tuple}" xprojection="WallClock"/>
               <aida:plotter nx="2" ny="3" height="700">
                  <aida:style>
                     <aida:attribute name="statisticsBoxFontSize" value="8"/>
                     <aida:style type="data">
                        <aida:attribute name="showErrorBars" value="false"/>   
                     </aida:style>  
                  </aida:style>
                  <aida:region title="Wall Clock time (secs)">
                     <aida:plot var="${wallPlot}"/>                     
                  </aida:region>
                  <aida:region title="Pending time (mins)">
                     <aida:plot var="${waitPlot}"/>                     
                  </aida:region>
               </aida:plotter>
            
         </c:forEach>
		 Plots Done
   </body>
</html>
