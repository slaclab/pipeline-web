<?xml version="1.0" encoding="UTF-8"?>
<%@page contentType="text/xml"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="sql"uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 


<pipeline
    xmlns="http://glast-ground.slac.stanford.edu/pipeline"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://glast-ground.slac.stanford.edu/pipeline http://glast-ground.slac.stanford.edu/pipeline.xsd">

    <sql:query var="name">
        select TASKNAME,TASKTYPENAME,BASEFILEPATH,RUNLOGFILEPATH from TASK, TASKTYPE where TASK_PK=? and TASKTYPE_FK=TASKTYPE_PK
        <sql:param value="${param.task}"/>           
    </sql:query>
    <name>${name.rowsByIndex[0][0]}</name>
    <type>${name.rowsByIndex[0][1]}</type>
    <dataset-base-path>${name.rowsByIndex[0][2]}</dataset-base-path>
    <run-log-path>${name.rowsByIndex[0][3]}</run-log-path>
    
    <sql:query var="data">
        select TASKPROCESSNAME,APPVERSION,COMMANDLINE from TASKPROCESS where task_fk=? order by sequence
        <sql:param value="${param.task}"/>           
    </sql:query>
    <c:forEach items="${data.rowsByIndex}" var="current">
        <executable name="${current[0]}Wrapper" version="${current[1]}">
            ${current[2]}
        </executable>
    </c:forEach>
    
    <sql:query var="data">
        select distinct BATCHQUEUENAME,BATCHLOGPATH,WORKINGDIRECTORY,BATCHGROUPNAME from TASKPROCESS,BATCHQUEUE,BATCHGROUP where task_fk=? and BATCHQUEUE_FK=BATCHQUEUE_PK and BATCHGROUP_FK=BATCHGROUP_PK
        <sql:param value="${param.task}"/>           
    </sql:query>
    <c:forEach items="${data.rowsByIndex}" var="current">
        <batch-job-configuration group="${current[3]}" name="${current[0]}-job" queue="${current[0]}">
            <working-directory>${current[2]}</working-directory>
            <log-file-path>${current[1]}</log-file-path>
        </batch-job-configuration>
    </c:forEach>     
    
    <sql:query var="data">
        select DATASETNAME,DSFILETYPENAME,DSTYPENAME,FILEPATH from DATASET, DSFILETYPE, DSTYPE where task_fk=? and DSFILETYPE_PK=DSFILETYPE_FK and DSTYPE_FK=DSTYPE_PK
        <sql:param value="${param.task}"/>           
    </sql:query>
    <c:forEach items="${data.rowsByIndex}" var="current">
        <file name="${current[0]}" type="${current[2]}" file-type="${current[1]}">${current[3]}</file>
    </c:forEach>        

    <sql:query var="data">
        select BATCHQUEUENAME,TASKPROCESSNAME,TASKPROCESS_PK from TASKPROCESS,BATCHQUEUE where task_fk=? and BATCHQUEUE_FK=BATCHQUEUE_PK order by sequence
        <sql:param value="${param.task}"/>           
    </sql:query>
    <c:forEach items="${data.rowsByIndex}" var="current">
        <processing-step name="${current[1]}" executable="${current[1]}Wrapper" batch-job-configuration="${current[0]}-job">
            <sql:query var="ds">
                select RW,DATASETNAME from TP_DS s ,DATASET d where s.taskprocess_fk=? and s.DATASET_FK=d.DATASET_PK order by rw
                <sql:param value="${current[2]}"/>  
            </sql:query>          
            <c:forEach items="${ds.rowsByIndex}" var="current">
                <c:choose>
                    <c:when test="${current[0]=='R'}">
                        <input-file name="${current[1]}"/>
                    </c:when>
                    <c:otherwise>
                        <output-file name="${current[1]}"/>
                    </c:otherwise>
                </c:choose>
            </c:forEach>
        </processing-step>
    </c:forEach>       
</pipeline>