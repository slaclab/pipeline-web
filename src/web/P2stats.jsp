<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="aida" uri="http://aida.freehep.org/jsp20" %>
<%@taglib prefix="tab" uri="http://java.freehep.org/tabs-taglib" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="aida" uri="http://aida.freehep.org/jsp20" %>
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
        <c:set var="lineSize" value="2"/>
        <sql:query var="datacheck">
            select createdate,startdate,enddate
            from stream where task=? and streamstatus='SUCCESS' and isLatest=1
            <sql:param value="${task}"/>
        </sql:query>
        
        <sql:query var="processes">
            select p.PROCESS,p.PROCESSNAME,p.PROCESSTYPE from PROCESS p   
            where p.TASK=?
            order by p.process    
            <sql:param value="${task}"/>
        </sql:query> 		
        
        <c:if test="${empty param.process || param.process > 0}">
            <c:set var="queryInStr" value="("/>
            <c:set var="rowALength" value="${fn:length(processes.rows)}"/>
            <c:forEach var="rowA" items="${processes.rows}" varStatus="status">
                <c:if test="${rowA.processtype == 'BATCH'}">
                    <c:set var="queryInStr" value="${queryInStr}?"/>
                    <c:if test="${status.count != rowALength}">
                        <c:set var="queryInStr" value="${queryInStr},"/>
                    </c:if>                    
                </c:if>
            </c:forEach>  
            <c:set var="queryInStr" value="${queryInStr})"/>
            
            <c:set var="allNodesQuery" >
                select enddate,startdate,submitdate,cpusecondsused,
                regexp_substr(lower(executionhost), '^[a-z]+') executionhost,PI.process as process
                from processinstance PI
                where PI.process in ${queryInStr}
                and PI.processingstatus = 'SUCCESS'
                and executionhost is not null
            </c:set>
            
            <sql:query var="allNodesData">
                ${allNodesQuery}
                <c:forEach var="rowA" items="${processes.rows}" varStatus="status">
                    <c:if test="${rowA.processtype == 'BATCH'}">
                        <sql:param value="${rowA.PROCESS}"/>
                    </c:if>
                </c:forEach>  
            </sql:query> 
            
         <!--   The number of data points is : ${fn:length(data.rows)}<br> -->
            
        </c:if>
        
        <c:if test="${fn:length(datacheck.rows) <= 0}">       
            <br>    <strong> There are no successful processes to plot for this task </strong><br>
        </c:if>      
        <c:if test="${fn:length(datacheck.rows) > 0}"> 
            <tab:tabs name="ProcessTabs" param="process">                
                <tab:tab name="Summary" href="P2statsTest1.jsp?task=${task}" value="0">                    
                    <sql:query var="data">
                        select createdate,startdate,enddate
                        from stream where task=? and streamstatus='SUCCESS' and isLatest=1
                        <sql:param value="${task}"/>
                    </sql:query>                                         
                    <aida:tuple var="tuple" query="${data}" />    
                    <aida:tupleProjection var="elapsed" tuple="${tuple}" xprojection="(ENDDATE-STARTDATE)/60"/>
                    <aida:tupleProjection var="wait" tuple="${tuple}" xprojection="(STARTDATE-CREATEDATE)/60"/>
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
                    </aida:plotter> 
                    
                </tab:tab>
                
                
                <c:forEach var="row" items="${processes.rows}">
                    <tab:tab name="${row.PROCESSNAME}" href="P2statsTest1.jsp" value="${row.PROCESS}">
                        
                        <sql:query var="data">
                            select enddate,startdate,submitdate,cpusecondsused,
                            regexp_substr(lower(executionhost), '^[a-z]+')  node
                            from processinstance PI
                            where PI.process = ?
                            and PI.processingstatus = 'SUCCESS'
                            <sql:param value="${row.PROCESS}"/>
                        </sql:query> 
                        
                        <aida:tuple var="tuple" query="${data}" />    
                        <aida:tupleProjection var="wallPlot" tuple="${tuple}" xprojection="(ENDDATE-STARTDATE)/60" />
                        
                        <aida:plotter nx="2" ny="2" height="600" width="600">
                            <aida:style>
                                <aida:attribute name="statisticsBoxFontSize" value="8"/>
                                <aida:style type="data">
                                    <aida:attribute name="showErrorBars" value="false"/>   
                                </aida:style>  
                            </aida:style>
                            <aida:region title="Wall Clock time (mins)">
                                <aida:plot var="${wallPlot}"/>                     
                            </aida:region>
                            <c:if test="${row.processtype !='SCRIPT'}"> 
                                <aida:region title="Pending time (mins)">
                                    <aida:tupleProjection var="waitPlot" tuple="${tuple}" xprojection="(STARTDATE-SUBMITDATE)/60"/>
                                    <aida:plot var="${waitPlot}"/>    			             
                                </aida:region>
                                <aida:region title="CPU time (mins)">
                                    <aida:tupleProjection var="cpuSeconds" tuple="${tuple}" xprojection="CPUSECONDSUSED/60"/>   
                                    <aida:plot var="${cpuSeconds}"/>    			             
                                </aida:region>
                                <aida:region title="CPU time/Wall Clock">
                                    <aida:tupleProjection var="wallCpu" tuple="${tuple}" xprojection="CPUSECONDSUSED/(ENDDATE-STARTDATE)"/>               
                                    <aida:plot var="${wallCpu}"/>    			             
                                </aida:region>
                            </c:if>  
                        </aida:plotter> 
                        
                        
                        <c:if test="${row.processtype !='SCRIPT'}"> 
                            
                            <sql:query var="hostnode">           
                                select distinct(regexp_substr(lower(PI.executionhost), '^[a-z]+') ) executionhost , P.task
                                from processinstance PI  ,process P
                                where PI.process = P.process
                                and PI.process = ?
                                and executionhost is not null
                                <sql:param value="${row.process}"/>
                            </sql:query> 
                            
                            
                            <c:if test="${fn:length(hostnode.rows) > 0}">
                                
                                <br> <strong>  PLOTS by BATCH NODES</strong><br>
                                
                                <aida:tuple var="allNodesTuple" query="${allNodesData}" />    
                                
                                <aida:plotter nx="2" ny="2" height="600" width="600">
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
                                    <aida:region title="Wall Clock time (mins)">
                                        <c:forEach var="rowB" items="${hostnode.rows}" varStatus="status">
                                            <aida:tupleProjection  name="${rowB.executionhost}" var="wallPlot" tuple="${allNodesTuple}" xprojection="(ENDDATE-STARTDATE)/60" filter="EXECUTIONHOST == \"${rowB.executionhost}\" && PROCESS == ${row.process}"/>
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
                                    <c:if test="${row.processtype !='SCRIPT'}"> 
                                        <aida:region title="Pending time (mins)">
                                            <c:forEach var="rowB" items="${hostnode.rows}" varStatus="status">
                                                <aida:tupleProjection  name="${rowB.executionhost}" var="waitPlot" tuple="${allNodesTuple}" xprojection="(STARTDATE-SUBMITDATE)/60" filter="EXECUTIONHOST == \"${rowB.executionhost}\" && PROCESS == ${row.process}"/>
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
                                        <aida:region title="CPU time (mins)">
                                            <c:forEach var="rowB" items="${hostnode.rows}" varStatus="status">
                                                <aida:tupleProjection name="${rowB.executionhost}" var="cpuSeconds" tuple="${allNodesTuple}" xprojection="CPUSECONDSUSED/60" filter="EXECUTIONHOST == \"${rowB.executionhost}\" && PROCESS == ${row.process}"/>   
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
                                        <aida:region title="CPU time/Wall Clock">
                                            <c:forEach var="rowB" items="${hostnode.rows}" varStatus="status">
                                                <aida:tupleProjection name="${rowB.executionhost}" var="wallCpu" tuple="${allNodesTuple}" xprojection="CPUSECONDSUSED/(ENDDATE-STARTDATE)" filter="EXECUTIONHOST == \"${rowB.executionhost}\" && PROCESS == ${row.process}"/>               
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
                                </aida:plotter> 
                                
                            </c:if>
                        </c:if>  
                    </tab:tab>             
                </c:forEach>            
            </tab:tabs> 
        </c:if> 
        
    </body>
</html>
