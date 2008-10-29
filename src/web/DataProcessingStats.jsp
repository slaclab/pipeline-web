<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="aida" uri="http://aida.freehep.org/jsp20" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://glast-ground.slac.stanford.edu/pipeline" prefix="pl" %>
<%@taglib prefix="utils" uri="http://glast-ground.slac.stanford.edu/utils" %>
<html>
    <head>
        <title>Data Processing delay</title>    
    </head>
    <body>
        
        <sql:query var="data">
            select (GLAST_UTIL.GetDeltaSeconds(dv.registered-to_date('01-JAN-01'))-n.metavalue)/3600+8 as hours from verdataset d 
            join datasetversion dv on (d.latestversion=dv.datasetversion) 
            join verdatasetmetanumber n on (n.datasetversion=dv.datasetversion and n.metaname='nMetStop')
            where datasetgroup=39684247 and n.metaValue>239907864.08432
        </sql:query>
        <aida:plotter height="400">            
            <aida:tuple var="tuple" query="${data}"/>    
            <aida:tupleProjection var="hours" tuple="${tuple}" xprojection="HOURS"/>
            <aida:region title= "Data processing elapsed time (hours)" >
                <aida:style>
                    <aida:style type="legendBox">
                        <aida:attribute name="isVisible" value="false"/>
                    </aida:style>
                </aida:style>   
                
                <aida:plot var="${hours}">
                </aida:plot>
            </aida:region>
        </aida:plotter>        
        
    </body>
</html>

</body>
</html>
