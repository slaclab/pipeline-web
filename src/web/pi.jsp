<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 

<html>
    <head>
        <title>Task ${taskName} Process ${processName} Stream ${streamIdPath}</title>
    </head>
    <body>

        <h2>Task ${taskName} Process ${processName} Stream ${streamIdPath}</h2>

        <sql:query var="rs">
            select * from processinstance
            join process using (process)
            where processinstance=?
            <sql:param value="${param.pi}"/>
        </sql:query>
        <c:set var="data" value="${rs.rows[0]}"/>

        <sql:query var="executions">
            select executionnumber, processinstance from processinstance
            join process using (process)
            where process=? and stream=? and AutoRetryNumber=0 and ExecutionNumber != ?
            <sql:param value="${data.process}"/>
            <sql:param value="${data.stream}"/>
            <sql:param value="${data.ExecutionNumber}"/>
        </sql:query>

        <sql:query var="retries">
            select processinstance, AutoRetryNumber from processinstance
            join process using (process)
            where process=? and stream=? and ExecutionNumber=? and AutoRetryNumber != ?
            <sql:param value="${data.process}"/>
            <sql:param value="${data.stream}"/>
            <sql:param value="${data.ExecutionNumber}"/>
            <sql:param value="${data.AutoRetryNumber}"/>
        </sql:query>


        <table>
            <tr><td>Type</td><td>${pl:prettyStatus(data.processtype)}</td></tr>
            <tr><td>Status</td><td>${pl:prettyStatus(data.processingstatus)}</td></tr>
            <tr><td>Stream</td><td>${pl:linkToStreams(streamIdPath,streamPath,".","si.jsp?stream=")}</td></tr>
            <tr><td>CreateDate</td><td>${pl:formatTimestamp(data.createDate)}</td></tr>
            <tr><td>SubmitDate</td><td>${pl:formatTimestamp(data.submitDate)}</td></tr>
            <tr><td>StartDate</td><td>${pl:formatTimestamp(data.startDate)}</td></tr>
            <tr><td>EndDate</td><td>${pl:formatTimestamp(data.endDate)}</td></tr>
            <tr><td>CPU Used</td><td>${data.CpuSecondsUsed}</td></tr>
            <tr><td>Memory Used</td><td>${data.MemoryUsed}</td></tr>
            <tr><td>Swap Used</td><td>${data.SwapUsed}</td></tr>
            <tr><td>Execution Host</td><td>${data.ExecutionHost}</td></tr>
            <tr><td>Exit Code</td><td>${data.ExitCode}</td></tr>
            <tr><td>Working Dir</td><td><a href="run.jsp?pi=${param.pi}">${data.WorkingDir}</a></td></tr>
            <tr><td>Log File</td><td><a href="log.jsp?pi=${param.pi}">${data.LogFile}</a></td></tr>
            <tr>
                <td>Execution Number</td>
                <td><b>${data.ExecutionNumber}</b>
                    <c:forEach var="row" items="${executions.rows}">
                        ,&nbsp;<a href="pi.jsp?pi=${row.processinstance}">${row.executionnumber}</a>
                    </c:forEach>
                </td>
            </tr>
            <tr>
                <td>Retry Number</td>
                <td><b>${data.AutoRetryNumber}</b>
                    <c:forEach var="row" items="${retries.rows}">
                        ,&nbsp;<a href="pi.jsp?pi=${row.processinstance}">${row.AutoRetryNumber}</a>
                    </c:forEach>
                </td>
            </tr>
            <tr><td>Is Latest</td><td>${data.IsLatest}</td></tr>
            <tr><td>Batch Job ID</td><td><a href="job.jsp?id=${data.JobId}&site=${data.JobSite}">${data.JobId}</a></td></tr>
        </table>

        <p>Links: <a href="logViewer.jsp?pi=${param.pi}&severity=500&minDate=None&maxDate=None">View Messages</a></p>

        <h3>Variables</h3>
        <sql:query var="rs">
            select * from processinstancevar
            where processinstance=?
            <sql:param value="${param.pi}"/>
        </sql:query>

        <display:table class="datatable" name="${rs.rows}" defaultsort="1" defaultorder="ascending">
            <display:column property="varname" title="Name" sortable="true" headerClass="sortable" />
            <display:column property="vartype" title="Type" sortable="true" headerClass="sortable"/>
            <display:column property="value" title="Value" sortable="true" headerClass="sortable" class="leftAligned"/>
        </display:table>


        <c:set var="showDownstreamPIs" value="${!empty param.showDownstreamPIsChanged ? !empty param.showDownstreamPIs : empty showDownstreamPIs ? true : showDownstreamPIs}" scope="session"/>
        <c:set var="showUpStreamPIs" value="${!empty param.showUpStreamPIsChanged ? !empty param.showUpStreamPIs : empty showUpStreamPIs ? true : showUpStreamPIs}" scope="session"/>
        <c:set var="showSubStreams" value="${!empty param.showSubStreamsChanged ? !empty param.showSubStreams : empty showSubStreams ? true : showSubStreams}" scope="session"/>
        <br>
        <pt:autoCheckBox name="showUpStreamPIs" value="${showUpStreamPIs}">Show UpStream Process Instances</pt:autoCheckBox>
        <pt:autoCheckBox name="showDownstreamPIs" value="${showDownstreamPIs}">Show Downstream Process Instances</pt:autoCheckBox>
        <pt:autoCheckBox name="showSubStreams" value="${showSubStreams}">Show Created SubStreams</pt:autoCheckBox>
        <br>

        <c:if test="${showUpStreamPIs}">
            <h3>Upstream Process Instances</h3>
            <sql:query var="dependentprocesses">
                select PI.ProcessInstance, P.Process, PI.Stream, P.ProcessName, Initcap(PI.ProcessingStatus) status, Initcap(P.ProcessType) ProcessType,
                PI.CreateDate, PI.SubmitDate, PI.StartDate, PI.EndDate, PI.JobID, PI.JobSite, PI.cpuSecondsUsed, PI.ExecutionHost, PI.ExecutionNumber,
                PI.AutoRetryNumber, P.AutoRetryMaxAttempts, PI.IsLatest, PC.Condition
                from
                ProcessInstance PI join Process P on (P.Process = PI.Process)
                join ((select Process, DependentProcess, InitCap(ProcessingStatus) AS Condition from ProcessStatusCondition where Hidden=0) UNION (select Process, DependentProcess, 'DONE' AS Condition from ProcessCompletionCondition where Hidden=0)) PC on (PI.Process = PC.Process)
                join (select ProcessInstance, Process, Stream, ParentStream from ProcessInstance join Stream using (Stream) where ProcessInstance=?) CurPI on (PC.DependentProcess = CurPI.Process and (PI.Stream = CurPI.Stream OR PI.Stream in (select Stream from Stream where ParentStream=CurPI.Stream)))
                where PI.IsLatest = 1
                order by displayorder
                <sql:param value="${param.pi}"/>
            </sql:query>

            <display:table class="datatable" name="${dependentprocesses.rows}" id="row" sort="list" pagesize="0" decorator="org.glast.pipeline.web.decorators.ProcessDecorator">
                <display:column property="Condition" title="Wait Condition" sortable="true" headerClass="sortable"/>
                <display:column property="ProcessName" title="Process" sortable="true" headerClass="sortable" href="pi.jsp" paramId="pi" paramProperty="ProcessInstance"/>
                <display:column property="Status" title="Status" sortable="true" headerClass="sortable"/>

                <display:column property="ProcessType" title="Type" sortable="true" headerClass="sortable" href="script.jsp" paramId="process" paramProperty="Process"/>
                <display:column property="CreateDate" title="Created" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
                <display:column property="SubmitDate" title="Submitted" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
                <display:column property="StartDate" title="Started" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
                <display:column property="EndDate" title="Ended" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
                <display:column property="job" title="Job Id" sortable="true" headerClass="sortable"/>
                <display:column property="cpuSecondsUsed" title="CPU" sortable="true" headerClass="sortable"/>
                <display:column property="executionHost" title="Host" sortable="true" headerClass="sortable"/>
                <display:column property="links" title="Links" class="leftAligned"/>
                <display:footer>
                </display:footer>
            </display:table>
        </c:if >

        <c:if test="${showDownstreamPIs}">
            <h3>Downstream Process Instances</h3>
            <sql:query var="dependentprocesses">
                select PI.ProcessInstance, P.Process, PI.Stream, P.ProcessName, Initcap(PI.ProcessingStatus) status, Initcap(P.ProcessType) ProcessType,
                PI.CreateDate, PI.SubmitDate, PI.StartDate, PI.EndDate, PI.JobID, PI.JobSite, PI.cpuSecondsUsed, PI.ExecutionHost, PI.ExecutionNumber,
                PI.AutoRetryNumber, P.AutoRetryMaxAttempts, PI.IsLatest, PC.Condition
                from
                ProcessInstance PI join Process P on (P.Process = PI.Process) join ((select Process, DependentProcess, InitCap(ProcessingStatus) AS Condition from ProcessStatusCondition where Hidden=0) UNION (select Process, DependentProcess, 'DONE' AS Condition from ProcessCompletionCondition where Hidden=0)) PC on (PI.Process = PC.DependentProcess)
                join (select ProcessInstance, Process, Stream, ParentStream from ProcessInstance join Stream using (Stream) where ProcessInstance=?) CurPI on (PC.Process = CurPI.Process and (PI.Stream in (CurPI.Stream, CurPI.ParentStream)))
                where PI.IsLatest = 1
                order by displayorder
                <sql:param value="${param.pi}"/>
            </sql:query>

            <display:table class="datatable" name="${dependentprocesses.rows}" id="row" sort="list" pagesize="0" decorator="org.glast.pipeline.web.decorators.ProcessDecorator">
                <display:column property="Condition" title="Wait Condition" sortable="true" headerClass="sortable"/>
                <display:column property="ProcessName" title="Process" sortable="true" headerClass="sortable" href="pi.jsp" paramId="pi" paramProperty="ProcessInstance"/>
                <display:column property="Status" title="Status" sortable="true" headerClass="sortable"/>

                <display:column property="ProcessType" title="Type" sortable="true" headerClass="sortable" href="script.jsp" paramId="process" paramProperty="Process"/>
                <display:column property="CreateDate" title="Created" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
                <display:column property="SubmitDate" title="Submitted" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
                <display:column property="StartDate" title="Started" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
                <display:column property="EndDate" title="Ended" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
                <display:column property="job" title="Job Id" sortable="true" headerClass="sortable"/>
                <display:column property="cpuSecondsUsed" title="CPU" sortable="true" headerClass="sortable"/>
                <display:column property="executionHost" title="Host" sortable="true" headerClass="sortable"/>
                <display:column property="links" title="Links" class="leftAligned"/>
                <display:footer>
                </display:footer>
            </display:table>
        </c:if >

        <c:if test="${showSubStreams}">
            <h3>SubStreams Created</h3>
            <sql:query var="createdStreams">
                select t.taskname, s.stream, s.streamid, Initcap(s.streamstatus)
                StreamStatus, s.createDate, s.StartDate, s.EndDate
                from stream s
                join Task t on (s.Task = t.task)
                join (select Stream ParStream, SubTask from
                ProcessInstance join CreateSubTaskCondition using (Process) where
                ProcessInstance=?) PS on (PS.ParStream = S.ParentStream and PS.SubTask = T.Task)
                where S.isLatest=1
                order by T.task, S.streamid
                <sql:param value="${param.pi}"/>
            </sql:query>


            <display:table class="datatable" name="${createdStreams.rows}" sort="list" defaultsort="1" defaultorder="ascending" pagesize="${createdStreams.rowCount>50 && empty param.showAll ? 20 : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >
                <display:column property="Taskname" title="taskname" sortable="true" group = "1" headerClass="sortable" />
                <display:column property="StreamId" title="Stream" sortable="true" headerClass="sortable" href="si.jsp" paramId="stream" paramProperty="stream"/>
                <display:column property="StreamStatus" title="Status" sortable="true" headerClass="sortable"/>
                <display:column property="CreateDate" title="Created" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator"/>
                <display:column property="StartDate" title="Started" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator"/>
                <display:column property="EndDate" title="Ended" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator"/>
                <display:footer>
                </display:footer>
            </display:table>
        </c:if >

    </body>
</html>
