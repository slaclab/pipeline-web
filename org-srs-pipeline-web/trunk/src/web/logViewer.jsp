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
    <script language="JavaScript" src="http://glast-ground.slac.stanford.edu/Commons/scripts/FSdateSelect.jsp"></script>
    <link rel="stylesheet" href="http://glast-ground.slac.stanford.edu/Commons/css/FSdateSelect.css" type="text/css"> 
</head>
<body>

<h2>Message Viewer</h2>

<%-- set date object for starting and ending dates --%>
<jsp:useBean id="logStartDate" class="java.util.Date" />
<jsp:useBean id="logEndDate" class="java.util.Date" />

<c:set var="clear"   value="${param.clear}" />
<c:set var="severity" value="${param.severity}"/> 
<c:set var="logTask" value="${param.task}"/>
<c:set var="logProcess" value="${param.process}" />
<c:set var="logProcessInstance" value="${param.processInstance}"/>
<c:set var="minimumDate" value="${param.minDate}"/> 
<c:set var="maximumDate" value="${param.maxDate}"/>

<c:if test="${!empty param.debug}">
    <h3>DEBUG=${param.debug}</h3>
    <c:set var="debug" value="${param.debug}" scope="session"/>     
</c:if>

<%-- check if this is first time visiting this page. Since log is huge set default if user does not have one --%>
<c:if test="${empty firstLogViewVisit}">
    <c:set var="firstLogViewVisit" value="beenHereDoneThat4" scope="session"/>
    <c:set var="ndays" value="${preferences.defaultMessagePeriodDays > 0 ? preferences.defaultMessagePeriodDays : '7'}"/>
    <c:set var="sessionLogDays" value="${ndays}" scope="session"/> 
    
    <c:choose> 
        <c:when test="${sessionLogDays > 0}"> 
            <c:set var="userSelectedNdays" value="true"/>
            <c:set var="userSelectedMinDate" value="false"/> 
            <c:set var="userSelectedMaxDate" value="false"/> 
            <c:set var="minimumDate" value='-1' /> 
            <c:set var="maximumDate" value='-1' />
        </c:when>
        <c:when test="${empty sessionLogDays || sessionLogDays < 1}">
            <c:set var="minimumDate" value="${logStartDate.time-preferences.defaultMessagePeriodMinutes*60*1000}"/>
            <c:set var="maximumDate" value='-1' />
            <c:set var="sessionLogDays" value="" scope="session"/> 
            <c:set var="userSelectedMinDate" value="true"/> 
            <c:set var="userSelectedMaxDate" value="false"/> 
        </c:when>
    </c:choose>
</c:if>

<c:if test="${debug == 1}"> 
    <h3>First Time Here. ndays=${ndays} sessionLogDays=${sessionLogDays} userSelectedNdays=${userSelectedNdays}<br>
        userSelectedMinDate=${userSelectedMinDate} userSelectedMaxDate=${userSelectedMaxDate}
    </h3>
</c:if>

<c:if test="${!empty param.submit}"> 
    <c:set var="minimumDate" value="${param.minDate}"/> 
    <c:set var="maximumDate" value="${param.maxDate}"/>
    <c:set var="ndays" value="${param.ndays}"/> 
    <c:set var="userSelectedMinDate" value="${!empty minDate && minDate != '-1' && mindate != sessionLogVMinDate && !empty param.Filter}"/> 
    <c:set var="userSelectedMaxDate" value="${!empty maxDate && maxDate != '-1' && maxDate != sessionLogVMaxDate && !empty param.Filter}"/>
    <c:set var="userSelectedNdays" value="${! empty ndays && !userSelectedMinDate && !userSelectedMaxDate && !empty param.Filter}" />
    
    <c:choose>
        <c:when test="${userSelectedMinDate || userSelectedMaxDate}">
            <c:set var="sessionLogDays" value="" scope="session"/>
            <c:set var="ndays" value=""/>
            <c:if test="${userSelectedMinDate}"> 
                <c:set var ="sessionLogMinDate" value="${minimumDate}" scope="session"/>
            </c:if>
            <c:if test="${userSelectedMaxDate}"> 
                <c:set var ="sessionLogMaxDate" value="${maximumDate}" scope="session"/>
            </c:if>
        </c:when>
        <c:when test="${userSelectedNdays && !userSelectedMinDate && !userSelectedMaxDate}">
            <c:set var="minimumDate" value='-1'/> 
            <c:set var="maximumDate" value='-1'/> 
            <c:set var="sessionLogDays" value="${ndays}" scope="session"/> 
            <c:set var ="sessionLogMinDate" value='-1' scope="session"/>
            <c:set var ="sessionLogMaxDate" value='-1' scope="session"/>
        </c:when>
    </c:choose> 
