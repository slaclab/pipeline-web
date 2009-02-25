<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="aida" uri="http://aida.freehep.org/jsp20" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib prefix="utils" uri="http://glast-ground.slac.stanford.edu/utils" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
    <head>
        <script language="JavaScript" src="http://glast-ground.slac.stanford.edu/Commons/scripts/FSdateSelect.jsp"></script>
        <link rel="stylesheet" href="http://glast-ground.slac.stanford.edu/Commons/css/FSdateSelect.css" type="text/css">        
        <title>Pipeline Jobs VS Time Plots</title>    
    </head>
    <body>
        
        ${aida:clearPlotRegistry(pageContext.session)}       
        <c:set var="datatbl" value="processingstatisticshour" scope="session"/>
        
        <c:set var="startTime" value="${param.startTime}" />
        <c:set var="endTime"   value="${param.endTime}"   />
        <c:set var="taskName" value="${param.taskName}" /> 
        <c:catch>
            <fmt:parseNumber var="hours" value="${param.hours}" type="number" integerOnly="true"/>
        </c:catch>
        
        <c:set var="userSelectedStartTime" value="${!empty startTime && startTime != '-1' && startTime != sessionStartTime}" /> 
        <c:set var="userSelectedEndTime" value="${!empty endTime && endTime != '-1' && endTime != sessionEndTime}" /> 
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
        <br>	
        
        <form name="DateForm">        
            <table bordercolor="#000000" bgcolor="#FFCC66" class="filtertable">
                <tr bordercolor="#000000" bgcolor="#FFCC66">               
                    <td colspan="5"><strong>Select Task</strong>:                 
                    <select name="taskName">
                        <sql:query var="taskdata">
                            select distinct taskname
                            from ${datatbl}  
                            order by taskname  
                        </sql:query>
                        <option value="ALL">All Tasks</option>
                        <c:forEach items="${taskdata.rows}" var="taskrow"> 
                            <option value="${taskrow.taskname}" ${taskrow.taskname == sessionTaskName ? 'selected' : ''}>${taskrow.taskname}</option>
                        </c:forEach>
                </select>		  </tr> 
                <tr bordercolor="#000000" bgcolor="#FFCC66">
                    
                    <td><strong>Start</strong> <utils:dateTimePicker size="20" name="startTime" showtime="true" format="%b/%e/%y %H:%M" value="${sessionUseHours ? -1 : sessionStartTime}"  timezone="PST8PDT"/></td> 
                    <td><strong>End</strong> <utils:dateTimePicker size="20" name="endTime"   showtime="true" format="%b/%e/%y %H:%M" value="${sessionUseHours ? -1 : sessionEndTime}" timezone="PST8PDT"/> </td>     
                    <td>or last <input name="hours" type="text" value="${sessionUseHours ? sessionHours : ''}" size="5"> hours</td>
                </tr> 
                
                <tr bordercolor="#000000" bgcolor="#FFCC66"> <td> <input type="submit" value="Submit" name="filter"></td>
                </tr> 
        </table></form>   
        
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
        <c:choose>
            <c:when test="${timerange <= 24}"> 
                <c:set var="datatbl" value="processingstatisticsmin" />
                <c:set var="plotby" value="Minutes" />
                <c:set var="groupby" value="${pl:ceil(timerange/2)}" />
            </c:when>
            <c:when test="${timerange <= 24*60 }"> 
                <c:set var="datatbl" value="processingstatisticshour"/>
                <c:set var="plotby" value="Hours" />
                <c:set var="groupby" value="${pl:ceil(timerange/(2*60))}" />
            </c:when>
            <c:when test="${timerange <= 24*60*24}"> 
                <c:set var="datatbl" value="processingstatisticsday"/>
                <c:set var="plotby" value="Days"/>
                <c:set var="groupby" value="${pl:ceil(timerange/(2*60*24))}" />
            </c:when>
            <c:when test="${timerange <= 24*60*24*7}"> 
                <c:set var="datatbl" value="processingstatisticsweek"/>
                <c:set var="plotby" value="Weeks"/>
                <c:set var="groupby" value="${pl:ceil(timerange/(2*60*24*7))}" />
            </c:when>
            <c:otherwise> 
                <c:set var="datatbl" value="processingstatisticsmonth"/>
                <c:set var="plotby" value="Months"/>
                <c:set var="groupby" value="${pl:ceil(timerange/(2*60*24*7*4))}" />
            </c:otherwise>
        </c:choose>        
        
        <sql:query var="data">
            <c:if test="${groupby != 1}">
                select min(entered) entered,avg(ready) ready,avg(submitted) submitted ,avg(running) running from ( 
            </c:if> 
            select sum(ready) ready, sum(running) running, sum(submitted) submitted,entered
            from ${datatbl} 
            where entered>=? and entered<=?
            <sql:dateParam value="${startRange}"/>
            <sql:dateParam value="${endRange}"/>
            <c:if test="${sessionTaskName != 'ALL'}">
                and taskname = ?
                <sql:param value="${sessionTaskName}"/>
            </c:if>  
            group by entered order by entered
            <c:if test="${groupby != 1}">
                ) group by  floor(rownum/?) order by entered
                <sql:param value="${groupby}"/>
            </c:if> 
        </sql:query>
        
        <P><span class="emphasis"> Starting Date: ${startRange}
                &nbsp; -&nbsp; &nbsp;   Ending   Date: ${endRange}<br>
        ${fn:length(data.rows)} records found from table ${plotby} with group by ${groupby}</span></P> 
        
        <c:if test="${data.rowCount > 0}">
            
            <aida:plotter height="400"> 
                
                <aida:tuple var="tuple" query="${data}"/>        
                <aida:datapointset var="ready" tuple="${tuple}" yaxisColumn="READY" xaxisColumn="ENTERED" />   
                <aida:datapointset var="submitted" tuple="${tuple}" yaxisColumn="SUBMITTED" xaxisColumn="ENTERED" />   
                <aida:datapointset var="running" tuple="${tuple}" yaxisColumn="RUNNING" xaxisColumn="ENTERED" />
                <aida:region title= "Task: ${sessionTaskName}" >
                    <aida:style>
                        <aida:style type="legendBox">
                            <aida:attribute name="isVisible" value="false"/>
                        </aida:style>
                        <aida:style type="xAxis">
                            <aida:attribute name="label" value=""/>
                            <aida:attribute name="type" value="date"/>
                        </aida:style>
                        <aida:style type="data">
                            <aida:attribute name="connectDataPoints" value="true"/>
                        </aida:style>
                    </aida:style>   
                    
                    <aida:plot var="${ready}">
                        <aida:style type="plotter"> 
                            <aida:style type="yAxis">
                                <aida:attribute name="yAxis" value="Y1"/>
                                <aida:attribute name="label" value="<html><span color=\"blue\">Ready</span>"/>
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
                    <aida:plot var="${submitted}">
                        <aida:style type="plotter">
                            <aida:style type="yAxis">
                                <aida:attribute name="yAxis" value="Y0"/>
                                <aida:attribute name="label" value="<html><span color=\"green\">Running</span>/<span color=\"red\">Submitted</span>"/>
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
                    <aida:plot var="${running}">
                        <aida:style type="plotter">   
                            <aida:style type="data">
                                <aida:style type="outline">
                                    <aida:attribute name="color" value="green"/>
                                </aida:style>
                                <aida:style type="marker">
                                    <aida:attribute name="color" value="green"/>
                                    <aida:attribute name="shape" value="dot"/>
                                </aida:style>
                            </aida:style>
                        </aida:style>
                    </aida:plot>
                </aida:region>	 
            </aida:plotter>
            
        </c:if>
        <c:if test="${data.rowCount == 0}">
            
            <br> 
            <span class="emphasis"><strong>There are no records for the data requested</strong></span>.
            
        </c:if>
        <br> 
        
        <c:if test="${sessionTaskName == 'ALL' && data.rowCount>0}">
            <sql:query var="taskdata">
                select taskname
                from ${datatbl}
                where entered>=? and entered<=?
                <sql:dateParam value="${startRange}"/>
                <sql:dateParam value="${endRange}"/>
                group by taskname 
                order by taskname  
            </sql:query>
            
            Number of tasks active in time period ${taskdata.rowCount}.
            <c:if test="${taskdata.rowCount>30}">
                Per task plot suppressed due to excessive task count.
            </c:if>   
            <br>
            <c:if test="${taskdata.rowCount<=30}">
                
                <sql:query var="tasks">   
                    <c:if test="${groupby != 1}">
                        select min(entered) entered 
                        <c:forEach items="${taskdata.rows}" var="taskrow" varStatus="status"> 
                            ,avg(N${status.count}) N${status.count}                            
                        </c:forEach>
                        from ( 
                    </c:if>   
                    select entered
                    <c:forEach items="${taskdata.rows}" var="taskrow" varStatus="status"> 
                        ,max(case when taskname='${taskrow.taskname}' then running else 0 end) N${status.count}                               
                    </c:forEach>
                    from ${datatbl} 
                    where entered>=? and entered<=?
                    <sql:dateParam value="${startRange}"/>
                    <sql:dateParam value="${endRange}"/>
                    and running > 0
                    group by entered order by entered  
                    <c:if test="${groupby != 1}">
                        ) group by  floor(rownum/?) order by entered
                        <sql:param value="${groupby}"/>
                    </c:if>   		 
                </sql:query>
                
                <aida:plotter height="600"> 
                    <aida:region  title="Running processes by task">
                        <aida:style>
                            <aida:style type="legendBox">
                                <aida:attribute name="isVisible" value="true"/>
                            </aida:style>
                            <aida:style type="statisticsBox">
                                <aida:attribute name="isVisible" value="false"/>
                            </aida:style>                        
                            <aida:style type="xAxis">
                                <aida:attribute name="label" value=""/>
                                <aida:attribute name="type" value="date"/>
                            </aida:style>
                            <aida:style type="data">
                                <aida:attribute name="connectDataPoints" value="true"/>
                            </aida:style>
                        </aida:style>  
                        
                        <aida:tuple var="tuple" query="${tasks}"/>        
                        <c:forEach items="${taskdata.rows}" var="taskrow" varStatus="status">                                                                              
                            <aida:datapointset var="running" title="${taskrow.taskname}" tuple="${tuple}" yaxisColumn="N${status.count}" xaxisColumn="ENTERED" />                                 
                            <aida:plot var="${running}"/>               
                        </c:forEach>   
                    </aida:region>	 
                </aida:plotter>  
            </c:if>
        </c:if> 
    </body>
</html>

</body>
</html>
