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

<%-- set date object for starting and ending dates --%>
<jsp:useBean id="logStartDate" class="java.util.Date" />
<jsp:useBean id="logEndDate" class="java.util.Date" />

<c:set var="debug" value="0"/>

<c:set var="minimumLong" value="${param.minDate}"/>
<c:set var="maximumLong" value="${param.maxDate}"/>
<c:set var="nminutes" value="${param.nminutes}"/>
<c:set var="severity" value="${param.severity}"/>
<c:set var="logTask" value="${task}"/>
<c:set var="logProcess" value="${process}" />
<c:set var="logProcessInstance" value="${processInstance}"/>
<c:set var="clear" value="${param.clear}" />

<c:if test="${empty firstLogVisit}">
    <c:set var="nminutes" value="${preferences.defaultMessagePeriodMinutes > 0 ? preferences.defaultMessagePeriodMinutes : '10'}"/>
    <c:set var="sessionLogMinutes" value="${nminutes}" scope="session"/>
    <c:set var="userSelectLogMinutes" value="true" scope="session"/> 
    <c:set var="userSelectLogMinimum" value="false" scope="session"/>
    <c:set var="userSelectLogMaximum" value="false" scope="session"/>
    <c:set var="userSelectLogSame" value="false" scope="session"/>
    <c:set var="firstLogVisit" value="beenVisited" scope="session"/>
    <h3>first visit nminutes=${nminutes} sessionLogMinutes=${sessionLogMinutes} </h3>
</c:if>

<c:if test="${! empty param.submit}">
    <c:set var="minimumLong" value="${param.minDate}"/>
    <c:set var="maximumLong" value="${param.maxDate}"/>
    <c:set var="nminutes" value="${param.nminutes}"/>
    <c:set var="userSelectLogMinimum" value="${!empty minimumLong && minimumLong != '-1' && minimumLong != sessionLogMinimum}" scope="session"/>
    <c:set var="userSelectLogMaximum" value="${!empty maximumLong && maximumLong != '-1' && maximumLong != sessionLogMaximum}" scope="session"/>
    <c:set var="userSelectLogMinutes" value="${!empty nminutes && !userSelectLogMinimum && !userSelectLogMaximum }" scope="session"/>
    <c:set var="userSelectLogSame" value="${!userSelectLogMinutes && !userSelectLogMinimum || !userSelectLogMaximum}" scope="session"/>

    <c:if test="${debug == 1}">
        <h3> BEFORE Choose<br>
            userSelectLogMinimum=${userSelectLogMinimum} minDate=${param.minDate} minimumLong=${minimumLong}<br>
            userSelectLogMaximum=${userSelectLogMaximum} maxDate=${param.maxDate} maximumLong=${maximumLong}<br>
            userSelectLogMinutes=${userSelectLogMinutes} minutes="${nminutes} <br>
            userSelectLogSame=${userSelectLogSame}<br>
        </h3>
    </c:if>

    <c:choose>
        <c:when test="${userSelectLogMinimum || userSelectLogMaximum}">
            <c:set var="sessionLogMinutes" value="" scope="session"/>
            <c:set var="nminutes" value="" />
            <c:set var="userSelectLogMinutes" value="false" />
            <c:if test="${userSelectLogMinimum}">
                <c:set var="sessionLogMinimum" value="${minimumLong}" scope="session"/>
            </c:if>
            <c:if test="${userSelectLogMaximum}">
                <c:set var="sessionLogMaximum" value="${maximumLong}" scope="session"/>
            </c:if>
        </c:when>
        <c:when test="${userSelectLogMinutes}">
            <c:set var="minimumLong" value="" />
            <c:set var="maximumLong" value="" />
            <c:set var="sessionLogMinimum" value="" scope="session" />
            <c:set var="sessionLogMaximum" value="" scope="session" />
            <c:set var="sessionLogMinutes" value="${nminutes}" scope="session"/>
            <c:set var="userSelectLogSame" value="false" scope="session"/> 
        </c:when>
    </c:choose>

    <c:if test="${debug == 1}">
        <h3> AFTER Choose<br>
            userSelectLogMinimum=${userSelectLogMinimum} minDate=${param.minDate} minimumLong=${minimumLong}<br>
            userSelectLogMaximum=${userSelectLogMaximum} maxDate=${param.maxDate} maximumLong=${maximumLong}<br>
            userSelectLogMinutes=${userSelectLogMinutes}<br>
            userSelectLogSame=${userSelectLogSame}<br>
        </h3>
    </c:if>

