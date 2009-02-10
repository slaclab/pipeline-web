<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/GroupManager" prefix="gm" %>
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
        
        <c:set var="debug" value="0"/> 
        
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
       
        <c:set var="streamIdFilter" value="${param.streamIdFilter}" scope="session"/>
        <c:set var="include" value="${param.include}" scope="session"/>
        <c:set var="regExp" value="${!empty param.regExp}" scope="session"/>
        <c:set var="min" value="${param.min}"/>
        <c:set var="max" value="${param.max}"/>
        <c:set var="status" value="${!empty param.status && param.status!='0' ? param.status : ''}"/>
        <c:set var="dateCategory" value="${empty param.dateCategory ? 'createdate' : param.dateCategory}"/>        
        <c:set var="showLatest" value="${!empty param.showLatestChanged ? !empty param.showLatest : empty showLatest ? true : showLatest}" scope="session"/>
        <c:set var="minDate" value="${param.minDate}"/>
        <c:set var="maxDate" value="${param.maxDate}"/>  
        <c:set var="minimumDate" value="${! empty param.minDate ? param.minDate : -1}"/>
        <c:set var="maximumDate" value="${! empty param.maxDate ? param.maxDate : -1}"/>
        <c:set var="pref_ndays" value="${preferences.defaultProcessPeriodDays}"/> 
        <c:set var="userSelectedMinDate" value="${!empty minDate && minDate != '-1'}" /> 
        <c:set var="userSelectedMaxDate" value="${!empty maxDate && maxDate != '-1'}" />
        <c:set var="userSelectedTaskName" value="${!empty taskName}" /> 
        <c:catch>
            <fmt:parseNumber var="ndays" value="${param.ndays}" type="number" integerOnly="true"/>
        </c:catch>
        <c:set var="userSelectedNdays" value="${! empty ndays && !userSelectedMinDate && !userSelectedMaxDate}" />
        
        <c:if test="${!empty param.reset}">
            <c:set var="min" value=""/>
            <c:set var="max" value=""/>
            <c:set var="minDate" value="-1"/> 
            <c:set var="maxDate" value="-1"/> 
            <c:set var="minimumDate" value="-1"/>
            <c:set var="maximumDate" value="-1"/> 
            <c:set var="status" value=""/> 
            <c:set var ="sessionMinDate" value="None"/>
            <c:set var ="sessionMaxDate" value="None"/> 
            <c:set var="sessionUseNdays" value="true"/> 
            <c:set var="sessionNdays" value="${pref_ndays}"/>
            <c:set var="userSelectedNdays" value="false"/> 
        </c:if>
        
        <c:choose>
            <c:when test="${userSelectedMinDate || userSelectedMaxDate}">
                <c:set var="sessionUseNdays" value="false" scope="session"/> 
                <c:set var="sessionNdays" value="" scope="session"/> 
                <c:set var="sessionMinDate" value="${minDate}" scope="session"/> 
                <c:set var="sessionMaxDate" value="${maxDate}" scope="session"/> 
            </c:when>
            <c:when test="${userSelectedNdays}">
                <c:set var="sessionUseNdays" value="true" scope="session"/> 
                <c:set var="sessionNdays" value="${!empty ndays ? ndays : pref_ndays}" scope="session"/> 
                <c:set var="sessionMinDate" value="-1" scope="session"/> 
                <c:set var="sessionMaxDate" value="-1" scope="session"/> 
            </c:when>
            
            <c:when test="${empty sessionUseNdays}">
                <c:set var ="sessionUseNdays" value="true" scope="session"/>
                <c:set var ="sessionNdays" value="${pref_ndays}" scope="session"/>
                <c:set var ="sessionMinDate" value="-1" scope="session"/>
                <c:set var ="sessionMaxDate" value="-1" scope="session"/>
            </c:when>
        </c:choose>
       
        <c:if test="${debug == 1}"> 
            <c:forEach var="p" items="${param}">
                <h3>${p}</h3>
            </c:forEach>
        </c:if>
        
        <c:if test="${debug == 1}">
            <h3>
                userselectedTask: ${userSelectedTask}<br>
                userselectedNdays: ${userSelectedNdays}<br>
                userselectedMinDate: ${userSelectedMinDate}<br>
                userselectedMaxDate: ${userSelectedMaxDate}<p>
                sessionMinDate: ${sessionMinDate}<br>
                sessionMaxDate: ${sessionMaxDate}<br>
                sessionNdays: ${sessionNdays}<br>
                sessionUseNdays: ${sessionUseNdays}<p>
                dateCategory ${param.dateCategory}<br>
                minDate: ${minDate}<br>
                maxDate: ${maxDate}<br>
                minimumDate: ${minimumDate}<br>
                maximumDate: ${maximumDate}<br>
                ndays: ${param.ndays}<br>
                pref_ndays: ${pref_ndays}<p>
                param.minDate=${param.minDate}<br>
                param.maxDate=${param.maxDate}<br>
                param.filter=${param.filter}<br>
                param.reset="${param.reset}"<br>
            </h3>
        </c:if>
        
        <sql:query var="test">
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
            
            <c:if test="${minimumDate > 0 && !userSelectedNdays}"> 
                and ${dateCategory}  >=  ? and ${dateCategory} is not null
                <jsp:useBean id="startDate" class="java.util.Date" /> 
                <jsp:setProperty name="startDate" property="time" value="${minimumDate}" /> 	  
                <sql:dateParam value="${startDate}" type="timestamp"/> 
            </c:if>
            <c:if test="${maximumDate > 0 && !userSelectedNdays}">
                and ${dateCategory} <=  ? and ${dateCategory} is not null
                <jsp:useBean id="endDate" class="java.util.Date" />
                <jsp:setProperty name="endDate" property="time" value="${maximumDate}" />
                <sql:dateParam value="${endDate}" type="timestamp"/>
            </c:if>  
            <c:if test="${userSelectedNdays && !userSelectedStartTime && !userSelectedEndTime}">
                and ${dateCategory} >= current_date - interval '${sessionNdays}' day
            </c:if>
        </sql:query>
        
        <c:if test = "${empty NumStatusReqs}">       
            <c:set var="NumStatusReqs" value="0"/> 
        </c:if>
        
        <c:set var="isBatch" value="${test.rows[0].processType=='BATCH'}"/> 
       
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
                                    <c:if test = "${seletedStatus ==  row.PROCESSINGSTATUS}">
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
                    <td><utils:dateTimePicker name="minDate" size="22" value="${sessionUseNdays ? -1 : sessionMinDate}" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/>
                    </td>
                    <td><utils:dateTimePicker name="maxDate" size="22" value="${sessionUseNdays ? -1 : sessionMaxDate}" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/>
                    </td>
                    <td>or last N days <input name="ndays" type="text" value="${sessionUseNdays ? sessionNdays : ''}" size="5"></td>
                    <td>
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
            <input type="hidden" name="showLatest" value="${showLatest}">
            <input type="hidden" name="showLatestChanged" value="${showLatest}">
        </form>
        
        <pt:autoCheckBox name="showLatest" value="${showLatest}">Show only latest execution: ${showLatest}</pt:autoCheckBox>
        
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
            <c:when test="${param.format=='id'}">
                <pre><c:forEach var="row" items="${test.rows}"><c:if test="${!empty row.JobID}">${row.JobID}<br></c:if></c:forEach></pre>
            </c:when>
            <c:otherwise>
                <form name="selectForm" action="confirm.jsp" method="post">
                    <display:table class="datatable" name="${test.rows}" id="Row" sort="list" defaultsort="1" defaultorder="ascending" pagesize="${test.rowCount>50 && empty param.showAll ? preferences.showStreams : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >
                        <display:column property="StreamIdPath" title="Stream" sortable="true" headerClass="sortable" comparator="org.glast.pipeline.web.decorators.StreamPathComparator" href="pi.jsp" paramId="pi" paramProperty="processinstance"/>
                        <c:if test="${empty process && !empty task}">
                            <display:column property="ProcessName" title="Process" sortable="true" headerClass="sortable"/>
                        </c:if>
                        <c:if test="${Row.Status =='Failed'}">
                            <display:column title="Status" sortable="true" headerClass="sortable">
                                <font color="#FF0000"> ${Row.Status} </font>
                            </display:column>
                        </c:if>
                        <c:if test="${Row.Status !='Failed'}">
                           <display:column title="Status" sortable="true" headerClass="sortable">
                                 ${Row.Status}  
                            </display:column>
                        </c:if>                           
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
                <c:if test="${test.rowCount>0}">
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
            </c:otherwise>                                                                                                                                                                                                           
        </c:choose>
        
    </body>
</html>
