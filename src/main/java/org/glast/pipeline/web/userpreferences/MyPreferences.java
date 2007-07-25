/*
 * MyPreferences.java
 *
 * Created on July 16, 2007, 10:39 AM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 *
 * PipelineUserPrefs allows the user to customize the default settings
 * that are displayed the first time a user logs in or whenever the user 
 * clears the default settings by clicking the clear button.
 */

package org.glast.pipeline.web.userpreferences;

/**
 *
 * @author chee
 */
public class MyPreferences {
    String task = "all";
    String taskVersion = "latestVersions";
    
    /** Creates a new instance of MyPreferences */
    public MyPreferences() {
    }
    // Setters
    public void setTask(String a){
        task = a;
    }
    
    public void setTaskVersion(String b){
        taskVersion = b;
    }
    // Getters
    public String getTask(){
        return task;
    }
    
    public String getTaskVersion(){
        return taskVersion;
    }
}
