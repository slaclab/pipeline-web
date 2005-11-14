<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib prefix="aida" uri="http://aida.freehep.org/jsp20" %>

<html>
    <head>
        <title>Pipeline status</title>
        <script language="JavaScript" src="scripts/FSdateSelect-UTF8.js"></script>
        <link rel="stylesheet" href="css/screen.css" type="text/css" media="screen, print" />
        <link rel="stylesheet" href="css/FSdateSelect.css" type="text/css">        
    </head>

    <body>
        <c:import url="header.jsp"/>
        <sql:query var="name">
            select TASKNAME from TASK where TASK_PK=?
            <sql:param value="${param.task}"/>           
        </sql:query>
        <c:set var="taskName" value="${name.rowsByIndex[0][0]}"/>
        
        <div id="breadCrumb"> 
            <a href="index.jsp">status</a> /
            <a href="task.jsp?task=${param.task}">${taskName}</a> /
        </div> 
     
        <sql:query var="data">
            select (STARTED-SUBMITTED)*24*60 "WaitTime", (ENDED-STARTED)*24*60*60 "WallClock", MEMORYBYTES/1000 "Bytes", CPUSECONDS/1000 "Cpu",CPUSECONDS/(ENDED-STARTED)/24/60/60/1000 "Ratio"  
            from TPINSTANCE i, PROCESSINGSTATUS s where TASKPROCESS_FK=? and PROCESSINGSTATUSNAME='END_SUCCESS'
            and i.PROCESSINGSTATUS_FK=s.PROCESSINGSTATUS_PK  
            <sql:param value="${param.process}"/>
        </sql:query>  
        <aida:tuple var="tuple" query="${data}" />        
        <aida:tupleProjection var="cpuPlot" tuple="${tuple}" xprojection="Cpu"/>
        <aida:tupleProjection var="memoryPlot" tuple="${tuple}" xprojection="Bytes"/>
        <aida:tupleProjection var="waitPlot" tuple="${tuple}" xprojection="WaitTime"/>
        <aida:tupleProjection var="wallPlot" tuple="${tuple}" xprojection="WallClock"/>
        <aida:tupleProjection var="ratioPlot" tuple="${tuple}" xprojection="Ratio"/>
        <aida:plotter nx="2" ny="3" height="700">
            <aida:region title="CPU Used (secs)">
                <aida:style>
                    <aida:attribute name="statisticsBoxFontSize" value="8"/>
                </aida:style>
                <aida:plot var="${cpuPlot}" >
                    <aida:style>
                        <aida:attribute name="showErrorBars" value="false"/>   
                    </aida:style>                      
                </aida:plot>
            </aida:region>
            <aida:region title="Memory Used (MB)">
                <aida:style>
                    <aida:attribute name="statisticsBoxFontSize" value="8"/>
                </aida:style>
                <aida:plot var="${memoryPlot}">
                    <aida:style>
                        <aida:attribute name="showErrorBars" value="false"/>   
                    </aida:style>                      
                </aida:plot>
            </aida:region>
            <aida:region title="Wall Clock time (secs)">
                <aida:style>
                    <aida:attribute name="statisticsBoxFontSize" value="8"/>
                </aida:style>
                <aida:plot var="${wallPlot}">
                    <aida:style>
                        <aida:attribute name="showErrorBars" value="false"/>   
                    </aida:style>                      
                </aida:plot>
            </aida:region>
            <aida:region title="Pending time (mins)">
                <aida:style>
                    <aida:attribute name="statisticsBoxFontSize" value="8"/>
                </aida:style>
                <aida:plot var="${waitPlot}">
                    <aida:style>
                        <aida:attribute name="showErrorBars" value="false"/>   
                    </aida:style>                      
                </aida:plot>
            </aida:region>
            <aida:region title="CPU/Wall Clock">
                <aida:style>
                    <aida:attribute name="statisticsBoxFontSize" value="8"/>
                </aida:style>
                <aida:plot var="${ratioPlot}" >
                    <aida:style>
                        <aida:attribute name="showErrorBars" value="false"/>   
                    </aida:style>                      
                </aida:plot>
            </aida:region>
        </aida:plotter>
    </body>
</html>
