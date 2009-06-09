<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/utils" prefix="utils" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/GroupManager" prefix="gm" %>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<head>
    <title>Streams for task: ${taskName}</title>
    <script language="JavaScript" src="http://glast-ground.slac.stanford.edu/Commons/scripts/FSdateSelect.jsp"></script>
    <link rel="stylesheet" href="http://glast-ground.slac.stanford.edu/Commons/css/FSdateSelect.css" type="text/css">        
</head>
<body>

<%-- must check if this is the first time user comes to this page --%>
<c:if test="${ empty firstTimeInStreamsPage}">
    <c:set var="ndays" value="${preferences.defaultStreamPeriodDays > 0 ? preferences.defaultStreamPeriodDays : ''}"/>
    <c:if test="${ndays > 0}">
        <c:set var="sessionStreamNdays" value="${ndays}" scope="session"/> 
        <c:set var="userSelectedSessionNdays" value="true" scope="session"/>
    </c:if>
    <c:set var="firstTimeInStreamsPage" value="beenHereDoneThat1" scope="session"/> 
</c:if>

<%-- if you add &debug=1 to url then debugging is on. --%>
<c:if test="${!empty param.debug}">
    <h3>DEBUG=${param.debug}</h3>
    <c:set var="debug" value="${param.debug}" scope="session"/>     
</c:if>

<c:set var="showLatest" value="${!empty param.showLatestChanged ? !empty param.showLatest : empty showLatest ? true : showLatest}" scope="session"/>
<c:set var="status" value="${!empty param.status && param.status!='0' ? param.status : ''}"/>
<c:set var="min" value="${param.min}" scope="session"/>
<c:set var="max" value="${param.max}" scope="session"/> 
<c:set var="minimumDate" value="${param.minDate}"/>
<c:set var="maximumDate" value="${param.maxDate}"/>
<c:set var="ndays" value="${param.ndays}"/>  

<%-- only execute this "if block" when user clicked submit --%>
<c:if test="${!empty param.submit}"> 
    <c:set var="userSelectedSessionMinimum" value="${!empty minimumDate && minimumDate != '-1' && minimumDate != sessionStreamMinDate }" scope="session" />
    <c:set var="userSelectedSessionMaximum" value="${!empty maximumDate && maximumDate != '-1' && maximumDate != sessionStreamMaxDate }" scope="session" />
    <c:set var="userSelectedTaskName" value="${!empty taskName}" /> 
    <c:set var="userSelectedSessionNdays" value="${!empty ndays && !userSelectedSessionMinimum && !userSelectedSessionMaximum }" scope="session"/>
    
    <c:choose>
        <c:when test="${userSelectedSessionMinimum || userSelectedSessionMaximum}">
            <c:set var="sessionStreamNdays" value="" scope="session"/> 
            <c:if test="${userSelectedSessionMinimum}">
                <c:set var ="sessionStreamMinDate" value="${minimumDate}" scope="session"/>
            </c:if>
            <c:if test="${userSelectedSessionMaximum}">
                <c:set var ="sessionStreamMaxDate" value="${maximumDate}" scope="session"/>
            </c:if>
        </c:when>
        <c:when test="${userSelectedSessionNdays}">
            <c:set var="minimumDate" value='-1'/> 
            <c:set var="maximumDate" value='-1'/> 
            <c:set var="sessionStreamNdays" value="${ndays}" scope="session"/> 
            <c:set var ="sessionStreamMinDate" value="" scope="session"/>
            <c:set var ="sessionStreamMaxDate" value="" scope="session"/>
        </c:when>
        <c:when test="${!userSelectedSessionMinimum && !userSelectedSessionMaximum && !userSelectedSessionNdays}">
            <c:set var ="sessionStreamMinDate" value="${minimumDate}" scope="session"/>
            <c:set var ="sessionStreamMaxDate" value="${maximumDate}" scope="session"/>
            <c:set var="sessionStreamNdays" value="${ndays}" scope="session"/> 
        </c:when>
    </c:choose>
