<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Strict//EN">
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
         table.filtertable { background-color: #FFCC66; }
         table.datatable td.admin { background-color: pink; padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px;  }
         
         table.mbeanAttributeTable {
         background:#5ff;
         }
         table.mbeanAttributeTable thead {
         background:#5cc;
         }
         table.mbeanOperationTable {
         background:#5ff;
         }
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