<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>

<html>
   <head>
      <title>Pipeline status</title>
   </head>
   <body>
      
      See also the <a href="https://jira.slac.stanford.edu/browse/PFE?report=com.atlassian.jira.plugin.system.project:changelog-panel">JIRA change log</a>.
           
      <h1>Release Notes - Pipeline Front End - Version 2.8</h1>
            
      <h2>Improvement</h2>
      <ul>
      <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-127'>PFE-127</a>] - stream filter</li>
      <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-139'>PFE-139</a>] - Add regular expression searching in process view</li>
      <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-183'>PFE-183</a>] - Allow filtering of processes by status and Task</li>
      <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-184'>PFE-184</a>] - Show other executions (and auto-retry-attempts) in process/stream detail pages.</li>
      </ul>
      
      <h1>Release Notes - Pipeline Front End - Version 2.7</h1>
      
      <h2>Bug</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-145'>PFE-145</a>] - Rollback checkboxs should not be displayed next to non latest streams/processes</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-165'>PFE-165</a>] - Symbol explanation for top plot ('Task: All') in Usage Plots is missing.</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-171'>PFE-171</a>] - It should be possible to rollback substreams from the "Stream" page (si.jsp)</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-179'>PFE-179</a>] - Is something not right in the PFE or Pipeline?</li>
      </ul>
      
      <h2>Improvement</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-133'>PFE-133</a>] - grid lines for usage plots</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-140'>PFE-140</a>] - Consistently add the total number of processes displayed</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-152'>PFE-152</a>] - redirect should support stream paths</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-175'>PFE-175</a>] - Page titles</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-176'>PFE-176</a>] - Show task version</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-180'>PFE-180</a>] - Change some default values</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-181'>PFE-181</a>] - Speed up usage plots</li>
      </ul>
      
      <h2>New Feature</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-178'>PFE-178</a>] - Add support for auto-rollback of failed processes</li>
      </ul>
      
      
      <h1>Release Notes - Pipeline Front End - Version 2.6</h1>
      
      <h2>Bug</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-163'>PFE-163</a>] - Dump job id list no longer works</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-164'>PFE-164</a>] - Refreshing log viewer page does not update the time as expected</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-168'>PFE-168</a>] - Log Detail page should point back to task that created the error</li>
      </ul>
      
      <h2>Improvement</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-150'>PFE-150</a>] - Add page for MBean properties</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-162'>PFE-162</a>] - need to expand the list of tasks in processing plots to include all tasks</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-169'>PFE-169</a>] - Downloading XML file should result in Save As dialog</li>
      </ul>
      
      
      <h1>Release Notes - Pipeline Front End - Version 2.5.1</h1>
      
      <h2>Bug</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-132'>PFE-132</a>] - login page deposits one in limbo</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-159'>PFE-159</a>] - Clicking on "messages" no longer works</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-161'>PFE-161</a>] - Total Streams column in Task Summary page shows 1 when total is actually 0</li>
      </ul>
      
      <h2>Improvement</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-160'>PFE-160</a>] - Throughput plot should span two columns</li>
      </ul>
      
      <h1>Release Notes - Pipeline Front End - Version 2.5</h1>
      
      <h2>Bug</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-120'>PFE-120</a>] - Stream Execution Number column header label is "Stream#"  should be "Exec#" or similar.</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-137'>PFE-137</a>] - Clicking on summary plots for L1Proc does not work</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-143'>PFE-143</a>] - Show CPU split by node type in usage plots</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-144'>PFE-144</a>] - Add ability to filter on time range to the message log viewer</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-146'>PFE-146</a>] - Links to working dirs, log files does not work for remote sites (IN2P3)</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-147'>PFE-147</a>] - On fair-share page the "time" component of the end-date does not appear to work</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-151'>PFE-151</a>] - "Show only latest execution" toggle doesn't fully work in stream view</li>
      </ul>
      
      <h2>Improvement</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-117'>PFE-117</a>] - Reorder streams on PII web page</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-148'>PFE-148</a>] - Add "total" column to process table</li>
      </ul>
      
      <h2>New Feature</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-31'>PFE-31</a>] - Save user preferences to a database, and init new sessions with this data</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-40'>PFE-40</a>] - Processing Display by Run & TP</li>
      </ul>
      
      <h1>Release Notes - Pipeline Front End - Version 2.4</h1>
      
      <h2>Improvement</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-138'>PFE-138</a>] - Add heirarhical display of processes to stream view</li>
      </ul>
      
      <h2>Task</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-141'>PFE-141</a>] - Don't display hidden dependencies</li>
      </ul>
      
      
      <h1>Release Notes - Pipeline Front End - Version 2.3</h1>
      
      <h2>Improvement</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-84'>PFE-84</a>] - User customizations</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-128'>PFE-128</a>] - apply stream filter to task view</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-130'>PFE-130</a>] - "not SUCCESS" filter</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-131'>PFE-131</a>] - Pipeline II Status page poor performance</li>
      </ul>
      
      <h1>Release Notes - Pipeline Front End - Version 2.2.2</h1>
      
      <h2>Bug</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-123'>PFE-123</a>] - redirect.jsp does not use most recent version of task</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-126'>PFE-126</a>] - Problem displaying XML for task</li>
      </ul>
      
      <h2>New Feature</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-124'>PFE-124</a>] - Show task type in task list</li>
      </ul>
      
      <h1>Release Notes - Pipeline Front End - Version 2.2.1</h1>
      
      <h2>Bug</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-119'>PFE-119</a>] - In si.jsp, Stream Processes table shows stream times rather than process times</li>
      </ul>
      
      <h2>Improvement</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-122'>PFE-122</a>] - Don't display process rollback options until process rollback works</li>
      </ul>
      
      <h1>Release Notes - Pipeline Front End - Version 2.2</h1>
      
      <h2>Bug</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-115'>PFE-115</a>] - Many features of Stream summary page do not work</li>
      </ul>
      
      <h2>Improvement</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-116'>PFE-116</a>] - display subtasks</li>
      </ul>
      
      <h2>Task</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-106'>PFE-106</a>] - improve front-end to use new features in server</li>
      </ul>
      
      <h1>Release Notes - Pipeline Front End - Version 2.1.1</h1>
      
      <h2>Bug</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-114'>PFE-114</a>] - Login broken</li>
      </ul>
      
      <h1>Release Notes - Pipeline Front End - Version 2.1</h1>
      
      <h2>Bug</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-112'>PFE-112</a>] - Prod|Dev|Test switch can leave things in strange state</li>
      </ul>
      
      <h2>Improvement</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-108'>PFE-108</a>] - rotate flowcharts</li>
      </ul>
      
      <h2>New Feature</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-107'>PFE-107</a>] - Download dot</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-113'>PFE-113</a>] - Add confirmation page to delete task request from admin.jsp</li>
      </ul>
      
      
      
      <h1>Release Notes - Pipeline Front End - Version 2.0.6</h1>
      <h2>Bug</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-111'>PFE-111</a>] - Process Display does not show streams with id=0</li>
      </ul>
      
      <h2>Improvement</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-110'>PFE-110</a>] - Create Stream function in admin should allow streams with id=0</li>
      </ul>
      
      
      <h1>Release Notes - Pipeline Front End - Version 2.0.5</h1>
      
      <h2>Bug</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-105'>PFE-105</a>] - Fix bug when uploading XML through web interface</li>
      </ul>
      
      <h1>Release Notes - Pipeline Front End - Version 2.0.4</h1>
      
      <h2>Bug</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-98'>PFE-98</a>] - Problem with version list in pipeline front end</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-103'>PFE-103</a>] - Pipeline Admin: Create Stream interface should start with no Task selected.</li>
      </ul>
      
      <h2>Improvement</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-96'>PFE-96</a>] - Task display should show comment (if present)</li>
      </ul>
      
      
      <h1>Release Notes - Pipeline Front End - Version 2.0.0</h1>
      
      First pipeline II release
      
      <h1>Release Notes - Pipeline Front End - Version 1.4.5</h1>
      
      <h2>Bug</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-95'>PFE-95</a>] - Null pointer exception when plotting</li>
      </ul>
      
      <h1>Release Notes - Pipeline Front End - Version 1.4.4</h1>
      
      <h2>Bug</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-82'>PFE-82</a>] - login/out doesnt work when called from non-index page</li>
      </ul>
      
      <h1>Release Notes - Pipeline Front End - Version 1.4.3</h1>
      
      <h2>Bug</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-79'>PFE-79</a>] - summary plots for large tasks not working</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-83'>PFE-83</a>] - Links in e-mail dont work because of redirection to login</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-87'>PFE-87</a>] - CPU column not sorting numerically</li>
      </ul>
      
      <h2>Improvement</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-86'>PFE-86</a>] - Summary block on run pages</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-88'>PFE-88</a>] - Task filter can't distinguish between digitization-v3r4p6 and digitization-v3r4p6muon</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-90'>PFE-90</a>] - More new dataset types</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-92'>PFE-92</a>] - Add time to task summary page</li>
      </ul>
      
      <h2>New Feature</h2>
      <ul>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-91'>PFE-91</a>] - 'OR' in Task Filter would be useful</li>
         <li>[<a href='https://jira.slac.stanford.edu/browse/PFE-93'>PFE-93</a>] - Enumerations in XML schema should be generated from database</li>
      </ul>
      
      
      <h1>Release Notes - Pipeline Front End - Version 1.4.2</h1>
      
      <h2>Bug</h2>
      <ul>
         <li>[<a href='http://jira.slac.stanford.edu/browse/PFE-72'>PFE-72</a>] - Request for cut/paste run lists</li>
      </ul>
      
      <h2>Improvement</h2>
      <ul>
         <li>[<a href='http://jira.slac.stanford.edu/browse/PFE-80'>PFE-80</a>] - Add ability to hide "secret" tasks</li>
      </ul>
      
      <h1>Release Notes - Pipeline Front End - Version 1.4.1</h1>
      
      <h2>Bug</h2>
      <ul>
         <li>[<a href='http://jira.slac.stanford.edu/browse/PFE-78'>PFE-78</a>] - Non-integer run numbers no longer suported</li>
      </ul>
      
      <h2>Task</h2>
      <ul>
         <li>[<a href='http://jira.slac.stanford.edu/browse/PFE-65'>PFE-65</a>] - Improve style-sheet</li>
         <li>[<a href='http://jira.slac.stanford.edu/browse/PFE-77'>PFE-77</a>] - Should pay for calendar component</li>
      </ul>
      
      <h2>Improvement</h2>
      <ul>
         <li>[<a href='http://jira.slac.stanford.edu/browse/PFE-73'>PFE-73</a>] - Request for more plots</li>
         <li>[<a href='http://jira.slac.stanford.edu/browse/PFE-75'>PFE-75</a>] - Would be good to associate "last active" date with each task on front-page</li>
      </ul>
      
      <h1>Release Notes - Pipeline Front End - Version 1.4</h1>
      
      <h2>Task</h2>
      <ul>
         <li>[<a href='http://jira.slac.stanford.edu/browse/PFE-66'>PFE-66</a>] - Move new pipeline front-end to Java CVS</li>
      </ul>
      
      <h1>Release Notes - Pipeline Front End - Version 1.3.5</h1>
      
      <h2>Bug</h2>
      <ul>
         <li>[<a href='http://jira.slac.stanford.edu/browse/PFE-71'>PFE-71</a>] - Run min/max not working</li>
      </ul>
      
      <h1>Release Notes - Pipeline Front End - Version 1.3.4</h1>
      
      <h2>Bug</h2>
      <ul>
         <li>[<a href='http://jira.slac.stanford.edu/browse/PFE-70'>PFE-70</a>] - Can't see prepared TPIs</li>
      </ul>
      
      <h1>Release Notes - Pipeline Front End - Version 1.3</h1>
      
      <h2>Task</h2>
      <ul>
         <li>[<a href='http://jira.slac.stanford.edu/browse/PFE-69'>PFE-69</a>] - New pipeline front-end should allow upload of config files.</li>
      </ul>
      
      <h2>Improvement</h2>
      <ul>
         <li>[<a href='http://jira.slac.stanford.edu/browse/PFE-33'>PFE-33</a>] - allow users to input task etc comments in xml files</li>
         <li>[<a href='http://jira.slac.stanford.edu/browse/PFE-47'>PFE-47</a>] - Add a "include pipelines with no runs" toggle to main stats page</li>
         <li>[<a href='http://jira.slac.stanford.edu/browse/PFE-67'>PFE-67</a>] - Task filter should be case insensitive</li>
         <li>[<a href='http://jira.slac.stanford.edu/browse/PFE-68'>PFE-68</a>] - Task list should include tasks without runs</li>
      </ul>
   </body>
</html>