</c:if>

<c:if test="${debug == 1}"> 
    <h3>
        userSelectedSessionNdays: ${userSelectedSessionNdays}<br>
        userSelectedSessionMinimum: ${userSelectedSessionMinimum}<br>
        userSelectedSessionMaximum: ${userSelectedSessionMaximum}<p>
        sessionStreamNdays: ${sessionStreamNdays}<br>
        sessionStreamMinDate: ${sessionStreamMinDate}<br>
        sessionStreamMaxDate: ${sessionStreamMaxDate}<p>
        minimumdate: ${minimumDate}<br>
        maximumdate: ${maximumDate}<p>
        ndays: ${ndays}<br>
        min: ${min}<br>
        max: ${max}<br>
        showLatest: ${param.showLatest}<br>
        showLatestChanged: ${param.showLatestChanged}<br>
        param.submit: ${param.submit}<br>
    </h3>
</c:if>

<c:if test="${!empty param.reset}">
    <c:set var="pref_ndays" value="${preferences.defaultStreamPeriodDays > 0 ? preferences.defaultStreamPeriodDays : ''}"/> 
    <c:set var="ndays" value="${!empty pref_ndays ? pref_ndays : ''}"/> 
    <c:set var="sessionStreamNdays" value="${ndays}" scope="session"/>
    <c:set var="min" value=""/>
    <c:set var="max" value=""/>
    <c:set var="minDate" value='-1'/> 
    <c:set var="maxDate" value='-1'/> 
    <c:set var="minimumDate" value='-1'/>
    <c:set var="maximumDate" value='-1'/> 
    <c:set var="status" value=""/>
    <c:set var ="sessionStreamMinDate" value='-1'/>
    <c:set var ="sessionStreamMaxDate" value='-1'/> 
    <c:choose>
         <c:when test ="${ndays > 0}"> 
        <c:set var="userSelectedSessionNdays" value="true"/>
    </c:when>
        <c:otherwise>
            <c:set var="userSelectedSessionNdays" value="false"/>
        </c:otherwise>
    </c:choose>
</c:if>

<sql:query var="taskVersion">
    select version,revision from task where task=?
    <sql:param value="${param.task}"/>
</sql:query>

<h2>Streams for task: ${taskName} ${taskVersion.rows[0]["version"]}.${taskVersion.rows[0]["revision"]} </h2>

<%-- execute the if block only when the user submits something, resets the form or the query hasn't been made yet --%>
<c:if test="${!empty param.submit || !empty param.reset || empty test || ( param.showLatestChanged) }">
    
