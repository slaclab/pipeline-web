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
      
      <sql:query var="proc_stats">
         select PROCESSINGSTATUS from PROCESSINGSTATUS
      </sql:query>
      
      <h2>Streams for process: ${processName}</h2>
      
      <p><a href="P2stats.jsp?process=${process}">Processing plots</a><!--&nbsp;.&nbsp;<a href="meta.jsp?process=${process}">Meta Data</a>--></p>
      
      <pt:taskSummary streamCount="runCount"/>
      
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
      <sql:query var="test">select * from 
         ( select p.PROCESSINSTANCE, s.streamid, sp.STREAMIDPATH, p.JOBID, Initcap(p.PROCESSINGSTATUS) status,p.CREATEDATE,p.SUBMITDATE,p.STARTDATE,p.ENDDATE, x.ProcessType, p.CPUSECONDSUSED, p.EXECUTIONHOST, p.EXITCODE
         <c:if test="${!showLatest}">, p.ExecutionNumber || case when  p.IsLatest=1  then '(*)' end processExecutionNumber, s.ExecutionNumber || case when  s.IsLatest=1  then '(*)' end streamExecutionNumber</c:if>
         from PROCESSINSTANCE p
         join streampath sp using (stream)
         join stream s using (stream)
         join process x using (process)
         where PROCESS=?
         <sql:param value="${param.process}"/>
         <c:if test="${showLatest}">and sp.IsLatestPath = 1 and p.isLatest=1</c:if>
         <c:if test="${!empty status}">
            and p.PROCESSINGSTATUS=?
            <sql:param value="${status}"/>
         </c:if>
         ) where (null is null) 
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
      
      <c:set var="isBatch" value="${test.rows[0].processType=='BATCH'}"/> 
      
      <form name="DateForm">
         <table class="filtertable"><tr><th>Stream</th><td>Min</td><td><input type="text" name="min" value="${min}"></td><td>Max</td><td><input type="text" name="max" value="${max}"></td> 
               <td>Status: <select size="1" name="status">
                     <option value="">All</option>
                     <c:forEach var="row" items="${proc_stats.rows}">
                        <option value="${row.PROCESSINGSTATUS}" ${status==row.PROCESSINGSTATUS ? "selected" : ""}>${pl:prettyStatus(row.PROCESSINGSTATUS)}</option>
                     </c:forEach>
            </select></td></tr>
            <tr><th>Date</th><td>Start</td><td><script language="JavaScript">FSfncWriteFieldHTML("DateForm","minDate","${empty minDate ? 'None' : minDate}",100,"http://glast-ground.slac.stanford.edu/Commons/images/FSdateSelector/","US",false,true)</script></td>
               <td>End</td><td><script language="JavaScript">FSfncWriteFieldHTML("DateForm","maxDate","${empty maxDate ? 'None' : maxDate}",100,"http://glast-ground.slac.stanford.edu/Commons/images/FSdateSelector/","US",false,true)</script></td>
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
               <display:table class="datatable" name="${test.rows}" sort="list" defaultsort="1" defaultorder="ascending" pagesize="${test.rowCount>50 && empty param.showAll ? 20 : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >
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
                  <display:column property="links" title="Links" />
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
