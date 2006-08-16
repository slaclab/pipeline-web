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
	color: #0000FF;
	font-weight: bold;
}
-->
      </style>
</head>
   <body>  
   
 <c:set var="filter" value="${param.filter}"/>  
 <c:set var="selectedHours" value="${param.selectedHours}"/>    
 <c:if test="${empty filter}">
 	<c:set var="filter" value="Hours"/>
	<c:set var="timeIntervalSet" value="false"/>
	<c:set var="selectedHours" value=""/>
  </c:if>
 
<c:if test="${filter == 'Dates'}">
	<c:set var="dateStart" value="${empty param.dateStart ? 'None' : param.dateStart}"/>
	<c:set var="dateEnd" value="${empty param.dateEnd ? 'None' : param.dateEnd}"/>
		
	<c:if test="${dateStart != 'None'}">
		<c:set var="timeIntervalSet" value="true"/>
		<c:set var="selectedHours" value=""/>
	</c:if>
</c:if>		
<c:if test="${filter == 'Hours'}">
	<c:set var="dateStart" value="None" />
	<c:set var="dateEnd" value="None" />
	<c:if test="${! empty selectedHours}"> 
		<c:set var="selectedHours" value="${selectedHours}"/>
	</c:if> 
	<c:if test="${empty selectedHours}"> 
		<c:set var="selectedHours" value="6"/>
	</c:if>	
</c:if>				
<form name="DateForm">
	<table width="630" cellpadding="5" cellspacing="5" class="filterTable">
    <tr>
    <th width="180" bgcolor="#FFFFFF">Show Data from:</th>
    <td width="60">
    <script language="JavaScript">
                        FSfncWriteFieldHTML("DateForm","dateStart","${dateStart}",100,
                        "http://glast-ground.slac.stanford.edu/Commons/images/FSdateSelector/","US",false,true)
    </script>
    </td>
    <th width="20" bordercolor="#0000FF" bgcolor="#FFFFFF">To</th>
    <td width="60">
                <script language="JavaScript">
                        FSfncWriteFieldHTML("DateForm","dateEnd","${dateEnd}",100,
                        "http://glast-ground.slac.stanford.edu/Commons/images/FSdateSelector/","US",false,true)
                    </script>
     </td>
     <th width="95"><input type="submit" value="Dates" name="filter"></th>
     <th width="20">or</th>
      </tr>
      <tr>
      <th width="180">Last</th>
      <td width="60">
         <input type="text" value="${selectedHours}" name="selectedHours">
      </td>
      <th width="20">Hours</th>
      <th width="95"><input name="filter" type="submit" value="Hours"></th>
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
 <c:if test="${filter == 'Dates'}"> 
 	<P class="style1"> Starting Date Range: ${startRange} </P>
	<P class="style1"> Ending   Date Range: ${endRange} </P>
</c:if>
 <c:if test="${filter == 'Hours'}"> 	
    <P class="style1">  Last ${selectedHours} Hours <br>
 </c:if>
 <%--
	<p> <span class="style1"><span class="style2">Pipeline Job Averages since  <fmt:formatDate value="${starttime}" pattern="yyyy-MMM-dd HH:mm"/>. </span></span> </p>
 --%>
  
    <aida:plotter nx="1" ny="2" height="600"> 
   <c:set var= "n" value= "0"/>
   <c:forTokens items ="glastdata:glastgrp" delims=":" var="pkg">
    <c:if test="${filter == 'Hours'}"> 

 
   <sql:query var="data" dataSource="jdbc/pipeline" >
     select to_char(PS.entered,'dd-mon-yyyy HH24') as entered, 
	  ps.entered jobtime,
	  BG.BATCHGROUPNAME,
	  PS.prepared as prepared,
      PS.SUBMITTED as submitted,
      PS.RUNNING as running
      from processingstatistics PS , BATCHGROUP BG
      WHERE PS.BATCHGROUP_FK = BG.BATCHGROUP_PK
      and bg.batchgroupname = ?
      and entered >= ? 
      and entered <  ? 
    	   <sql:param value = "${pkg}"/>
   <sql:dateParam value = "${startRange}" />
   <sql:dateParam value = "${endRange}" />
	</sql:query>
 </c:if>

 <c:if test="${filter == 'Dates'}"> 
 
 <sql:query var="data" dataSource="jdbc/pipeline" >
     select to_char(PS.entered,'dd-mon-yyyy HH24') as entered, 
	  min(ps.entered) jobtime,
	  BG.BATCHGROUPNAME,
	  avg(PS.prepared) as prepared,
      avg(PS.SUBMITTED) as submitted,
      avg(PS.RUNNING) as running
      from processingstatistics PS , BATCHGROUP BG
      WHERE PS.BATCHGROUP_FK = BG.BATCHGROUP_PK
      and bg.batchgroupname = ?
      and entered >= ? 
      and entered <  ? 
	  GROUP BY to_char(PS.ENTERED,'dd-mon-yyyy HH24'), BG.BATCHGROUPNAME
	   <sql:param value = "${pkg}"/>
   <sql:dateParam value = "${startRange}" />
   <sql:dateParam value = "${endRange}" />
</sql:query>
   </c:if>
     
  
   <aida:tuple var="tuple" query="${data}" />        
      <aida:datapointset var="prepared" tuple="${tuple}" yaxisColumn="PREPARED" xaxisColumn="JOBTIME" />   
      <aida:datapointset var="submitted" tuple="${tuple}" yaxisColumn="SUBMITTED" xaxisColumn="JOBTIME" />   
      <aida:datapointset var="running" tuple="${tuple}" yaxisColumn="RUNNING" xaxisColumn="JOBTIME" />   
	  <aida:region title="${pkg}">
	    <aida:style>
	 	   <aida:attribute name="showStatisticsBox" value="false"/>		        
	        <aida:style type="xAxis">
			
		 	   <aida:attribute name="label" value="${filter}"/>
		 	   <aida:attribute name="type" value="date"/>
 	        </aida:style>
	        <aida:style type="data">
		 	   <aida:attribute name="connectDataPoints" value="true"/>
 	        </aida:style>
	    </aida:style>   

	    <aida:plot var="${prepared}">
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
    </c:forTokens>   
   </aida:plotter>
 
  
   </body>
</html>
