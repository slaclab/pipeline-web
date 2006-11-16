<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://www.opensymphony.com/sitemesh/decorator" prefix="decorator" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
    <head>
        <title><decorator:title default="Glast Pipeline" /></title>
        <link href="http://glast-ground.slac.stanford.edu/Commons/css/glastCommons.jsp" rel="stylesheet" type="text/css">
        <style type="text/css">
           .pageHeader p { margin-top: .5em; margin-bottom: 0; }
           .emphasis {color: #CC0000}
           table.filtertable { background-color: #FFCC66; padding: 2px 4px 2px 4px }
        </style>
        <decorator:head />
    </head>
    <body>
        <c:import url="header.jsp"/>
        <div class="pageBody">
            <decorator:body />
        </div>
    </body>
</html>