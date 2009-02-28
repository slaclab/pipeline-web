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
    private int defaultMessagePeriodMinutes = 10;
    private int defaultMessagePeriodDays = 7;
    private int defaultStreamPeriodDays = -1;
    private int defaultProcessPeriodDays = -1;
    private int defaultPerfPlotDays = 30;
    private int showStreams = 20;
     
    
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
    
    public void setDefaultMessagePeriodMinutes(int defaultMessagePeriodMinutes) {
        this.defaultMessagePeriodMinutes = defaultMessagePeriodMinutes;
    }
    
    public void setDefaultMessagePeriodDays(int defaultMessagePeriodDays) {
        this.defaultMessagePeriodDays = defaultMessagePeriodDays;
    }
    
   public void setDefaultStreamPeriodDays (int defaultStreamPeriodDays){
      this.defaultStreamPeriodDays = defaultStreamPeriodDays;
   }
   
    public void setDefaultProcessPeriodDays (int defaultProcessPeriodDays){
      this.defaultProcessPeriodDays = defaultProcessPeriodDays;
   }
   
    public void setDefaultPerfPlotDays (int defaultPerfPlotDays){
      this.defaultPerfPlotDays = defaultPerfPlotDays;
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
   
    public int getDefaultMessagePeriodDays()
   {
      return defaultMessagePeriodDays;
   }

   public int getDefaultStreamPeriodDays()
   {
      return defaultStreamPeriodDays;
   } 
   
   public int getDefaultProcessPeriodDays()
   {
      return defaultProcessPeriodDays;
   } 
   
   public int getDefaultPerfPlotDays()
   {
      return defaultPerfPlotDays;
   }   
}
