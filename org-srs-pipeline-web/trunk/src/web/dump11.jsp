<?xml version="1.0" encoding="UTF-8"?>
<%@page contentType="text/xml"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="sql"uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 


<pipeline
    xmlns="http://glast-ground.slac.stanford.edu/pipeline"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://glast-ground.slac.stanford.edu/pipeline http://glast-ground.slac.stanford.edu/Pipeline/schemas/1.1/pipeline.xsd">

    <sql:query var="name">
        select TASKNAME,TASKTYPENAME,BASEFILEPATH,RUNLOGFILEPATH,NOTATION 
        from TASK join TASKTYPE on (TASKTYPE_FK=TASKTYPE_PK) 
        left outer join RI_TASK on (TASK_FK=TASK_PK) 
        left outer join RECORDINFO on (RECORDINFO_FK=RECORDINFO_PK) where TASK_PK=?
        <sql:param value="${param.task}"/>           
    </sql:query>
    <name>${name.rows[0]["TASKNAME"]}</name>
    <type>${name.rows[0]["TASKTYPENAME"]}</type>
    <notation>${name.rows[0]["NOTATION"]}</notation>
    <dataset-base-path>${name.rows[0]["BASEFILEPATH"]}</dataset-base-path>
    <run-log-path>${name.rows[0]["RUNLOGFILEPATH"]}</run-log-path>
    
    <sql:query var="data">
        select TASKPROCESSNAME,APPVERSION,COMMANDLINE from TASKPROCESS where task_fk=? order by sequence
        <sql:param value="${param.task}"/>           
    </sql:query>
    <c:forEach items="${data.rows}" var="current">
        <executable name="${current['TASKPROCESSNAME']}Wrapper" version="${current['APPVERSION']}">
            ${current['COMMANDLINE']}
        </executable>
    </c:forEach>
    
    <sql:query var="data">
        select distinct BATCHQUEUENAME,BATCHLOGPATH,WORKINGDIRECTORY,BATCHGROUPNAME from TASKPROCESS,BATCHQUEUE,BATCHGROUP where task_fk=? and BATCHQUEUE_FK=BATCHQUEUE_PK and BATCHGROUP_FK=BATCHGROUP_PK
        <sql:param value="${param.task}"/>           
    </sql:query>
    <c:forEach items="${data.rows}" var="current">
        <batch-job-configuration group="${current['BATCHGROUPNAME']}" name="${current['BATCHQUEUENAME']}-job" queue="${current['BATCHQUEUENAME']}">
            <working-directory>${current['WORKINGDIRECTORY']}</working-directory>
            <log-file-path>${current['BATCHLOGPATH']}</log-file-path>
        </batch-job-configuration>
    </c:forEach>     
    
    <sql:query var="data">
       select DATASETNAME,DSFILETYPENAME,DSTYPENAME,FILEPATH, NOTATION 
       from DATASET join DSFILETYPE on (DSFILETYPE_PK=DSFILETYPE_FK)
                    join DSTYPE on (DSTYPE_FK=DSTYPE_PK)
                    left outer join RI_DATASET on (DATASET_FK=DATASET_PK) 
                    left outer join RECORDINFO on (RECORDINFO_FK=RECORDINFO_PK)
       where task_fk=?
        <sql:param value="${param.task}"/>           
    </sql:query>
    <c:forEach items="${data.rows}" var="current">
        <file name="${current['DATASETNAME']}" type="${current['DSTYPENAME']}" file-type="${current['DSFILETYPENAME']}">
            <notation>${current['NOTATION']}</notation>
            <path>${current['FILEPATH']}</path>
        </file>
    </c:forEach>
    <sql:query var="data">        
       select DATASETNAME, FILEPATH, TASKNAME
       from TASKPROCESS p join TP_DS on (TASKPROCESS_PK=TASKPROCESS_FK)
                          join DATASET d on (DATASET_FK=DATASET_PK)
                          join TASK t on (d.TASK_FK = t.TASK_PK)
       where p.task_fk=? and d.TASK_FK != p.TASK_FK
       <sql:param value="${param.task}"/>           
    </sql:query>    
    <c:forEach items="${data.rows}" var="current">
        <foreign-input-file name="${current['DATASETNAME']}" pipeline="${current['TASKNAME']}" file="${current['DATASETNAME']}"/>
    </c:forEach>    
    <sql:query var="data">
       select BATCHQUEUENAME,TASKPROCESSNAME,TASKPROCESS_PK,NOTATION 
       from TASKPROCESS join BATCHQUEUE on (BATCHQUEUE_FK=BATCHQUEUE_PK) 
                        left outer join RI_TASKPROCESS on (TASKPROCESS_FK=TASKPROCESS_PK) 
                        left outer join RECORDINFO on (RECORDINFO_FK=RECORDINFO_PK)
       where task_fk=? order by sequence
        <sql:param value="${param.task}"/>           
    </sql:query>
    <c:forEach items="${data.rows}" var="current">
        <processing-step name="${current['TASKPROCESSNAME']}" executable="${current['TASKPROCESSNAME']}Wrapper" batch-job-configuration="${current['BATCHQUEUENAME']}-job">
            <notation>${current['NOTATION']}</notation>
            <sql:query var="ds">
                select RW,DATASETNAME from TP_DS s ,DATASET d where s.taskprocess_fk=? and s.DATASET_FK=d.DATASET_PK order by rw
                <sql:param value="${current['TASKPROCESS_PK']}"/>  
            </sql:query>          
            <c:forEach items="${ds.rows}" var="current">
                <c:choose>
                    <c:when test="${current['RW']=='R'}">
                        <input-file name="${current['DATASETNAME']}"/>
                    </c:when>
                    <c:otherwise>
                        <output-file name="${current['DATASETNAME']}"/>
                    </c:otherwise>
                </c:choose>
            </c:forEach>
        </processing-step>
    </c:forEach>       
</pipeline>