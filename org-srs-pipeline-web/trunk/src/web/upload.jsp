<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@page import="org.apache.commons.fileupload.*"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="p" uri="http://glast-ground.slac.stanford.edu/pipeline"%>
<%@taglib uri="http://glast-ground.slac.stanford.edu/GroupManager" prefix="gm" %>

<html>
    <head>
        <title>Pipeline: Upload</title>
    </head>
    <body>
        <c:if test="${!gm:isUserInGroup(userName,'PipelineAdmin')}">
            <c:redirect url="noPermission.jsp"/>
        </c:if>

        <h1>Pipeline: Upload</h1>
    
        <c:choose>
            <c:when test="${!empty param.cancel}">
                <c:redirect url="index.jsp"/>
            </c:when>
            <c:when test="${empty param.submit}">
                <form method="POST" enctype="multipart/form-data">
                    XML File: <input type="file" name="xml" value="" width="60" />
                    <input type="submit" value="Submit" name="submit">
                    <input type="submit" value="Cancel" name="cancel">
                </form>
            </c:when>
            <c:otherwise>
                <c:catch var="error">
                    <p:upload user="${userName}" xml="${param.xml}"/>
                </c:catch>
                <c:choose>
                    <c:when test="${empty error}">
                        Upload successful!
                    </c:when>
                    <c:otherwise>
                        Sorry upload failed!
                        <p:reportError error="${error}"/>
                    </c:otherwise>
                </c:choose>
                <ul>   
                    <li><a href="index.jsp">Back to task list</a></li>
                    <li><a href="upload.jsp">Upload another file</a></li>
                </ul>
            </c:otherwise>
        </c:choose>
    </body>
</html>
