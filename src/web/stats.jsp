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

      <h1>Performance Plots</h1>

      <tab:tabs name="ProcessTabs" param="process">
         <tab:tab name="Summary" value="0" href="stats.jsp?task=${param.task}">
            <sql:query var="data">
               select RUNNAME, (tpi2.ended-tpi1.submitted)*24*60  "jobtime" from TASK 
               join run r on task_fk=task_pk
               join TPINSTANCE tpi1 on run_pk = tpi1.run_fk 
               and tpi1.taskprocess_fk = (select taskprocess_pk from taskprocess 
               where task_fk = task_pk and sequence=1)
               join TPINSTANCE tpi2 on run_pk = tpi2.run_fk 
               and tpi2.taskprocess_fk = (select taskprocess_pk from taskprocess 
               where task_fk = task_pk and sequence=(select max(sequence) 
               from taskprocess where task_fk = task_pk))
               where task_pk=?
               <sql:param value="${param.task}"/>
            </sql:query>  
            <aida:tuple var="tuple" query="${data}" />        
            <aida:tupleProjection var="jobtimeplot" tuple="${tuple}" xprojection="jobtime"/>
       
            <aida:plotter>
               <aida:region title="Job Time">
                  <aida:style>
                     <aida:attribute name="statisticsBoxFontSize" value="8"/>
                  </aida:style>
                  <aida:plot var="${jobtimeplot}" >
                     <aida:style>
                        <aida:attribute name="showErrorBars" value="false"/>   
                     </aida:style>                      
                  </aida:plot>
               </aida:region>
            </aida:plotter>
         </tab:tab>
         
         <sql:query var="processes">
            select TASKPROCESS_PK, TASKPROCESSNAME from TASKPROCESS where TASK_FK=? order by SEQUENCE
            <sql:param value="${param.task}"/>
         </sql:query> 
         <c:forEach var="row" items="${processes.rows}">
            <tab:tab name="${row.TASKPROCESSNAME}" href="stats.jsp?task=${param.task}" value="${row.TASKPROCESS_PK}">
               <sql:query var="data">
                  select (STARTED-SUBMITTED)*24*60 "WaitTime", (ENDED-STARTED)*24*60*60 "WallClock", MEMORYBYTES/1000 "Bytes", CPUSECONDS/1000 "Cpu",case when ended=started then null else CPUSECONDS/(ENDED-STARTED)/24/60/60/1000 end "Ratio"  
                  from TPINSTANCE i, PROCESSINGSTATUS s where TASKPROCESS_FK=? and PROCESSINGSTATUSNAME='END_SUCCESS'
                  and i.PROCESSINGSTATUS_FK=s.PROCESSINGSTATUS_PK  
                  <sql:param value="${row.TASKPROCESS_PK}"/>
               </sql:query>  
               <aida:tuple var="tuple" query="${data}" />        
               <aida:tupleProjection var="cpuPlot" tuple="${tuple}" xprojection="Cpu"/>
               <aida:tupleProjection var="memoryPlot" tuple="${tuple}" xprojection="Bytes"/>
               <aida:tupleProjection var="waitPlot" tuple="${tuple}" xprojection="WaitTime"/>
               <aida:tupleProjection var="wallPlot" tuple="${tuple}" xprojection="WallClock"/>
               <aida:tupleProjection var="ratioPlot" tuple="${tuple}" xprojection="Ratio"/>
               <aida:plotter nx="2" ny="3" height="700">
                  <aida:style>
                     <aida:attribute name="statisticsBoxFontSize" value="8"/>
                     <aida:style type="data">
                        <aida:attribute name="showErrorBars" value="false"/>   
                     </aida:style>  
                  </aida:style>
                  <aida:region title="CPU Used (secs)">
                     <aida:plot var="${cpuPlot}"/>
                  </aida:region>
                  <aida:region title="Memory Used (MB)">
                     <aida:plot var="${memoryPlot}"/>
                  </aida:region>
                  <aida:region title="Wall Clock time (secs)">
                     <aida:plot var="${wallPlot}"/>                     
                  </aida:region>
                  <aida:region title="Pending time (mins)">
                     <aida:plot var="${waitPlot}"/>                     
                  </aida:region>
                  <aida:region title="CPU/Wall Clock">
                     <aida:plot var="${ratioPlot}"/>                    
                  </aida:region>
               </aida:plotter>
            </tab:tab>
         </c:forEach>
      </tab:tabs>
   </body>
</html>
