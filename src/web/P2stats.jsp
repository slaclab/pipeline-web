<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="aida" uri="http://aida.freehep.org/jsp20" %>
<%@taglib prefix="tab" uri="http://java.freehep.org/tabs-taglib" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="aida" uri="http://aida.freehep.org/jsp20" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.*,javax.servlet.jsp.jstl.sql.*,hep.aida.*"%>
<%@taglib prefix="utils" uri="http://glast-ground.slac.stanford.edu/utils" %>
<html>
    <head>
        <title>Performance Plots</title>
    </head>
    <body>
        <c:set var="debug" value="0"/> 
        <c:set var="startTime" value="${param.startTime}" />
        <c:set var="endTime"   value="${param.endTime}" /> 
        <c:set var="ndays" value="${param.ndays}"/> 
        <c:set var="userSelectedStartTime" value="${!empty startTime && startTime != '-1' && startTime != sessionStartTime && !empty param.filter}" /> 
        <c:set var="userSelectedEndTime" value="${!empty endTime && endTime != '-1' && endTime != sessionEndTime && !empty param.filter}" /> 
        <c:set var="userSelectedNdays" value="${!empty ndays && !userSelectedStartTime && !userSelectedEndTime && !empty param.filter}"/> 
        <c:set var="pref_ndays" value="${preferences.defaultPerfPlotDays}"/> 
        <c:set var="userSelectedTask" value="${param.task}" scope="session" />  
        <c:set var="userSelectedNdays" value="${!empty ndays && !userSelectedStartTime && !userSelectedEndTime && !empty param.filter}"/>
        <%--
        <c:catch>
            <fmt:parseNumber var="ndays" value="${param.ndays}" type="number" integerOnly="true"/>
        </c:catch>  --%>
       
        <c:choose>
            <c:when test="${userSelectedStartTime || userSelectedEndTime}">
                <c:set var="sessionUseNdays" value="false" scope="session"/> 
                <c:set var="sessionNdays" value="" scope="session"/> 
                <c:set var="sessionStartTime" value="${startTime}" scope="session"/> 
                <c:set var="sessionEndTime" value="${endTime}" scope="session"/> 
            </c:when>
            <c:when test="${userSelectedNdays}">
                <c:set var="sessionUseNdays" value="true" scope="session"/> 
                <c:set var="sessionNdays" value="${!empty ndays ? ndays : pref_ndays}" scope="session"/> 
                <c:set var="sessionStartTime" value="None" scope="session"/> 
                <c:set var="sessionEndTime" value="None" scope="session"/> 
            </c:when>
            
            <c:when test="${empty sessionUseNdays}">
                <c:set var ="sessionUseNdays" value="true" scope="session"/>
                <c:set var ="sessionNdays" value="${pref_ndays}" scope="session"/>
                <c:set var ="sessionStartTime" value="None" scope="session"/>
                <c:set var ="sessionEndTime" value="None" scope="session"/>
            </c:when>
        </c:choose>
        
        <c:if test="${!empty param.reset}">
            <c:set var="startTime" value="-1"/>
            <c:set var="endTime" value="-1"/> 
            <c:set var="startTimeDate" value="None"/> 
            <c:set var="endTimeDate" value="None"/> 
            <c:set var ="sessionStartTime" value="None"/>
            <c:set var ="sessionEndTime" value="None"/> 
            <c:set var="sessionUseNdays" value="true"/> 
            <c:set var="sessionNdays" value="${pref_ndays}"/>
            <c:set var="userSelectedNdays" value="false"/> 
        </c:if>
        
        <c:if test="${debug == 1}"> 
            <h3>
                userselectedNdays: ${userSelectedNdays}<br>
                userselectedStartTime: ${userSelectedStartTime}<br>
                userselectedEndTime: ${userSelectedEndTime}<p>
                sessionStartTime: ${sessionStartTime}<br>
                sessionEndTime: ${sessionEndTime}<br>
                sessionNdays: ${sessionNdays}<br>
                sessionUseNdays: ${sessionUseNdays}<p>
                startTime: ${startTime}<br>
                endTime: ${endTime}<br>
                ndays: ${param.ndays}<br>
                pref_ndays: ${pref_ndays}<p>
                param.startTime=${param.startTime}<br>
                param.endTime=${param.endTime}<br>
                param.filter=${param.filter}<br>
                param.reset="${param.reset}"<br>
                userselectedTask: ${userSelectedTask}<br>
            </h3>
        </c:if>
        
        <form name="DateForm">        
            <table bordercolor="#000000" bgcolor="#FFCC66" class="filtertable">
                <tr bordercolor="#000000" bgcolor="#FFCC66">               
                    <td colspan="5"><strong>Select Timespan</strong>:                 
                </tr> 
                <tr bordercolor="#000000" bgcolor="#FFCC66">
                    <td><strong>Start</strong> <utils:dateTimePicker size="20" name="startTime" showtime="true" format="%b/%e/%y %H:%M" value="${sessionUseNdays ? -1 : sessionStartTime}"  timezone="PST8PDT"/></td> 
                    <td><strong>End</strong> <utils:dateTimePicker size="20" name="endTime"   showtime="true" format="%b/%e/%y %H:%M" value="${sessionUseNdays ? -1 : sessionEndTime}" timezone="PST8PDT"/></td>
                    <td>or last N days <input name="ndays" type="text" value="${sessionUseNdays ? sessionNdays : ''}" size="5"></td>
                </tr> 
                <input type="hidden" name="task" value="${task}"/>
                <tr bordercolor="#000000" bgcolor="#FFCC66"> <td> <input type="submit" value="Submit" name="filter">
                <input type="submit" value="Reset" name="reset"></td>
                </tr> 
        </table></form>   
        
        
        <jsp:useBean id="endTimeBean" class="java.util.Date" />
        <jsp:setProperty name="endTimeBean" property="time" value="${endTime}" /> 	  
        <c:set var="endRange" value="${endTimeBean}"/>
        <jsp:useBean id="startTimeBean" class="java.util.Date" /> 
        <jsp:setProperty name="startTimeBean" property="time" value="${startTime}" /> 	  
        <c:set var="startRange" value="${startTimeBean}" />                
        
        
        <%
        String[] plotColors = new String[] {"red","blue","green","black","orange","purple","brown","gray","pink"};
        session.setAttribute("plotColors",plotColors);
        session.setAttribute("numberPlotColors",plotColors.length);
        %>
        <%-- see if all or only one plot is to be displayed and 
         then set plotter ny & nx values accordingly --%>
         
        <c:if test = "${empty param.selectedPlot}"> 
            <c:set var ="selectedPlot" value="ALL"/>
            <c:set var="plotnumX" value="2" /> 
            <c:set var="plotnumY" value="4"/>
            <c:set var="plotheight" value="800"/>
            <c:set var="plotwidth" value="800"/>
        </c:if>
        <c:if test = "${!empty param.selectedPlot}"> 
            <c:set var ="selectedPlot" value="${param.selectedPlot}"/>
            <c:set var="plotnumX" value="4" /> 
            <c:set var="plotnumY" value="1" />
            <c:set var="plotheight" value="600"/>
            <c:set var="plotwidth" value="1000"/>
        </c:if>
        
        <c:set var="lineSize" value="2"/>
        <sql:query var="datacheck">
            select createdate,startdate,enddate
            from stream where task=? 
            and streamstatus='SUCCESS' 
            and PII.GetStreamIsLatestPath(Stream)=1
            <sql:param value="${task}"/>
            <c:if test="${ startTime > 0 && !userSelectedNdays}">
                and startdate >= ?
                <sql:dateParam value="${startRange}"/>
            </c:if>
            <c:if test="${ endTime > 0 && !userSelectedNdays}">
                and enddate <= ?
                <sql:dateParam value="${endRange}"/>
            </c:if>
            <c:if test="${userSelectedNdays && (!userSelectedStartTime || !userSelectedEndTime)}"> 
                and STARTDATE >= ? and ENDDATE <= ?
                <jsp:useBean id="maxUsedDays" class="java.util.Date" />
                <jsp:useBean id="minUsedDays" class="java.util.Date" />
                <jsp:setProperty name="minUsedDays" property="time" value="${maxUsedDays.time - ndays*24*60*60*1000}" />       
                <sql:dateParam value="${minUsedDays}" type="timestamp"/> 
                <sql:dateParam value="${maxUsedDays}" type="timestamp"/> 
            </c:if>  
        </sql:query>
        
        <sql:query var="processes">
            select p.PROCESS,p.PROCESSNAME,p.PROCESSTYPE 
            from PROCESS p   
            where p.TASK=?
            <sql:param value="${task}"/>
            order by p.process               
        </sql:query> 		
        
        <c:if test="${fn:length(datacheck.rows) <= 0}">       
            <br>    <strong> There are no successful processes to plot for this task </strong><br>
        </c:if>      
        <c:if test="${fn:length(datacheck.rows) > 0}"> 
            <tab:tabs name="ProcessTabs" param="process">                
                <tab:tab name="Summary" href="P2stats.jsp?task=${task}&startTime=${startTime}&endTime=${endTime}" value="0">                    
                    <sql:query var="data">
                        select createdate,startdate,enddate, 
                        (GLAST_UTIL.GetTimeFromEpochMS(enddate)-GLAST_UTIL.GetTimeFromEpochMS(startdate))/(1000*60) as elapsedTime
                        , (GLAST_UTIL.GetTimeFromEpochMS(startdate)-GLAST_UTIL.GetTimeFromEpochMS(createdate))/(1000*60) as waitTime
                        from stream where task=? 
                        <sql:param value="${task}"/>
                        and streamstatus='SUCCESS' 
                        <c:if test="${ startTime > 0 && !userSelectedNdays}">
                            and startdate >= ?
                            <sql:dateParam value="${startRange}"/>
                        </c:if>
                        <c:if test="${ endTime > 0 && !userSelectedNdays}">
                            and enddate <= ?
                            <sql:dateParam value="${endRange}"/>
                        </c:if>
                        <c:if test="${userSelectedNdays && !userSelectedStartTime && !userSelectedEndTime}">
                            and STARTDATE >= ? and ENDDATE <= ?
                            <jsp:useBean id="maxDateUsedDays" class="java.util.Date" />
                            <jsp:useBean id="minDateUsedDays" class="java.util.Date" />
                            <jsp:setProperty name="minDateUsedDays" property="time" value="${maxDateUsedDays.time - ndays*24*60*60*1000}" />       
                            <sql:dateParam value="${minDateUsedDays}" type="timestamp"/> 
                            <sql:dateParam value="${maxDateUsedDays}" type="timestamp"/> 
                        </c:if>
                        and  PII.GetStreamIsLatestPath(Stream)=1                                
                    </sql:query>                                         
                    <aida:tuple var="tuple" query="${data}" />    
                    <aida:tupleProjection var="elapsed" tuple="${tuple}" xprojection="(ENDDATE-STARTDATE)/60"/>
                    <aida:tupleProjection var="wait" tuple="${tuple}" xprojection="(STARTDATE-CREATEDATE)/60"/>
                    
                    <aida:datapointset var="elapsedTimeline" tuple="${tuple}"  yaxisColumn="ELAPSEDTIME" xaxisColumn="STARTDATE" />   
                    <aida:datapointset var="waitTimeline" tuple="${tuple}"  yaxisColumn="WAITTIME" xaxisColumn="CREATEDATE" />   
                    
                    <sql:query var="stream_data">
                        with q1 as
                        (select TRUNC(EndDate) on_date, COUNT(1) successfully_completed
                        from Stream 
                        where Task=? and StreamStatus='SUCCESS' 
                        group by Task, TRUNC(EndDate))
                        select on_date, successfully_completed, sum(successfully_completed) over (order by on_date) tot from q1
                        <sql:param value="${task}"/>
                    </sql:query>
                    <aida:tuple var="stream_tuple" query="${stream_data}" />
                    <aida:datapointset var="succeeded" tuple="${stream_tuple}" yaxisColumn="SUCCESSFULLY_COMPLETED" xaxisColumn="ON_DATE" />   
                    <aida:datapointset var="succ_run_total" tuple="${stream_tuple}" yaxisColumn="TOT" xaxisColumn="ON_DATE" />   
                    <aida:plotter nx="2" ny="3" height="600" width="600">
                        <aida:style>
                            <aida:attribute name="statisticsBoxFontSize" value="8"/>
                            <aida:style type="data">
                                <aida:attribute name="showErrorBars" value="false"/>   
                            </aida:style>  
                        </aida:style>
                        <aida:region title="Elapsed time (mins)">
                            <aida:plot var="${elapsed}"/>                     
                        </aida:region>
                        <aida:region title="Wait time (mins)">
                            <aida:plot var="${wait}"/>                     
                        </aida:region>
                        <aida:region title="Elapsed time (mins) Timeline" >
                            <aida:style>
                                <aida:style type="legendBox">
                                    <aida:attribute name="isVisible" value="false"/>
                                </aida:style>
                                <aida:style type="xAxis">
                                    <aida:attribute name="label" value=""/>
                                    <aida:attribute name="type" value="date"/>
                                </aida:style>
                                <aida:style type="data">
                                    <aida:style type="outline">                                    
                                        <aida:attribute name="isVisible" value="false"/>
                                    </aida:style>
                                    <aida:style type="marker"> 
                                        <aida:attribute name="size" value="2"/>
                                    </aida:style>                                    
                                </aida:style>
                            </aida:style>
                            <aida:plot var="${elapsedTimeline}">
                            </aida:plot>                            
                        </aida:region>
                        <aida:region title="Wait time (mins) Timeline" >
                            <aida:style>
                                <aida:style type="legendBox">
                                    <aida:attribute name="isVisible" value="false"/>
                                </aida:style>
                                <aida:style type="xAxis">
                                    <aida:attribute name="label" value=""/>
                                    <aida:attribute name="type" value="date"/>
                                </aida:style>
                                <aida:style type="data">
                                    <aida:style type="outline">                                    
                                        <aida:attribute name="isVisible" value="false"/>
                                    </aida:style>
                                    <aida:style type="marker"> 
                                        <aida:attribute name="size" value="2"/>
                                    </aida:style>                                    
                                </aida:style>
                            </aida:style>
                            <aida:plot var="${waitTimeline}">
                            </aida:plot>                            
                        </aida:region>
                        
                        <aida:region title= "Task Throughput" colSpan="2">
                            <aida:style>
                                <aida:style type="legendBox">
                                    <aida:attribute name="isVisible" value="false"/>
                                </aida:style>
                                <aida:style type="xAxis">
                                    <aida:attribute name="label" value=""/>
                                    <aida:attribute name="type" value="date"/>
                                </aida:style>
                                <aida:style type="data">
                                    <aida:attribute name="connectDataPoints" value="false"/>
                                </aida:style>
                            </aida:style>   
                            
                            <aida:plot var="${succ_run_total}">
                                <aida:style type="plotter"> 
                                    <aida:style type="yAxis">
                                        <aida:attribute name="yAxis" value="Y1"/>
                                        <aida:attribute name="label" value="Succeeded Total"/>
                                        <aida:attribute name="allowZeroSuppression" value="false"/>
                                    </aida:style>
                                    <aida:style type="data">
                                        <aida:style type="outline">                                    
                                            <aida:attribute name="color" value="blue"/>
                                        </aida:style>
                                        <aida:style type="marker">
                                            <aida:attribute name="color" value="blue"/>
                                            <aida:attribute name="shape" value="box"/>
                                        </aida:style>
                                    </aida:style>
                                </aida:style>
                            </aida:plot>
                            <aida:plot var="${succeeded}">
                                <aida:style type="plotter">
                                    <aida:style type="yAxis">
                                        <aida:attribute name="yAxis" value="Y0"/>
                                        <aida:attribute name="label" value="Succeeded"/>
                                        <aida:attribute name="allowZeroSuppression" value="false"/>
                                    </aida:style>
                                    <aida:style type="data">
                                        <aida:style type="outline">
                                            <aida:attribute name="color" value="red"/>
                                        </aida:style>
                                        <aida:style type="marker">
                                            <aida:attribute name="color" value="red"/>
                                            <aida:attribute name="shape" value="triangle"/>
                                        </aida:style>
                                    </aida:style>
                                </aida:style>
                            </aida:plot>
                        </aida:region>	 
                    </aida:plotter> 
                    
                </tab:tab>
                
                <c:forEach var="row" items="${processes.rows}">
                    <tab:tab name="${row.PROCESSNAME}" href="P2stats.jsp?task=${task}&startTime=${startTime}&endTime=${endTime}" value="${row.PROCESS}">
                        <sql:query var="data">
                            select enddate,startdate,submitdate,cpusecondsused,
                            cpusecondsused/60 as cpuUsedTime ,
                            (GLAST_UTIL.GetTimeFromEpochMS(enddate)-GLAST_UTIL.GetTimeFromEpochMS(startdate))/(1000*60) as wallPlotTime,
                            cpusecondsused/(GLAST_UTIL.GetTimeFromEpochMS(enddate)-GLAST_UTIL.GetTimeFromEpochMS(startdate))/(1000*60) as WallCpuTime,                      
                            (GLAST_UTIL.GetTimeFromEpochMS(startdate)-GLAST_UTIL.GetTimeFromEpochMS(submitdate))/(1000*60) as waitPlotTime,
                            regexp_substr(lower(PI.executionhost), '^[a-z]+')executionhost
                            from processinstance PI
                            where PI.process = ?
                            <sql:param value="${row.PROCESS}"/>
                            and PI.processingstatus = 'SUCCESS'
                            <c:if test="${ startTime > 0 && !userSelectedNdays}">
                                and startdate >= ?
                                <sql:dateParam value="${startRange}"/>
                            </c:if>
                            <c:if test="${ endTime > 0 && !userSelectedNdays}">
                                and enddate <= ?
                                <sql:dateParam value="${endRange}"/>
                            </c:if>   
                            <c:if test="${userSelectedNdays && !userSelectedStartTime && !userSelectedEndTime}"> 
                                and startdate > current_date - interval '${sessionUseNdays ? sessionNdays : 7}' day
                            </c:if>   
                            
                        </sql:query>             
                        
                        <aida:tuple var="tuple" query="${data}" />    
                        
                        <%-- Don't plot this section if an single NODE plot is to be displayed
                             to display plot at top of the web page ....--%>
                        <c:if test="${param.nodeplot ne 'y'}">
                            
                            <aida:tupleProjection var="wallPlot" tuple="${tuple}" xprojection="(ENDDATE-STARTDATE)/60" />       
                            <aida:datapointset var="wallPlotTimeLine" tuple="${tuple}"  yaxisColumn="WALLPLOTTIME" xaxisColumn="STARTDATE" />  
                            
                            <aida:plotter nx="${plotnumX}" ny="${plotnumY}" height="${plotheight}" width="${plotwidth}" createImageMap="true">
                                <aida:style>
                                    <aida:attribute name="statisticsBoxFontSize" value="8"/>
                                    <aida:style type="data">
                                        <aida:attribute name="showErrorBars" value="false"/>  
                                        <aida:style type="marker"> 
                                            <aida:attribute name="size" value="2"/>
                                        </aida:style>                                        
                                    </aida:style>  
                                </aida:style>
                                
                                <c:set var ="plotName" value ="wallPlot"/>
                                <c:if test="${selectedPlot == plotName or selectedPlot =='ALL' }" >
                                    <aida:region title="Wall Clock time (mins)" var="region" href="?selectedPlot=${plotName}&process=${row.process}" >
                                        <aida:plot var="${wallPlot}"/>                     
                                    </aida:region>                                                              
                                    <aida:region title="Wall Clock Time Timeline" >
                                        <aida:style>
                                            <aida:style type="legendBox">
                                                <aida:attribute name="isVisible" value="false"/>
                                            </aida:style>
                                            <aida:style type="xAxis">
                                                <aida:attribute name="label" value=""/>
                                                <aida:attribute name="type" value="date"/>
                                            </aida:style>
                                            <aida:style type="data">
                                                <aida:style type="outline">                                    
                                                    <aida:attribute name="isVisible" value="false"/>
                                                </aida:style>
                                                <aida:style type="marker"> 
                                                    <aida:attribute name="size" value="2"/>
                                                </aida:style>                                                
                                            </aida:style>
                                        </aida:style>
                                        <aida:plot var="${wallPlotTimeLine}">
                                        </aida:plot>                                        
                                    </aida:region>
                                </c:if>
                                <c:if test="${row.processtype !='SCRIPT'}"> 
                                    <c:set var ="plotName" value ="pendingPlot"/>
                                    <c:if test="${selectedPlot == plotName or selectedPlot =='ALL' }" >                    
                                        <aida:region title="Pending time (mins)" var="region" href="?selectedPlot=${plotName}&process=${row.process}" >
                                            <aida:tupleProjection var="waitPlot" tuple="${tuple}" xprojection="(STARTDATE-SUBMITDATE)/60"/>
                                            <aida:plot var="${waitPlot}"/>    			             
                                        </aida:region>
                                        <aida:region title="Pending time Timeline" >
                                            <aida:datapointset var="waitPlotTimeLine" tuple="${tuple}"  yaxisColumn="WAITPLOTTIME" xaxisColumn="SUBMITDATE" /> 
                                            <aida:style>
                                                <aida:style type="legendBox">
                                                    <aida:attribute name="isVisible" value="false"/>
                                                </aida:style>
                                                <aida:style type="xAxis">
                                                    <aida:attribute name="label" value=""/>
                                                    <aida:attribute name="type" value="date"/>
                                                </aida:style>
                                                <aida:style type="data">
                                                    <aida:style type="outline">                                    
                                                        <aida:attribute name="isVisible" value="false"/>
                                                    </aida:style>
                                                    <aida:style type="marker"> 
                                                        <aida:attribute name="size" value="2"/>
                                                    </aida:style>                                                    
                                                </aida:style>
                                            </aida:style>
                                            <aida:plot var="${waitPlotTimeLine}">
                                            </aida:plot>
                                        </aida:region>
                                    </c:if>                          
                                    <c:set var ="plotName" value ="cpuSecondsPlot"/>
                                    <c:if test="${selectedPlot == plotName or selectedPlot =='ALL' }" >
                                        <aida:region title="CPU time (mins)" var="region" href="?selectedPlot=${plotName}&process=${row.process}" >
                                            <aida:tupleProjection var="cpuSeconds" tuple="${tuple}" xprojection="CPUSECONDSUSED/60"/>   
                                            <aida:plot var="${cpuSeconds}"/>    			             
                                        </aida:region>
                                        <aida:region title="CPU time Timeline" >
                                            <aida:datapointset var="cpuSecondsTimeLine" tuple="${tuple}"  yaxisColumn="CPUUSEDTIME" xaxisColumn="CPUSECONDSUSED" /> 
                                            <aida:style>
                                                <aida:style type="legendBox">
                                                    <aida:attribute name="isVisible" value="false"/>
                                                </aida:style>
                                                <aida:style type="xAxis">
                                                    <aida:attribute name="label" value=""/>
                                                    <aida:attribute name="type" value="date"/>
                                                </aida:style>
                                                <aida:style type="data">
                                                    <aida:style type="outline">                                    
                                                        <aida:attribute name="isVisible" value="false"/>
                                                    </aida:style>
                                                    <aida:style type="marker"> 
                                                        <aida:attribute name="size" value="2"/>
                                                    </aida:style>                                                    
                                                </aida:style>
                                            </aida:style>
                                            <aida:plot var="${cpuSecondsTimeLine}">
                                            </aida:plot>
                                        </aida:region>
                                    </c:if>                          
                                    <c:set var ="plotName" value ="cpuWallPlot"/>
                                    <c:if test="${selectedPlot == plotName or selectedPlot =='ALL' }" >
                                        <aida:region title="CPU time/Wall Clock" var="region" href="?selectedPlot=${plotName}&process=${row.process}" >
                                            <aida:tupleProjection var="wallCpu" tuple="${tuple}" xprojection="CPUSECONDSUSED/(ENDDATE-STARTDATE)"/>               
                                            <aida:plot var="${wallCpu}"/>    			             
                                        </aida:region>
                                        <aida:region title="CPU time/Wall Clock Timeline" >
                                            <aida:datapointset var="wallCpuTimeLine" tuple="${tuple}"  yaxisColumn="WALLCPUTIME" xaxisColumn="STARTDATE" /> 
                                            <aida:style>
                                                <aida:style type="legendBox">
                                                    <aida:attribute name="isVisible" value="false"/>
                                                </aida:style>
                                                <aida:style type="xAxis">
                                                    <aida:attribute name="label" value=""/>
                                                    <aida:attribute name="type" value="date"/>
                                                </aida:style>
                                                <aida:style type="data">
                                                    <aida:style type="outline">                                    
                                                        <aida:attribute name="isVisible" value="false"/>
                                                    </aida:style>
                                                    <aida:style type="marker"> 
                                                        <aida:attribute name="size" value="2"/>
                                                    </aida:style>                                                    
                                                </aida:style>
                                            </aida:style>
                                            <aida:plot var="${wallCpuTimeLine}">
                                            </aida:plot>
                                        </aida:region>
                                    </c:if>  
                                </c:if>  
                            </aida:plotter>                         
                        </c:if>                                                  
                        
                        <c:if test="${row.processtype !='SCRIPT'}">                                                         
                            <sql:query var="hostnode">           
                                select distinct(regexp_substr(lower(PI.executionhost), '^[a-z]+') ) executionhost 
                                from processinstance PI  ,process P
                                where PI.process = P.process
                                and PI.process = ?                               
                                <sql:param value="${row.process}"/>                                
                                and executionhost is not null
                            </sql:query>                             
                            
                            <c:if test="${fn:length(hostnode.rows) > 0}">
                                
                                <br> <strong>  PLOTS by BATCH NODES</strong><br>
                                
                                <aida:plotter nx="${plotnumX}" ny="${plotnumY}" height="${plotheight}" width="${plotwidth}" createImageMap="true">
                                    <aida:style>
                                        <aida:style type="statisticsBox">
                                            <aida:attribute name="isVisible" value="false"/>   
                                        </aida:style>  
                                        <aida:style type="data">
                                            <aida:style type="errorBar">
                                                <aida:attribute name="isVisible" value="false"/>   
                                            </aida:style>  
                                            <aida:style type="fill">
                                                <aida:attribute name="isVisible" value="false"/>   
                                            </aida:style>  
                                        </aida:style>  
                                    </aida:style>
                                    <c:set var ="plotName" value ="wallPlotNodes"/>
                                    <c:if test="${selectedPlot == plotName or selectedPlot =='ALL'}" > 
                                        <aida:region title="Wall Clock time (mins)" var="region" href="?selectedPlot=${plotName}&process=${row.process}&nodeplot=y" >
                                            <c:forEach var="rowB" items="${hostnode.rows}" varStatus="status">
                                                <aida:tupleProjection  name="${rowB.executionhost}" var="wallPlot" tuple="${tuple}" xprojection="(ENDDATE-STARTDATE)/60" filter="EXECUTIONHOST == \"${rowB.executionhost}\" "/>
                                                <aida:plot var="${wallPlot}">
                                                    <aida:style>
                                                        <aida:style type="line">
                                                            <aida:attribute name="color" value="${plotColors[status.index%numberPlotColors]}"/>    
                                                            <aida:attribute name="thickness" value="${lineSize}"/>    
                                                        </aida:style>                                                                  
                                                    </aida:style>                                                                                  
                                                </aida:plot>                     
                                            </c:forEach>                                        
                                        </aida:region>
                                    </c:if>
                                    <c:if test="${row.processtype !='SCRIPT'}"> 
                                        <c:set var ="plotName" value ="waitPlotNodes"/>
                                        <c:if test="${selectedPlot == plotName or selectedPlot =='ALL' }" >
                                            
                                            <aida:region title="Pending time (mins)" var="region" href="?selectedPlot=${plotName}&process=${row.process}&nodeplot=y">
                                                <c:forEach var="rowB" items="${hostnode.rows}" varStatus="status">
                                                    <aida:tupleProjection  name="${rowB.executionhost}" var="waitPlot" tuple="${tuple}" xprojection="(STARTDATE-SUBMITDATE)/60" filter="EXECUTIONHOST == \"${rowB.executionhost}\" "/>
                                                    <aida:plot var="${waitPlot}">
                                                        <aida:style>
                                                            <aida:style type="line">
                                                                <aida:attribute name="color" value="${plotColors[status.index%numberPlotColors]}"/>    
                                                                <aida:attribute name="thickness" value="${lineSize}"/>    
                                                            </aida:style>                                                                  
                                                        </aida:style>                                                                                                                                      
                                                    </aida:plot>    			             
                                                </c:forEach>                                        
                                            </aida:region>
                                        </c:if>
                                        <c:set var ="plotName" value ="cpuSecondsPlotNodes"/>
                                        <c:if test="${selectedPlot == plotName or selectedPlot =='ALL' }" >
                                            <aida:region title="CPU time (mins)" var="region" href="?selectedPlot=${plotName}&process=${row.process}&nodeplot=y">
                                                <c:forEach var="rowB" items="${hostnode.rows}" varStatus="status">
                                                    <aida:tupleProjection name="${rowB.executionhost}" var="cpuSeconds" tuple="${tuple}" xprojection="CPUSECONDSUSED/60" filter="EXECUTIONHOST == \"${rowB.executionhost}\" "/>   
                                                    <aida:plot var="${cpuSeconds}">
                                                        <aida:style>
                                                            <aida:style type="line">
                                                                <aida:attribute name="color" value="${plotColors[status.index%numberPlotColors]}"/>    
                                                                <aida:attribute name="thickness" value="${lineSize}"/>    
                                                            </aida:style>                                                                  
                                                        </aida:style>                                                                                                                                      
                                                    </aida:plot>
                                                </c:forEach>                                        
                                            </aida:region>
                                        </c:if>
                                        <c:set var ="plotName" value ="wallCpuPlotNodes"/>
                                        <c:if test="${selectedPlot == plotName or selectedPlot =='ALL' }" >
                                            <aida:region title="CPU time/Wall Clock" var="region" href="?selectedPlot=${plotName}&process=${row.process}&nodeplot=y">
                                                <c:forEach var="rowB" items="${hostnode.rows}" varStatus="status">
                                                    <aida:tupleProjection name="${rowB.executionhost}" var="wallCpu" tuple="${tuple}" xprojection="CPUSECONDSUSED/(ENDDATE-STARTDATE)" filter="EXECUTIONHOST == \"${rowB.executionhost}\" "/>               
                                                    <aida:plot var="${wallCpu}">                                               
                                                        <aida:style>
                                                            <aida:style type="line">
                                                                <aida:attribute name="color" value="${plotColors[status.index%numberPlotColors]}"/>    
                                                                <aida:attribute name="thickness" value="${lineSize}"/>    
                                                            </aida:style>                                                                  
                                                        </aida:style>                                                                                                                                      
                                                    </aida:plot>    			             
                                                </c:forEach>                                        
                                            </aida:region>  
                                        </c:if>
                                    </c:if>  
                                </aida:plotter> 
                            </c:if>
                        </c:if>  
                    </tab:tab>             
                </c:forEach>            
            </tab:tabs> 
        </c:if>        
        
        
        
    </body>
</html>