</c:if>

<c:if test= "${!empty clear || empty severity}">
    <c:set var="severity" value="800" /> 
    <c:set var="logTask" value=""/>
    <c:set var="logProcess" value=""/>
    <c:set var="logProcessInstance" value=""/>
    <c:set var="ndays" value="${preferences.defaultMessagePeriodDays}"/>
    <c:set var="sessionLogDays" value="${!empty ndays ? ndays : '7'}" scope="session"/> 
    <c:choose> 
        <c:when test="${sessionLogDays > 0}">
            <c:set var="userSelectedNdays" value="true"/> 
            <c:set var="minimumDate" value='-1'/>
            <c:set var="maximumDate" value='-1'/>
        </c:when>
        <c:when test="${sessionLogDays < 1 || empty sessionLogDays}">
            <c:set var="userSelectedMinDate" value="true"/> 
            <c:set var="minimumDate" value="${logStartDate.time-preferences.defaultMessagePeriodMinutes*60*1000}"/>
            <c:set var="maximumDate" value='-1'/>
            <c:set var="ndays" value=""/> 
        </c:when>
    </c:choose>
</c:if> 

<c:if test="${param.debug == 1}">
    <h3>
        userSelectedNdays: ${userSelectedNdays}<br>
        userSelectedMinDate: ${userSelectedMinDate}<br>
        userSelectedMaxDate: ${userSelectedMaxDate}<p>
        minimumDate: ${minimumDate}<br>
        maximumDate: ${maximumDate}<p>
        sessionLogMinDate: ${sessionLogMinDate}<br>
        sessionLogMaxDate: ${sessionLogMaxDate}<br>
        sessionLogDays: ${sessionLogDays}<p>
        ndays: ${ndays}<br>
    </h3>
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
<tr>
    <td><utils:dateTimePicker value="${minimumDate}" size="22" name="minDate" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/></td>
    <td><utils:dateTimePicker value="${maximumDate}" size="22" name="maxDate" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/></td>
    <td>or last N days <input name="ndays" type="text" value="${sessionLogDays}" size="5"></td>
    <td><input type="submit" value="Filter" name="submit">&nbsp;<input type="submit" value="Default" name="clear"></td>
    </td>
</tr>
</table>
</form>

<c:if test="${!empty param.submit || !empty clear || empty LVlog}"> 
    <gsql:query  var="LVlog" defaultSortColumn="timeentered" pageSize="500">
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
        <c:if test="${minimumDate > 0 && !userSelectedNdays}">
            and timeentered>=?       
            <jsp:setProperty name="logStartDate" property="time" value="${minimumDate}"/>   
            <gsql:dateParam value="${logStartDate}" type="timestamp"/> 
        </c:if>
        <c:if test="${maximumDate > 0 && !userSelectedNdays}"> 
            and timeentered<=?      
            <jsp:setProperty name="logEndDate" property="time" value="${maximumDate}" /> 	
            <gsql:dateParam value="${logEndDate}" type="timestamp"/> 
        </c:if>  
        <c:if test="${userSelectedNdays && !userSelectedMinDate && !userSelectedMaxDate}">
            and timeentered >= ? and timeentered <= ? 
            <jsp:useBean id="maxLogDateDays" class="java.util.Date" />
            <jsp:useBean id="minLogDateDays" class="java.util.Date" />
            <jsp:setProperty name="minLogDateDays" property="time" value="${maxLogDateDays.time - sessionLogDays*24*60*60*1000}" />       
            <gsql:dateParam value="${minLogDateDays}" type="timestamp"/> 
            <gsql:dateParam value="${maxLogDateDays}" type="timestamp"/> 
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
</c:if>

<display:table class="datatable" name="${LVlog}" sort="external" decorator="org.glast.pipeline.web.decorators.LogTableDecorator">
    <display:column property="timeentered" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" title="Time" sortable="true" headerClass="sortable" />
    <display:column property="log_level" decorator="org.glast.pipeline.web.decorators.LogLevelColumnDecorator" title="Level" sortable="true" headerClass="sortable" />
    <display:column property="taskLinkPath" title="Task" />
    <display:column property="processname" title="Process" sortable="true" headerClass="sortable" href="process.jsp" paramId="process" paramProperty="process"/>
    <display:column property="streamIdPath" title="Stream" href="pi.jsp" paramId="pi" paramProperty="processinstance" />
    <display:column property="message" title="Message" class="leftAligned" />
    <display:column property="exception" title="Detail" class="leftAligned" />
</display:table>

</body>
</html>
