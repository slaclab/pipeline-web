<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="jc" uri="http://glast-ground.slac.stanford.edu/JobControl" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
    <head>
        <title>Job status</title>
        <link rel="stylesheet" href="css/screen.css" type="text/css" media="screen, print" />
    </head>
    <body>   
        <c:import url="header.jsp"/>
        <h1>Job ${param.id}</h1>
        <jc:status var="status" id="${param.id}"/>
        <c:choose>
            <c:when test="${empty status}">
                <p>No information currently available for job ${param.id}.</p>
            </c:when>
            <c:otherwise>
                <table border="1">
                    <tbody>
                        <tr>
                            <td>Status:</td>
                            <td>${status.status}</td>
                        </tr>                
                        <tr>
                            <td>Host:</td>
                            <td>${status.host}</td>
                        </tr>
                        <tr>
                            <td>Queue:</td>
                            <td>${status.queue}</td>
                        </tr>
                        <tr>
                            <td>Submitted:</td>
                            <td>${status.submitted}</td>
                        </tr>
                        <tr>
                            <td>Started:</td>
                            <td>${status.started}</td>
                        </tr>
                        <tr>
                            <td>Ended:</td>
                            <td>${status.ended}</td>
                        </tr>
                        <tr>
                            <td>CpuUsed:</td>
                            <td>${status.cpuUsed}</td>
                        </tr>
                        <tr>
                            <td>Memory Used:</td>
                            <td>${status.memoryUsed}</td>
                        </tr>
                        <tr>
                            <td>Swap Used:</td>
                            <td>${status.swapUsed}</td>
                        </tr>
                        <tr>
                            <td>Comment:</td>
                            <td><pre>${status.comment}</pre></td>
                        </tr>
                    </tbody>
                </table>   
            </c:otherwise>
        </c:choose>
    </body>
</html>
