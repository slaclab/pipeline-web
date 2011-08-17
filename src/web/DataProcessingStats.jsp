<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="aida" uri="http://aida.freehep.org/jsp20" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib prefix="time" uri="http://srs.slac.stanford.edu/time" %>
<%@ page import="hep.aida.*" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
    <head>
        <title>Data Processing delay</title>
    </head>
    <body>

        <c:set var="startTime" value="${param.startTime}"/>
        <c:set var="endTime" value="${param.endTime}"/>

        <c:if test="${param.filter=='Clear'}">
            <c:set var="startTime" value="-1"/>
            <c:set var="endTime" value="-1"/>
        </c:if>

        <form name="DateForm">
            <table class="filtertable">
                <tr>
                    <td><strong>Start</strong> <time:dateTimePicker size="20" name="startTime" showtime="false" format="%b/%e/%y" value="${startTime}"  timezone="PST8PDT"/></td>
                    <td><strong>End</strong> <time:dateTimePicker size="20" name="endTime" showtime="false" format="%b/%e/%y" value="${endTime}" timezone="PST8PDT"/> </td>
                </tr>
                <tr>
                    <td> <input type="submit" value="Filter" name="filter"><input type="submit" value="Clear" name="filter"></td>
                </tr>
            </table>
        </form>

        <sql:query var="data">
            select (GLAST_UTIL.GetDeltaSeconds(dv.registered-to_date('01-JAN-01'))-f.treceive+978307200)/3600+
    (case when (dv.registered>'07-NOV-10 02:00' and dv.registered<'13-MAR-11 02:00') or
               (dv.registered>'01-NOV-09 02:00' and dv.registered<'14-MAR-10 02:00') or 
               (dv.registered>'02-NOV-08 02:00' and dv.registered<'08-MAR-09 02:00') then 8 else 7 end) 
                                                    as SLAC,
            (f.treceive-978307200-n.metavalue)/3600 as NASA,
            n.metavalue as runStart
            from verdataset d
            join datasetversion dv on (d.latestversion=dv.datasetversion)
            join verdatasetmetanumber n on (n.datasetversion=dv.datasetversion and n.metaname='nMetStop')
            join verdatasetlocation l on (dv.masterlocation= l.datasetlocation)
            join isoc_flight.fcopy_incoming f on (
            f.downlink_id=(
            select max (downlink_id)
            from isoc_flight.glastops_downlink_acqsummary a
            where a.startedat= l.runmin and a.scid = 77
            )
            )
            where datasetgroup=39684247 and n.metaValue>239907864.08432
            <c:if test="${startTime>0}">
                <jsp:useBean id="startTimeBean" class="java.util.Date" />
                <jsp:setProperty name="startTimeBean" property="time" value="${startTime}" />
                and dv.registered>?
                <sql:dateParam value="${startTimeBean}"/>
            </c:if>
            <c:if test="${endTime>0}">
                <jsp:useBean id="endTimeBean" class="java.util.Date" />
                <jsp:setProperty name="endTimeBean" property="time" value="${endTime}" />
                and dv.registered<?
                <sql:dateParam value="${endTimeBean}"/>
            </c:if>
        </sql:query>
        ${aida:clearPlotRegistry(pageContext.session)}
        <aida:plotter height="400" width="1000" nx="2">
            <aida:tuple var="tuple" query="${data}"/>
            <aida:tupleProjection var="lslac" tuple="${tuple}" xprojection="log10(SLAC)" xbins="96" xmin="-2" xmax="3" name="SLAC"/>
            <aida:tupleProjection var="lnasa" tuple="${tuple}" xprojection="log10(NASA)" xbins="96" xmin="-2" xmax="3" name="NASA"/>
            <aida:tupleProjection var="ltotal" tuple="${tuple}" xprojection="log10(SLAC+NASA)" xbins="96" xmin="-2" xmax="3" name="Total"/>
            <aida:tupleProjection var="slac" tuple="${tuple}" xprojection="SLAC" xbins="96" xmin="0" xmax="48" name="SLAC"/>
            <aida:tupleProjection var="nasa" tuple="${tuple}" xprojection="NASA" xbins="96" xmin="0" xmax="48" name="NASA"/>
            <aida:tupleProjection var="total" tuple="${tuple}" xprojection="SLAC+NASA" xbins="96" xmin="0" xmax="48" name="Total"/>

            <aida:region title= "Data processing elapsed time per run" >
                <aida:style>
                    <aida:style type="data">
                        <aida:style type="errorBar">
                            <aida:attribute name="isVisible" value="false"/>
                        </aida:style>
                    </aida:style>
                    <aida:style type="xAxis">
                        <aida:attribute name="label" value="Hours"/>
                    </aida:style>
                </aida:style>
                <aida:plot var="${slac}">
                    <aida:style>
                        <aida:style type="fill">
                            <aida:attribute name="color" value="red"/>
                            <aida:attribute name="opacity" value="0.5"/>
                        </aida:style>
                    </aida:style>
                </aida:plot>
                <aida:plot var="${nasa}">
                    <aida:style>
                        <aida:style type="fill">
                            <aida:attribute name="color" value="blue"/>
                            <aida:attribute name="opacity" value="0.5"/>
                        </aida:style>
                    </aida:style>
                </aida:plot>
                <aida:plot var="${total}">
                    <aida:style>
                        <aida:style type="fill">
                            <aida:attribute name="color" value="green"/>
                            <aida:attribute name="opacity" value="0.5"/>
                        </aida:style>
                    </aida:style>
                </aida:plot>
            </aida:region>
            <aida:region title= "Data processing elapsed time per run" >
                <aida:style>
                    <aida:style type="data">
                        <aida:style type="errorBar">
                            <aida:attribute name="isVisible" value="false"/>
                        </aida:style>
                    </aida:style>
                    <aida:style type="xAxis">
                        <aida:attribute name="label" value="log10(Hours)"/>
                    </aida:style>
                </aida:style>
                <aida:plot var="${lslac}">
                    <aida:style>
                        <aida:style type="fill">
                            <aida:attribute name="color" value="red"/>
                            <aida:attribute name="opacity" value="0.5"/>
                        </aida:style>
                    </aida:style>
                </aida:plot>
                <aida:plot var="${lnasa}">
                    <aida:style>
                        <aida:style type="fill">
                            <aida:attribute name="color" value="blue"/>
                            <aida:attribute name="opacity" value="0.5"/>
                        </aida:style>
                    </aida:style>
                </aida:plot>
                <aida:plot var="${ltotal}">
                    <aida:style>
                        <aida:style type="fill">
                            <aida:attribute name="color" value="green"/>
                            <aida:attribute name="opacity" value="0.5"/>
                        </aida:style>
                    </aida:style>
                </aida:plot>
            </aida:region>
        </aida:plotter>
        <%-- make an average delay per day plot --%>
        <%
        IAnalysisFactory af = IAnalysisFactory.create();
        ITree tree = af.createTreeFactory().create();
        IHistogramFactory hf = af.createHistogramFactory(tree);
        ICloud2D cSLAC = hf.createCloud2D("SLAC");
        ICloud2D cNASA = hf.createCloud2D("NASA");
        ICloud2D cTotal = hf.createCloud2D("Total");
        ITuple tuple = (ITuple) pageContext.getAttribute("tuple");
        tuple.start();
        ITupleColumn.D runStart = (ITupleColumn.D) tuple.column("RUNSTART");
        ITupleColumn.D SLAC = (ITupleColumn.D) tuple.column("SLAC");
        ITupleColumn.D NASA = (ITupleColumn.D) tuple.column("NASA");
        while (tuple.next()) {
            cSLAC.fill(runStart.value(),Math.log10(SLAC.value()));
            cNASA.fill(runStart.value(),Math.log10(NASA.value()));
            cTotal.fill(runStart.value(),Math.log10(SLAC.value()+NASA.value()));
        }
        pageContext.setAttribute("cSLAC",cSLAC);
        pageContext.setAttribute("cNASA",cNASA);
        pageContext.setAttribute("cTotal",cTotal);
        %>
        <aida:plotter height="400" width="1000">
            <aida:region title= "Data processing elapsed time per run vs MET" >
                <aida:style>
                    <aida:style type="yAxis">
                        <aida:attribute name="label" value="log10(Hours)"/>
                    </aida:style>
                    <aida:style type="xAxis">
                        <aida:attribute name="label" value="MET"/>
                    </aida:style>
                </aida:style>
                <aida:plot var="${cSLAC}">
                    <aida:style>
                        <aida:style type="marker">
                            <aida:attribute name="size" value="2"/>
                            <aida:attribute name="color" value="red"/>
                            <aida:attribute name="shape" value="box"/>
                            <aida:attribute name="opacity" value="0.5"/>
                        </aida:style>
                    </aida:style>
                </aida:plot>
                <aida:plot var="${cNASA}">
                    <aida:style>
                        <aida:style type="marker">
                            <aida:attribute name="size" value="2"/>
                            <aida:attribute name="color" value="blue"/>
                            <aida:attribute name="shape" value="box"/>
                            <aida:attribute name="opacity" value="0.5"/>
                        </aida:style>
                    </aida:style>
                </aida:plot>
                <aida:plot var="${cTotal}">
                    <aida:style>
                        <aida:style type="marker">
                            <aida:attribute name="size" value="2"/>
                            <aida:attribute name="color" value="green"/>
                            <aida:attribute name="shape" value="box"/>
                            <aida:attribute name="opacity" value="0.5"/>
                        </aida:style>
                    </aida:style>
                </aida:plot>
            </aida:region>
        </aida:plotter>

        <h2>Notes</h2>
        <ul>
        <li>NASA = Hours elapsed between end of data taking for run and ALL data for that run arriving at SLAC.
        <li>SLAC = Hours elapsed between ALL data for that run arriving at SLAC and data being registered in data catalog.
        <li>Y axis of scatter plot and X axis of second histogram show log10(hours) so that both body of distribution and tails can be seen.
        <table>
            <tr><th>Log10(Hours)</th><th>Time</th></tr>
            <tr><td>-1</td><td>6 minutes</td></tr>
            <tr><td>-0.5</td><td>20 minutes</td></tr>
            <tr><td>0</td><td>1 hour</td></tr>
            <tr><td>0.5</td><td>3 hours</td></tr>
            <tr><td>1</td><td>10 hours</td></tr>
            <tr><td>1.5</td><td>30 hours</td></tr>
            <tr><td>2</td><td>4 days</td></tr>
            <tr><td>2.5</td><td>13 days</td></tr>
        </table>

    </body>
</html>
