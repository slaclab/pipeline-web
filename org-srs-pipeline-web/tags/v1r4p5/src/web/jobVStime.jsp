<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib prefix="aida" uri="http://aida.freehep.org/jsp20" %>

<html>
   <head>
      <title>Pipeline Jobs VS Time Plots </title>
      <style type="text/css">
<!--
.style1 {
	color: #FF0000;
	font-weight: bold;
}
.style2 {color: #0000FF}
-->
      </style>
</head>
   <body>  
    <c:set var="datespan" value="FEB 14 to now"/>
    <c:if test="${empty datespanX }">
       <c:set var="datespanX" value="7"/>
   </c:if>  
   <c:if test="${! empty param.datespanX }">
        <c:set var="datespanX" value="${param.datespanX}"/>    
   </c:if>    
	<% pageContext.setAttribute("now",System.currentTimeMillis()/1000.);  %>
    <p> <span class="style1"><span class="style2">Pipeline Job Averages since Feb 14 2006</span></span> </p>
    <aida:plotter nx="2" ny="6" height="1400"> 
   <c:set var= "n" value= "0"/>
	   <c:forTokens items ="glastdata:glastgrp" delims=":" var="pkg">
	  
	 
   <sql:query var="data">
         select TRUNC(PS.entered) as entered, BG.BATCHGROUPNAME,avg(PS.prepared) as prepared,
avg(PS.SUBMITTED) as submitted,
avg(PS.RUNNING) as running
 from processingstatistics PS , BATCHGROUP BG
WHERE PS.BATCHGROUP_FK = BG.BATCHGROUP_PK
and bg.batchgroupname = ? 
AND trunc(ENTERED) >='14-feb-2006' 
GROUP BY TRUNC(PS.ENTERED), BG.BATCHGROUPNAME
		  <sql:param value = "${pkg}"/>
   </sql:query>
    
     
  
   <aida:tuple var="tuple" query="${data}" />        
      <aida:datapointset var="prepared" tuple="${tuple}" yaxisColumn="PREPARED" xaxisColumn="ENTERED" />   
      <aida:datapointset var="submitted" tuple="${tuple}" yaxisColumn="SUBMITTED" xaxisColumn="ENTERED" />   
      <aida:datapointset var="running" tuple="${tuple}" yaxisColumn="RUNNING" xaxisColumn="ENTERED" />   
	  <aida:region title="${pkg} from ${datespan}  ">
	    <aida:style>
	 	   <aida:attribute name="showStatisticsBox" value="false"/>		        
	        <aida:style type="xAxis">
		 	   <aida:attribute name="label" value="DAYS"/>
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
