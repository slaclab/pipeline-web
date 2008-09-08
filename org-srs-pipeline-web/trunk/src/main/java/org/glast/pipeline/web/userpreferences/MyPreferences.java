package org.glast.pipeline.web.userpreferences;

/**
 *
 * @author chee
 *
 */

/* defaultSort defines what column to use for sorting, the default is to use column 1 */
public class MyPreferences {
    private String task = "last30";
    private String taskVersion = "latestVersions";
    private String defaultOrder = "descending";
    private String defaultSort = "1";
    private int showStreams = 20;
    private int defaultMessagePeriodMinutes = 10;
    
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
    
    public void setDefaultOrder(String defaultOrder) {
        this.defaultOrder = defaultOrder;        
    }
    
    public void setDefaultSort(String defaultSort) {
        this.defaultSort = defaultSort;
    }
    
    public void setShowStreams(int c){
        showStreams = c;
    }
    
    // Getters
    
    public String getTask(){
        return task;
    }
    
    public String getTaskVersion(){
        return taskVersion;
    }
    
    public String getDefaultOrder() {
        return defaultOrder;
    }
    
    public String getDefaultSort() {
        return defaultSort;
    }
    
    public int getShowStreams(){
        return showStreams;
    }

   public int getDefaultMessagePeriodMinutes()
   {
      return defaultMessagePeriodMinutes;
   }

   public void setDefaultMessagePeriodMinutes(int defaultMessagePeriodMinutes)
   {
      this.defaultMessagePeriodMinutes = defaultMessagePeriodMinutes;
   }
    
}
