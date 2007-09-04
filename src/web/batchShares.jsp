<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%--
The taglib directive below imports the JSTL library. If you uncomment it,
you must also add the JSTL library to the project. The Add Library... action
on Libraries node in Projects view can be used to add the JSTL 1.1 library.
--%>
<%-- tag libraries --%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="utils" uri="http://glast-ground.slac.stanford.edu/utils" %>
<%@ taglib prefix="aida" uri="http://aida.freehep.org/jsp20" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link href="http://glast-ground.slac.stanford.edu/Commons/css/glastCommons.jsp" rel="stylesheet" type="text/css">
        <title>Batch Fair Shares Page</title>    
    </head>
    
    <body>
        
        <h1>Batch Fair Shares Page</h1>
        
        <%-- didIMaketheQuery
- make query and get all groups
- loop over the result set and build a list of all the available groups
        --%>
        
        <c:if test="${empty loadValuesFromDB}">
            <%
            System.getProperties().setProperty("jas.plot.vertical.labels","true");            
            %>
            <sql:query var="resultgrp" dataSource="jdbc/glastgenDev" scope="session">
                select group_name from bqueue_groups order by group_name
            </sql:query> 
            <%-- there is only 1 fair share and does not depend on the queue
            <sql:query var="resultque" dataSource="jdbc/glastgenDev" scope="session">
                select queue_name from bqueue_queues where queue_name = 'short' order by queue_name
            </sql:query> 
            --%>
            <c:set var="loadValuesFromDB" value="false" scope="session"/> 
            <c:set var="selectedGroup" value="glastgrp" scope="session" />
            <%-- <c:set var="selectedQueue" value="${resultque.rows[0].queue_name}" scope="session" /> --%>
            <c:set var="selectedData" value="cpu_time" scope="session" />
            <c:set var="availableData" value="${fn:split('cpu_time,priority,reserved,shares,started,wall_clock',',')}" scope="session"/>
            <c:set var="availableColors" value="${fn:split('blue,red,orange,black,green,brown,yellow,pink',',')}" scope="session"/>
        </c:if>   
        
        <%--
        Each time the user submits the form we save what they selected. Use the variable
        selectedGroup and selectedQueue to update the list that the browser will show to the enduser.
        --%>
        
        <c:if test="${ ! empty paramValues.listofgroups }">
            <c:set var="selectedGroup" value="" scope="session" />
            <c:forEach items="${paramValues.listofgroups}" var="currentvals">
                <c:if test="${selectedGroup != ''}">
                    <c:set var="selectedGroup" value="${selectedGroup}," scope="session" />  
                </c:if>
                <c:set var="selectedGroup" value="${selectedGroup}${currentvals}" scope="session" />  
            </c:forEach>
        </c:if>
        
        <%-- fair shares is not queue dependent. SCCS has only one lot defined for fair shares and it crosses all queues 
        <c:if test="${ ! empty param.listofqueues}" >
            <c:set var="selectedQueue" value="${param.listofqueues}" scope="session" />   
        </c:if>
        --%>
        <c:if test="${ ! empty paramValues.listofdata}" >
            <c:set var="selectedData" value="" scope="session" />   
            
            <c:forEach items="${paramValues.listofdata}" var="currentdata">
                <c:if test="${selectedData != ''}">
                    <c:set var="selectedData" value="${selectedData}," scope="session" />  
                </c:if>
                <c:set var="selectedData" value="${selectedData}${currentdata}" scope="session" />                    
            </c:forEach> 
        </c:if> 
        
        <c:set var="fairShareBeginTime" value="${ empty param.fairShareBeginTime ? fairShareBeginTime : param.fairShareBeginTime}" scope="session"/>
        <c:set var="fairShareEndTime" value="${ empty param.fairShareEndTime ? fairShareEndTime : param.fairShareEndTime}" scope="session"/>
        
        <form id="batShares" name="batShares"  action="batchShares.jsp">
            <table class="filtertable">
                <tr><td>
                        <table>
                            <tr>
                                <th>Begin Time</th>
                                <td> 
                                    <utils:dateTimePicker value="${empty fairShareBeginTime ? utils:now('PST')-140*24*60*60*1000 : fairShareBeginTime}" size="18" name="fairShareBeginTime" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/>
                                </td>
                                <th>End Time</th>
                                <td> 
                                    <utils:dateTimePicker value="${empty fairShareEndTime ? utils:now('PST') : fairShareEndTime}" size="18" name="fairShareEndTime" format="%d/%b/%Y %H:%M:%S" showtime="true" timezone="PST"/> 
                                </td>
                            </tr>
                            <p></p>
                            <tr><th>Groups</th><td>
                                    <select name="listofgroups" multiple=1 size="4">
                                        <c:forEach items="${resultgrp.rows}" var="groupname">
                                            <option <c:if test="${fn:contains(selectedGroup,groupname.group_name)}">selected</c:if>>${groupname.group_name}</option>
                                        </c:forEach>
                                    </select>  
                                </td>
                                <th>Data</th><td>
                                    <select name="listofdata" multiple=1 size="4">
                                        <c:forEach var="data" items="${availableData}" >
                                            <option <c:if test="${fn:contains(selectedData,data)}">selected</c:if>>${data}</option>
                                        </c:forEach>
                                    </select>     
                            </td></tr>
                        </table>
                </td></tr>
                <%-- <tr><td>
                       <table>
                            <tr><th>Groups</th><th>Data</th></tr>
                            
                            <tr><td>
                                    <select name="listofgroups" multiple=1 size="4">
                                        <c:forEach items="${resultgrp.rows}" var="groupname">
                                            <option <c:if test="${fn:contains(selectedGroup,groupname.group_name)}">selected</c:if>>${groupname.group_name}</option>
                                        </c:forEach>
                                    </select>  
                                </td>
                              <!--  
                                <td>
                                    <select name="listofqueues" size="4">
                                        <c:forEach items="${resultque.rows}" var="queue">
                                            <option <c:if test="${selectedQueue == queue.queue_name}">selected</c:if>>${queue.queue_name}</option>
                                        </c:forEach>
                                    </select>   
                                </td>
                                -->
                               
                                <td>
                                    <select name="listofdata" multiple=1 size="4">
                                        <c:forEach var="data" items="${availableData}" >
                                            <option <c:if test="${fn:contains(selectedData,data)}">selected</c:if>>${data}</option>
                                        </c:forEach>
                                    </select>   
                                </td> 
                            </tr>
                            <tr><td colspan="2">&nbsp;</td></tr>
                            <tr><td><input type="submit" name="Submit" value="Submit" /></td>
                            <td></td></tr>
                        </table>
                      
                </td></tr>
                --%>
                <tr><td><input type="submit" name="Submit" value="Submit" /></td></tr>
            </table> 
            
        </form>
        
        
        <jsp:useBean id="startTime" class="java.util.Date" /> 
        <jsp:setProperty name="startTime" property="time" value="${fairShareBeginTime}" /> 	  
        <jsp:useBean id="stopTime" class="java.util.Date" /> 
        <jsp:setProperty name="stopTime" property="time" value="${fairShareEndTime}" /> 	  
        
        
        <c:forEach items="${paramValues.listofdata}" var="data">
            
            <aida:plotter height="400"> 
                <aida:region title="${data}" >
                    <aida:style>
                        <aida:style type="statisticsBox">
                            <aida:attribute name="isVisible" value="false"/>
                        </aida:style>
                        <aida:style type="xAxis">
                            <aida:attribute name="label" value="Time"/>
                            <aida:attribute name="type" value="date"/>
                        </aida:style>
                        <aida:style type="yAxis">
                            <aida:attribute name="label" value="${data}"/>
                        </aida:style>
                        <aida:style type="data">
                            <aida:style type="outline">
                                <aida:attribute name="isVisible" value="false"/>
                            </aida:style>
                        </aida:style>
                    </aida:style>   
                    
                    <c:forEach items="${paramValues.listofgroups}" var="group" varStatus="status" >
                        
                        
                        <sql:query var="batchDBInfo" dataSource="jdbc/glastgenDev" scope="session">
                            select ${data}, snapshot_date from bqueue_groups bg, bqueue_data bd
                            where bg.group_name = bd.group_name and bd.group_name = ? and
                            bd.snapshot_date >= ? and bd.snapshot_date <= ?                       
                            <sql:param value="${group}" />
                            <sql:dateParam value="${startTime}"/>
                            <sql:dateParam value="${stopTime}"/>
                        </sql:query>
                        
                        
                        <aida:tuple var="tuple" query="${batchDBInfo}"/>        
                        <aida:datapointset var="plot" tuple="${tuple}" yaxisColumn="${fn:toUpperCase(data)}" xaxisColumn="SNAPSHOT_DATE" title="${group}"/>   
                        
                        <aida:plot var="${plot}">
                            <aida:style>        
                                <aida:style type="marker">
                                    <aida:attribute name="color" value="${availableColors[status.index]}"/>
                                    <aida:attribute name="shape" value="dot"/>
                                </aida:style>
                            </aida:style>
                        </aida:plot>
                        
                        
                    </c:forEach>
                </aida:region>
            </aida:plotter>
            
        </c:forEach>
        
        <%--
        
        <c:set var="rowsReturned" value="${batchDBInfo.rowCount}"/>
        Number of selected rows: ${rowsReturned}<br>
        
        <table>
            <tr>
                <c:forEach items="${batchDBInfo.columnNames}" var="colName">
                    <th>-${fn:escapeXml(colName)}</th>
                </c:forEach> 
            </tr>
            <c:forEach items="${batchDBInfo.rowsByIndex}" var="row">  
                <tr>
                    <td>${row[0]} ${fn:length(row)} ${batchDBInfo.rows}</td>
                </tr>
            </c:forEach>
            
        </table>
        --%>
        
        <%--
        <c:out value="${param.listofqueues}"/><br>
        
        <c:forEach items="${paramValues.listofdata}" var="currentvals2">
            <c:out value="${currentvals2}" /><br>
        </c:forEach>
        --%>
        
        <%--
        <utils:dateTimePicker value="${utils:toTime("${param.beginTime}")}" name="convertedBegin" timezone="PST"/>
        <utils:dateTimePicker value="${utils:toTime("${param.endTime}")}"  name="convertedEnd" timezone="PST"/>
       
       
        <c:out value="${param.beginTime}"/><br>
        <c:out value="${param.endTime}"/><br>
       --%>  
        
        <%--
- decide what the default value is (either glast, or all of the groups or whatherver) -> selectedGroups
- loop over the result set and build the form


<option  <:if test="if selected loopvariable">selected</c:if>  >loopvariable</option>
--%>
        
        <%--
Something here ${paramValues['listofgroups']}<br>
<c:forEach items="${paramValues['listofgroups']}" var="group">
    Group: <b>${group}</b>
</c:forEach>
--%>
        
        <%--
        <c:choose>
            <c:when test="${!empty param.Submit}"> 
                Group: "${param.listofgroups}"
            </c:when>
            
            <c:when test="${!empty param.clear}">
            </c:when>
        </c:choose>
        --%>        
    </body>
</html>