<sql:query var="test" scope="session"> 
    select stream.*,PII.GetStreamPath(stream) StreamPath, PII.GetStreamIdPath(stream) StreamIdPath, PII.GetStreamProgress(stream) progress
    from stream    
    where task=? 
    <sql:param value="${param.task}" />
    
    <c:if test="${showLatest}"> and isLatest=1 and PII.GetStreamIsLatestPath(stream)=1</c:if>
    
    <c:if test="${!empty status}"> 
        <c:set var ="NumStatusReqs" value = "${fn:length(paramValues.status)}" />      
        <c:set var ="LastReq" value = "${fn:length(paramValues.status) -1}" />
        <c:choose> 
            <c:when  test = "${NumStatusReqs > 1}"> 
                and streamstatus in (
                <c:forEach  var="i" begin= "0" end="${NumStatusReqs -'1'}" step="1" > 
                    <c:set var ="testi" value = "${i}" />                                          
                    <c:if test = "${testi== LastReq}">           
                        '${paramValues.status[i]}'                        
                    </c:if>
                    <c:if test = "${testi != LastReq}">
                        '${paramValues.status[i]}',                     
                    </c:if>                       
                </c:forEach>
                )
            </c:when>   
            <c:otherwise>     
                <c:if test= "${status != 'NOTSUCCESS'}">
                    and streamstatus=?
                    <sql:param value="${status}"/>
                </c:if>
                <c:if test= "${status == 'NOTSUCCESS'}">
                    and streamstatus != 'SUCCESS'            
                </c:if>         
            </c:otherwise>
        </c:choose>
    </c:if>   
    <c:if test="${!empty min}">
        and StreamId>=? 
        <sql:param value="${min}"/>
    </c:if>
    <c:if test="${!empty max}">
        and StreamId<=?
        <sql:param value="${max}"/>
    </c:if>
    
    <c:if test="${minimumDate > 0 && !userSelectedSessionNdays}">
        and STARTDATE>=?
        <jsp:useBean id="minDateUsed" class="java.util.Date" />
        <jsp:setProperty name="minDateUsed" property="time" value="${minimumDate}" />       
        <sql:dateParam value="${minDateUsed}" type="timestamp"/> 
    </c:if>
    <c:if test="${maximumDate > 0 && !userSelectedSessionNdays}">
        and ENDDATE<=?
        <jsp:useBean id="maxDateUsed" class="java.util.Date" />
        <jsp:setProperty name="maxDateUsed" property="time" value="${maximumDate}" />
        <sql:dateParam value="${maxDateUsed}" type="timestamp"/> 
    </c:if>
    <c:if test="${userSelectedSessionNdays && !userSelectedSessionMinimum && !userSelectedSessionMaximum}">
        and STARTDATE >= ? and ENDDATE <= ?
        <jsp:useBean id="maxDateUsedDays" class="java.util.Date" />
        <jsp:useBean id="minDateUsedDays" class="java.util.Date" />
        <jsp:setProperty name="minDateUsedDays" property="time" value="${maxDateUsedDays.time - sessionStreamNdays*24*60*60*1000}" />       
        <sql:dateParam value="${minDateUsedDays}" type="timestamp"/> 
        <sql:dateParam value="${maxDateUsedDays}" type="timestamp"/>    
    </c:if>   
</sql:query>    
</c:if>

<sql:query var="statii">
    select STREAMSTATUS from STREAMSTATUS order by displayorder
</sql:query>

<%-- uses session variables for date or days, they will be reset to the latest value whenever the user actually changes either the calendar or Ndays --%>
<form name="DateForm">
    <table class="filtertable"><tr><th>Stream</th><td>Min</td><td><input type="text" name="min" value="${min}"></td><td>Max</td><td><input type="text" name="max" value="${max}"></td> 
            <td>Status: <select size="3" name="status" multiple>
                    <option value="" ${status=="" ? "selected" : ""}>All</option>
                <option value="NOTSUCCESS" ${status=="NOTSUCCESS" ? "selected" : ""} >All Not Success </option> 
                <c:forEach var="row" items="${statii.rows}">
                    <c:set var= "found" value = "0" /> 
                    <c:forEach  var = "seletedStatus" items = "${paramValues.status}" > 
                        <c:if test = "${seletedStatus ==  row.STREAMSTATUS}">
                            <c:set var= "found" value = "1" />    
                        </c:if>                                                    
                    </c:forEach>   
                    <option value="${row.STREAMSTATUS}" ${found =="1" ? "selected" : ""}>${pl:prettyStatus(row.STREAMSTATUS)}</option>                                                               
                </c:forEach>                         
                <tr><th>Date</th>
                <td>Start</td><td><utils:dateTimePicker value="${sessionStreamMinDate}" size="22" name="minDate" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/></td>
                <td>End</td><td><utils:dateTimePicker value="${sessionStreamMaxDate}" size="22" name="maxDate" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/></td>
                <td>or last N days <input name="ndays" type="text" value="${sessionStreamNdays}" size="5"></td> 
            </td>
            <td><input type="submit" value="Filter" name="submit">&nbsp;<input type="submit" value="Reset" name="reset">
        <input type="hidden" name="task" value="${task}"></td></tr>
        <tr><td colspan="4"><input type="checkbox" name="showAll" ${empty param.showAll ? "" : "checked"} > Show all streams on one page</td></tr>
    </table>
