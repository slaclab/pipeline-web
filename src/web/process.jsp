<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html>
    <head>
        <title>Pipeline status</title>
        <script language="JavaScript" src="http://glast-ground.slac.stanford.edu/Commons/scripts/FSdateSelect.jsp"></script>
        <link rel="stylesheet" href="http://glast-ground.slac.stanford.edu/Commons/css/FSdateSelect.css" type="text/css">        
    </head>
    <body>
        
        <sql:query var="proc_stats">
            select PROCESSINGSTATUS_PK "psPK", PROCESSINGSTATUSNAME "psName" from PROCESSINGSTATUS
        </sql:query>
        
        <h2>Runs for process: ${processName}</h2>
        
        <p><b>*NEW*</b> <a href="stats.jsp?task=${param.task}&process=${param.process}">Show processing statistics</a></p>

        <sql:query var="run_stats">
            select RUNSTATUS_PK "rsPK", RUNSTATUSNAME "rsName" from RUNSTATUS
        </sql:query>
        
        <sql:query var="summary">
            select            
            <c:forEach var="row" items="${run_stats.rows}" varStatus="status">
                SUM(case when RUNSTATUS_FK=${row.rsPK} then 1 else 0 end) "${row.rsName}",
            </c:forEach>
            SUM(1) "ALL"
            from RUN r, TASK t WHERE t.TASK_PK=? and r.TASK_FK=t.TASK_PK GROUP BY TASK_FK
            <sql:param value="${param.task}"/>           
        </sql:query> 
        
        <div class="taskSummary">Task Summary: 
           <c:forEach var="row" items="${run_stats.rows}" varStatus="status">
               ${pl:prettyStatus(row.rsName)}:&nbsp;${summary.rowsByIndex[0][status.index]},
           </c:forEach>
           Total:&nbsp;${summary.rows[0]["ALL"]}
        </div>
        
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
                <c:if test="${!empty param.status}"><c:set var="status" value="${param.status == 0 ? '' : param.status}" scope="session"/></c:if>
            </c:otherwise>
        </c:choose>
               
        <c:set var="runNumber" value="to_number(RUNNAME)"/>
        <c:if test="${fn:contains(taskName,'b33')}">
            <c:set var="runNumber" value="RUNNAME"/>
        </c:if>

        <sql:query var="test">select * from 
            ( select rownum, TPINSTANCE_PK "Id", ${runNumber} "Run", PROCESSINGSTATUSNAME "Status", SUBMITTED "Submitted", MEMORYBYTES "Bytes", CPUSECONDS "Cpu", PID 
            from TPINSTANCE i
            join RUN r on (i.RUN_FK=r.RUN_PK)
            join PROCESSINGSTATUS s on (i.PROCESSINGSTATUS_FK=s.PROCESSINGSTATUS_PK)
            where TASKPROCESS_FK=?  
            <c:if test="${!empty status}">and PROCESSINGSTATUS_FK=?</c:if>
            ) where rownum>0
            <c:if test="${!empty min}">and "Run">=? </c:if>
            <c:if test="${!empty max}">and "Run"<=? </c:if>
            <c:if test="${!empty minDate && minDate!='None'}"> and "Submitted">=? </c:if>
            <c:if test="${!empty maxDate && maxDate!='None'}"> and "Submitted"<=? </c:if>
            <sql:param value="${param.process}"/>
            <c:if test="${!empty status}"><sql:param value="${status}"/></c:if>
            <c:if test="${!empty min}"><sql:param value="${min}"/></c:if>
            <c:if test="${!empty max}"><sql:param value="${max}"/></c:if>
            <c:if test="${!empty minDate && minDate!='None'}"> 
                <fmt:parseDate value="${minDate}" pattern="MM/dd/yyyy" var="minDateUsed"/>
                <sql:dateParam value="${minDateUsed}" type="date"/> 
            </c:if>
            <c:if test="${!empty maxDate && maxDate!='None'}"> 
                <fmt:parseDate value="${maxDate}" pattern="MM/dd/yyyy" var="maxDateUsed"/>
                <% java.util.Date d = (java.util.Date) pageContext.getAttribute("maxDateUsed"); 
                    d.setTime(d.getTime()+24*60*60*1000);
                %>
                <sql:dateParam value="${maxDateUsed}" type="date"/> 
            </c:if>
        </sql:query>

        <form name="DateForm">
            <table class="filterTable"><tr><th>Run</th><td>Min</td><td><input type="text" name="min" value="${min}"></td><td>Max</td><td><input type="text" name="max" value="${max}"></td> 
                <td>Status: <select size="1" name="status">
                    <option value="">All</option>
                    <c:forEach var="row" items="${proc_stats.rows}">
                        <option value="${row.psPK}" ${status==row.psPK ? "selected" : ""}>${pl:prettyStatus(row.psName)}</option>
                    </c:forEach>
                </select></td></tr>
                <tr><th>Date</th><td>Start</td><td><script language="JavaScript">FSfncWriteFieldHTML("DateForm","minDate","${empty minDate ? 'None' : minDate}",100,"http://glast-ground.slac.stanford.edu/Commons/images/FSdateSelector/","US",false,true)</script></td>
                <td>End</td><td><script language="JavaScript">FSfncWriteFieldHTML("DateForm","maxDate","${empty maxDate ? 'None' : maxDate}",100,"http://glast-ground.slac.stanford.edu/Commons/images/FSdateSelector/","US",false,true)</script></td>
                <td><input type="submit" value="Filter" name="submit">&nbsp;<input type="submit" value="Clear" name="clear">
                <input type="hidden" name="task" value="${param.task}"> 
                <input type="hidden" name="process" value="${param.process}"></td></tr>
                <tr><td colspan="4"><input type="checkbox" name="showAll" ${empty param.showAll ? "" : "checked"} > Show all runs on one page</td></tr>
            </table>
        </form>
        
        <c:choose>
            <c:when test="${param.mode=='run'}">
                <pre><c:forEach var="row" items="${test.rows}">${row.run}<br></c:forEach></pre>
            </c:when>
            <c:when test="${param.mode=='id'}">
                <pre><c:forEach var="row" items="${test.rows}"><c:if test="${!empty row.PID}">${row.PID}<br></c:if></c:forEach></pre>
            </c:when>
            <c:otherwise>
                <display:table class="dataTable" name="${test.rows}" sort="list" defaultsort="1" defaultorder="ascending" pagesize="${test.rowCount>50 && empty param.showAll ? 20 : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >
                    <display:column property="Run" sortable="true" headerClass="sortable" />
                    <display:column property="status" sortable="true" headerClass="sortable"/>
                    <display:column property="submitted" sortable="true" headerClass="sortable"/>
                    <display:column property="bytes" title="Memory (MB)" sortable="true" headerClass="sortable"/>
                    <display:column property="cpu" title="CPU (secs)" sortable="true" headerClass="sortable"/>
                    <display:column property="job" title="Job Id" sortable="true" headerClass="sortable"/>
                    <display:column property="links" title="Links (<a href=help.html>?</a>)" />
                </display:table>
                <c:if test="${test.rowCount>0}">
                    <ul>
                    <li><a href="process.jsp?process=${param.process}&task=${param.task}&mode=run">Dump run list</a>.</li>
                    <li><a href="process.jsp?process=${param.process}&task=${param.task}&mode=id">Dump job id list</a>.</li>
                    </ul>
                </c:if>
            </c:otherwise>
        </c:choose>
    </body>
</html>
