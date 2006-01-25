<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="jc" uri="http://glast-ground.slac.stanford.edu/JobControl" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
    <head>
        <title>Job status</title>
    </head>
    <body>   
        <h1>Job ${param.id}</h1>
        <jc:status var="jobStatus" id="${param.id}"/>
        <c:choose>
            <c:when test="${empty jobStatus}">
                <p>No information currently available for job ${param.id}.</p>
            </c:when>
            <c:otherwise>
                <table border="1">
                    <tbody>
                        <tr>
                            <td>Status:</td>
                            <td>${jobStatus.status}</td>
                        </tr>                
                        <tr>
                            <td>Host:</td>
                            <td>${jobStatus.host}</td>
                        </tr>
                        <tr>
                            <td>Queue:</td>
                            <td>${jobStatus.queue}</td>
                        </tr>
                        <tr>
                            <td>Submitted:</td>
                            <td>${jobStatus.submitted}</td>
                        </tr>
                        <tr>
                            <td>Started:</td>
                            <td>${jobStatus.started}</td>
                        </tr>
                        <tr>
                            <td>Ended:</td>
                            <td>${jobStatus.ended}</td>
                        </tr>
                        <tr>
                            <td>CpuUsed:</td>
                            <td>${jobStatus.cpuUsed}</td>
                        </tr>
                        <tr>
                            <td>Memory Used:</td>
                            <td>${jobStatus.memoryUsed}</td>
                        </tr>
                        <tr>
                            <td>Swap Used:</td>
                            <td>${jobStatus.swapUsed}</td>
                        </tr>
                        <tr>
                            <td>Comment:</td>
                            <td><pre>${jobStatus.comment}</pre></td>
                        </tr>
                    </tbody>
                </table>   
            </c:otherwise>
        </c:choose>
    </body>
</html>
