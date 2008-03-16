<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/GroupManager" prefix="gm" %>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib prefix="utils" uri="http://glast-ground.slac.stanford.edu/utils" %>
<html>
    <head>
        <title>Pipeline status</title>
        <script language="JavaScript" src="http://glast-ground.slac.stanford.edu/Commons/scripts/FSdateSelect.jsp"></script>
        <link rel="stylesheet" href="http://glast-ground.slac.stanford.edu/Commons/css/FSdateSelect.css" type="text/css">        
    </head>
    <body>
        
        <sql:query var="proc_stats">
            select PROCESSINGSTATUS from PROCESSINGSTATUS displayorder
        </sql:query>
        
        <h2>Streams for process: ${processName}</h2>
        
        <p><a href="P2stats.jsp?process=${process}">Processing plots</a><!--&nbsp;.&nbsp;<a href="meta.jsp?process=${process}">Meta Data</a>--></p>
        
        <pt:taskSummary streamCount="runCount"/>
   
        <c:set var="minDate" value="${ empty param.minDate ? '-1' : param.minDate}" scope="session"/>
        <c:set var="maxDate" value="${ empty param.maxDate ? '-1' : param.maxDate}" scope="session"/>       
        
        <jsp:useBean id="startDate" class="java.util.Date" /> 
        <jsp:setProperty name="startDate" property="time" value="${minDate}" /> 	  
        <jsp:useBean id="endDate" class="java.util.Date" /> 
        <jsp:setProperty name="endDate" property="time" value="${maxDate}" /> 	  
        
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
        <c:choose>
            <c:when test="${!empty param.dateCategory}">
                <c:set var="dateCategory" value="${param.dateCategory}"  scope="session"/>
            </c:when>
            <c:otherwise>
                <c:set var="dateCategory" value="createdate"  scope="session"/>
            </c:otherwise>  
        </c:choose> 
        
        <c:set var="showLatest" value="${!empty param.showLatestChanged ? !empty param.showLatest : empty showLatest ? true : showLatest}" scope="session"/>
  
        <sql:query var="test">
            select * from 
            ( 
            with processinstance2 as
            (
            select * from processinstance
            where process=?
            <sql:param value="${param.process}"/>
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
            select p.PROCESSINSTANCE, s.streamid, PII.GetStreamIdPath(stream) StreamIdPath, stream, p.JOBID, p.JobSite, Initcap(p.PROCESSINGSTATUS) status,p.CREATEDATE,p.SUBMITDATE,p.STARTDATE,p.ENDDATE, x.ProcessType, p.CPUSECONDSUSED, p.EXECUTIONHOST, p.EXITCODE
            <c:if test="${!showLatest}">, p.ExecutionNumber || case when  p.IsLatest=1  then '(*)' end processExecutionNumber, s.ExecutionNumber || case when  s.IsLatest=1  then '(*)' end streamExecutionNumber</c:if>
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
            <c:if test="${!empty param.pstream}">
                and ? in (select ss.stream from stream ss start with ss.stream=q.stream connect by ss.stream = prior ss.parentstream)
                <sql:param value="${param.pstream}"/>
            </c:if>        
            
            <c:if test="${minDate != '-1'}"> 
                and ${dateCategory}  >=  ?            
                <sql:dateParam value="${startDate}" type="timestamp"/> 
            </c:if>
            <c:if test="${maxDate != '-1'}">
                and ${dateCategory} <=  ?              
                <sql:dateParam value="${endDate}" type="timestamp"/> 
            </c:if>            
        </sql:query>
        
        <c:if test = "${empty NumStatusReqs}">       
            <c:set var="NumStatusReqs" value="0"/> 
        </c:if>
        
        <c:set var="isBatch" value="${test.rows[0].processType=='BATCH'}"/> 
        <form name="DateForm">
            <table class="filtertable" >
                <tr><th>Stream</th><td>Min <input type="text" name="min" value="${min}"></td>
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
               </td></tr>
                <tr>  

                    <td><select size="1" name="dateCategory">

                                <option value="createdate"${dateCategory == "createdate" ? "selected" : "" }>Created Date</option>
                                <option value="submitdate" ${dateCategory == "submitdate" ? "selected" : "" }>Submitted Date</option>
                                <option value="startdate"${dateCategory == "startdate" ? "selected" : "" }>Started Date</option>
                                <option value="enddate"${dateCategory == "enddate" ? "selected" : "" }>Ended Date</option>

                    </select> </td>
                    <td><utils:dateTimePicker value="${minDate}" size="22" name="minDate" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/></td>
                    <td><utils:dateTimePicker value="${maxDate}" size="22" name="maxDate" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/></td>

                    <td><input type="submit" value="Filter" name="submit">&nbsp;<input type="submit" value="Clear" name="clear">
                <input type="hidden" name="process" value="${process}"></td></tr>
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
            <c:when test="${param.format=='id'}">
                <pre><c:forEach var="row" items="${test.rows}"><c:if test="${!empty row.JobID}">${row.JobID}<br></c:if></c:forEach></pre>
            </c:when>
            <c:otherwise>
                <form name="selectForm" action="confirm.jsp" method="post">
                    <display:table class="datatable" name="${test.rows}" sort="list" defaultsort="1" defaultorder="ascending" pagesize="${test.rowCount>50 && empty param.showAll ? preferences.showStreams : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >
                        <display:column property="StreamIdPath" title="Stream" sortable="true" headerClass="sortable" comparator="org.glast.pipeline.web.decorators.StreamPathComparator" href="pi.jsp" paramId="pi" paramProperty="processinstance"/>
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
                            <display:column property="selector" title=" " class="admin"/>
                            <display:footer>
                                <tr>
                                    <td colspan="20" class="admin">                
                                        <a href="javascript:void(0)" onClick="ShowAll(true);">Select all</a>&nbsp;.&nbsp;
                                        <a href="javascript:void(0)" onClick="ShowAll(false);">Deselect all</a>&nbsp;.&nbsp;
                                        <a href="javascript:void(0)" onClick="ToggleAll();">Toggle selection</a>
                                        <input type="hidden" name="process" value="${process}">
                                        <input type="submit" value="Rollback Selected" name="submit">
                                    </td>
                                </tr>
                            </display:footer>
                        </c:if>
                    </display:table>
                </form>
                
                <c:if test="${test.rowCount>0}">
                    <ul>
                        <li><a href="process.jsp?process=${process}&format=stream">Dump stream id list</a>.</li>
                        <li><a href="process.jsp?process=${process}&format=id">Dump job id list</a>.</li>
                    </ul>
                </c:if>
            </c:otherwise>                                                                                                                                                                                                           
        </c:choose>
    </body>
</html>
