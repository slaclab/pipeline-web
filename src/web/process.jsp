<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://srs.slac.stanford.edu/GroupManager" prefix="gm" %>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>
<%@taglib prefix="utils" uri="http://glast-ground.slac.stanford.edu/utils" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
    <head>
        <c:choose>
            <c:when test="${!empty processName}">
                <title>Streams for process: ${processName}</title>
            </c:when>
            <c:when test="${!empty task}">
                <title>Streams for task: ${taskName}</title>
            </c:when>
        </c:choose>
        <script language="JavaScript" src="http://glast-ground.slac.stanford.edu/Commons/scripts/FSdateSelect.jsp"></script>
        <link rel="stylesheet" href="http://glast-ground.slac.stanford.edu/Commons/css/FSdateSelect.css" type="text/css">        
    </head>
    <body>

        <%-- must check if this is the first time user comes to this page. check if user preference exist for processhours --%>
        <c:if test="${ empty firstProcessVisit}">
            <c:set var="processhours" value="${preferences.defaultProcessPeriodHours > 0 ? preferences.defaultProcessPeriodHours : ''}"/>
            <c:if test="${processhours > 0}">
                <c:set var="sessionProcessHours" value="${processhours}" scope="session"/>
                <c:set var="userSelectedProcessHours" value="true" scope="session"/>
                <c:set var="userSelectedProcessMinDate" value="false"/> 
                <c:set var="userSelectedProcessMaxDate" value="false"/> 
            </c:if>
            <c:set var="firstProcessVisit" value="beenHereDoneThat3" scope="session"/>
        </c:if>
        
        <sql:query var="proc_stats">
            select PROCESSINGSTATUS from PROCESSINGSTATUS order by displayorder
        </sql:query>
        
        <c:choose>
            <c:when test="${!empty processName}">
                <h2>Streams for process: ${processName}</h2>
                <p><a href="P2stats.jsp?process=${process}">Processing plots</a><!--&nbsp;.&nbsp;<a href="meta.jsp?process=${process}">Meta Data</a>--></p>
            </c:when>
            <c:when test="${!empty task}">
                <h2>Streams for task: ${taskName}</h2>
                <p><a href="JobProcessingStats.jsp?taskName=${taskName}">Processing plots</a></p>
            </c:when>
        </c:choose>
        
        <pt:taskSummary streamCount="runCount"/>      
        
        <c:set var="dateCategory" value="${empty param.dateCategory ? 'createdate' : param.dateCategory}"/>
        <c:set var="showLatest" value="${!empty param.showLatestChanged ? !empty param.showLatest : empty showLatest ? true : showLatest}" scope="session"/> 
        <c:set var="streamIdFilter" value="${param.streamIdFilter}" scope="session"/>
        <c:set var="include" value="${param.include}" scope="session"/>
        <c:set var="regExp" value="${!empty param.regExp}" scope="session"/>
        <c:set var="min" value="${param.min}"/>
        <c:set var="max" value="${param.max}"/>
        <c:set var="status" value="${!empty param.status && param.status!='0' ? param.status : ''}" scope="session"/> 
        <c:set var="userSelectedTaskName" value="${!empty taskName}" /> 
        <c:set var="minDate" value="${param.minDate}"/> 
        <c:set var="maxDate" value="${param.maxDate}"/>
        <c:set var="processhours" value="${param.processhours}"/>
        
        <c:if test="${! empty param.submit}">
            <c:set var="userSelectedProcessMinDate" value="${!empty minDate && minDate != sessionProcessMinDate && minDate != -1}"/> 
            <c:set var="userSelectedProcessMaxDate" value="${!empty maxDate && maxDate != sessionProcessMaxDate && maxDate != -1}"/>
            <c:set var="userSelectedProcessHours" value="${!empty processhours && !userSelectedProcessMinDate && !userSelectedProcessMaxDate}" scope="session"/>
            <c:set var="userSelectedStartNone" value="${empty processhours && minDate == '-1' }"/>
            <c:set var="userSelectedEndNone" value="${empty processhours && maxDate == '-1' }"/>

            <c:choose>
                <c:when test="${userSelectedProcessMinDate || userSelectedProcessMaxDate}">
                    <c:set var="sessionProcessHours" value="" scope="session"/>
                    <c:if test="${userSelectedProcessMinDate}">
                        <c:set var ="sessionProcessMinDate" value="${minDate}" scope="session"/>
                    </c:if>
                    <c:if test="${userSelectedProcessMaxDate}">
                        <c:set var ="sessionProcessMaxDate" value="${maxDate}" scope="session"/>
                    </c:if>
                </c:when>
                <c:when test="${userSelectedProcessHours}">
                    <c:set var="minDate" value='-1'/>
                    <c:set var="maxDate" value='-1'/>
                    <c:set var="sessionProcessHours" value="${processhours}" scope="session"/>
                    <c:set var ="sessionProcessMinDate" value='-1' scope="session"/>
                    <c:set var ="sessionProcessMaxDate" value='-1' scope="session"/>
                </c:when>
            </c:choose>

            <c:choose>
                <c:when test="${userSelectedStartNone || userSelectedEndNone}">
                    <c:set var="sessionProcessHours" value="" scope="session"/>
                    <c:if test="${userSelectedStartNone}">
                        <c:set var ="sessionProcessMinDate" value="" scope="session"/>
                    </c:if>
                    <c:if test="${userSelectedEndNone}">
                        <c:set var ="sessionProcessMaxDate" value="" scope="session"/>
                    </c:if>
                </c:when>
            </c:choose>
        </c:if> 
         
        <c:if test="${! empty param.reset}">
                <c:set var="pref_processhours" value="${preferences.defaultProcessPeriodHours > 0 ? preferences.defaultProcessPeriodHours : ''}"/>
                <c:set var="min" value=""/>
                <c:set var="max" value=""/>
                <c:set var="status" value=""/>
                <c:set var="minDate" value='-1'/>
                <c:set var="maxDate" value='-1'/>
                <c:set var="sessionProcessHours" value="${pref_processhours}" scope="session"/>
                <c:set var="sessionProcessMinDate" value='-1' scope="session"/>
                <c:set var="sessionProcessMaxDate" value='-1' scope="session"/>
                <c:set var="userSelectedProcessHours" value="${pref_processhours > 0 ? 'true' : 'false'}"/>
                <c:set var="showAll" value="checked"/> 
        </c:if>
                
        <sql:query var="pqTest">
            select * from
            (
            with processinstance2 as
            (
            select * from processinstance

            <c:choose>
                <c:when test="${!empty processName}">
                    where process=?
                    <sql:param value="${param.process}"/>
                </c:when>
                <c:when test="${!empty task}">
                    where process in (
                    select process from process where task in (select task from task start with task=? connect by parenttask = prior task)
                    )
                    <sql:param value="${param.task}"/>
                </c:when>
            </c:choose>

            <c:if test="${showLatest}">and islatest=1 and PII.GetStreamIsLatestPath(stream)=1</c:if>

            <c:if test="${!empty status}">
                <c:set var ="NumStatusReqs" value = "${fn:length(paramValues.status)}" />
                <c:set var ="LastReq" value = "${fn:length(paramValues.status)-1}" />
                <c:choose>
                    <c:when  test = "${NumStatusReqs > 1}">
                        and PROCESSINGSTATUS in (
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
                            and PROCESSINGSTATUS=?
                            <sql:param value="${status}"/>
                        </c:if>
                        <c:if test= "${status == 'NOTSUCCESS'}">
                            and PROCESSINGSTATUS != 'SUCCESS'
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </c:if>
            )
            select p.PROCESSINSTANCE,p.isLatest, s.streamid, PII.GetStreamIdPath(stream) StreamIdPath, stream, p.JOBID, p.JobSite, Initcap(p.PROCESSINGSTATUS) status,p.CREATEDATE,p.SUBMITDATE,p.STARTDATE,p.ENDDATE, x.ProcessName, x.ProcessType, p.CPUSECONDSUSED, p.EXECUTIONHOST, p.EXITCODE
            <c:if test="${!showLatest}">, p.ExecutionNumber || case when x.autoRetryMaxAttempts > 0 then '(' || p.autoRetryNumber || '/' || x.autoRetryMaxAttempts || ')' end || case when  p.IsLatest=1  then '(*)' end processExecutionNumber, s.ExecutionNumber || case when  s.IsLatest=1  then '(*)' end streamExecutionNumber</c:if>

            from processinstance2 p
            join stream s using (stream)
            join process x using (process)
            ) q where (null is null)

            <c:if test="${!empty min}">
                and StreamId>=?
                <sql:param value="${min}"/>
            </c:if>
            <c:if test="${!empty max}">
                and StreamId<=?
                <sql:param value="${max}"/>
            </c:if>
            <c:if test="${!empty taskFilter && !regExp}">
                and PII.GetStreamIdPath(stream) like ?
                <sql:param value="%${streamIdFilter}%"/>
            </c:if>

            <c:if test="${!empty streamIdFilter }">
                and regexp_like(PII.GetStreamIdPath(stream),?)
                <sql:param value="${streamIdFilter}"/>
            </c:if>
            <c:if test="${!empty param.pstream}">
                and ? in (select ss.stream from stream ss start with ss.stream=q.stream connect by ss.stream = prior ss.parentstream)
                <sql:param value="${param.pstream}"/>
            </c:if>
         
         
            <c:if test="${sessionProcessMinDate > 0 && !userSelectedProcessHours}">
                and ${dateCategory}  >=  ?
                <jsp:useBean id="startDate" class="java.util.Date" />
                <jsp:setProperty name="startDate" property="time" value="${sessionProcessMinDate}" />
                <sql:dateParam value="${startDate}" type="timestamp"/>
            </c:if>
            <c:if test="${sessionProcessMaxDate > 0 && !userSelectedProcessHours}">
                and ${dateCategory} <=  ?
                <jsp:useBean id="endDate" class="java.util.Date" />
                <jsp:setProperty name="endDate" property="time" value="${sessionProcessMaxDate}" />
                <sql:dateParam value="${endDate}" type="timestamp"/>
            </c:if>
            <c:if test="${userSelectedProcessHours}">
                and ${dateCategory} >= ? and ${dateCategory} <= ?
                <jsp:useBean id="maxDateUsedHours" class="java.util.Date" />
                <jsp:useBean id="minDateUsedHours" class="java.util.Date" />
                <jsp:setProperty name="minDateUsedHours" property="time" value="${maxDateUsedHours.time - sessionProcessHours*60*60*1000}" />
                <sql:dateParam value="${minDateUsedHours}" type="timestamp"/>
                <sql:dateParam value="${maxDateUsedHours}" type="timestamp"/>
            </c:if>
        </sql:query>
 
        <c:if test = "${empty NumStatusReqs}">       
            <c:set var="NumStatusReqs" value="0"/> 
        </c:if>
      
        <c:set var="isBatch" value="${pqTest.rows[0].processType=='BATCH'}"/> 

        <form name="DateForm">
            <table class="filtertable" >
                <tr><th>Top Level Stream: </th><td>Min <input type="text" name="min" value="${min}"></td>
                    <td>Max <input type="text" name="max" value="${max}"></td> 
                    <td>Status: <select size="3" name="status" multiple>
                            <option value="" ${status=="" ? "selected" : ""}>All</option>
                            <option value="NOTSUCCESS" ${status=="NOTSUCCESS" ? "selected" : ""} >All Not Success </option>                            
                            <c:forEach var="row" items="${proc_stats.rows}">
                                <c:set var= "found" value = "0" /> 
                                <c:forEach  var = "seletedStatus" items = "${paramValues.status}" > 
                                    <c:if test = "${seletedStatus ==  row.PROCESSINGSTATUS && empty param.reset}">
                                        <c:set var= "found" value = "1" />
                                    </c:if>                                                    
                                </c:forEach>   
                                <option value="${row.PROCESSINGSTATUS}" ${found == "1" ? "selected" : "" }>${pl:prettyStatus(row.PROCESSINGSTATUS)}</option>                                                                
                            </c:forEach>                         
                        </select>      
                    </td>
                </tr>
                <tr>                      
                    <th>Stream Filter:</th><td> <input type="text" name="streamIdFilter" value="${streamIdFilter}"></td>
                    <td><input type="checkbox" name="regExp" ${regExp ? 'checked' : ''}> Regular Expression (<a href="http://www.oracle.com/technology/oramag/webcolumns/2003/techarticles/rischert_regexp_pt1.html">?</a>)</td>
                </tr> 
                <tr>  
                    <td><select size="1" name="dateCategory">
                            <option value="createdate"${dateCategory == "createdate" ? "selected" : "" }>Created Date</option>
                            <c:if test="${isBatch}"> 
                                <option value="submitdate" ${dateCategory == "submitdate" ? "selected" : "" }>Submitted Date</option>
                            </c:if>
                            <option value="startdate"${dateCategory == "startdate" ? "selected" : "" }>Started Date</option>
                            <option value="enddate"${dateCategory == "enddate" ? "selected" : "" }>Ended Date</option>
                        </select> 
                    </td>
                    <td><utils:dateTimePicker value="${sessionProcessMinDate}" size="22" name="minDate" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/>
                    </td>
                    <td><utils:dateTimePicker value="${sessionProcessMaxDate}" size="22" name="maxDate" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/>
                    </td>  
                    <td>
                        or last N hours <input name="processhours" type="text" value="${sessionProcessHours}" size="5">
                    </td>
                    <td>
                      <!--  <input type="submit" value="Filter" name="submit">&nbsp;<input type="submit" value="Clear" name="clear"> -->
                      <input type="submit" value="Filter" name="submit">&nbsp;<input type="submit" value="Reset" name="reset">
                        <c:choose>
                            <c:when test="${!empty processName}">
                                <input type="hidden" name="process" value="${process}">
                            </c:when>
                            <c:when test="${!empty task}">
                                <input type="hidden" name="task" value="${task}">
                            </c:when>
                        </c:choose>
                    </td>
                </tr>
                <tr>
                    <td colspan="4"><input type="checkbox" name="showAll" ${empty param.showAll ? "" : "checked"} > Show all streams on one page
                    </td>
                </tr>
            </table>
            <input type="hidden" name="pstream" value="${param.pstream}">
            <input type="hidden" name="process" value="${param.process}">
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
        
        <c:set var="adminMode" value="${gm:isUserInGroup(pageContext,'PipelineAdmin')}"/>
        <c:choose>
            <c:when test="${param.format=='stream'}">
                <pre><c:forEach var="row" items="${pqTest.rows}">${row.streamid}<br></c:forEach></pre>
            </c:when>
            <c:when test="${param.format=='id'}">
                <pre><c:forEach var="row" items="${pqTest.rows}"><c:if test="${!empty row.JobID}">${row.JobID}<br></c:if></c:forEach></pre>
            </c:when>
            <c:otherwise>
                <form name="selectForm" action="confirm.jsp" method="post">
                    <display:table excludedParams="submit" class="datatable" name="${pqTest.rows}" id="Row" sort="list" defaultsort="1" defaultorder="ascending" pagesize="${test.rowCount>50 && empty param.showAll ? preferences.showStreams : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >
                        <display:column property="StreamIdPath" title="Stream" sortable="true" headerClass="sortable" comparator="org.glast.pipeline.web.decorators.StreamPathComparator" href="pi.jsp" paramId="pi" paramProperty="processinstance"/>
                        <c:if test="${empty process && !empty task}">
                            <display:column property="ProcessName" title="Process" sortable="true" headerClass="sortable"/>
                        </c:if>
                        <display:column property="Status" sortable="true" headerClass="sortable"/>             
                        <c:if test="${!showLatest}">
                            <display:column property="ProcessExecutionNumber" title="Process #"/>
                            <display:column property="StreamExecutionNumber" title="Stream #"/>
                        </c:if>
                        <display:column property="CreateDate" title="Created" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
                        <c:if test="${isBatch}">
                            <display:column property="SubmitDate" title="Submitted" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
                        </c:if>
                        <display:column property="StartDate" title="Started" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
                        <display:column property="EndDate" title="Ended" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
                        <c:if test="${isBatch}">
                            <display:column property="job" title="Job Id" sortable="true" headerClass="sortable"/>
                            <display:column property="cpuSecondsUsed" title="CPU" sortable="true" headerClass="sortable"/>
                            <display:column property="executionHost" title="Host" sortable="true" headerClass="sortable"/>
                        </c:if>
                        <display:column property="links" title="Links" class="leftAligned"/>                    
                        <c:if test="${adminMode}">                  
                            <display:column title="" property="isLatestSelector" class="admin"/>                        
                            <display:footer>
                                <tr>
                                    <td colspan="20" class="admin">                
                                        <a href="javascript:void(0)" onClick="ShowAll(true);">Select all</a>&nbsp;.&nbsp;
                                        <a href="javascript:void(0)" onClick="ShowAll(false);">Deselect all</a>&nbsp;.&nbsp;
                                        <a href="javascript:void(0)" onClick="ToggleAll();">Toggle selection</a>
                                        <c:choose>
                                            <c:when test="${!empty processName}">
                                                <input type="hidden" name="process" value="${process}">
                                            </c:when>
                                            <c:when test="${!empty task}">
                                                <input type="hidden" name="task" value="${task}">
                                            </c:when>
                                        </c:choose>
                                        <input type="submit" value="Rollback Selected" name="submit">
                                    </td>
                                </tr>
                            </display:footer>
                        </c:if>
                    </display:table>                 
                </form>
                <%--
                <c:if test="${pqTest.rowCount>0}">
                    <ul>
                        <c:choose>
                            <c:when test="${!empty processName}">
                                <li><a href="process.jsp?process=${process}&min=${param.min}&max=${param.max}&status=${param.status}&minDate=${param.minDate}&maxDate=${param.maxDate}&format=stream">Dump stream id list</a>.</li>
                                <li><a href="process.jsp?process=${process}&min=${param.min}&max=${param.max}&status=${param.status}&minDate=${param.minDate}&maxDate=${param.maxDate}&format=id">Dump job id list</a>.</li>
                            </c:when>
                            <c:when test="${!empty task}">
                                <li><a href="process.jsp?task=${task}&min=${param.min}&max=${param.max}&status=${param.status}&minDate=${param.minDate}&maxDate=${param.maxDate}&format=stream">Dump stream id list</a>.</li>
                                <li><a href="process.jsp?task=${task}&min=${param.min}&max=${param.max}&status=${param.status}&minDate=${param.minDate}&maxDate=${param.maxDate}&format=id">Dump job id list</a>.</li>
                            </c:when>
                        </c:choose>
                    </ul>
                </c:if>
                --%>

                <c:if test="${pqTest.rowCount>0}">
                    <ul>
                        <c:choose>
                            <c:when test="${!empty processName}">
                                <li><a href="process.jsp?process=${process}&min=${param.min}&max=${param.max}&status=${param.status}&minDate=${sessionProcessMinDate}&maxDate=${sessionProcessMaxDate}&format=stream">Dump stream id list</a>.</li>
                                <li><a href="process.jsp?process=${process}&min=${param.min}&max=${param.max}&status=${param.status}&minDate=${sessionProcessMinDate}&maxDate=${sessionProcessMaxDate}&format=id">Dump job id list</a>.</li>
                            </c:when>
                            <c:when test="${!empty task}">
                                <li><a href="process.jsp?task=${task}&min=${param.min}&max=${param.max}&status=${param.status}&minDate=${sessionProcessMinDate}&maxDate=${sessionProcessMaxDate}&format=stream">Dump stream id list</a>.</li>
                                <li><a href="process.jsp?task=${task}&min=${param.min}&max=${param.max}&status=${param.status}&minDate=${sessionProcessMinDate}&maxDate=${sessionProcessMaxDate}&format=id">Dump job id list</a>.</li>
                            </c:when>
                        </c:choose>
                    </ul>
                </c:if>

            </c:otherwise>                                                                                                                                                                                                           
        </c:choose>
        
    </body>
</html>
