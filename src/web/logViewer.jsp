<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>
<%@taglib prefix="utils" uri="http://glast-ground.slac.stanford.edu/utils" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/GlastSQL" prefix="gsql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
    <title>Message Viewer</title> 
</head>
<body>

<h2>Message Viewer</h2>  

<c:set var="debug" value="0"/> 

<c:set var="minimumLong" value="${param.minDate}"/>
<c:set var="maximumLong" value="${param.maxDate}"/>
<c:set var="nminutes" value="${param.nminutes}"/> 
<c:set var="severity" value="${param.severity}"/> 
<c:set var="logTask" value="${task}"/>
<c:set var="logProcess" value="${process}" />
<c:set var="logProcessInstance" value="${processInstance}"/>
<c:set var="userFirstVisit" value="${empty nminutes && empty minimumLong && empty maximumLong}"/>

<c:set var="userSelectedLogMin" value="${!empty minimumLong && minimumLong != '-1' && minimumLong != sessionLogMinimum }" />
<c:set var="userSelectedLogMax" value="${!empty maximumLong && maximumLong != '-1' && maximumLong != sessionLogMaximum }" />
<c:set var="userSelectedLogMinutes" value="${!empty nminutes && !userSelectedLogMin && !userSelectedLogMax }" /> 

<jsp:useBean id="logStartDate" class="java.util.Date" scope = "session"/>
<jsp:useBean id="logEndDate" class="java.util.Date" scope="session" />


<c:choose> 
    <c:when test="${userFirstVisit}">
        <c:set var="nminutes" value="${preferences.defaultMessagePeriodMinutes > 0 ? preferences.defaultMessagePeriodMinutes : '10'}"/>
        <c:set var="sessionLogMinutes" value="${nminutes}" scope="session"/> 
        <c:set var="sessionLogMinimum" value="${logEndDate.time-nminutes*60*1000}" scope="session"/>
        <c:set var="sessionLogMaximum" value="${logEndDate.time}" scope="session"/>
        <jsp:setProperty name="logStartDate" property="time" value="${sessionLogMinimum}"/> 
        <jsp:setProperty name="logEndDate" property="time" value="${sessionLogMaximum}"/>  
        <c:set var="userSelectedLogMinutes" value="true"/> 
        <c:set var="firstTimeInLogViewer" value="beenHereDoneThat6" scope="session"/> 
    </c:when>
    <c:when test="${userSelectedLogMin || userSelectedLogMax}">
        
        <c:set var="userSelectedLogMinutes" value="false"/> 
        <c:set var="sessionLogMinutes" value="" scope="session"/> 
        <c:if test="${userSelectedLogMin}">
            <c:set var ="sessionLogMinimum" value="${minimumLong}"/>
            <jsp:setProperty name="logStartDate" property="time" value="${sessionLogMinimum}"/>
        </c:if>
        <c:if test="${userSelectedLogMax}">
            <c:set var ="sessionLogMaximum" value="${maximumLong}" />
            <jsp:setProperty name="logEndDate" property="time" value="${sessionLogMaximum}"/>
        </c:if>
    </c:when>
    <c:when test="${userSelectedLogMinutes && !userSelectedLogMin && !userSelectedLogMax}">
        <c:set var="sessionLogMinutes" value="${nminutes}"/> 
    </c:when>
</c:choose>

<%-- must update session variable when user resubmits timepick of none e.g. -1 --%>
<c:if test="${!userSelectedLogMax && maximumLong == '-1' }"> 
    <c:set var="sessionLogMaximum" value='-1'/> 
</c:if>
<c:if test="${!userSelectedLogMin && minimumLong == '-1' }"> 
    <c:set var="sessionLogMinimum" value='-1'/> 
</c:if>

<c:set var="clear" value="${param.clear}" />

<%-- If clear button selected, set start to enddate minus nminutes for default date values --%>
<%--
<jsp:setProperty name="logStartDate" property="time" value="${sessionLogMinimum}"/> 
    <jsp:setProperty name="logEndDate" property="time" value="${sessionLogMaximum}"/>  
--%>

<c:if test= "${clear =='Default'}"> 
    <c:set var="nminutes" value="${preferences.defaultMessagePeriodMinutes > 0 ? preferences.defaultMessagePeriodMinutes : '10'}"/>
    <h3>CLEAR DEFAULTS nminutes=${nminutes}</h3>
    <c:set var="userSelectedLogMinutes" value="true" scope="session" /> 
    <c:set var="minimumLong" value='-1'/>
    <c:set var="maximumLong" value='-1'/>
    <c:set var="sessionLogMinutes" value="${nminutes}" scope="session"/> 
    <c:set var="sessionLogMinimum" value="${logEndDate.time-nminutes*60*1000}"/> 
    <c:set var="sessionLogMaximum" value="${logEndDate.time}"/>
    <c:set var="severity" value="800" /> 
    <c:set var="logTask" value=""/>
    <c:set var="logProcess" value=""/>
    <c:set var="logProcessInstance" value=""/>
</c:if> 

<%-- old code replaced by firstVistToLogViewer
     If no start/end dates provided use default dates: start date = current date/time - 24 hours and end date = None 
<c:if test="${empty minimumDate}">
    <c:set var="minimumDate" value="${logStartDate.time-preferences.defaultMessagePeriodMinutes*60*1000}"/>
</c:if>
<c:if test="${empty maximumDate}">
    <c:set var="maximumDate" value="-1"/>
</c:if>
--%>
     
