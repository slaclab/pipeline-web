<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/GroupManager" prefix="gm" %>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 

<html>
<head>
   <title>Pipeline status</title>
</head>
<body>

   <c:set var="showLatest" value="${!empty param.showLatestChanged ? !empty param.showLatest : empty showLatest ? true : showLatest}" scope="session"/>

   <sql:query var="rs1">
      select * from stream 
      join streampath using(stream)
      where stream=?
      <sql:param value="${param.stream}"/>
   </sql:query>
   <c:set var="data" value="${rs1.rows[0]}"/>

   <table>        
      <tr><td>StreamId</td><td>${data.streamIdPath}</td></tr>   
      <tr><td>ExecutionNumber</td></td><td>${data.executionNumber}</td></tr>
      <tr><td>Is Latest</td><td>${data.isLatestPath}</td></tr>
      <tr><td>Status</td><td>${data.streamStatus}</td></tr>
      <tr><td>Submited</td><td>${pl:formatTimestamp(data.createDate)}</td></tr>          
      <tr><td>StartDate</td><td>${pl:formatTimestamp(data.startDate)}</td></tr>                   
      <tr><td>EndDate</td><td>${pl:formatTimestamp(data.endDate)}</td></tr>                                                
   </table>

   <h3>Variables</h3>

   <sql:query var="rs">
      select * from streamvar
      where stream=?
      <sql:param value="${param.stream}"/>
   </sql:query>      

   <display:table class="datatable" name="${rs.rows}" defaultsort="1" defaultorder="ascending">
      <display:column property="varname" title="Name" sortable="true" headerClass="sortable" />
      <display:column property="vartype" title="Type" sortable="true" headerClass="sortable"/>
      <display:column property="value" title="Value" sortable="true" headerClass="sortable"/>
   </display:table>   

   <h3>Stream Processes</h3>
   <pt:autoCheckBox name="showLatest" value="${showLatest}">Show only latest execution</pt:autoCheckBox><br>

   <sql:query var="testprocess">select * from processinstance pi
      join stream using (stream)
      join process using (process)
      where stream = ?		
      <c:if test="${showLatest}"> 
         and pi.isLatest=1
      </c:if >
      order by displayorder
      <sql:param value="${param.stream}"/>    
   </sql:query>   

   <display:table class="datatable" name="${testprocess.rows}" sort="list" pagesize="${test.rowCount>50 && empty param.showAll ? 20 : 0}"  >
      <display:column property="ProcessName" title="Process" sortable="true" headerClass="sortable" href="pi.jsp" paramId="pi" paramProperty="ProcessInstance"/>
      <display:column property="ProcessingStatus" title="Status" sortable="true" headerClass="sortable"/>
      <display:column property="ProcessType" title="Type" sortable="true" headerClass="sortable"/>                       
      <display:column property="CreateDate" title="Created" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
      <c:if test="${isBatch}">
         <display:column property="SubmitDate" title="Submitted" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
      </c:if>
      <display:column property="StartDate" title="Started" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
      <display:column property="EndDate" title="Ended" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator" />
      <c:if test="${isBatch}">
         <display:column property="job" title="Job Id" sortable="true" headerClass="sortable"/>
         <display:column property="cpuSecondsUsed" title="CPU" sortable="true" headerClass="sortable"/>
         <display:column property="executionHost" title="Host" sortable="true" headerClass="sortable"/>
      </c:if>
      <display:column property="links" title="Links" />
      <c:if test="${adminMode}">
         <display:column property="selector" title=" " class="admin"/>                                      
      </c:if>
   </display:table>   

   <h3>Substreams</h3>

   <sql:query var="test">SELECT * FROM stream 
      join task using (task)
      where  parentstream = ? 
      order by task, streamid
      <sql:param value="${param.stream}"/>    
   </sql:query>


   <display:table class="datatable" name="${test.rows}" sort="list" defaultsort="1" defaultorder="ascending" pagesize="${test.rowCount>50 && empty param.showAll ? 20 : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >
      <display:column property="Taskname" title="taskname" sortable="true" group = "1" headerClass="sortable" />              			    
      <display:column property="StreamId" title="Stream" sortable="true" headerClass="sortable" href="si.jsp" paramId="stream" paramProperty="stream"/>                  
      <display:column property="StreamStatus" title="Status" sortable="true" headerClass="sortable"/>
      <c:if test="${!showLatest}">
         <display:column property="ExecutionNumber" title="Stream #"/>
      </c:if>
      <display:column property="CreateDate" title="Created" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator"/>
      <display:column property="StartDate" title="Started" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator"/>
      <display:column property="EndDate" title="Ended" sortable="true" headerClass="sortable" decorator="org.glast.pipeline.web.decorators.TimestampColumnDecorator"/>
   </display:table>

</body>
</html>
