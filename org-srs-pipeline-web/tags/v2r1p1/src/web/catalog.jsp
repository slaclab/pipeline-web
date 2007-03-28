<?xml version="1.0" encoding="UTF-8"?>
<%@page contentType="text/xml"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="sql"uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 

<!DOCTYPE catalog SYSTEM "dcs.dtd">

<catalog name="Glast Data Catalog">
    <sql:query var="data">
select dsi.dsinstance_pk, dsi.filename, dsi.filepath, dsi.bytes,r.runname,ds.datasetname,dt.dstypename,ft.dsfiletypename from 
dsinstance dsi, run r, dataset ds, dsfiletype ft, dstype dt
where r.task_fk=? and ds.dataset_pk = dsi.dataset_fk and dsi.run_fk = r.run_pk and r.runstatus_fk = (select runstatus_pk from runstatus where runstatusname = 'DONE') and ft.dsfiletype_pk=ds.dsfiletype_fk and dt.dstype_pk=ds.dstype_fk and (ds.dsfiletype_fk=22 or ds.dsfiletype_fk=2) order by r.runname asc
        <sql:param value="${param.task}"/>           
    </sql:query>
    <c:forEach items="${data.rowsByIndex}" var="current">
        <dataset name="${current[1]}" id="${current[2]}${current[1]}">
           <meta name="format" value="${current[7]}"/>
           <meta name="file">
              <meta name="size" value="${current[3]}"/>
           </meta>
           <meta name="pipeline">
              <meta name="dsinstance" value="${current[0]}"/>
              <meta name="task" value="${current[4]}"/>
           </meta>
        </dataset>
    </c:forEach>
</catalog>