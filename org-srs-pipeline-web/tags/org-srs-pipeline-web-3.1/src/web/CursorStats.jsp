<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="aida" uri="http://aida.freehep.org/jsp20" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib prefix="time" uri="http://srs.slac.stanford.edu/time" %>
<html>
   <head>
      <script language="JavaScript" src="http://glast-ground.slac.stanford.edu/Commons/scripts/FSdateSelect.jsp"></script>
      <link rel="stylesheet" href="http://glast-ground.slac.stanford.edu/Commons/css/FSdateSelect.css" type="text/css">        
      <title>Cursors VS Time Plots</title>    
   </head>
   <body>
      
      <c:set var="startTime" value="${param.startTime}" />
      <c:set var="endTime"   value="${param.endTime}"   />
      <c:catch>
         <fmt:parseNumber var="hours" value="${param.hours}" type="number" integerOnly="true"/>
      </c:catch>
      
      <c:set var="userSelectedStartTime" value="${!empty startTime && startTime != '-1' && startTime != sessionStartTime}" /> 
      <c:set var="userSelectedEndTime" value="${!empty endTime && endTime != '-1' && endTime != sessionEndTime}" /> 
      <c:set var="userSelectedHours" value="${!empty hours &&  !userSelectedStartTime && !userSelectedEndTime}" /> 
      
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
            <c:redirect url="CursorStats.jsp"/>
         </c:when>
         <c:when test="${userSelectedHours}">
            <c:set var ="sessionUseHours" value="true" scope="session"/>
            <c:set var ="sessionHours" value="${hours}" scope="session"/>
            <c:redirect url="CursorStats.jsp"/>
         </c:when>
         <c:when test="${empty sessionUseHours}">
            <c:set var ="sessionUseHours" value="true" scope="session"/>
            <c:set var ="sessionHours" value="8" scope="session"/>
            <c:set var ="sessionStartTime" value="None" scope="session"/>
            <c:set var ="sessionEndTime" value="None" scope="session"/>
         </c:when>
      </c:choose>
      <br>	
      
      <form name="DateForm">        
         <table class="filtertable">
            <tr>
               <td><strong>Start</strong> <time:dateTimePicker size="20" name="startTime" showtime="true" format="%b/%e/%y %H:%M" value="${sessionUseHours ? -1 : sessionStartTime}"  timezone="PST8PDT"/></td>
               <td><strong>End</strong> <time:dateTimePicker size="20" name="endTime"   showtime="true" format="%b/%e/%y %H:%M" value="${sessionUseHours ? -1 : sessionEndTime}" timezone="PST8PDT"/> </td>
               <td>or last <input name="hours" type="text" value="${sessionUseHours ? sessionHours : ''}" size="10"> </td>
            </tr> 
            
            <tr> <td> <input type="submit" value="Submit" name="filter"></td></tr> 
         </table>
      </form>   
      
      <jsp:useBean id="endTimeBean" class="java.util.Date" />
      <c:set var="endRange" value="${endTimeBean}"/>
      <jsp:useBean id="startTimeBean" class="java.util.Date" /> 
      <jsp:setProperty name="startTimeBean" property="time" value="${startTimeBean.time-sessionHours*60*60*1000}" /> 	  
      <c:set var="startRange" value="${startTimeBean}" />
      
      <c:if test="${ ! sessionUseHours && sessionEndTime != '-1' }">   		  
         <jsp:setProperty name="endRange" property="time" value="${sessionEndTime}" /> 	  
      </c:if>
      <c:if test="${ ! sessionUseHours && sessionStartTime != '-1' }">   		 
         <jsp:setProperty name="startRange" property="time" value="${sessionStartTime}" /> 	  
      </c:if>
      
      <c:set var="timerange" value="${(endRange.time-startRange.time)/(1000*60*60)}" />
      
      <c:set var="datatbl" value="processingstatisticsmin" />
      <c:set var="plotby" value="Minutes" />
      <c:set var="groupby" value="${pl:ceil(timerange/2)}" />     
      
      <P><span class="emphasis"> Starting Date: ${startRange}
            &nbsp; -&nbsp; &nbsp;   Ending   Date: ${endRange}<br>
      
      <aida:plotter height="600" width="1000"> 
         <aida:region  title="Cursors by session vs time">
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
            
            <sql:query var="sessions">
               select unique machine,sid, SUBSTR(machine, 1 ,INSTR(machine, '.', 1, 1)-1)||'-'||sid name from cursorstatisticsmin 
               where entered>=? and entered<=?
               <sql:dateParam value="${startRange}"/>
               <sql:dateParam value="${endRange}"/>
            </sql:query>
            
            <c:forEach items="${sessions.rows}" var="session"> 
               <sql:query var="data">
                  <c:if test="${groupby != 1}">
                     select min(entered) entered,max(cursors) cursors from ( 
                  </c:if> 
                  select entered, cursors from cursorstatisticsmin
                  where entered>=? and entered<=?
                  <sql:dateParam value="${startRange}"/>
                  <sql:dateParam value="${endRange}"/>
                  and machine=? and sid=?
                  <sql:param value="${session.machine}"/>
                  <sql:param value="${session.sid}"/>
                  <c:if test="${groupby != 1}">
                     ) group by  floor(rownum/?) order by entered
                     <sql:param value="${groupby}"/>
                  </c:if> 
               </sql:query>
               
               <c:if test="${fn:length(data.rows) > 0}"> 
                  
                  <aida:tuple var="tuple" query="${data}"/>        
                  <aida:datapointset var="current" title="${session.name}" tuple="${tuple}" yaxisColumn="CURSORS" xaxisColumn="ENTERED" />   
                  <aida:plot var="${current}"/>
                  
               </c:if>   
            </c:forEach>   
         </aida:region>	 
      </aida:plotter>  
   </body>
</html>

</body>
</html>
