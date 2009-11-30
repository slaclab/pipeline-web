<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%--
The taglib directive below imports the JSTL library. If you uncomment it,
you must also add the JSTL library to the project. The Add Library... action
on Libraries node in Projects view can be used to add the JSTL 1.1 library.
20sep07 Added option show N-number of Streams instead of 20 or all. 20 is still the default if nothing is chosen.
--%>
<%-- --%>
<%@taglib prefix="preferences" uri="http://srs.slac.stanford.edu/preferences" %>
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
        
        <preferences:preferences name="preferences">
            
            <tr>
                <th colspan="3">
                    Preferences For Pipeline II Main Page
                </th>
            </tr>
            <preferences:preference name="task"  size="50" title="Default Task">
                <preferences:value value="all" text="All Tasks"/>
                <preferences:value value="runs" text="Tasks with Runs"/>
                <preferences:value value="noruns" text="Tasks without Runs"/>
                <preferences:value value="active" text="Tasks with Active Runs"/>
                <preferences:value value="last30" text="Active in Last 30 days"/>
            </preferences:preference>
            
            <preferences:preference name="taskVersion" size="50" title="Default Version ">
                <preferences:value value="latestVersions" text="Latest Task Versions"/>
                <preferences:value value="allVersions" text="All Task Versions"/>
                <preferences:value value="mergeVersions" text="Merge Task Versions"/>
            </preferences:preference>
            
            <preferences:preference name="defaultSort" size = "50" title="Default Sort Column">
                <preferences:value value="1" text="Last Active"/>
                <preferences:value value="2" text="Task Name"/>
                <preferences:value value="3" text="Type"/>
                <preferences:value value="4" text="Waiting"/>
                <preferences:value value="5" text="Queued"/>
                <preferences:value value="6" text="Running"/>
                <preferences:value value="7" text="Success"/>
                <preferences:value value="8" text="Failed"/>
                <preferences:value value="9" text="Terminating"/>
                <preferences:value value="10" text="Terminated"/>
                <preferences:value value="11" text="Canceling"/>
                <preferences:value value="12" text="Canceled"/>
            </preferences:preference>
            
            <preferences:preference name="defaultOrder" size="50" title="Default Sort Order ">
                <preferences:value value="ascending"/>
                <preferences:value value="descending"/>
            </preferences:preference>
            <tr>
                <th colspan="3">
                    Preferences For Streams Processing<br>
                </th>
            </tr> 
            <preferences:preference name="showStreams" size="5" title="Default Number of Streams">
            </preferences:preference>
       
            <preferences:preference name="defaultStreamPeriodHours" size="5" title="Default Stream period (last N hours) ">
            </preferences:preference>
            
            <tr>
                <th colspan="3">
                    Preferences For Process Period<br>
                </th>
            </tr> 
            <preferences:preference name="defaultProcessPeriodHours" size="5" title="Default processes in the last N hours">
            </preferences:preference>
            
            <tr>
                <th colspan="3">
                    Preferences For JobProcessingStats Plots Period<br>
                </th>
            </tr>
            <preferences:preference name="defaultPerfPlotHours" size="5" title="Default Performance Plot Period (last N hours) ">
            </preferences:preference>

            <tr>
                <th colspan="3">
                    Preferences For P2stat Plots <br>
                </th>
            </tr>
            <preferences:preference name="defaultP2statHours" size="5" title="Default Performance Period (last N hours) ">
            </preferences:preference>

            <tr>
                <th colspan="3">
                    Preferences For LogViewer Period
                </th>
            </tr>            
            <preferences:preference name="defaultMessagePeriodMinutes" size="5" title="Default time period (minutes)">
            </preferences:preference>

            <tr>
                <th colspan="3">
                    Preferences For DataProcessingStats
                </th>
            </tr>
            <preferences:preference name="defaultDPhours" size="5" title="Default time period (hours)">
            </preferences:preference>

        </preferences:preferences>
    </body>
</html>
