<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%--
The taglib directive below imports the JSTL library. If you uncomment it,
you must also add the JSTL library to the project. The Add Library... action
on Libraries node in Projects view can be used to add the JSTL 1.1 library.
20sep07 Added option show N-number of Streams instead of 20 or all. 20 is still the default if nothing is chosen.
--%>
<%-- --%>
<%@taglib prefix="utils" uri="http://glast-ground.slac.stanford.edu/utils" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
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
            
            <tr>
                <th colspan="3">
                    Preferences For Pipeline II Main Page
                </th>
            </tr>
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
            <tr>
                <th colspan="3">
                    Preferences For Streams Processing<br>
                </th>
            </tr> 
            <utils:preference name="showStreams" size="5" title="Default Number of Streams">
            </utils:preference>  
            
            <utils:preference name="defaultStreamPeriodDays" size="5" title="Default Stream period (last N days) ">
            </utils:preference>
            
            <tr>
                <th colspan="3">
                    Preferences For Job Processing Period<br>
                </th>
            </tr> 
            <utils:preference name="defaultProcessPeriodDays" size="5" title="Default processes in the last N days">
            </utils:preference>  
            
            <tr>
                <th colspan="3">
                    Preferences For Summary Plots Period<br>
                </th>
            </tr> 
            <utils:preference name="defaultPerfPlotDays" size="5" title="Default Performance Period (last N days) ">
            </utils:preference>
            <tr>
                <th colspan="3">
                    Preferences For Message Viewer
                </th>
            </tr>            
            <utils:preference name="defaultMessagePeriodMinutes" size="5" title="Default time period (minutes)"> 
            </utils:preference>
            <utils:preference name="defaultMessagePeriodDays" size="5" title="Default time period (days)"> 
            </utils:preference>
        </utils:preferences>
    </body>
</html>
