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
<%@taglib prefix="time" uri="http://srs.slac.stanford.edu/time" %>
<html>
    <head>
        <title>Performance Plots</title>
    </head>
    <body>
        
        <jsp:useBean id="endTimeBean" class="java.util.Date" />
        <jsp:useBean id="startTimeBean" class="java.util.Date" />

        <c:set var="debug" value="0"/>
        <c:set var="isSubmit" value="${param.filter}"/>
        <c:set var="isDefault" value="${param.default}"/>

        <c:if test="${empty firstTimeP2stats}">
            <c:set var="P2hours" value="${preferences.defaultP2statHours > 0 ? preferences.defaultP2statHours : ''}"/>
            <c:set var="sessionP2Hours" value="${P2hours}" scope="session"/>
            <c:set var="sessionP2StartTime" value="" scope="session"/>
            <c:set var="sessionP2EndTime" value="" scope="session"/>
            <c:set var="firstTimeP2stats" value="beenHereDoneThat2" scope="session"/>
            <c:set var="userSelectedP2hours" value="${P2hours > 0 ? 'true' : 'false'}"/>
            <c:set var="userSelectedStartTime" value="false"/>
            <c:set var="userSelectedEndTime" value="false"/>
        </c:if>
        
  <%--      <c:if test="${isSubmit == 'Submit'}"> --%>
            <c:set var="P2hours" value="${param.p2hours}"/>
            <c:set var="startTime" value="${param.startTime}" />
            <c:set var="endTime"   value="${param.endTime}" />
            <c:set var="userSelectedStartTime" value="${!empty startTime && startTime != '-1' && startTime != sessionP2StartTime}" /> 
            <c:set var="userSelectedEndTime" value="${!empty endTime && endTime != '-1' && endTime != sessionP2EndTime}" /> 
            <c:set var="userSelectedP2hours" value="${!empty P2hours && !userSelectedStartTime && !userSelectedEndTime}"/>
            <c:set var="userSelectedStartNone" value="${startTime == '-1' && empty P2hours}"/>
            <c:set var="userSelectedEndNone" value="${endTime == '-1' && empty P2hours}"/>
            <c:set var="pref_nhours" value="${preferences.defaultP2statHours}"/>
      <%-- <c:set var="userSelectedTask" value="${param.task}" scope="session" /> --%>

            <c:choose>
                <c:when test="${userSelectedStartTime || userSelectedEndTime}">
                    <c:set var="sessionP2Hours" value="" scope="session"/>
                    <c:if test="${userSelectedStartTime}"> 
                        <c:set var ="sessionP2StartTime" value="${startTime}" scope="session"/>
                    </c:if>
                    <c:if test="${userSelectedEndTime}">
                        <c:set var ="sessionP2EndTime" value="${endTime}" scope="session"/>
                    </c:if>
                </c:when>
                <c:when test="${userSelectedP2hours}">
                    <c:set var="sessionP2Hours" value="${P2hours}" scope="session"/>
                    <c:set var="sessionP2StartTime" value="" scope="session"/> 
                    <c:set var="sessionP2EndTime" value="" scope="session"/> 
                </c:when>
            </c:choose>
            <c:choose>
                <c:when test="${userSelectedStartNone}">
                    <c:set var ="sessionP2StartTime" value="-1" scope="session" />
                    <c:set var="sessionP2Hours" value="" scope="session"/>
                </c:when>
                <c:when test="${userSelectedEndNone}">
                    <c:set var ="sessionP2EndTime" value="-1" scope="session"/>
                    <c:set var="sessionP2Hours" value="" scope="session"/>
                </c:when>
            </c:choose>
   <%--    </c:if> --%>
       
       <c:if test="${debug == 1}">
           <h3> 
           userSelectedStartTime=${userSelectedStartTime} startTime=${startTime} sessionP2StartTime=${sessionP2StartTime}<br>
           userSelectedEndTime=${userSelectedEndTime} endTime=${endTime} sessionP2EndTime=${sessionP2EndTime}<br>
           userSelectedP2hours=${userSelectedP2hours} sessionP2Hours=${sessionP2Hours} <br>
           </h3>
       </c:if>

       <c:if test="${isDefault == 'Default'}">
           <c:set var="pref_nhours" value="${preferences.defaultP2statHours > 0 ? preferences.defaultP2statHours : ''}"/>
           <c:set var="P2hours" value="${pref_nhours}"/>
           <c:set var="startTime" value="-1"/>
           <c:set var="endTime" value="-1"/>
           <c:set var ="sessionP2StartTime" value="-1" scope="session"/>
           <c:set var ="sessionP2EndTime" value="-1" scope="session" />
           <c:set var="sessionP2Hours" value="${pref_nhours}" scope="session" />
           <c:set var="userSelectedP2hours" value="${P2hours > 0 ? 'true' : 'false'}"/>
           <c:set var="userSelectedStartTime" value="false"/>
           <c:set var="userSelectedEndTime" value="false"/>
       </c:if>

       <c:if test="${debug == 1}">
           <h3>
               userSelectedP2hours: ${userSelectedP2hours}<br>
               userselectedStartTime: ${userSelectedStartTime}<br>
               userselectedEndTime: ${userSelectedEndTime}<p>
               sessionP2StartTime: ${sessionP2StartTime}<br>
               sessionP2EndTime: ${sessionP2EndTime}<br>
               sessionP2Hours: ${sessionP2Hours}<br>
               startTime: ${startTime}<br>
               endTime: ${endTime}<br>
               P2hours: ${P2hours}<p>
               param.startTime: ${param.startTime}<br>
               param.endTime: ${param.endTime}<br>
               param.filter: ${param.filter}<br>
               param.default: ${param.default}<br>
               param.task: ${param.task}<br>
               isDefault: ${isDefault}<br>
               isSubmit: ${isSubmit}<br>
           </h3>
       </c:if>
        
        <form name="DateForm">        
            <table bordercolor="#000000" bgcolor="#FFCC66" class="filtertable">
                <tr bordercolor="#000000" bgcolor="#FFCC66">               
                    <td colspan="5"><strong>Select Timespan</strong>:                 
                </tr> 
                <tr bordercolor="#000000" bgcolor="#FFCC66">
                    <td><strong>Start</strong> <time:dateTimePicker size="20" name="startTime" showtime="true" format="%b/%e/%y %H:%M" value="${sessionP2StartTime}"  timezone="PST8PDT"/></td>
                    <td><strong>End</strong> <time:dateTimePicker size="20" name="endTime" showtime="true" format="%b/%e/%y %H:%M" value="${sessionP2EndTime}" timezone="PST8PDT"/></td>
                    <td>or last N hours <input name="p2hours" type="text" value="${sessionP2Hours}" size="5"></td>
                </tr> 
                <input type="hidden" name="task" value="${task}"/>
                <tr bordercolor="#000000" bgcolor="#FFCC66"> <td> <input type="submit" value="Submit" name="filter">
                <input type="submit" value="Default" name="default"></td>
                </tr> 
        </table></form>  

        <%-- calculate start and end ranges for all following queries when hours is NOT selected --%>
        <%-- if hours selected, startRange and endRange are calculated within the 'if' block for that query --%>
        <c:if test="${!userSelectedP2hours}">
            <jsp:setProperty name="endTimeBean" property="time" value="${sessionP2EndTime}" />
            <c:set var="endRange" value="${endTimeBean}"/>
            <jsp:setProperty name="startTimeBean" property="time" value="${sessionP2StartTime}" />
            <c:set var="startRange" value="${startTimeBean}" />
        </c:if>

        <%--
        <jsp:setProperty name="endTimeBean" property="time" value="${endTime}" />
        <c:set var="endRange" value="${endTimeBean}"/>
        <jsp:setProperty name="startTimeBean" property="time" value="${startTime}" />
        <c:set var="startRange" value="${startTimeBean}" />                
        --%>
        
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

            <c:if test="${ sessionP2StartTime > 0 && !userSelectedP2hours }">
                and startdate >= ?
                <sql:dateParam value="${startRange}"/>
            </c:if>
            <c:if test="${ sessionP2EndTime > 0 && !userSelectedP2hours}">
                and enddate <= ?
                <sql:dateParam value="${endRange}"/>
            </c:if>
            <c:if test="${userSelectedP2hours}">
                and STARTDATE >= ? and ENDDATE <= ?
                <c:set var="endRange" value="${endTimeBean}"/>
                <jsp:setProperty name="startTimeBean" property="time" value="${endTimeBean.time - sessionP2Hours*60*60*1000}" />
                <c:set var="startRange" value="${startTimeBean}"/> 
                <sql:dateParam value="${startRange}" type="timestamp"/>
                <sql:dateParam value="${endRange}" type="timestamp"/>
                <c:set var="foo1" value="startTimeBean=${startTimeBean} and endTimeBean=${endTimeBean}" />
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
            <br>    <strong> There are no successful processes to plot for this task</strong><br>
        </c:if>
        
        <c:if test="${fn:length(datacheck.rows) > 0}"> 
            <tab:tabs name="ProcessTabs" param="process">                
                <tab:tab name="Summary" href="P2stats.jsp?task=${task}&startTime=${sessionP2StartTime}&endTime=${sessionP2EndTime}&p2hours=${sessionP2Hours}&filter=Submit" value="0">
                    <sql:query var="data">
                        select createdate,startdate,enddate, 
                        (TIME_UTIL.GetTimeFromEpochMS(enddate)-TIME_UTIL.GetTimeFromEpochMS(startdate))/(1000*60) as elapsedTime
                        , (TIME_UTIL.GetTimeFromEpochMS(startdate)-TIME_UTIL.GetTimeFromEpochMS(createdate))/(1000*60) as waitTime
                        from stream where task=? 
                        <sql:param value="${task}"/>
                        and streamstatus='SUCCESS' 
                       
                       <c:if test="${ sessionP2StartTime > 0 && !userSelectedP2hours}">
                            and startdate >= ?
                            <jsp:setProperty name="startTimeBean" property="time" value="${sessionP2StartTime}" />
                            <c:set var="startRange" value="${startTimeBean}"/> 
                            <sql:dateParam value="${startRange}"/>
                        </c:if>
                        <c:if test="${ sessionP2EndTime > 0 && !userSelectedP2hours}">
                            and enddate <= ?
                            <jsp:setProperty name="endTimeBean" property="time" value="${sessionP2EndTime}" />
                            <c:set var="endRange" value="${endTimeBean}"/>
                            <sql:dateParam value="${endRange}"/>
                        </c:if>
                        <c:if test="${userSelectedP2hours}">
                            and STARTDATE >= ? and ENDDATE <= ?
                            <c:set var="endRange" value="${endTimeBean}"/>
                            <jsp:setProperty name="startTimeBean" property="time" value="${endTimeBean.time - sessionP2Hours*60*60*1000}" />
                            <c:set var="startRange" value="${startTimeBean}"/> 
                            <sql:dateParam value="${startRange}" type="timestamp"/>
                            <sql:dateParam value="${endRange}" type="timestamp"/>

                            <%--
                            <c:set var="minDateUsedDays" value="${startTimeBean}"/>
                            <c:set var="maxDateUsedDays" value="${endTimeBean}"/>
                            <jsp:setProperty name="minDateUsedDays" property="time" value="${maxDateUsedDays.time - P2hours*24*60*60*1000}" />
                            <sql:dateParam value="${minDateUsedDays}" type="timestamp"/>
                            <sql:dateParam value="${maxDateUsedDays}" type="timestamp"/>


                            <jsp:useBean id="maxDateUsedDays" class="java.util.Date" />
                            <jsp:useBean id="minDateUsedDays" class="java.util.Date" />
                            <jsp:setProperty name="minDateUsedDays" property="time" value="${maxDateUsedDays.time - nhours*24*60*60*1000}" />
                            <sql:dateParam value="${minDateUsedDays}" type="timestamp"/>
                            <sql:dateParam value="${maxDateUsedDays}" type="timestamp"/>
                            --%>
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
                    <tab:tab name="${row.PROCESSNAME}" href="P2stats.jsp?task=${task}&startTime=${sessionP2StartTime}&endTime=${sessionP2EndTime}&p2hours=${sessionP2Hours}&filter=Submit" value="${row.PROCESS}">
                        <sql:query var="data">
                            select enddate,startdate,submitdate,cpusecondsused,
                            cpusecondsused/60 as cpuUsedTime ,
                            (TIME_UTIL.GetTimeFromEpochMS(enddate)-TIME_UTIL.GetTimeFromEpochMS(startdate))/(1000*60) as wallPlotTime,
                            cpusecondsused/(TIME_UTIL.GetTimeFromEpochMS(enddate)-TIME_UTIL.GetTimeFromEpochMS(startdate))/(1000*60) as WallCpuTime,
                            (TIME_UTIL.GetTimeFromEpochMS(startdate)-TIME_UTIL.GetTimeFromEpochMS(submitdate))/(1000*60) as waitPlotTime,
                            regexp_substr(lower(PI.executionhost), '^[a-z]+')executionhost
                            from processinstance PI
                            where PI.process = ?
                            <sql:param value="${row.PROCESS}"/>
                            and PI.processingstatus = 'SUCCESS'
                            <c:if test="${ sessionP2StartTime > 0 && !userSelectedP2hours}">
                                and startdate >= ?
                                <sql:dateParam value="${startRange}"/>
                            </c:if>
                            <c:if test="${ sessionP2EndTime > 0 && !userSelectedP2hours}">
                                and enddate <= ?
                                <sql:dateParam value="${endRange}"/>
                            </c:if>
                            <c:if test="${userSelectedP2hours}">
                                and STARTDATE >= ? and ENDDATE <= ?
                                <c:set var="endRange" value="${endTimeBean}"/>
                                <jsp:setProperty name="startTimeBean" property="time" value="${endTimeBean.time - sessionP2Hours*60*60*1000}" />
                                <c:set var="startRange" value="${startTimeBean}"/>
                                <sql:dateParam value="${startRange}" type="timestamp"/>
                                <sql:dateParam value="${endRange}" type="timestamp"/>
                                <c:set var="foo3" value="and startdate >= ${startRange} and enddate <= ${endRange}" />
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
