<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/GroupManager" prefix="gm" %>
<%@taglib prefix="pt" tagdir="/WEB-INF/tags"%>

<html>
   <head>
      <title>Pipeline status</title>
   </head>
   <body>
     
     <br>   
	  <c:set var="showLatest" value="${!empty param.showLatestChanged ? !empty param.showLatest : empty showLatest ? true : showLatest}" scope="session"/>
	 
	   <sql:query var="rs1">
        select * from processinstance 
	 	join stream  using (stream)
		join streampath   using(stream)
        where stream=?
         <sql:param value="${param.stream}"/>
      </sql:query>
      <c:set var="data" value="${rs1.rows[0]}"/>

      <table>
         <tr><td>Stream</td><td>${data.stream}</td></tr>
         <tr><td>Task</td><td>${data.task}</td></tr>          
         <tr><td>ParentStream</td><td>${data.parentstream}</td></tr>       
		  <tr><td>StreamId</td><td>${data.streamId}</td></tr>   
          <tr><td>ExecutionNumber</td></td><td>${data.executionNumber}</td></tr>
		   <tr><td>Latest</td><td>${data.islatest}</td></tr>
		    <tr><td>Status</td><td>${data.streamStatus}</td></tr>
		 <tr><td>Submited</td><td>${pl:formatTimestamp(data.createDate)}</td></tr>          
         <tr><td>StartDate</td><td>${pl:formatTimestamp(data.startDate)}</td></tr>                   
         <tr><td>EndDate</td><td>${pl:formatTimestamp(data.endDate)}</td></tr>                                     
                 
      </table>
   <!--
      <p>Links: <a href="logViewer.jsp?pi=${param.pi}&severity=500&minDate=None&maxDate=None">View Messages</a></p>
    -->  
      <h3>Variables</h3>
	  
      <sql:query var="rs">
         select * from streamvar
         where stream=?
         <sql:param value="${param.stream}"/>
      </sql:query>      
      
	<display:table class="dataTable" name="${rs.rows}" defaultsort="1" defaultorder="ascending">
		<display:column property="varname" title="Name" sortable="true" headerClass="sortable" />
		<display:column property="vartype" title="Type" sortable="true" headerClass="sortable"/>
		<display:column property="value" title="Value" sortable="true" headerClass="sortable"/>
	</display:table>   
	  
	  <h3>Stream Processes: </h3>
    <pt:autoCheckBox name="showLatest" value="${showLatest}">Show only latest execution</pt:autoCheckBox><br>
	    
	  <sql:query var="testprocess">select * from processinstance pi
			join stream using (stream)
			join streampath using (stream)
			join process using (process)
 			where stream = ?		
			<c:if test="${showLatest}"> 
		   and streampath.IsLatestPath = 1 and stream.isLatest=1
		   and pi.isLatest=1
		 </c:if >
			order by displayorder
	   <sql:param value="${param.stream}"/>    
	   </sql:query>   
	   
	<display:table class="dataTable" name="${testprocess.rows}" sort="list" defaultsort="1" defaultorder="ascending" pagesize="${test.rowCount>50 && empty param.showAll ? 20 : 0}"  >
        <display:column property="ProcessName" title="Process" sortable="true" headerClass="sortable" href="process.jsp?status=0" paramId="process" paramProperty="Process"/>
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
        <display:column property="links" title="Links (<a href=help.html>?</a>)" />
        <c:if test="${adminMode}">
          <display:column property="selector" title=" " class="admin"/>                                      
        </c:if>
	</display:table>   
	      	  
	  <h3>Substreams: </h3>
   
   	  <sql:query var="test">SELECT * FROM stream 
       	join task using (task)
 		where  parentstream = ? 
		order by task, streamid
        <sql:param value="${param.stream}"/>    
   </sql:query>
     
     
	<display:table class="dataTable" name="${test.rows}" sort="list" defaultsort="1" defaultorder="ascending" pagesize="${test.rowCount>50 && empty param.showAll ? 20 : 0}" decorator="org.glast.pipeline.web.decorators.ProcessDecorator" >
  
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
