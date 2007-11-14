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
       
        <sql:query var="datacheck">
            select createdate,startdate,enddate
            from stream where task=? and streamstatus='SUCCESS' and isLatest=1
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
                
                <sql:query var="processes">
                    select p.PROCESS,p.PROCESSNAME,p.PROCESSTYPE from PROCESS p   
                    where p.TASK=?
                    order by p.process    
                    <sql:param value="${task}"/>
                </sql:query> 		
                
                
                <c:forEach var="row" items="${processes.rows}">
                    <tab:tab name="${row.PROCESSNAME}" href="P2stats.jsp" value="${row.PROCESS}">
                        
                        <sql:query var="data">
                            select enddate,startdate,submitdate,cpusecondsused,
                            regexp_substr(lower(executionhost), '^[a-z]+')  node
                            from processinstance PI
                            where PI.process = ?
                            and PI.processingstatus = 'SUCCESS'
                            <sql:param value="${row.PROCESS}"/>
                        </sql:query> 
                        
                        <aida:tuple var="tuple" query="${data}" />    
                        <aida:tupleProjection var="wallPlot" tuple="${tuple}" xprojection="(ENDDATE-STARTDATE)/60"/>
                        <c:if test="${row.processtype !='SCRIPT'}"> 

                            <aida:tupleProjection var="waitPlot" tuple="${tuple}" xprojection="(STARTDATE-SUBMITDATE)/60"/>
                            <aida:tupleProjection var="cpuSeconds" tuple="${tuple}" xprojection="CPUSECONDSUSED/60"/>   
                            <aida:tupleProjection var="wallCpu" tuple="${tuple}" xprojection="CPUSECONDSUSED/(ENDDATE-STARTDATE)"/>               
                        </c:if>
                        
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
                                    <aida:plot var="${waitPlot}"/>    			             
                                </aida:region>
                                <aida:region title="CPU time (mins)">
                                    <aida:plot var="${cpuSeconds}"/>    			             
                                </aida:region>
                                <aida:region title="CPU time/Wall Clock">
                                    <aida:plot var="${wallCpu}"/>    			             
                                </aida:region>
                            </c:if>  
                        </aida:plotter> 
                       
                    </tab:tab>             
                </c:forEach>            
            </tab:tabs>
        </c:if> 
             
          <br> <strong>  PLOTS by BATCH NODES</strong><br>
        <sql:query var="processes">
            select p.PROCESS,p.PROCESSNAME,p.PROCESSTYPE from PROCESS p   
            where p.TASK=?
            order by p.process    
            <sql:param value="${task}"/>
        </sql:query> 		
        
        <c:forEach var="rowA" items="${processes.rows}">             
            <sql:query var="hostnode">           
                select distinct(regexp_substr(lower(PI.executionhost), '^[a-z]+') ) executionhost , P.task
                from processinstance PI  ,process P
                where PI.process = P.process
                and PI.process = ?
                and executionhost is not null
                <sql:param value="${rowA.process}"/>
            </sql:query> 
            
            <c:if test="${fn:length(hostnode.rows) > 0}">
                
                <%
                ArrayList wallPlotList = new ArrayList();
                ArrayList waitPlotList = new ArrayList();
                ArrayList cpuSecondsPlotList = new ArrayList();
                ArrayList wallCpuPlotList = new ArrayList();
                pageContext.setAttribute("wallPlotList",wallPlotList);
                pageContext.setAttribute("waitPlotList",waitPlotList);
                pageContext.setAttribute("cpuSecondsPlotList",cpuSecondsPlotList);
                pageContext.setAttribute("wallCpuPlotList",wallCpuPlotList);
                String[] plotColors = new String[] {"red","blue","green","black","orange","purple","brown","gray","pink"};
                pageContext.setAttribute("plotColors",plotColors);
                pageContext.setAttribute("numberPlotColors",plotColors.length);
                %>
                
                
                <c:forEach var="rowB" items="${hostnode.rows}">
                 <%-- <strong> Node:    ${rowB.executionhost}*</strong><br> --%>
                    
                    <sql:query var="data">
                        select enddate,startdate,submitdate,cpusecondsused,
                        regexp_substr(lower(executionhost), '^[a-z]+') executionhost
                        from processinstance PI
                        where PI.process = ?
                        and PI.processingstatus = 'SUCCESS'
                        and executionhost like ?
                        and executionhost is not null
                        <sql:param value="${rowA.PROCESS}"/>
                        <sql:param value="${rowB.executionhost}%"/>
                    </sql:query> 
                    
                    <c:set var="hostName" value="${rowB.executionhost}"/>
                    
                    <aida:tuple var="tuple" query="${data}" />    
                    <aida:tupleProjection  var="wallPlot" tuple="${tuple}" xprojection="(ENDDATE-STARTDATE)/60"/>
                    <%
                    IHistogram1D wallPlotHist = (IHistogram1D)pageContext.getAttribute("wallPlot");
                    wallPlotHist.setTitle((String)pageContext.getAttribute("hostName"));
                    wallPlotList.add(wallPlotHist);                    
                    %>
                    
                    <c:if test="${row.processtype !='SCRIPT'}"> 
                        <aida:tupleProjection var="waitPlot" tuple="${tuple}" xprojection="(STARTDATE-SUBMITDATE)/60"/>
                        <aida:tupleProjection var="cpuSeconds" tuple="${tuple}" xprojection="CPUSECONDSUSED/60"/>   
                        <aida:tupleProjection var="wallCpu" tuple="${tuple}" xprojection="CPUSECONDSUSED/(ENDDATE-STARTDATE)"/>               
                        <%
                        IHistogram1D waitPlotHist = (IHistogram1D)pageContext.getAttribute("waitPlot");
                        waitPlotHist.setTitle((String)pageContext.getAttribute("hostName"));
                        waitPlotList.add(waitPlotHist);
                        IHistogram1D cpuSecondsPlotHist = (IHistogram1D)pageContext.getAttribute("cpuSeconds");
                        cpuSecondsPlotHist.setTitle((String)pageContext.getAttribute("hostName"));
                        cpuSecondsPlotList.add(cpuSecondsPlotHist);
                        IHistogram1D wallCpuPlotHist = (IHistogram1D)pageContext.getAttribute("wallCpu");
                        wallCpuPlotHist.setTitle((String)pageContext.getAttribute("hostName"));
                        wallCpuPlotList.add(wallCpuPlotHist);                    
                        %>
                    </c:if>
                    
                </c:forEach>
                
                <c:set var="lineSize" value="2"/>
                
                <aida:plotter nx="2" ny="2" height="600" width="600">
                    <aida:style>
                        <aida:attribute name="statisticsBoxFontSize" value="8"/>
                        <aida:style type="statisticsBox">
                            <aida:attribute name="isVisible" value="false"/>   
                        </aida:style>  
                        <aida:style type="data">
                            <aida:attribute name="showErrorBars" value="false"/>   
                            <aida:style type="fill">
                                <aida:attribute name="isVisible" value="false"/>   
                            </aida:style>  
                        </aida:style>  
                    </aida:style>
                    
                    <aida:region  title="Wall Clock time (mins)">
                        <c:forEach var="rowB" items="${hostnode.rows}" varStatus="status">
                            <aida:plot  var="${wallPlotList[status.index]}"  >
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
                                <aida:plot  var="${waitPlotList[status.index]}">    			             
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
                                <aida:plot  var="${cpuSecondsPlotList[status.index]}">    			             
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
                                <aida:plot  var="${wallCpuPlotList[status.index]}">    			             
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
                <%
                
                wallPlotList.clear();
                waitPlotList.clear();
                cpuSecondsPlotList.clear();
                wallCpuPlotList.clear();
                %>                    
            </c:if>
        </c:forEach>                 
        
        
        
        
    </body>
</html>
