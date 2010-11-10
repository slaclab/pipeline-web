<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="aida" uri="http://aida.freehep.org/jsp20" %>
<%@taglib prefix="tab" uri="http://java.freehep.org/tabs-taglib" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="aida" uri="http://aida.freehep.org/jsp20" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.*,javax.servlet.jsp.jstl.sql.*,hep.aida.*"%>

<html>
    <head>
        <title>Performance Plots</title>
    </head>
    <body>

        <%
        String[] plotColors = new String[] {"red","blue","green","black","orange","purple","brown","gray","pink"};
        session.setAttribute("plotColors",plotColors);
        session.setAttribute("numberPlotColors",plotColors.length);
        %>
        <%-- see if all or only one plot is to be displayed and
         then set plotter ny & nx values accordingly --%>

        <c:if test = "${empty param.selectedPlot}">
            <c:set var ="selectedPlot" value="ALL"/>
            <c:set var="plotnumX" value="2" />
            <c:set var="plotnumY" value="2"/>
            <c:set var="plotheight" value="600"/>
            <c:set var="plotwidth" value="600"/>
        </c:if>
        <c:if test = "${!empty param.selectedPlot}">
            <c:set var ="selectedPlot" value="${param.selectedPlot}"/>
            <c:set var="plotnumX" value="2" />
            <c:set var="plotnumY" value="1" />
            <c:set var="plotheight" value="400"/>
            <c:set var="plotwidth" value="800"/>
        </c:if>

        <c:set var="lineSize" value="2"/>
        <sql:query var="datacheck">
            select createdate,startdate,enddate
            from stream where task=? and streamstatus='SUCCESS' and PII.GetStreamIsLatestPath(Stream)=1
            <sql:param value="${task}"/>
        </sql:query>

        <sql:query var="processes">
            select p.PROCESS,p.PROCESSNAME,p.PROCESSTYPE from PROCESS p
            where p.TASK=?
            order by p.process
            <sql:param value="${task}"/>
        </sql:query>

        <c:if test="${fn:length(datacheck.rows) <= 0}">
            <br>    <strong> There are no successful processes to plot for this task </strong><br>
        </c:if>
        <c:if test="${fn:length(datacheck.rows) > 0}">
            <tab:tabs name="ProcessTabs" param="process">
                <tab:tab name="Summary" href="P2stats.jsp?task=${task}" value="0">
                    <sql:query var="data">
                        select createdate,startdate,enddate
                        from stream where task=? and streamstatus='SUCCESS' and  PII.GetStreamIsLatestPath(Stream)=1
                        <sql:param value="${task}"/>
                    </sql:query>
                    <aida:tuple var="tuple" query="${data}" />
                    <aida:tupleProjection var="elapsed" tuple="${tuple}" xprojection="(ENDDATE-STARTDATE)/60"/>
                    <aida:tupleProjection var="wait" tuple="${tuple}" xprojection="(STARTDATE-CREATEDATE)/60"/>
                    <sql:query var="stream_data">
                        with q1 as
                           (select TRUNC(EndDate) on_date, COUNT(1) successfully_completed
                              from Stream
                              where Task=? and StreamStatus='SUCCESS'
                              group by Task, TRUNC(EndDate))
                        select on_date, successfully_completed, sum(successfully_completed) over (order by on_date) tot from q1
                        <sql:param value="${task}"/>
                    </sql:query>
                    <aida:tuple var="stream_tuple" query="${stream_data}" />
                    <aida:datapointset var="succeeded" tuple="${stream_tuple}" yaxisColumn="SUCCESSFULLY_COMPLETED" xaxisColumn="ON_DATE" />
                    <aida:datapointset var="succ_run_total" tuple="${stream_tuple}" yaxisColumn="TOT" xaxisColumn="ON_DATE" />
                    <aida:plotter nx="2" ny="2" height="600" width="600">
                        <aida:style>
                            <aida:attribute name="statisticsBoxFontSize" value="8"/>
                            <aida:style type="data">
                                <aida:attribute name="showErrorBars" value="false"/>
                            </aida:style>
                        </aida:style>
                        <aida:region title="Elapsed time (mins)">
                            <aida:plot var="${elapsed}"/>
                        </aida:region>
                        <aida:region title="Wait time (mins)">
                            <aida:plot var="${wait}"/>
                        </aida:region>

                        <aida:region title= "Task Throughput" colSpan="2">
                           <aida:style>
                              <aida:style type="legendBox">
                                 <aida:attribute name="isVisible" value="false"/>
                              </aida:style>
                              <aida:style type="xAxis">
                                 <aida:attribute name="label" value=""/>
                                 <aida:attribute name="type" value="date"/>
                              </aida:style>
                              <aida:style type="data">
                                 <aida:attribute name="connectDataPoints" value="false"/>
                              </aida:style>
                           </aida:style>

                           <aida:plot var="${succ_run_total}">
                              <aida:style type="plotter">
                                 <aida:style type="yAxis">
                                    <aida:attribute name="yAxis" value="Y1"/>
                                    <aida:attribute name="label" value="Succeeded Total"/>
                                    <aida:attribute name="allowZeroSuppression" value="false"/>
                                 </aida:style>
                                 <aida:style type="data">
                                    <aida:style type="outline">
                                       <aida:attribute name="color" value="blue"/>
                                    </aida:style>
                                    <aida:style type="marker">
                                       <aida:attribute name="color" value="blue"/>
                                       <aida:attribute name="shape" value="box"/>
                                    </aida:style>
                                 </aida:style>
                              </aida:style>
                           </aida:plot>
                           <aida:plot var="${succeeded}">
                              <aida:style type="plotter">
                                 <aida:style type="yAxis">
                                    <aida:attribute name="yAxis" value="Y0"/>
                                    <aida:attribute name="label" value="Succeeded"/>
                                    <aida:attribute name="allowZeroSuppression" value="false"/>
                                 </aida:style>
                                 <aida:style type="data">
                                    <aida:style type="outline">
                                       <aida:attribute name="color" value="red"/>
                                    </aida:style>
                                    <aida:style type="marker">
                                       <aida:attribute name="color" value="red"/>
                                       <aida:attribute name="shape" value="triangle"/>
                                    </aida:style>
                                 </aida:style>
                              </aida:style>
                           </aida:plot>
                        </aida:region>
                     </aida:plotter>

                </tab:tab>

                <c:forEach var="row" items="${processes.rows}">
                    <tab:tab name="${row.PROCESSNAME}" href="P2stats.jsp" value="${row.PROCESS}">

                        <sql:query var="data">
                            select enddate,startdate,submitdate,cpusecondsused,
                            regexp_substr(lower(PI.executionhost), '^[a-z]+')executionhost
                            from processinstance PI
                            where PI.process = ?
                            and PI.processingstatus = 'SUCCESS'
                            <sql:param value="${row.PROCESS}"/>
                        </sql:query>

                        <aida:tuple var="tuple" query="${data}" />

                        <%-- Don't plot this section if an single NODE plot is to be displayed
                             to display plot at top of the web page ....--%>
                        <c:if test="${param.nodeplot ne 'y'}">

                            <aida:tupleProjection var="wallPlot" tuple="${tuple}" xprojection="(ENDDATE-STARTDATE)/60" />
                            <aida:plotter nx="${plotnumX}" ny="${plotnumY}" height="${plotheight}" width="${plotwidth}" createImageMap="true">
                                <aida:style>
                                    <aida:attribute name="statisticsBoxFontSize" value="8"/>
                                    <aida:style type="data">
                                        <aida:attribute name="showErrorBars" value="false"/>
                                    </aida:style>
                                </aida:style>

                                <c:set var ="plotName" value ="wallPlot"/>
                                <c:if test="${selectedPlot == plotName or selectedPlot =='ALL' }" >
                                    <aida:region title="Wall Clock time (mins)" var="region" href="?selectedPlot=${plotName}&process=${row.process}" >
                                        <aida:plot var="${wallPlot}"/>
                                    </aida:region>
                                </c:if>
                                <c:if test="${row.processtype !='SCRIPT'}">
                                    <c:set var ="plotName" value ="pendingPlot"/>
                                    <c:if test="${selectedPlot == plotName or selectedPlot =='ALL' }" >
                                        <aida:region title="Pending time (mins)" var="region" href="?selectedPlot=${plotName}&process=${row.process}" >
                                            <aida:tupleProjection var="waitPlot" tuple="${tuple}" xprojection="(STARTDATE-SUBMITDATE)/60"/>
                                            <aida:plot var="${waitPlot}"/>
                                        </aida:region>
                                    </c:if>
                                    <c:set var ="plotName" value ="cpuSecondsPlot"/>
                                    <c:if test="${selectedPlot == plotName or selectedPlot =='ALL' }" >
                                        <aida:region title="CPU time (mins)" var="region" href="?selectedPlot=${plotName}&process=${row.process}" >
                                            <aida:tupleProjection var="cpuSeconds" tuple="${tuple}" xprojection="CPUSECONDSUSED/60"/>
                                            <aida:plot var="${cpuSeconds}"/>
                                        </aida:region>
                                    </c:if>
                                    <c:set var ="plotName" value ="cpuWallPlot"/>
                                    <c:if test="${selectedPlot == plotName or selectedPlot =='ALL' }" >
                                        <aida:region title="CPU time/Wall Clock" var="region" href="?selectedPlot=${plotName}&process=${row.process}" >
                                            <aida:tupleProjection var="wallCpu" tuple="${tuple}" xprojection="CPUSECONDSUSED/(ENDDATE-STARTDATE)"/>
                                            <aida:plot var="${wallCpu}"/>
                                        </aida:region>
                                    </c:if>
                                </c:if>
                            </aida:plotter>
                        </c:if>
                        <c:if test="${row.processtype !='SCRIPT'}">
                            <sql:query var="hostnode">
                                select distinct(regexp_substr(lower(PI.executionhost), '^[a-z]+') ) executionhost
                                from processinstance PI  ,process P
                                where PI.process = P.process
                                and PI.process = ?
                                and executionhost is not null
                                <sql:param value="${row.process}"/>
                            </sql:query>

                            <c:if test="${fn:length(hostnode.rows) > 0}">

                                <br> <strong>  PLOTS by BATCH NODES</strong><br>

                                <aida:plotter nx="${plotnumX}" ny="${plotnumY}" height="${plotheight}" width="${plotwidth}" createImageMap="true">
                                    <aida:style>
                                        <aida:style type="statisticsBox">
                                            <aida:attribute name="isVisible" value="false"/>
                                        </aida:style>
                                        <aida:style type="data">
                                            <aida:style type="errorBar">
                                                <aida:attribute name="isVisible" value="false"/>
                                            </aida:style>
                                            <aida:style type="fill">
                                                <aida:attribute name="isVisible" value="false"/>
                                            </aida:style>
                                        </aida:style>
                                    </aida:style>
                                    <c:set var ="plotName" value ="wallPlotNodes"/>
                                    <c:if test="${selectedPlot == plotName or selectedPlot =='ALL'}" >
                                        <aida:region title="Wall Clock time (mins)" var="region" href="?selectedPlot=${plotName}&process=${row.process}&nodeplot=y" >
                                            <c:forEach var="rowB" items="${hostnode.rows}" varStatus="status">
                                                <aida:tupleProjection  name="${rowB.executionhost}" var="wallPlot" tuple="${tuple}" xprojection="(ENDDATE-STARTDATE)/60" filter="EXECUTIONHOST == \"${rowB.executionhost}\" "/>
                                                <aida:plot var="${wallPlot}">
                                                    <aida:style>
                                                        <aida:style type="line">
                                                            <aida:attribute name="color" value="${plotColors[status.index%numberPlotColors]}"/>
                                                            <aida:attribute name="thickness" value="${lineSize}"/>
                                                        </aida:style>
                                                    </aida:style>
                                                </aida:plot>
                                            </c:forEach>
                                        </aida:region>
                                    </c:if>
                                    <c:if test="${row.processtype !='SCRIPT'}">
                                        <c:set var ="plotName" value ="waitPlotNodes"/>
                                        <c:if test="${selectedPlot == plotName or selectedPlot =='ALL' }" >

                                            <aida:region title="Pending time (mins)" var="region" href="?selectedPlot=${plotName}&process=${row.process}&nodeplot=y">
                                                <c:forEach var="rowB" items="${hostnode.rows}" varStatus="status">
                                                    <aida:tupleProjection  name="${rowB.executionhost}" var="waitPlot" tuple="${tuple}" xprojection="(STARTDATE-SUBMITDATE)/60" filter="EXECUTIONHOST == \"${rowB.executionhost}\" "/>
                                                    <aida:plot var="${waitPlot}">
                                                        <aida:style>
                                                            <aida:style type="line">
                                                                <aida:attribute name="color" value="${plotColors[status.index%numberPlotColors]}"/>
                                                                <aida:attribute name="thickness" value="${lineSize}"/>
                                                            </aida:style>
                                                        </aida:style>
                                                    </aida:plot>
                                                </c:forEach>
                                            </aida:region>
                                        </c:if>
                                        <c:set var ="plotName" value ="cpuSecondsPlotNodes"/>
                                        <c:if test="${selectedPlot == plotName or selectedPlot =='ALL' }" >
                                            <aida:region title="CPU time (mins)" var="region" href="?selectedPlot=${plotName}&process=${row.process}&nodeplot=y">
                                                <c:forEach var="rowB" items="${hostnode.rows}" varStatus="status">
                                                    <aida:tupleProjection name="${rowB.executionhost}" var="cpuSeconds" tuple="${tuple}" xprojection="CPUSECONDSUSED/60" filter="EXECUTIONHOST == \"${rowB.executionhost}\" "/>
                                                    <aida:plot var="${cpuSeconds}">
                                                        <aida:style>
                                                            <aida:style type="line">
                                                                <aida:attribute name="color" value="${plotColors[status.index%numberPlotColors]}"/>
                                                                <aida:attribute name="thickness" value="${lineSize}"/>
                                                            </aida:style>
                                                        </aida:style>
                                                    </aida:plot>
                                                </c:forEach>
                                            </aida:region>
                                        </c:if>
                                        <c:set var ="plotName" value ="wallCpuPlotNodes"/>
                                        <c:if test="${selectedPlot == plotName or selectedPlot =='ALL' }" >
                                            <aida:region title="CPU time/Wall Clock" var="region" href="?selectedPlot=${plotName}&process=${row.process}&nodeplot=y">
                                                <c:forEach var="rowB" items="${hostnode.rows}" varStatus="status">
                                                    <aida:tupleProjection name="${rowB.executionhost}" var="wallCpu" tuple="${tuple}" xprojection="CPUSECONDSUSED/(ENDDATE-STARTDATE)" filter="EXECUTIONHOST == \"${rowB.executionhost}\" "/>
                                                    <aida:plot var="${wallCpu}">
                                                        <aida:style>
                                                            <aida:style type="line">
                                                                <aida:attribute name="color" value="${plotColors[status.index%numberPlotColors]}"/>
                                                                <aida:attribute name="thickness" value="${lineSize}"/>
                                                            </aida:style>
                                                        </aida:style>
                                                    </aida:plot>
                                                </c:forEach>
                                            </aida:region>
                                        </c:if>
                                    </c:if>
                                </aida:plotter>
                            </c:if>
                        </c:if>
                    </tab:tab>
                </c:forEach>
            </tab:tabs>
        </c:if>
    </body>
</html>