</form>

<pt:autoCheckBox name="showLatest" value="${showLatest}">Show only latest execution</pt:autoCheckBox>

<script language="JavaScript" type="text/javascript">
         function ShowAll(set) {
           for (var i = 0; i < document.selectForm.elements.length; i++) {
             if(document.selectForm.elements[i].type == 'checkbox'){
               document.selectForm.elements[i].checked = set;
             }
           }
         }
         function ToggleAll() {
           for (var i = 0; i < document.selectForm.elements.length; i++) {
             if(document.selectForm.elements[i].type == 'checkbox'){
               document.selectForm.elements[i].checked = !(document.selectForm.elements[i].checked);
             }
           }
         }
</script>  

<c:set var="adminMode" value="${gm:isUserInGroup(userName,'PipelineAdmin')}"/>
<c:choose>
<c:when test="${param.format=='stream'}">
    <pre><c:forEach var="row" items="${test.rows}">${row.streamid}<br></c:forEach></pre>
</c:when>
<c:otherwise>
<form name="selectForm" action="confirm.jsp" method="post">
<display:table excludedParams="submit" class="datatable" name="${test.rows}" id="row" sort="list" defaultsort="1" defaultorder="descending" pagesize="${test.rowCount>50 && empty param.showAll ? preferences.showStreams : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >
<display:column property="StreamId" title="Stream" sortable="true" headerClass="sortable" comparator="org.glast.pipeline.web.decorators.StreamPathComparator" href="si.jsp" paramId="stream" paramProperty="stream"/>
<c:if test="${row.StreamStatus =='FAILED'}">
    <display:column title="Status" sortable="true" headerClass="sortable">
        <font color="#FF0000"> ${row.StreamStatus} </font>
    </display:column>
</c:if>
<c:if test="${row.StreamStatus !='FAILED'}">
    <display:column title="Status" sortable="true" headerClass="sortable">
        ${row.StreamStatus}  
    </display:column>
</c:if>  

<c:if test="${!showLatest}">
    <display:column title="#">
        ${row.executionNumber}${row.isLatest>0 ? "(*)" : ""}
    </display:column>
</c:if>
<display:column property="CreateDate" title="Created" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator"/>
<display:column property="StartDate" title="Started" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator"/>
<display:column property="EndDate" title="Ended" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator"/>
<display:column title="Progress">
    <c:set var="p" value="${fn:split(row.progress,':')}"/>
    <utils:progressBar donePercentage="${100*p[0]/(p[0]+p[1]+p[2])}" errorPercentage="${100*p[1]/(p[0]+p[1]+p[2])}" />
</display:column>
<c:if test="${adminMode}">   
    <display:column property="isLatestStreamSelector" title=" " class="admin"/>       
    <display:footer>
        <tr>
            <td colspan="20" class="admin">     
                <a href="javascript:void(0)" onClick="ShowAll(true);">Select all</a>&nbsp;.&nbsp;
                <a href="javascript:void(0)" onClick="ShowAll(false);">Deselect all</a>&nbsp;.&nbsp;
                <a href="javascript:void(0)" onClick="ToggleAll();">Toggle selection</a>
                <input type="hidden" name="task" value="${task}">
                <input type="hidden" name="app" value="streams">
                <input type="hidden" name="status" value="${param.status}">
                <input type="submit" value="Rollback Selected Streams" name="submit">
            </td>
        </tr>
    </display:footer>
    </tr>   
</c:if>
</display:table>

</form>

<c:if test="${test.rowCount>0}">
    <ul>
        <li><a href="streams.jsp?task=${param.task}&min=${param.min}&max=${param.max}&status=${param.status}&minDate=${param.minDate}&maxDate=${param.maxDate}&format=stream">Dump stream id list</a>.</li>
    </ul>
</c:if>
</c:otherwise>                                                                                                                                                                                                           
</c:choose>
</body>
</html>