<c:if test="${empty severity}">
    <c:set var="severity" value="800" /> 
    <c:set var="logTask" value=""/>
    <c:set var="logProcess" value=""/>
    <c:set var="logProcessInstance" value=""/>
</c:if>

<form name="DateForm">
<table class="filtertable">
<tr>
    <td colspan="20">
        Task: <pt:taskChooser name="task" selected="${logTask}" allowNone="true" useKey="true"/>
        <c:if test="${!empty logTask}">
            Process: <pt:processChooser name="process" selected="${logProcess}" allowNone="true" task="${logTask}"/> 
            <c:if test="${!empty logProcess}">
                Stream <pt:processInstanceChooser name="pi" selected="${logProcessInstance}" allowNone="true" process="${logProcess}"/> 
            </c:if>
        </c:if>
        Severity: <select name="severity">
            <option value="0">-</option>
            <option ${severity==1000 ? 'selected' : ''} value="1000">SEVERE</option>
            <option ${severity==900 ? 'selected' : ''} value="900">WARNING</option>
            <option ${severity==800 ? 'selected' : ''} value="800">INFO</option>
            <option ${severity==500 ? 'selected' : ''} value="500">FINE</option>
            <option ${severity==400 ? 'selected' : ''} value="400">FINER</option>
            <option ${severity==300 ? 'selected' : ''} value="300">FINEST</option>
        </select>
    </td>
</tr>

<%--
<c:set var="timezone" value="PST" /><br>
    ${utils:now(timezone)} ${minimumLong} ${maximumLong} <br>
--%>

<tr>
    <td><utils:dateTimePicker value="${minimumLong}" size="22" name="minDate" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/></td>
    <td><utils:dateTimePicker value="${maximumLong}" size="22" name="maxDate" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/></td>
    <td>last <input type="text" value="${sessionLogMinutes}" size="4" name="nminutes"/> minutes</td>
    <td><input type="submit" value="Filter" name="submit">&nbsp;<input type="submit" value="Default" name="clear"></td>
    </td>
</tr>
</table>
</form>

<c:if test="${debug == 0}"> 
    <gsql:query  var="log" defaultSortColumn="timeentered" pageSize="500">
        select log, log_level, message, timeentered, processInstance, process, processname, taskPath, taskNamePath,
        case when exception is null then 0 else 1 end hasException,
        PII.GetStreamIdPath(stream) streamIdPath
        from log l
        left outer join processinstance i using (processinstance)
        left outer join process p using (process)
        left outer join taskpath t using (task)
        where log_level > 0 
        <c:if test="${!empty severity}"> 
            and log_level>=? 
            <gsql:param value="${severity}"/>
        </c:if> 
        <c:if test="${sessionLogMinimum != '-1' && !userSelectedLogMinutes}">
            and timeentered >= ?       
            <jsp:useBean id="minuteBeanStart1" class="java.util.Date" scope="session"/>
            <jsp:setProperty name="minuteBeanStart1" property="time" value="${sessionLogMinimum}" />
            <gsql:dateParam value="${minuteBeanStart1}" type="timestamp"/> 
        </c:if>
        <c:if test="${sessionLogMaximum != '-1' && !userSelectedLogMinutes}"> 
            and timeentered <= ?     
            <jsp:useBean id="minuteBeanEnd1" class="java.util.Date" scope="session"/>
            <jsp:setProperty name="minuteBeanEnd1" property="time" value="${sessionLogMaximum}" />
            <gsql:dateParam value="${minuteBeanEnd1}" type="timestamp"/> 
        </c:if>   
        <c:if test="${userSelectedLogMinutes && !userSelectedLogMin && !userSelectedLogMax}">
            and timeentered >= ? and timeentered <= ?
            <jsp:useBean id="minuteBeanStart2" class="java.util.Date" scope="session"/>
            <jsp:useBean id="minuteBeanEnd2" class="java.util.Date" scope="session"/> 
            <jsp:setProperty name="minuteBeanStart2" property="time" value="${minuteBeanEnd2.time - sessionLogMinutes*60*1000}" />
            <gsql:dateParam value="${minuteBeanStart2}" type="timestamp"/> 
            <gsql:dateParam value="${minuteBeanEnd2}" type="timestamp"/> 
        </c:if>
        <c:if test="${!empty logTask}">
            and task=?
            <gsql:param value="${logTask}"/>
        </c:if>
        <c:if test="${!empty logProcess}">
            and process=?
            <gsql:param value="${logProcess}"/>
        </c:if>
        <c:if test="${!empty logProcessInstance}">
            and processinstance=?
            <gsql:param value="${logProcessInstance}"/>
        </c:if>
    </gsql:query>
    
    <display:table class="datatable" name="${log}" sort="external" decorator="org.glast.pipeline.web.decorators.LogTableDecorator">          
        <display:column property="timeentered" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" title="Time" sortable="true" headerClass="sortable" />
        <display:column property="log_level" decorator="org.glast.pipeline.web.decorators.LogLevelColumnDecorator" title="Level" sortable="true" headerClass="sortable" />
        <display:column property="taskLinkPath" title="Task" />
        <display:column property="processname" title="Process" sortable="true" headerClass="sortable" href="process.jsp" paramId="process" paramProperty="process"/>
        <display:column property="streamIdPath" title="Stream" href="pi.jsp" paramId="pi" paramProperty="processinstance" />
        <display:column property="message" title="Message" class="leftAligned" />
        <display:column property="exception" title="Detail" class="leftAligned" />
    </display:table>
</c:if>

</body>
</html>
