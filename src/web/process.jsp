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
        <script language="JavaScript" src="scripts/FSdateSelect-UTF8.js"></script>
        <link rel="stylesheet" href="css/FSdateSelect.css" type="text/css">        
    </head>
    <body>
        
        <sql:query var="proc_stats">
            select PROCESSINGSTATUS_PK "psPK", PROCESSINGSTATUSNAME "psName" from PROCESSINGSTATUS
        </sql:query>
 
        <sql:query var="name">
            select TASKPROCESSNAME from TASKPROCESS where TASKPROCESS_PK=?
            <sql:param value="${param.process}"/>           
        </sql:query>  
        <c:set var="processName" value="${name.rows[0].TASKPROCESSNAME}"/>
        
        <h2>Runs for process: ${processName}</h2>
        
        <p><b>*NEW*</b> <a href="stats.jsp?task=${param.task}&process=${param.process}">Show processing statistics</a></p>
        
        <c:choose>
            <c:when test="${empty param.clear}">  
                <c:set var="min" value="${param.min}"/>
                <c:set var="max" value="${param.max}"/>
                <c:set var="minDate" value="${param.minDate}"/>
                <c:set var="maxDate" value="${param.maxDate}"/> 
                <c:set var="status" value="${param.status}"/>
            </c:when>
            <c:otherwise>
                <c:set var="min" value=""/>
                <c:set var="max" value=""/>
                <c:set var="minDate" value=""/>
                <c:set var="maxDate" value=""/> 
                <c:set var="status" value=""/>
            </c:otherwise>
        </c:choose>
               
        <c:set var="runNumber" value="to_number(RUNNAME)"/>
        <c:if test="${fn:contains(taskName,'b33')}">
            <c:set var="runNumber" value="RUNNAME"/>
        </c:if>

        <sql:query var="test">select * from 
               ( select rownum, TPINSTANCE_PK "Id", to_number(RUNNAME) "Run", PROCESSINGSTATUSNAME "Status", SUBMITTED "Submitted", MEMORYBYTES "Bytes", CPUSECONDS "Cpu", PID 
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
                <tr><th>Date</th><td>Start</td><td><script language="JavaScript">FSfncWriteFieldHTML("DateForm","minDate","${empty minDate ? 'None' : minDate}",100,"img/FSdateSelector/","US",false,true)</script></td>
                <td>End</td><td><script language="JavaScript">FSfncWriteFieldHTML("DateForm","maxDate","${empty maxDate ? 'None' : maxDate}",100,"img/FSdateSelector/","US",false,true)</script></td>
                <td><input type="submit" value="Filter">&nbsp;<input type="submit" value="Clear" name="clear">
                <input type="hidden" name="task" value="${param.task}"> 
                <input type="hidden" name="process" value="${param.process}"></td></tr>
                <tr><td colspan="4"><input type="checkbox" name="showAll" ${empty param.showAll ? "" : "checked"} > Show all runs on one page</td></tr>
            </table>
        </form>
        
        <display:table class="dataTable" name="${test.rows}" sort="list" defaultsort="1" defaultorder="ascending" pagesize="${test.rowCount>50 && empty param.showAll ? 20 : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >
            <display:column property="Run" sortable="true" headerClass="sortable" />
            <display:column property="status" sortable="true" headerClass="sortable"/>
            <display:column property="Submitted" sortable="true" headerClass="sortable"/>
            <display:column property="bytes" title="Memory (MB)" sortable="true" headerClass="sortable"/>
            <display:column property="cpu" title="CPU (secs)" sortable="true" headerClass="sortable"/>
            <display:column property="job" title="Job Id" sortable="true" headerClass="sortable"/>
            <display:column property="links" title="Links (<a href=help.html>?</a>)" />
        </display:table>

    </body>
</html>
