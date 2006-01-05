<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@page import="org.apache.commons.fileupload.*"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="p" uri="http://glast-ground.slac.stanford.edu/pipeline"%>
<%@taglib prefix="cas" uri="http://www.yale.edu/its/tp/cas/version2"%>
<%@taglib uri="http://glast-ground.slac.stanford.edu/GroupManager" prefix="gm" %>

<html>
    <head>
        <title>Pipeline: Upload</title>
    </head>
    <body>
        <cas:auth var="userName" scope="session">
            <cas:loginUrl>https://glast-ground.slac.stanford.edu/cas/login</cas:loginUrl>
            <cas:validateUrl>https://glast-ground.slac.stanford.edu/cas/proxyValidate</cas:validateUrl>
            <cas:service>
                <c:url value="${pageContext.request.requestURL}"/>
            </cas:service>
        </cas:auth>
        <c:if test="${!gm:isUserInGroup(userName,'PipelineAdmin')}">
            <c:redirect url="noPermission.jsp"/>
        </c:if>
        <%
        if (FileUpload.isMultipartContent(request)) {
            // Create a new file upload handler
            DiskFileUpload upload = new DiskFileUpload();
            java.util.Map param = new java.util.HashMap();
            // Parse the request
            java.util.List /* FileItem */ items = upload.parseRequest(request);
            for (java.util.Iterator i = items.iterator(); i.hasNext(); ) {
                FileItem item = (FileItem) i.next();
                if (item.isFormField()) {
                    String name = item.getFieldName();
                    String value = item.getString();
                    param.put(name, value);
                } else {
                    String file = item.getString();
                    param.put(item.getFieldName(), file);
                }
            }
            pageContext.setAttribute("params", param);
        }
        %>
        <h1>Pipeline: Upload</h1>
    
        <c:choose>
            <c:when test="${!empty params.cancel}">
                <c:redirect url="index.jsp"/>
            </c:when>
            <c:when test="${empty params.submit}">
                <form method="POST" enctype="multipart/form-data">
                    XML File: <input type="file" name="xml" value="" width="60" />
                    <input type="submit" value="Submit" name="submit">
                    <input type="submit" value="Cancel" name="cancel">
                </form>
            </c:when>
            <c:otherwise>
                <c:catch var="error">
                    <p:upload user="${userName}" xml="${params.xml}"/>
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
