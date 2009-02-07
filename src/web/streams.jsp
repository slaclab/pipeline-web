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
 
<sql:query var="taskVersion">
    select version,revision from task where task=?
    <sql:param value="${param.task}"/>
</sql:query>

<h2>Streams for task: ${taskName} ${taskVersion.rows[0]["version"]}.${taskVersion.rows[0]["revision"]} </h2>

<c:set var="debug" value="0"/> 
<c:set var="min" value="${param.min}"/>
<c:set var="max" value="${param.max}"/>
<c:set var="minimumDate" value="${param.minDate}"/>
<c:set var="maximumDate" value="${param.maxDate}"/>
<c:set var="status" value="${!empty param.status && param.status!='0' ? param.status : ''}"/>
<c:set var="pref_ndays" value="${preferences.defaultStreamPeriodDays}"/> 
<c:set var="userSelectedMinimumDate" value="${!empty minimumDate && minimumDate != '-1' && minimumDate != sessionMinimumDate}" /> 
<c:set var="userSelectedMaximumDate" value="${!empty maximumDate && maximumDate != '-1' && maximumDate != sessionMaximumDate}" />
<c:set var="userSelectedTaskName" value="${!empty taskName}" /> 
<c:catch>
    <fmt:parseNumber var="ndays" value="${param.ndays}" type="number" integerOnly="true"/>
</c:catch>
<c:set var="userSelectedNdays" value="${! empty ndays && !userSelectedMinimumDate && !userSelectedMaximumDate}" />
<c:if test="${userSelectedTaskName}">
    <c:set var ="sessionTaskName" value="${taskName}" scope="session"/>
</c:if> 

<c:choose>
    <c:when test="${userSelectedMinimumDate || userSelectedMaximumDate}">
        <c:set var="userSelectedNdays" value="false"/> 
        <c:set var="selectedNdays" value=""/> 
        <c:set var="sessionNdays" value="" scope="session"/> 
        <c:set var ="sessionUseNdays" value="false" scope="session"/>
        <c:set var ="sessionMinimumDate" value="${minimumDate}" scope="session"/>
        <c:set var ="sessionMaximumDate" value="${maximumDate}" scope="session"/>
    </c:when>
    <c:when test="${userSelectedNdays}">
        <c:set var="sessionUseNdays" value="true" scope="session"/> 
        <c:set var="sessionNdays" value="${!empty ndays ? ndays : pref_ndays}" scope="session"/> 
        <c:set var="sessionMinimumDate" value="-1" scope="session"/> 
        <c:set var="sessionMaximumDate" value="-1" scope="session"/> 
    </c:when>
    <c:when test="${empty sessionUseNdays}">
        <c:set var ="sessionUseNdays" value="true" scope="session"/>
        <c:set var ="sessionNdays" value="${pref_ndays}" scope="session"/>
        <c:set var ="sessionMinimumDate" value="None" scope="session"/>
        <c:set var ="sessionMaximumDate" value="None" scope="session"/>
    </c:when>
</c:choose>


<c:if test="${debug == 1}"> 
    <h3>
        userselectedNdays: ${userSelectedNdays}<br>
        userselectedminimumdate: ${userSelectedMinimumDate}<br> 
        userselectedmaximumdate: ${userSelectedMaximumDate}<p>
        sessionMinimumDate: ${sessionMinimumDate}<br>
        sessionMaximumDate: ${sessionMaximumDate}<p>
        sessionNdays: ${sessionNdays}<br>
        sessionUseNdays: ${sessionUseNdays}<p>
        minimumdate: ${minimumDate}<br>
        maximumdate: ${maximumDate}<p>
        ndays: ${ndays}<br>
        pref_ndays: ${pref_ndays}<br>
        param.minDate=${param.minDate}<br>
        param.maxDate=${param.maxDate}
    </h3>
</c:if>

<c:if test="${!empty param.reset}">
    <c:set var="min" value=""/>
    <c:set var="max" value=""/>
    <c:set var="minimumDate" value="-1"/>
    <c:set var="maximumDate" value="-1"/> 
    <c:set var="status" value=""/>
    <c:set var ="sessionMinimumDate" value="None"/>
    <c:set var ="sessionMaximumDate" value="None"/> 
    <c:set var="sessionUseNdays" value="true"/> 
    <c:set var="sessionNdays" value="${pref_ndays}"/>
    <c:set var="userSelectedNdays" value="false"/> 
</c:if>

<c:set var="showLatest" value="${!empty param.showLatestChanged ? !empty param.showLatest : empty showLatest ? true : showLatest}" scope="session"/>

<sql:query var="test">select stream.*,PII.GetStreamPath(stream) StreamPath, PII.GetStreamIdPath(stream) StreamIdPath, PII.GetStreamProgress(stream) progress
    from stream    
        where task=? 
        <sql:param value="${param.task}"/>
 
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
    
    <c:if test="${minimumDate > 0 && !userSelectedNdays}"> 
        and STARTDATE>=?
        <jsp:useBean id="minDateUsed" class="java.util.Date" />
        <jsp:setProperty name="minDateUsed" property="time" value="${minimumDate}" />       
        <sql:dateParam value="${minDateUsed}" type="timestamp"/> 
    </c:if>
    <c:if test="${maximumDate > 0 && !userSelectedNdays}">
        and ENDDATE<=?
        <jsp:useBean id="maxDateUsed" class="java.util.Date" />
        <jsp:setProperty name="maxDateUsed" property="time" value="${maximumDate}" />
        <sql:dateParam value="${maxDateUsed}" type="timestamp"/> 
    </c:if>
    <c:if test="${userSelectedNdays && !userSelectedMinimumDate && !userSelectedMaximumDate}"> 
        and startdate > current_date - interval '${sessionUseNdays ? sessionNdays : pref_ndays}' day
    </c:if>   
</sql:query>

<sql:query var="statii">
    select STREAMSTATUS from STREAMSTATUS order by displayorder
</sql:query>

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
                <td>Start</td><td><utils:dateTimePicker value="${sessionUseNdays ? -1 : sessionMinimumDate}" size="22" name="minDate" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PDT"/></td>
                <td>End</td><td><utils:dateTimePicker value="${sessionUseNdays ? -1 : sessionMaximumDate}" size="22" name="maxDate" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PDT"/></td>
                <td>or last N days <input name="ndays" type="text" value="${sessionUseNdays ? sessionNdays : ''}" size="5"></td> 
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
<display:table class="datatable" name="${test.rows}" id="row" sort="list" defaultsort="1" defaultorder="ascending" pagesize="${test.rowCount>50 && empty param.showAll ? preferences.showStreams : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >
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