<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib prefix="srs_utils" uri="http://srs.slac.stanford.edu/utils" %>
<%@taglib prefix="login" uri="http://srs.slac.stanford.edu/login" %>

<table width="100%">
    <tr>
        <td colspan="2">
            <srs_utils:menuBar />
        </td>
    </tr>
    <tr>
        <td valign="top" rowspan="2">
            <a href="index.jsp">
                <srs_utils:logo title="Pipeline-II"/>
            </a>
        </td>
        <td align="right" valign="top">
            <a href="releasenotes.jsp">Version ${initParam.version}</a>
            |
            Jira <a href="http://jira.slac.stanford.edu/browse/PFE">(Front-End)</a> <a href="http://jira.slac.stanford.edu/browse/PII">(Server)</a>
            |
            <a href="http://confluence.slac.stanford.edu/display/ds/Pipeline+II+User%27s+Guide">Help</a>
        </td>
    </tr>
    <tr>
        <td align="right" valign="bottom">
            <table>
                <tr>
                    <td align="right">
                        <jsp:useBean id="now" class="java.util.Date" />
                        Page updated: <fmt:formatDate value="${now}" pattern="MM/dd/yyyy HH:mm:ss"/> <c:if test="${empty skipRefresh || ! skipRefresh}"><srs_utils:refresh /></c:if>
                    </td>
                </tr>
                <tr>
                    <td align="right">
                        <login:login useQueryString="true"/> Mode: [ <srs_utils:modeChooser mode="dataSourceMode" href="index.jsp"/> ]  <c:if test="${ ! empty userName }"><srs_utils:conditonalLink url="myPreferences.jsp" name="Preferences" /></c:if>
                    </td>
                </tr>
                <tr>
                    <td align="right">
                        <srs_utils:conditonalLink url="index.jsp" name="Task List" iswelcome="true"/>&nbsp;.
                        <srs_utils:conditonalLink url="logViewer.jsp" name="Message Viewer" />&nbsp;.
                        <srs_utils:conditonalLink url="JobProcessingStats.jsp" name="Usage Plots" />&nbsp;.
                        <srs_utils:conditonalLink url="http://srs.slac.stanford.edu/BatchAllocations/batchShares.jsp" name="Fair Share Plots" />&nbsp;.
                        <srs_utils:conditonalLink url="admin.jsp" name="Admin" />&nbsp;.
                        <srs_utils:conditonalLink url="admin_jmx.jsp" name="JMX" />
                    </td>
                </tr>
            </table>
        </td>  
    </tr>
</table>
<c:if test="${!empty param.processingMessage}"> 
    <strong><p align="center"> ${param.processingMessage}</p> </strong>
</c:if>
<c:if test="${!empty task}">
    <div class="breadCrumb">
        <a href="index.jsp">summary</a>
        / ${pl:linkToTasks(taskNamePath,taskPath," / ","task.jsp?task=")}
        <c:if test="${!empty processName}">/ <a href="process.jsp?process=${process}">${processName}</a> </c:if>
    </div>
</c:if>


