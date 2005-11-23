<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib prefix="aida" uri="http://aida.freehep.org/jsp20" %>

<html>
    <head>
        <title>Pipeline Status</title>
        <script language="JavaScript" src="scripts/FSdateSelect-UTF8.js"></script>
        <link rel="stylesheet" href="css/screen.css" type="text/css" media="screen, print" />
        <link rel="stylesheet" href="css/FSdateSelect.css" type="text/css">        
    </head>

    <body>
        <c:import url="header.jsp"/>
        <sql:query var="name">
            select TASKNAME from TASK where TASK_PK=?
            <sql:param value="${param.task}"/>           
        </sql:query>
        <c:set var="taskName" value="${name.rowsByIndex[0][0]}"/>
        
        <div id="breadCrumb"> 
            <a href="index.jsp">status</a> /
            <a href="task.jsp?task=${param.task}">${taskName}</a> /
        </div> 
     
        <sql:query var="data">
           select RUNNAME, tpi2.ended-tpi1.submitted "jobtime" from TASK 
               join run r on task_fk=task_pk
               join TPINSTANCE tpi1 on run_pk = tpi1.run_fk 
			   and tpi1.taskprocess_fk = (select taskprocess_pk from taskprocess 
			   where task_fk = task_pk and sequence=1)
               join TPINSTANCE tpi2 on run_pk = tpi2.run_fk 
			   and tpi2.taskprocess_fk = (select taskprocess_pk from taskprocess 
			   where task_fk = task_pk and sequence=(select max(sequence) 
			   from taskprocess where task_fk = task_pk))
               where task_pk=?

            <sql:param value="${param.task}"/>
        </sql:query>  
        <aida:tuple var="tuple" query="${data}" />        
        <aida:tupleProjection var="jobtimeplot" tuple="${tuple}" xprojection="jobtime"/>
       
        <aida:plotter nx="1" ny="2" height="700">
            <aida:region title="Job Time">
                <aida:style>
                    <aida:attribute name="statisticsBoxFontSize" value="8"/>
                </aida:style>
                <aida:plot var="${jobtimeplot}" >
                    <aida:style>
                        <aida:attribute name="showErrorBars" value="false"/>   
                    </aida:style>                      
                </aida:plot>
            </aida:region>
           
        </aida:plotter>
    </body>
</html>
