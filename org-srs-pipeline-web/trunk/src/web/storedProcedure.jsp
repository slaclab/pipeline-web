<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/GlastSQL" prefix="gsql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>

<html>
    <head>
        <title>Pipeline status</title>
        <link rel="stylesheet" href="css/screen.css" type="text/css" media="screen, print" />
        <link rel="stylesheet" href="css/FSdateSelect.css" type="text/css">        
    </head>
    <body>
        <c:choose>
          <c:when test="${param.mode=='prod'}">
            <sql:setDataSource dataSource="jdbc/pipeline" scope="session"/>
            <c:set var="mode" value="Prod" scope="session"/>
          </c:when>
          <c:when test="${param.mode=='dev'}">
            <sql:setDataSource dataSource="jdbc/pipeline-dev" scope="session"/>
            <c:set var="mode" value="Dev" scope="session"/>
          </c:when>
          <c:when test="${param.mode=='test'}">
            <sql:setDataSource dataSource="jdbc/pipeline-test" scope="session"/>
            <c:set var="mode" value="Test" scope="session"/>
          </c:when>
        </c:choose>
        
        <h1>Stored Procedures</h1>
        
        <gsql:call>
         begin
            ?:=DPF.getNumberOfTasks();
         end;
           <gsql:result var="result" type="integer"/>
        </gsql:call>    
        
        <p>getNumberOfTasks() = ${result} </p>
                
         <gsql:call>{call ?:=DPF.getNumberOfTasks()}
           <gsql:result var="result" type="integer"/>
        </gsql:call>    

        <p>getNumberOfTasks() = ${result} </p>
        
        <gsql:call>
         begin
            ?:=DPF.getTaskExistsByName(?);
         end;
           <gsql:result var="result" type="integer"/>
           <gsql:param value="demo"/>
        </gsql:call>    

        <p>getTaskExistsByName() = ${result} </p>
              
        <gsql:call>
         begin
            ?:=DPF.getTaskNameByPK(?);
         end;
           <gsql:result var="result" type="varchar"/>
           <gsql:param value="1348"/>
        </gsql:call>    

        <p>getTaskNameByPK() = ${result} </p>
        
        <gsql:call>
         begin
            ?:=DPF.getTaskList();
         end;
           <gsql:result var="result" type="cursor"/>
        </gsql:call>    

        <p>getTaskList() = ${result} size=${result.rowCount}</p>
        
        <display:table class="dataTable" name="${result.rows}" defaultsort="1" defaultorder="ascending">
            <display:column property="TASK_PK" sortable="true" headerClass="sortable"/>
            <display:column property="TASKNAME" sortable="true" headerClass="sortable" />
            <display:column property="TASKTYPENAME" sortable="true" headerClass="sortable" />
            <display:column property="RUNLOGFILEPATH" sortable="true" headerClass="sortable" />
            <display:column property="BASEFILEPATH" sortable="true" headerClass="sortable" />
        </display:table>
    </body>
</html>
