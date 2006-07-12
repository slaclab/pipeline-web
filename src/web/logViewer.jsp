<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>

<html>
   <head>
      <title>Pipeline Log viewer</title> 
      <script language="JavaScript" src="http://glast-ground.slac.stanford.edu/Commons/scripts/FSdateSelect.jsp"></script>
      <link rel="stylesheet" href="http://glast-ground.slac.stanford.edu/Commons/css/FSdateSelect.css" type="text/css"> 
   </head>
   <body>

      <h2>Log Viewer</h2>

      <c:choose>
         <c:when test="${!empty param.clear}">
            <c:set var="logMinDate" value="" scope="session"/>
            <c:set var="logMaxDate" value="" scope="session"/> 
         </c:when>
         <c:when test="${!empty param.submit}">
            <c:set var="logMinDate" value="${param.minDate}" scope="session"/>
            <c:set var="logMaxDate" value="${param.maxDate}" scope="session"/>
         </c:when>
      </c:choose>
      
      <form name="DateForm">
         <table class="filterTable">
            <tr>
              <td>Task:</td><td><pt:taskChooser name="logTask" selected="${param.logTask}" allowNone="true" useKey="true"/> </td>
            </tr>
            <tr>
               <th>Date</th>
               <td>Start</td>
               <td>
                  <script language="JavaScript">FSfncWriteFieldHTML("DateForm","minDate","${empty logMinDate ? 'None' : logMinDate}",100,"http://glast-ground.slac.stanford.edu/Commons/images/FSdateSelector/","US",false,true)</script>
               </td>
               <td>End</td>
               <td>
                  <script language="JavaScript">FSfncWriteFieldHTML("DateForm","maxDate","${empty logMaxDate ? 'None' : logMaxDate}",100,"http://glast-ground.slac.stanford.edu/Commons/images/FSdateSelector/","US",false,true)</script>
               </td>
               <td><input type="submit" value="Filter" name="submit">&nbsp;<input type="submit" value="Default" name="clear"></td>
            </tr>
         </table>
      </form>
        
        
      <sql:query var="log">
         select log, log_level, message, timeentered, streamid, processname, taskname, case when exception is null then 0 else 1 end hasException 
         from log l
         left outer join processinstance i on l.processinstance = i.processinstance
         left outer join process p using (process)
         left outer join stream s  using (stream)
         left outer join task t on t.task=p.task
         where log_level > 0 
         <c:if test="${!empty minDate && minDate!='None'}"> and timeentered>=? </c:if>
         <c:if test="${!empty maxDate && maxDate!='None'}"> and timeentered<=? </c:if>
         <c:if test="${!empty minDate && minDate!='None'}"> 
            <fmt:parseDate value="${logMinDate}" pattern="MM/dd/yyyy" var="minDateUsed"/>
            <sql:dateParam value="${minDateUsed}" type="date"/> 
         </c:if>
         <c:if test="${!empty logMaxDate && logMaxDate!='None'}"> 
            <fmt:parseDate value="${logMaxDate}" pattern="MM/dd/yyyy" var="maxDateUsed"/>
            <% java.util.Date d = (java.util.Date) pageContext.getAttribute("maxDateUsed"); 
               d.setTime(d.getTime()+24*60*60*1000);
            %>
            <sql:dateParam value="${maxDateUsed}" type="date"/> 
         </c:if>
      </sql:query>
        
      <display:table class="dataTable" name="${log.rows}" defaultsort="1" defaultorder="descending" decorator="org.glast.pipeline.web.decorators.LogTableDecorator">
         <display:column property="timeentered" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" comparator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" title="Time" sortable="true" headerClass="sortable" />
         <display:column property="log_level" decorator="org.glast.pipeline.web.decorators.LogLevelColumnDecorator" title="Level" sortable="true" headerClass="sortable" />
         <display:column property="taskname" title="Task" sortable="true" headerClass="sortable" />
         <display:column property="processname" title="Process" sortable="true" headerClass="sortable"/>
         <display:column property="streamid" title="Stream" sortable="true" headerClass="sortable" />
         <display:column property="message" title="Message" class="leftAligned" />
         <display:column property="exception" title="Detail" class="leftAligned" />
      </display:table>
   </body>
</html>
