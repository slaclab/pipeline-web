<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>

<html>
    <head>
        <title>Pipeline status</title>
        <link rel="stylesheet" href="css/screen.css" type="text/css" media="screen, print" />
    </head>
    <body>
        <c:import url="header.jsp"/>
        <div id="breadCrumb"> 
            <a href="index.jsp">status</a> /
        </div> 
    
        <sql:query var="name">
            select TASKNAME from TASK where TASK_PK=?
            <sql:param value="${param.task}"/>           
        </sql:query>
        
        <sql:query var="proc_stats">
            select PROCESSINGSTATUS_PK "psPK", PROCESSINGSTATUSNAME "psName" from PROCESSINGSTATUS
        </sql:query>
 
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
        
        <h2>Run Summary: ${name.rowsByIndex[0][0]} XML: <a href="xml.jsp?xml=dump.jsp&task=${param.task}">(1.0)</a> <a href="xml.jsp?xml=dump11.jsp&task=${param.task}">(1.1)</a> <a href="xml.jsp?xml=catalog.jsp&task=${param.task}">(catalog)</a> </h2>

        <c:choose>
            <c:when test="${empty summary.rows[0]['ALL']}">
                <p> No runs in this task.</p>
            </c:when>
            <c:otherwise>
                <p>To filter by status click on the count in the status column. To see all runs click on the name in the Name column.</p>   
                <p><b>*NEW*</b> <a href="running.jsp?task=${param.task}">Show running jobs</a></p>
        
                <p>Task Summary: 
                    <c:forEach var="row" items="${run_stats.rows}" varStatus="status">
                        ${pl:prettyStatus(row.rsName)}:&nbsp;${summary.rowsByIndex[0][status.index]},
                    </c:forEach>
                    Total:&nbsp;${summary.rows[0]["ALL"]}
                </p>

                <sql:query var="test">select 
                    <c:forEach var="row" items="${proc_stats.rows}">
                        SUM(case when PROCESSINGSTATUS_FK=${row.psPK} then 1 else 0 end) "${row.psName}",
                    </c:forEach>
                    TASKPROCESS_PK "Id", MIN(TASKPROCESSNAME) "Name" , MIN(SEQUENCE) "Sequence"
                    from TASKPROCESS, TPINSTANCE where TASK_FK=? and TASKPROCESS_PK=TASKPROCESS_FK GROUP BY TASKPROCESS_PK
                    <sql:param value="${param.task}"/>
                </sql:query>

                <display:table class="dataTable" name="${test.rows}" defaultsort="1" defaultorder="ascending" decorator="glast.pipeline.web.decorators.ProcessDecorator">
                    <display:column property="Sequence" title="#" sortable="true" headerClass="sortable"/>
                    <display:column property="Name" sortable="true" headerClass="sortable" href="process.jsp?task=${param.task}" paramId="process" paramProperty="Id"/>
                    <c:forEach var="row" items="${proc_stats.rows}">
                        <display:column property="${row.psName}" title="${pl:prettyStatus(row.psName)}" sortable="true" headerClass="sortable" href="process.jsp?task=${param.task}&status=${row.psPK}" paramId="process" paramProperty="Id"/>
                    </c:forEach>
                    <display:column property="taskLinks" title="Links (<a href=help.html>?</a>)" />
                </display:table>
            </c:otherwise>
        </c:choose>
    </body>
</html>
