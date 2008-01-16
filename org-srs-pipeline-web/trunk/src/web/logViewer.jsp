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
    <title>Pipeline Message Viewer</title> 
    <script language="JavaScript" src="http://glast-ground.slac.stanford.edu/Commons/scripts/FSdateSelect.jsp"></script>
    <link rel="stylesheet" href="http://glast-ground.slac.stanford.edu/Commons/css/FSdateSelect.css" type="text/css"> 
</head>
<body>

<h2>Message Viewer</h2>
<%-- set date object for starting and ending dates --%>
<jsp:useBean id="logStartDate" class="java.util.Date" />
<jsp:useBean id="logEndDate" class="java.util.Date" />

<c:if test="${! empty param.minDate}">
    <c:set var="minDate" value="${param.minDate}" scope="session"/>
</c:if>
<c:if test="${! empty param.maxDate}">
    <c:set var="maxDate" value="${param.maxDate}" scope="session"/>
</c:if>
<%-- If clear button selected set start and end dates to default values --%>
<c:set var="clear"   value="${param.clear}" /> 
<c:if test= "${clear =='Default'}"> 
    <c:set var="minDate" value="" scope="session"/>
    <c:set var="maxDate" value="" scope="session"/>
</c:if> 
<%-- If no start/end dates provided use default dates: start date = current date/time - 24 hours and end date = current date/time --%>
<c:if test="${empty minDate || minDate == -1}">
    <c:set var="minDate" value="${logStartDate.time-24*60*60*1000}" scope="session"/>
</c:if>
<c:if test="${empty maxDate || maxDate == -1}">
    <c:set var="maxDate" value="${logEndDate.time}" scope="session"/>
</c:if>
<jsp:setProperty name="logStartDate" property="time" value="${minDate}"/>   
<jsp:setProperty name="logEndDate" property="time" value="${maxDate}" /> 	

<c:set var="severity" value="${param.severity}" scope="session"/> 
<c:set var="logTask" value="${task}" scope="session"/>
<c:set var="logProcess" value="${process}" scope="session"/>
<c:set var="logProcessInstance" value="${processInstance}" scope="session"/>

<c:if test="${!empty clear || empty severity}">
    <c:set var="severity" value="800" scope="session"/> 
    <c:set var="logTask" value="" scope="session"/>
    <c:set var="logProcess" value="" scope="session"/>
    <c:set var="logProcessInstance" value="" scope="session"/>
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
    <td><utils:dateTimePicker value="${minDate}" size="22" name="minDate" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/></td>
    <td><utils:dateTimePicker value="${maxDate}" size="22" name="maxDate" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/></td>
    
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
    <c:if test="${!empty severity}"> and log_level>=? 
        <gsql:param value="${severity}"/>
    </c:if>    
    and timeentered>=?        
    <gsql:dateParam value="${logStartDate}" type="timestamp"/> 
    
    <c:if test="${!empty logEndDate  && logEndDate!='-1'  }"> and timeentered<=?       
        <gsql:dateParam value="${logEndDate}" type="timestamp"/> 
    </c:if>   
    <c:if test="${!empty logTask}">and task=?
        <gsql:param value="${logTask}"/>
    </c:if>
    <c:if test="${!empty logProcess}">and process=?
        <gsql:param value="${logProcess}"/>
    </c:if>
    <c:if test="${!empty logProcessInstance}">and processinstance=?
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
