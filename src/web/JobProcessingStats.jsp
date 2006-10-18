<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
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
.style1 {
	color: #000000;
	font-weight: bold;
}
.style4 {color: #000000}
-->
      </style>
</head>
   <body>  
<%-- set the form calendar dates to "none" (no dates selected) and 
initial datatable (datatbl) to processingstatisticshour   
			

<P class="style1"> A- dateStart set to: ${param.dateStart}</P>
<P class="style1"> B- selectedHours set to: ${param.selectedHours}</P>
--%>	


	<c:set var="taskname" value="${param.taskname}" scope="session"/>
	<c:set var="displaytask" value="${taskname}" scope="session"/>	
	<c:set var="datatbl" value="processingstatisticshour" scope="session"/>
	
	
<%-- set default time interval  & time interval if no startdate selected & datatable to 
processingstatisticshour
 
<P class="style1"> -1- Hours set  ${selectedHours}</P>
 	<P class="style1"> -1- Starting Date Range: ${dateStart}</P>
--%>		
	
	<c:choose>
		<c:when test="${ param.dateStart != 'None' && (( param.dateStart != dateStart) || (param.dateEnd != 'None' && param.dateEnd != dateEnd))}">
			<c:set var="selectedHours" value="" scope="session"/>
		    <c:set var="dateStart" value="${param.dateStart}" scope="session"/>
    		<c:set var="dateEnd" value="${param.dateEnd}"  scope="session"/>
		</c:when>
		<c:otherwise>
	    	<c:set var="dateStart" value="None"  scope="session"/>
		    <c:set var="dateEnd" value="None"  scope="session"/>
			<c:set var="selectedHours" value="${ ! empty param.selectedHours ? param.selectedHours : '6'}" scope="session"/>		
		</c:otherwise>
	</c:choose> 
	
<%--  Set up the form --%>		

	<form name="DateForm">        
	<table width="709" cellpadding="5" cellspacing="5" bgcolor="#FFCC66" class="filterTable">
    <tr bgcolor="#FFCC66">
    <td bgcolor="#FFCC66">Show Data from: </td>
    <td>
    <script language="JavaScript">
    FSfncWriteFieldHTML("DateForm","dateStart","${dateStart}",100,
    "http://glast-ground.slac.stanford.edu/Commons/images/FSdateSelector/","US",false,true)
    </script>    </td>
    <td width="55">To</td>
    <td colspan="2">
    <script language="JavaScript">
    FSfncWriteFieldHTML("DateForm","dateEnd","${dateEnd}",100,
    "http://glast-ground.slac.stanford.edu/Commons/images/FSdateSelector/","US",false,true)
    </script>    </td>
    <td width="43">Or </td>
    <td width="252"> Last
    <input name="selectedHours" type="text" value="${selectedHours}" size="6">Hours	</td>
	</tr>
    <tr>               
	<td width="107" bgcolor="#FFCC66">Display Task: </td>
	<td width="97" bgcolor="#FFCC66"><select name="taskname">
<%-- Get task names to display in form from oracle query --%>
    <sql:query var="taskdata">
		select  distinct taskname
   			from ${datatbl}  
			order by taskname  
   	</sql:query>
   	<option value="ALL">All Tasks</option>
   	<c:forEach items="${taskdata.rowsByIndex}" var="taskrow"> <c:forEach items="${taskrow}" var="taskname">
		<option value="${taskname}">${taskname}</option>
	</c:forEach> </c:forEach>
	</select></td>
	<td colspan="2" bgcolor="#FFCC66"><input type="submit" value="Submit" name="filter"></td>
	</tr>
    </table>
   </form>
		
   <%-- <P>Data date range:  ${dateStart} ${dateEnd}</P> --%>
	
	<jsp:useBean id="endtime" class="java.util.Date" />
	<c:set var="endRange" value="${endtime}"/>
    <jsp:useBean id="starttime" class="java.util.Date" /> 
    <jsp:setProperty name="starttime" property="time" value="${starttime.time -selectedHours*60*60*1000}" /> 
    <c:set var="startRange" value="${starttime}" />

	<c:if test="${dateStart!='None'}"> 
	   <fmt:parseDate value="${dateStart}" var="startRange" pattern="MM/dd/yyyy" />
	</c:if>
	<c:if test="${dateEnd!='None'}">
	   <fmt:parseDate value="${dateEnd}" var="endRange" pattern="MM/dd/yyyy" />
	</c:if>
	<%--
	<br>
	<b>Start Range: ${startRange} ${startRange.time}</b>
	<b>End Range: ${endRange} ${endRange.time}</b>
	<b>Delta Range: ${(endRange.time-startRange.time)/(1000*60*60)}</b>
	<br>
	--%>
<%-- determine what the time range is for the query --%>
   	<c:set var="timerange" value="${(endRange.time-startRange.time)/(1000*60*60)}" scope="session"/>
<%-- determine what statistics table to use based upon length of the timespan & set plot labels --%>   
   	<c:if test="${timerange <='3'}"> 
    	<c:set var="datatbl" value="processingstatisticsmin" scope="session"/>
       	<c:set var="plotby" value="Minutes" scope="session"/>
   	</c:if>
    <c:if test="${timerange >='4' && timerange <= 48 }"> 
       	<c:set var="datatbl" value="processingstatisticshour" scope="session"/>
       	<c:set var="plotby" value="Hours" scope="session"/>
   	</c:if>
   	<c:if test="${timerange >='48' && timerange <= 168}"> 
      	<c:set var="datatbl" value="processingstatisticsday" scope="session"/>
      	<c:set var="plotby" value="Days" scope="session"/>
   	</c:if>
   	<c:if test="${timerange >='168' && timerange <= 672}"> 
      	<c:set var="datatbl" value="processingstatisticsweek" scope="session"/>
      	<c:set var="plotby" value="Weeks" scope="session"/>
   	</c:if>
   	<c:if test="${timerange >='672'}"> 
     	<c:set var="datatbl" value="processingstatisticsmonth" scope="session"/>
     	<c:set var="plotby" value="Months" scope="session"/>
   	</c:if>
<%--<p> <span class="style1"><span class="style2">Pipeline Job Averages since  <fmt:formatDate value="${starttime}" pattern="yyyy-MMM-dd HH:mm"/>. </span></span> </p>--%>
 	
	<P class="style1"><span class="style4"> Starting Date: ${startRange}
	 &nbsp; -&nbsp; &nbsp;   Ending   Date: ${endRange}</span></P> 	
	 <c:if test="${empty taskname}"> 
	 	<c:set var="taskname" value="ALL" scope="session"/>
	 </c:if>
	 <P class="style1">                 
	
   	<aida:plotter nx="1" ny="2" height="600"> 
   	<c:set var= "n" value= "0"/>
   	<sql:query var="data">
		select  ready as ready, submitted as submitted, running as running, 
      		to_date(to_char(entered,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS') as entered 
      		from ${datatbl} 
	  		where entered >= ? AND entered <= ?
			<sql:dateParam value="${startRange}"/>
			<sql:dateParam value="${endRange}"/>
			<c:if test="${taskname != 'ALL'}">
	  			and taskname = ?
				<sql:param value="${taskname}"/>
			</c:if>  
  	</sql:query>
	<%--  
    
   <c:forEach items="${data.rowsByIndex}" var="row">
	  <c:forEach items="${row}" var="cell">
	    ${cell}  - 
	  </c:forEach>
	 <br>
  </c:forEach>
  --%>
   <aida:tuple var="tuple" query="${data}" scope="session"/>        
      <aida:datapointset var="ready" tuple="${tuple}" yaxisColumn="READY" xaxisColumn="ENTERED" />   
      <aida:datapointset var="submitted" tuple="${tuple}" yaxisColumn="SUBMITTED" xaxisColumn="ENTERED" />   
      <aida:datapointset var="running" tuple="${tuple}" yaxisColumn="RUNNING" xaxisColumn="ENTERED" />   
	  <aida:region title= "${taskname}" >
	    <aida:style>
	 	   <aida:attribute name="showStatisticsBox" value="false"/>		        
	        <aida:style type="xAxis">
		 	   <aida:attribute name="label" value="${plotby}"/>
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
 
  <c:set var="selectedHours" value="" scope="session"/>
   </body>
</html>
