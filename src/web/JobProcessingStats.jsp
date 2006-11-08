<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="aida" uri="http://aida.freehep.org/jsp20" %>


<html>
   <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script language="JavaScript" src="http://glast-ground.slac.stanford.edu/Commons/scripts/FSdateSelect.jsp"></script>
        <link rel="stylesheet" href="http://glast-ground.slac.stanford.edu/Commons/css/FSdateSelect.css" type="text/css">        
      <title>Pipeline Jobs VS Time Plots </title>    
	  <link href="http://glast-ground.slac.stanford.edu/Commons/css/glastCommons.jsp" rel="stylesheet" type="text/css">  
      <style type="text/css">
<!--
.style6 {color: #CC0000}
.style8 {color: #CC0000; font-weight: bold; }
-->
      </style>
</head>
<body>
<c:set var="datatbl" value="processingstatisticshour" scope="session"/>
 
 <c:set var="startTime" value="${param.startTime}" />
<c:set var="endTime"   value="${param.endTime}"   />
<c:set var="hours" value="${param.hours}" /> 
<c:set var="taskName" value="${param.taskName}" /> 
 
 
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
	   <c:redirect url="usageplots.jsp"/>
    </c:when>
    <c:when test="${userSelectedHours}">
       <c:set var ="sessionUseHours" value="true" scope="session"/>
	   <c:set var ="sessionHours" value="${hours}" scope="session"/>
	   <c:redirect url="usageplots.jsp"/>
    </c:when>
    <c:when test="${empty sessionUseHours}">
      <c:set var ="sessionUseHours" value="true" scope="session"/>
	  <c:set var ="sessionHours" value="8" scope="session"/>
	  <c:set var ="sessionStartTime" value="None" scope="session"/>
	  <c:set var ="sessionEndTime" value="None" scope="session"/>
    </c:when>
</c:choose>

  <form name="DateForm">        
	<table width="709" cellpadding="5" cellspacing="5" bgcolor="#FFCC66" class="filterTable">
    <tr bgcolor="#FFCC66">
    <td bgcolor="#FFCC66">Show Data from: </td>
    <td>
    <script language="JavaScript">
    FSfncWriteFieldHTML("DateForm","startTime","${sessionUseHours ? 'None' : sessionStartTime}",100,
    "http://glast-ground.slac.stanford.edu/Commons/images/FSdateSelector/","US",false,true)
    </script>    </td>
    <td width="55">To</td>
    <td colspan="2">
    <script language="JavaScript">
    FSfncWriteFieldHTML("DateForm","endTime","${sessionUseHours ? 'None' : sessionEndTime}",100,
    "http://glast-ground.slac.stanford.edu/Commons/images/FSdateSelector/","US",false,true)
    </script>    </td>
    <td width="43">Or </td>
    <td width="252"> Last
    <input name="hours" type="text" value="${sessionUseHours ? sessionHours : ''}" size="6">Hours	</td>
	</tr>
    <tr>               
	<td width="107" bgcolor="#FFCC66">Display Task: </td>
	<td width="97" bgcolor="#FFCC66"><select name="taskName">
<%-- Get task names to display in form from oracle query --%>
    <sql:query var="taskdata" dataSource="jdbc/pipeline-ii" >
		select  distinct taskname
   			from ${datatbl}  
			order by taskname  
   	</sql:query>
   	<option value="ALL">All Tasks</option>
   	<c:forEach items="${taskdata.rows}" var="taskrow"> 
		<option value="${taskrow.taskname}" ${taskrow.taskname == sessionTaskName ? 'selected' : ''}>${taskrow.taskname}</option>
	</c:forEach>
	</select></td>
	<td colspan="2" bgcolor="#FFCC66"><input type="submit" value="Submit" name="filter"></td>
	</tr>
    </table>
</form>
   
	<jsp:useBean id="endTimeBean" class="java.util.Date" />
	<c:set var="endRange" value="${endTimeBean}"/>
    <jsp:useBean id="startTimeBean" class="java.util.Date" /> 
    <jsp:setProperty name="startTimeBean" property="time" value="${startTimeBean.time -sessionHours*60*60*1000}" /> 
    <c:set var="startRange" value="${startTimeBean}" />
		
	<c:if test="${ ! sessionUseHours && sessionEndTime != 'None' }">   		  
		   <fmt:parseDate value="${sessionEndTime}" var="endRange" pattern="MM/dd/yyyy" />
	</c:if>
	<c:if test="${ ! sessionUseHours && sessionStartTime != 'None' }">   		 
		     <fmt:parseDate value="${sessionStartTime}" var="startRange" pattern="MM/dd/yyyy" />
	</c:if>
   	<c:set var="timerange" value="${(endRange.time-startRange.time)/(1000*60*60)}" />
   	<c:if test="${timerange <='3'}"> 
    	<c:set var="datatbl" value="processingstatisticsmin" />
       	<c:set var="plotby" value="Minutes" />
   	</c:if>
    <c:if test="${timerange >='4' && timerange <= 48 }"> 
       	<c:set var="datatbl" value="processingstatisticshour"/>
       	<c:set var="plotby" value="Hours" />
   	</c:if>
   	<c:if test="${timerange >='48' && timerange <= 168}"> 
      	<c:set var="datatbl" value="processingstatisticsday"/>
      	<c:set var="plotby" value="Days"/>
   	</c:if>
   	<c:if test="${timerange >='168' && timerange <= 672}"> 
      	<c:set var="datatbl" value="processingstatisticsweek"/>
      	<c:set var="plotby" value="Weeks"/>
   	</c:if>
   	<c:if test="${timerange >='672'}"> 
     	<c:set var="datatbl" value="processingstatisticsmonth"/>
     	<c:set var="plotby" value="Months"/>
   	</c:if>
<%--<p> <span class="style1"><span class="style2">Pipeline Job Averages since  <fmt:formatDate value="${starttime}" pattern="yyyy-MMM-dd HH:mm"/>. </span></span> </p>--%>
 	
	<P class="style1"><span class="style4"> Starting Date: ${startRange}
	 &nbsp; -&nbsp; &nbsp;   Ending   Date: ${endRange}</span></P> 	
	<%-- <c:if test="${sessionTaskName = 'ALL'}"> 
	 	<c:set var="taskname" value="ALL"/>
	 </c:if> --%>
	 <P class="style1">                 
  
   	<c:set var= "n" value= "0"/>
   	<sql:query var="data" dataSource="jdbc/pipeline-ii" >
		select  ready as ready, submitted as submitted, running as running, 
      		to_date(to_char(entered,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS') as entered 
      		from ${datatbl} 
	  		where entered >= ? AND entered <= ?
			<sql:dateParam value="${startRange}"/>
			<sql:dateParam value="${endRange}"/>
			<c:if test="${sessionTaskName != 'ALL'}">
	  			and taskname = ?
				<sql:param value="${sessionTaskName}"/>
			   </c:if>  
  	</sql:query>
<br><span class="style8">Number of records found:  ${fn:length(data.rows)} </span><br>
<c:if test="${fn:length(data.rows) >0}">
  	<aida:plotter nx="1" ny="2" height="600"> 

   <aida:tuple var="tuple" query="${data}" scope="session"/>        
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
  <c:if test="${fn:length(data.rows) ==0}">
  
 <br> 
 <span class="style6"><strong>There are no records for the data requested</strong></span>.
  
  </c:if>
</body>
</html>

  
  
</body>
</html>
