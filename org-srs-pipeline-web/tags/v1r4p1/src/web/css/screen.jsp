<%@page contentType="text/css"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

pre.log { border: 1px solid #000000; }
font.logFile { font-size : 100%; }

body{ 
   background-color: #fff; padding:0 0 0 0; margin:0 0 0 0;
}

table.pageHeader{
   width: 100%;
}

div.pageBody{
   margin: 0 10px 0 10px;
}

div.breadCrumb{
   margin: 0 10px 0 10px;
}

body, input, select, td, th, textarea{ 
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; 
	font-size: 11px;
}

a, a:visited { 
	text-decoration: none; 
}

a:hover {
	text-decoration: underline;
}

img{ 
	border: none;
}

table.filtertable {
	margin: 10px 0px 0px 0px;
        border: 1px solid #666;
}

span.pagebanner {
	background-color: #eee;
	border: 1px dotted #999;
	padding: 2px 4px 2px 4px;
	margin-top: 10px;
	display: block;
	border-bottom: none;
}

span.pagelinks {
	background-color: #eee;
	border: 1px dotted #999;
	padding: 2px 4px 2px 4px;
	display: block;
	border-top: none;
	margin-bottom: -5px;
}

div.taskSummary {
	background-color: #eee;
	border: 1px dotted #999;
	padding: 2px 4px 2px 4px;
	display: block;
	border-top: none;
}

table.datatable {
	margin: 10px 0px 10px 0px;
        border: 1px solid #666;
}

table.datatable thead th {
	text-align: left;
}

table.datatable thead th.emptyCell {
    background-color: #FFFFFF;
    border: 0px solid #666;
}

table.datatable th, table.datatable td {
	padding: 2px 4px 2px 4px;
	text-align: right;
	vertical-align: top;
}

table.datatable td.leftAligned {
	text-align: left;
}

table.datatable thead tr {
  background-color: #fc0; 
}

table.datatable thead a {
    text-decoration: none;
}

table.datatable th.sorted {
    background-color: orange;
}

table.datatable th a, table.datatable th a:visited {
    color: black;
}

table.datatable th.sorted a, table.datatable th.sortable a {
	background-position: right;
	display: block;
	width: 100%;
        ${fn:contains(header['user-agent'],'Gecko') ? 'margin' : 'padding'}: 0px 10px 0px 0px;
}

table.datatable tr.odd {
  background-color: #fff
}

table.datatable tr.tableRowEven, table.datatable tr.even {
  background-color: #fea
}

table.datatable th.sortable a {
        background-repeat: no-repeat;
	background-image: url(../img/arrow_off.png);
}

table.datatable th.order1 a {
        background-repeat: no-repeat;
	background-image: url(../img/arrow_down.png);
}

table.datatable th.order2 a {
        background-repeat: no-repeat;
	background-image: url(../img/arrow_up.png);
}