<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/GroupManager" prefix="gm" %>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>

<html>
<head>
    <title>Pipeline status</title>
    <script language="JavaScript" src="http://glast-ground.slac.stanford.edu/Commons/scripts/FSdateSelect.jsp"></script>
    <link rel="stylesheet" href="http://glast-ground.slac.stanford.edu/Commons/css/FSdateSelect.css" type="text/css">        
</head>
<body>


<h2>Streams for task: ${taskName}</h2>

<c:choose>
    <c:when test="${!empty param.clear}">
        <c:set var="min" value=""  scope="session"/>
        <c:set var="max" value="" scope="session"/>
        <c:set var="minDate" value="" scope="session"/>
        <c:set var="maxDate" value="" scope="session"/> 
        <c:set var="status" value="" scope="session"/>
    </c:when>
    <c:when test="${!empty param.submit}">
        <c:set var="min" value="${param.min}" scope="session"/>
        <c:set var="max" value="${param.max}" scope="session"/>
        <c:set var="minDate" value="${param.minDate}" scope="session"/>
        <c:set var="maxDate" value="${param.maxDate}" scope="session"/>
        <c:set var="status" value="${param.status}" scope="session"/>
    </c:when>
    <c:otherwise>
        <c:if test="${!empty param.status}"><c:set var="status" value="${param.status == '0' ? '' : param.status}" scope="session"/></c:if>
    </c:otherwise>
</c:choose>

<c:set var="showLatest" value="${!empty param.showLatestChanged ? !empty param.showLatest : empty showLatest ? true : showLatest}" scope="session"/>

<sql:query var="test">select *  from stream
    join streampath using (stream)
    where task=?
    <sql:param value="${param.task}"/>
    <c:if test="${showLatest}"> and isLatest=1 and IsLatestPath=1</c:if>
    and isLatest=1 and IsLatestPath=1
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
    <c:if test="${!empty minDate && minDate!='None'}"> 
        and CREATEDATE>=?
        <fmt:parseDate value="${minDate}" pattern="MM/dd/yyyy" var="minDateUsed"/>
        <sql:dateParam value="${minDateUsed}" type="date"/> 
    </c:if>
    <c:if test="${!empty maxDate && maxDate!='None'}">
        and CREATEDATE<=?
        <fmt:parseDate value="${maxDate}" pattern="MM/dd/yyyy" var="maxDateUsed"/>
        <% java.util.Date d = (java.util.Date) pageContext.getAttribute("maxDateUsed");
        d.setTime(d.getTime()+24*60*60*1000);
        %>
        <sql:dateParam value="${maxDateUsed}" type="date"/> 
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
            <option value="${row.STREAMSTATUS}" ${status==row.STREAMSTATUS ? "selected" : ""}>${pl:prettyStatus(row.STREAMSTATUS)}</option>
        </c:forEach>
      
        <tr><th>Date</th><td>Start</td><td><script language="JavaScript">FSfncWriteFieldHTML("DateForm","minDate","${empty minDate ? 'None' : minDate}",100,"http://glast-ground.slac.stanford.edu/Commons/images/FSdateSelector/","US",false,true)</script></td>
            <td>End</td><td><script language="JavaScript">FSfncWriteFieldHTML("DateForm","maxDate","${empty maxDate ? 'None' : maxDate}",100,"http://glast-ground.slac.stanford.edu/Commons/images/FSdateSelector/","US",false,true)</script></td>
            <td><input type="submit" value="Filter" name="submit">&nbsp;<input type="submit" value="Clear" name="clear">
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
<display:table class="datatable" name="${test.rows}" id="row" sort="list" defaultsort="1" defaultorder="ascending" pagesize="${test.rowCount>50 && empty param.showAll ? 20 : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >
<display:column property="StreamId" title="Stream" sortable="true" headerClass="sortable" comparator="org.glast.pipeline.web.decorators.StreamPathComparator" href="si.jsp" paramId="stream" paramProperty="stream"/>
<display:column property="StreamStatus" title="Status" sortable="true" headerClass="sortable"/>
<c:if test="${!showLatest}">
    <display:column title="#">
        ${row.executionNumber}${row.isLatest>0 ? "(*)" : ""}
    </display:column>
</c:if>
<display:column property="CreateDate" title="Created" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator"/>
<display:column property="StartDate" title="Started" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator"/>
<display:column property="EndDate" title="Ended" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator"/>
<c:if test="${adminMode}">
    <display:column property="streamSelector" title=" " class="admin"/>
    <display:footer>
        <tr>
            <td colspan="20" class="admin">     
                <a href="javascript:void(0)" onClick="ShowAll(true);">Select all</a>&nbsp;.&nbsp;
                <a href="javascript:void(0)" onClick="ShowAll(false);">Deselect all</a>&nbsp;.&nbsp;
                <a href="javascript:void(0)" onClick="ToggleAll();">Toggle selection</a>
                <input type="hidden" name="task" value="${task}">
                <input type="submit" value="Rollback Selected Streams" name="submit">
            </td>
        </tr>
    </display:footer>
</tr>              </c:if>
</display:table>

</form>

<c:if test="${test.rowCount>0}">
    <ul>
        <li><a href="streams.jsp?task=${param.task}&format=stream">Dump stream id list</a>.</li>
    </ul>
</c:if>
</c:otherwise>                                                                                                                                                                                                           
</c:choose>
</body>
</html>
