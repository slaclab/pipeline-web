<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>
<%@taglib uri="http://glast-ground.slac.stanford.edu/GlastSQL" prefix="gsql" %>

<html>
   <head>
      <title>Pipeline Message Viewer</title> 
      <script language="JavaScript" src="http://glast-ground.slac.stanford.edu/Commons/scripts/FSdateSelect.jsp"></script>
      <link rel="stylesheet" href="http://glast-ground.slac.stanford.edu/Commons/css/FSdateSelect.css" type="text/css"> 
   </head>
   <body>
      
      <h2>Message Viewer</h2>
      
      <c:set var="logMinDate" value="${param.minDate}" scope="session"/>
      <c:set var="logMaxDate" value="${param.maxDate}" scope="session"/>
      <c:set var="severity" value="${param.severity}" scope="session"/> 
      <c:set var="logTask" value="${task}" scope="session"/>
      <c:set var="logProcess" value="${process}" scope="session"/>
      <c:set var="logProcessInstance" value="${processInstance}" scope="session"/>
      
      <c:if test="${!empty param.clear || empty severity}">
         <% pageContext.setAttribute("now",new java.util.Date()); %> 
         <fmt:formatDate var="today" pattern="MM/dd/yyyy" value="${now}"/>
         <c:set var="logMinDate" value="${today}" scope="session"/>
         <c:set var="logMaxDate" value="" scope="session"/> 
         <c:set var="severity" value="800" scope="session"/> 
         <c:set var="logTask" value="" scope="session"/>
         <c:set var="logProcess" value="" scope="session"/>
         <c:set var="logProcessInstance" value="" scope="session"/>
      </c:if>
      
      <form name="DateForm">
         <table class="filtertable">
            <tr>
               <td colspan="20">
                  Task: <pt:taskChooser name="task" selected="${logTask}" allowNone="true" useKey="true"/>
                  <c:if test="${!empty logTask}">
                     Process: <pt:processChooser name="process" selected="${logProcess}" allowNone="true" task="${logTask}"/> 
                     <c:if test="${!empty logProcess}">
                        Stream <pt:processInstanceChooser name="pi" selected="${logProcessInstance}" allowNone="true" process="${logProcess}"/> 
                     </c:if>
                  </c:if>
                  Severity: <select name="severity">
                     <option value="0">-</option>
                     <option ${severity==1000 ? 'selected' : ''} value="1000">SEVERE</option>
                     <option ${severity==900 ? 'selected' : ''} value="900">WARNING</option>
                     <option ${severity==800 ? 'selected' : ''} value="800">INFO</option>
                     <option ${severity==500 ? 'selected' : ''} value="500">FINE</option>
                     <option ${severity==400 ? 'selected' : ''} value="400">FINER</option>
                     <option ${severity==300 ? 'selected' : ''} value="300">FINEST</option>
                  </select>
               </td>
            </tr>
            <tr>
                  <td>Date Start</td><td><script language="JavaScript">FSfncWriteFieldHTML("DateForm","minDate","${empty logMinDate ? 'None' : logMinDate}",100,"http://glast-ground.slac.stanford.edu/Commons/images/FSdateSelector/","US",false,true)</script></td>
                  <td>End</td><td><script language="JavaScript">FSfncWriteFieldHTML("DateForm","maxDate","${empty logMaxDate ? 'None' : logMaxDate}",100,"http://glast-ground.slac.stanford.edu/Commons/images/FSdateSelector/","US",false,true)</script></td>
                  <td><input type="submit" value="Filter" name="submit">&nbsp;<input type="submit" value="Default" name="clear"></td>
               </td>
            </tr>
         </table>
      </form>
      
      
      <gsql:query var="log" defaultSortColumn="timeentered" pageSize="500">
         select log, log_level, message, timeentered, processInstance, streamIdPath, process, processname, taskPath, taskNamePath, case when exception is null then 0 else 1 end hasException 
         from log l
         left outer join processinstance i using (processinstance)
         left outer join process p using (process)
         left outer join streampath s using (stream)
         left outer join taskpath t using (task)
         where log_level > 0 
         <c:if test="${!empty severity}"> and log_level>=? 
            <gsql:param value="${severity}"/>
         </c:if>
         <c:if test="${!empty logMinDate && logMinDate!='None'}"> and timeentered>=? 
            <fmt:parseDate value="${logMinDate}" pattern="MM/dd/yyyy" var="minDateUsed"/>
            <gsql:dateParam value="${minDateUsed}" type="date"/> 
         </c:if>
         <c:if test="${!empty logMaxDate && logMaxDate!='None'}"> and timeentered<=?
            <fmt:parseDate value="${logMaxDate}" pattern="MM/dd/yyyy" var="maxDateUsed"/>
            <jsp:setProperty name="maxDateUsed" property="time" value="${maxDateUsed.time+24*60*60*1000}"/>
            <gsql:dateParam value="${maxDateUsed}" type="date"/> 
         </c:if>
         <c:if test="${!empty logTask}">and task=?
            <gsql:param value="${logTask}"/>
         </c:if>
         <c:if test="${!empty logProcess}">and process=?
            <gsql:param value="${logProcess}"/>
         </c:if>
         <c:if test="${!empty logProcessInstance}">and processinstance=?
            <gsql:param value="${logProcessInstance}"/>
         </c:if>
      </gsql:query>
      
      <display:table class="datatable" name="${log}" sort="external" decorator="org.glast.pipeline.web.decorators.LogTableDecorator">
         <display:column property="timeentered" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" title="Time" sortable="true" headerClass="sortable" />
         <display:column property="log_level" decorator="org.glast.pipeline.web.decorators.LogLevelColumnDecorator" title="Level" sortable="true" headerClass="sortable" />
         <display:column property="taskLinkPath" title="Task" />
         <display:column property="processname" title="Process" sortable="true" headerClass="sortable" href="process.jsp" paramId="process" paramProperty="process"/>
         <display:column property="streamIdPath" title="Stream" href="pi.jsp" paramId="pi" paramProperty="processinstance" />
         <display:column property="message" title="Message" class="leftAligned" />
         <display:column property="exception" title="Detail" class="leftAligned" />
      </display:table>
   </body>
</html>
