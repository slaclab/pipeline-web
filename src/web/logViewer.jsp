<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/GroupManager" prefix="gm" %>

<html>
    <head>
        <title>Pipeline Log viewer</title>  
    </head>
    <body>

        <h2>Log Vewer</h2>

        <sql:query var="log">
        select log_level, message, cast(timeentered as date) time, streamid, processname, taskname
           from log
           left outer join processinstance  i on processinstance = threadid
           left outer join process p using (process)
           left outer join stream s  using (stream)
           left outer join task  t on t.task=p.task
        </sql:query>
        
        <display:table class="dataTable" name="${log.rows}" defaultsort="1" defaultorder="descending" decorator="org.glast.pipeline.web.decorators.ProcessDecorator">
           <display:column property="time" title="Time" sortable="true" headerClass="sortable" />
           <display:column property="log_level" title="Level" sortable="true" headerClass="sortable" />
           <display:column property="taskname" title="Task" sortable="true" headerClass="sortable" />
           <display:column property="processname" title="Process" sortable="true" headerClass="sortable"/>
           <display:column property="streamid" title="Stream" sortable="true" headerClass="sortable" />
          <display:column property="message" title="Message" class="leftAligned" />
        </display:table>
    </body>
</html>
