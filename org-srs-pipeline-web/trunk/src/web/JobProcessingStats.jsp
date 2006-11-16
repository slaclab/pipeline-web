<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="aida" uri="http://aida.freehep.org/jsp20" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>


<html>
   <head>
      <script language="JavaScript" src="http://glast-ground.slac.stanford.edu/Commons/scripts/FSdateSelect.jsp"></script>
      <link rel="stylesheet" href="http://glast-ground.slac.stanford.edu/Commons/css/FSdateSelect.css" type="text/css">        
      <title>Pipeline Jobs VS Time Plots </title>    
   </head>
   <body>
      <c:set var="datatbl" value="processingstatisticshour" scope="session"/>
 
      <c:set var="startTime" value="${param.startTime}" />
      <c:set var="endTime"   value="${param.endTime}"   />
      <c:set var="taskName" value="${param.taskName}" /> 
      <c:catch>
         <fmt:parseNumber var="hours" value="${param.hours}" type="number" integerOnly="true"/>
      </c:catch>
 
      <c:set var="userSelectedStartTime" value="${!empty startTime && startTime != 'None' && startTime != sessionStartTime}" /> 
      <c:set var="userSelectedEndTime" value="${!empty endTime && endTime != 'None' && endTime != sessionEndTime}" /> 
      <c:set var="userSelectedHours" value="${!empty hours &&  !userSelectedStartTime && !userSelectedEndTime}" /> 
      <c:set var="userSelectedTaskName" value="${!empty taskName}" /> 
 
      <c:choose>
         <c:when test="${userSelectedTaskName}">
            <c:set var ="sessionTaskName" value="${taskName}" scope="session"/>
         </c:when>
         <c:when test="${!userSelectedTaskName && empty sessionTaskName}"> 
            <c:set var ="sessionTaskName" value="ALL" scope="session"/>
         </c:when>
      </c:choose> 

      <c:choose>
         <c:when test="${userSelectedStartTime || userSelectedEndTime}">
            <c:set var ="sessionUseHours" value="false" scope="session"/>
            <c:set var ="sessionStartTime" value="${startTime}" scope="session"/>
            <c:set var ="sessionEndTime" value="${endTime}" scope="session"/>
            <c:redirect url="JobProcessingStats.jsp"/>
         </c:when>
         <c:when test="${userSelectedHours}">
            <c:set var ="sessionUseHours" value="true" scope="session"/>
            <c:set var ="sessionHours" value="${hours}" scope="session"/>
            <c:redirect url="JobProcessingStats.jsp"/>
         </c:when>
         <c:when test="${empty sessionUseHours}">
            <c:set var ="sessionUseHours" value="true" scope="session"/>
            <c:set var ="sessionHours" value="8" scope="session"/>
            <c:set var ="sessionStartTime" value="None" scope="session"/>
            <c:set var ="sessionEndTime" value="None" scope="session"/>
         </c:when>
      </c:choose>

      <form name="DateForm">        
         <table class="filtertable">
            <tr>
               <td>Show data from</td>
               <td>
               <script language="JavaScript">
                  FSfncWriteFieldHTML("DateForm","startTime","${sessionUseHours ? 'None' : sessionStartTime}",100,
                  "http://glast-ground.slac.stanford.edu/Commons/images/FSdateSelector/","US",false,true)
               </script></td>
               <td>to</td>
               <td>
               <script language="JavaScript">
                  FSfncWriteFieldHTML("DateForm","endTime","${sessionUseHours ? 'None' : sessionEndTime}",100,
                  "http://glast-ground.slac.stanford.edu/Commons/images/FSdateSelector/","US",false,true)
               </script></td>
               <td>or last <input name="hours" type="text" value="${sessionUseHours ? sessionHours : ''}" size="6"> hours</td>
            </tr>
            <tr>               
               <td colspan="5">Task: 
               <select name="taskName">
                  <%-- Get task names to display in form from oracle query --%>
                  <sql:query var="taskdata">
                     select  distinct taskname
                     from ${datatbl}  
                     order by taskname  
                  </sql:query>
                  <option value="ALL">All Tasks</option>
                  <c:forEach items="${taskdata.rows}" var="taskrow"> 
                     <option value="${taskrow.taskname}" ${taskrow.taskname == sessionTaskName ? 'selected' : ''}>${taskrow.taskname}</option>
                  </c:forEach>
               </select>
               <input type="submit" value="Submit" name="filter"></td>
            </tr>
         </table>
      </form>
   
      <jsp:useBean id="endTimeBean" class="java.util.Date" />
      <c:set var="endRange" value="${endTimeBean}"/>
      <jsp:useBean id="startTimeBean" class="java.util.Date" /> 
      <jsp:setProperty name="startTimeBean" property="time" value="${startTimeBean.time-sessionHours*60*60*1000}" /> 
      <c:set var="startRange" value="${startTimeBean}" />
		
      <c:if test="${ ! sessionUseHours && sessionEndTime != 'None' }">   		  
         <fmt:parseDate value="${sessionEndTime}" var="endRange" pattern="MM/dd/yyyy" />
      </c:if>
      <c:if test="${ ! sessionUseHours && sessionStartTime != 'None' }">   		 
         <fmt:parseDate value="${sessionStartTime}" var="startRange" pattern="MM/dd/yyyy" />
      </c:if>
      <c:set var="timerange" value="${(endRange.time-startRange.time)/(1000*60*60)}" />
      <c:choose>
         <c:when test="${timerange <= 10}"> 
            <c:set var="datatbl" value="processingstatisticsmin" />
            <c:set var="plotby" value="Minutes" />
         </c:when>
         <c:when test="${timerange <= 48 }"> 
            <c:set var="datatbl" value="processingstatisticshour"/>
            <c:set var="plotby" value="Hours" />
         </c:when>
         <c:when test="${timerange <= 168}"> 
            <c:set var="datatbl" value="processingstatisticsday"/>
            <c:set var="plotby" value="Days"/>
         </c:when>
         <c:when test="${timerange <= 672}"> 
            <c:set var="datatbl" value="processingstatisticsweek"/>
            <c:set var="plotby" value="Weeks"/>
         </c:when>
         <c:otherwise> 
            <c:set var="datatbl" value="processingstatisticsmonth"/>
            <c:set var="plotby" value="Months"/>
         </c:otherwise>
      </c:choose>        
  
      <sql:query var="data">
         select  sum(ready) ready, sum(running) running, sum(submitted) submitted,entered
         from ${datatbl} 
         where entered>=? and entered<=?
         <sql:dateParam value="${startRange}"/>
         <sql:dateParam value="${endRange}"/>
         <c:if test="${sessionTaskName != 'ALL'}">
            and taskname = ?
            <sql:param value="${sessionTaskName}"/>
         </c:if>  
         group by entered
      </sql:query>

      <P><span class="emphasis"> Starting Date: ${startRange}
      &nbsp; -&nbsp; &nbsp;   Ending   Date: ${endRange}<br>
      ${fn:length(data.rows)} records found from table ${plotby}</span></P> 
      
      <c:if test="${fn:length(data.rows) > 0}">

         <aida:plotter height="400"> 

            <aida:tuple var="tuple" query="${data}"/>        
            <aida:datapointset var="ready" tuple="${tuple}" yaxisColumn="READY" xaxisColumn="ENTERED" />   
            <aida:datapointset var="submitted" tuple="${tuple}" yaxisColumn="SUBMITTED" xaxisColumn="ENTERED" />   
            <aida:datapointset var="running" tuple="${tuple}" yaxisColumn="RUNNING" xaxisColumn="ENTERED" />   
            <aida:region title= "${sessionTaskName}" >
               <aida:style>
                  <aida:attribute name="showStatisticsBox" value="false"/>		        
                  <aida:style type="xAxis">
                     <aida:attribute name="label" value=""/>
                     <aida:attribute name="type" value="date"/>
                  </aida:style>
                  <aida:style type="data">
                     <aida:attribute name="connectDataPoints" value="true"/>
                  </aida:style>
               </aida:style>   

               <aida:plot var="${ready}">
                  <aida:style>        
                     <aida:attribute name="lineBetweenPointsColor" value="blue"/>
                     <aida:style type="marker">
                        <aida:attribute name="color" value="blue"/>
                        <aida:attribute name="shape" value="box"/>
                     </aida:style>
                  </aida:style>
               </aida:plot>
               <aida:plot var="${submitted}">
                  <aida:style>        
                     <aida:attribute name="lineBetweenPointsColor" value="red"/>
                     <aida:style type="marker">
                        <aida:attribute name="color" value="red"/>
                        <aida:attribute name="shape" value="triangle"/>
                     </aida:style>
                  </aida:style>
               </aida:plot>
               <aida:plot var="${running}">
                  <aida:style>        
                     <aida:attribute name="lineBetweenPointsColor" value="green"/>
                     <aida:style type="marker">
                        <aida:attribute name="color" value="green"/>
                        <aida:attribute name="shape" value="dot"/>
                     </aida:style>
                  </aida:style>
               </aida:plot>
            </aida:region>	 
         </aida:plotter>

      </c:if>
      <c:if test="${fn:length(data.rows) == 0}">
  
         <br> 
         <span class="emphasis"><strong>There are no records for the data requested</strong></span>.
  
      </c:if>
   </body>
</html>

  
  
</body>
</html>
