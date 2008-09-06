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
    <title>Message Viewer: Task: ${task} Process: ${process} Instance: ${processInstance}</title> 
    <script language="JavaScript" src="http://glast-ground.slac.stanford.edu/Commons/scripts/FSdateSelect.jsp"></script>
    <link rel="stylesheet" href="http://glast-ground.slac.stanford.edu/Commons/css/FSdateSelect.css" type="text/css"> 
</head>
<body>

<h2>Message Viewer: Task: ${task} Process: ${process} Instance: ${processInstance} </h2>

<%-- set date object for starting and ending dates --%>
<jsp:useBean id="logStartDate" class="java.util.Date" />
<jsp:useBean id="logEndDate" class="java.util.Date" />

<c:if test="${!empty param.minDate}">
    <c:set var="minimumDate" value="${param.minDate=='None' ? -1 : param.minDate}"/>
</c:if>
<c:if test="${!empty param.maxDate}">
    <c:set var="maximumDate" value="${param.maxDate=='None' ? -1 : param.maxDate}"/>
</c:if>
<%-- If clear button selected set start and end dates to default values --%>
<c:set var="clear"   value="${param.clear}" /> 
<c:if test= "${clear =='Default'}"> 
    <c:set var="minimumDate" value=""/>
    <c:set var="maximumDate" value=""/>
</c:if> 
<%-- If no start/end dates provided use default dates: start date = current date/time - 24 hours and end date = None --%>
<c:if test="${empty minimumDate}">
    <c:set var="minimumDate" value="${logStartDate.time-preferences.defaultMessagePeriodMinutes*60*1000}"/>
</c:if>
<c:if test="${empty maximumDate}">
    <c:set var="maximumDate" value="-1"/>
</c:if>

<c:set var="severity" value="${param.severity}"/> 
<c:set var="logTask" value="${task}"/>
<c:set var="logProcess" value="${process}" />
<c:set var="logProcessInstance" value="${processInstance}"/>

<c:if test="${!empty clear || empty severity}">
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
<tr>
    <td><utils:dateTimePicker value="${minimumDate}" size="22" name="minDate" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/></td>
    <td><utils:dateTimePicker value="${maximumDate}" size="22" name="maxDate" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/></td>
    
    <td><input type="submit" value="Filter" name="submit">&nbsp;<input type="submit" value="Default" name="clear"></td>
    </td>
</tr>
</table>
</form>
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
    <c:if test="${minimumDate !='-1'}">
       and timeentered>=?       
       <jsp:setProperty name="logStartDate" property="time" value="${minimumDate}"/>   
       <gsql:dateParam value="${logStartDate}" type="timestamp"/> 
    </c:if>
    <c:if test="${maximumDate!='-1'}"> 
       and timeentered<=?      
       <jsp:setProperty name="logEndDate" property="time" value="${maximumDate}" /> 	
       <gsql:dateParam value="${logEndDate}" type="timestamp"/> 
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
</body>
</html>