</c:if>

<c:if test="${empty severity}">
    <c:set var="severity" value="800" />
    <c:set var="logTask" value=""/>
    <c:set var="logProcess" value=""/>
    <c:set var="logProcessInstance" value=""/>
</c:if>

<c:if test= "${clear =='Default'}">
    <c:set var="nminutes" value="${preferences.defaultMessagePeriodMinutes > 0 ? preferences.defaultMessagePeriodMinutes : '10'}"/>
    <c:set var="userSelectLogMinutes" value="true" scope="session" />
    <c:set var="minimumLong" value='-1'/>
    <c:set var="maximumLong" value='-1'/>
    <c:set var="sessionLogMinutes" value="${nminutes}" scope="session"/>
    <c:set var="sessionLogMinimum" value=""/>
    <c:set var="sessionLogMaximum" value=""/>
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
    <td><utils:dateTimePicker value="${minimumLong}" size="22" name="minDate" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/></td>
    <td><utils:dateTimePicker value="${maximumLong}" size="22" name="maxDate" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/></td>
    <td>last <input type="text" value="${sessionLogMinutes}" size="4" name="nminutes"/> minutes</td>
    <td><input type="submit" value="Filter" name="submit">&nbsp;<input type="submit" value="Default" name="clear"></td>
    </td>
</tr>
</table>
</form>

<c:if test="${debug == 1}">
    <h3>
        userSelectLogMinimum = ${userSelectLogMinimum} minimumLong=${minimumLong} sessionLogMinimum=${sessionLogMinimum}<br>
        userSelectLogMaximum = ${userSelectLogMaximum} maximumLong=${maximumLong} sessionLogMaximum=${sessionLogMaximum}<br>
        userSelectLogMinutes = ${userSelectLogMinutes} nminutes=${nminutes} sessionLogMinutes=${sessionLogMinutes}<br>
        userSelectLogSame = ${userSelectLogSame}<br>
    </h3>

    <c:if test="${userSelectLogMinimum || (userSelectLogSame && minimumLong != -1) }">
        and timeentered>=?
        <h3>*1* and timeentered >= ${minimumLong}</h3>
    </c:if>
    <c:if test="${userSelectLogMaximum || (userSelectLogSame && maximumLong != -1)}">
        and timeentered<=?
        <h3>*2* and timeentered <= ${maximumLong}</h3>
    </c:if>
    <c:if test="${userSelectLogMinutes}">
        <h3>*3* and timeentered >= ${logStartDate} - ${nminutes} minutes and timeentered <= ${logEndDate} </h3>
    </c:if>
</c:if>

<%--
<c:if test="${userSelectLogMinutes || (!userSelectLogSame && minimumLong == -1 && maximumLong == -1)}">
        <h3>*3* and timeentered >= ${logStartDate} - ${nminutes} minutes and timeentered <= ${logEndDate} </h3>
    </c:if>
--%>

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
        <c:if test="${userSelectLogMinimum || (userSelectLogSame && minimumLong != -1) }">
            and timeentered>=?
            <jsp:setProperty name="logStartDate" property="time" value="${minimumLong}"/>
            <gsql:dateParam value="${logStartDate}" type="timestamp"/>
        </c:if>
        <c:if test="${userSelectLogMaximum || (userSelectLogSame && maximumLong != -1)}">
            and timeentered<=?
            <jsp:setProperty name="logEndDate" property="time" value="${maximumLong}" />
            <gsql:dateParam value="${logEndDate}" type="timestamp"/>
        </c:if>
        <c:if test="${userSelectLogMinutes || (userSelectLogSame && minimumLong == -1 && maximumLong == -1)}">
            and timeentered >= ? and timeentered <= ?
            <jsp:setProperty name="logStartDate" property="time" value="${logEndDate.time-sessionLogMinutes*60*1000}" />
            <gsql:dateParam value="${logStartDate}" type="timestamp"/>
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

    <display:table excludedParams="submit" class="datatable" name="${log}" sort="external" decorator="org.glast.pipeline.web.decorators.LogTableDecorator">
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
