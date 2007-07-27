<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%--
The taglib directive below imports the JSTL library. If you uncomment it,
you must also add the JSTL library to the project. The Add Library... action
on Libraries node in Projects view can be used to add the JSTL 1.1 library.
--%>
<%-- --%>
<%@taglib prefix="utils" uri="http://glast-ground.slac.stanford.edu/utils" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
<%-- --%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Set User Preferences Form</title>
    </head>
    <body>
        
    <h1>Set User Preferences Form</h1>
    This form allows you to set the default settings to be used when you first logon to Pipeline-II.<br>
            Select items from the pull down menus and then click the <strong>Update Preferences</strong> button.<p>
            <utils:preferences name="preferences">
                <utils:preference name="task"  size="50" title="Default Task">
                <utils:value value="all" text="All Tasks"/>
                <utils:value value="runs" text="Tasks with Runs"/>
                <utils:value value="noruns" text="Tasks without Runs"/>                
                <utils:value value="active" text="Tasks with Active Runs"/>
                <utils:value value="last30" text="Active in Last 30 days"/>
            </utils:preference>
            <utils:preference name="taskVersion" size="50" title="Default Version ">
                <utils:value value="latestVersions" text="Latest Task Versions"/>
                <utils:value value="allVersions" text="All Task Versions"/>
                <utils:value value="mergeVersions" text="Merge Task Versions"/>
            </utils:preference>  
            <utils:preference name="defaultSort" size = "50" title="Default Sort Column">
                <utils:value value="1" text="Last Active"/>
                <utils:value value="2" text="Task Name"/>
                <utils:value value="3" text="Type"/>
                <utils:value value="4" text="Waiting"/>
                <utils:value value="5" text="Queued"/>
                <utils:value value="6" text="Running"/>          
                 <utils:value value="7" text="Success"/>
                <utils:value value="8" text="Failed"/>
                <utils:value value="9" text="Terminating"/>
                <utils:value value="10" text="Terminated"/>
                <utils:value value="11" text="Canceling"/>
                <utils:value value="12" text="Canceled"/> 
            </utils:preference> 
            <utils:preference name="defaultOrder" size="50" title="Default Sort Order ">
                <utils:value value="ascending"/>
                <utils:value value="descending"/>
            </utils:preference>
        </utils:preferences>
     
        <%--
        <table>
            <td>Task Filter: <input type="text" name="taskFilter" value="${taskFilter}"></td>
            <td><input type="checkbox" name="regExp" ${regExp ? 'checked' : ''}> Regular Expression (<a href="http://www.oracle.com/technology/oramag/webcolumns/2003/techarticles/rischert_regexp_pt1.html">?</a>)</td>
            <td><select name="include">
                    <utils:value="all" ${include=='all' ? "selected" : ""}>All tasks</option>
                    <utils:value="runs" ${include=='runs' ? "selected" : ""}>Tasks with Runs</option>
                    <option value="noruns" ${include=='noruns' ? "selected" : ""}>Tasks without Runs</option>
                    <option value="active" ${include=='active' ? "selected" : ""}>Tasks with Active Runs</option>
                    <option value="last30" ${include=='last30' ? "selected" : ""}>Active in Last 30 days</option>
            </select></td>
            <td><select name="versionGroup">
                    <option value="latestVersions" ${versionGroup=='latestVersions' ? "selected" : ""}>Latest Task Versions</option>
                    <option value="allVersions" ${versionGroup=='allVersions' ? "selected" : ""}>All Task Versions</option>
                    <option value="mergeVersions" ${versionGroup=='mergeVersions' ? "selected" : ""}>Merge Task Versions</option>
            </select></td>
            <td><input type="submit" value="Filter" name="submit">&nbsp;<input type="submit" value="Clear" name="clear"></td>
        </table> 
        
        <utils:preference name="timeSelection"             title="Time Selection: ">
            <utils:value value="Event"/>
            <utils:value value="Posted"/>
        </utils:preference> 
    </utils:preferences> --%>
    <%--
    This example uses JSTL, uncomment the taglib directive above.
    To test, display the page like this: index.jsp?sayHello=true&name=Murphy
    --%>
    <%--
    <c:if test="${param.sayHello}">
        <!-- Let's welcome the user ${param.name} -->
        Hello ${param.name}!
    </c:if>
    --%>
    
    </body>
</html>
