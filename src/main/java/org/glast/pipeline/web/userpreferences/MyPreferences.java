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
    private int defaultStreamPeriodDays = -1;
    private int defaultProcessPeriodDays = -1;
    private int defaultPerfPlotDays = -1;
    private int defaultP2statDays = -1;
    private int defaultDPhours = -1;
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
    
   public void setDefaultStreamPeriodDays (int defaultStreamPeriodDays){
      this.defaultStreamPeriodDays = defaultStreamPeriodDays;
   }
   
    public void setDefaultProcessPeriodDays (int defaultProcessPeriodDays){
      this.defaultProcessPeriodDays = defaultProcessPeriodDays;
   }
   
    public void setDefaultPerfPlotDays (int defaultPerfPlotDays){
      this.defaultPerfPlotDays = defaultPerfPlotDays;
   }

    public void setDefaultP2statDays (int defaultP2statDays){
      this.defaultP2statDays = defaultP2statDays;
   }

   public void setDefaultDPhours (int defaultDPhours){
      this.defaultDPhours = defaultDPhours;
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

   public int getDefaultP2statDays()
   {
      return defaultP2statDays;
   }

   public int getDefaultDPhours()
   {
      return defaultDPhours;
   }

}
