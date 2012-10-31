package org.srs.pipeline.web.userpreferences;

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
    private int defaultStreamPeriodHours = -1;
    private int defaultProcessPeriodHours = -1;
    private int defaultPerfPlotHours = 7;
    private int defaultP2statHours = -1;
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
    
   public void setDefaultStreamPeriodHours (int defaultStreamPeriodHours){
      this.defaultStreamPeriodHours = defaultStreamPeriodHours;
   }
   
    public void setDefaultProcessPeriodHours (int defaultProcessPeriodHours){
      this.defaultProcessPeriodHours = defaultProcessPeriodHours;
   }
   
    public void setDefaultPerfPlotHours (int defaultPerfPlotHours){
      this.defaultPerfPlotHours = defaultPerfPlotHours;
   }

    public void setDefaultP2statHours (int defaultP2statHours){
      this.defaultP2statHours = defaultP2statHours;
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
   
   public int getDefaultStreamPeriodHours()
   {
      return defaultStreamPeriodHours;
   } 
   
   public int getDefaultProcessPeriodHours()
   {
      return defaultProcessPeriodHours;
   } 
   
   public int getDefaultPerfPlotHours()
   {
      if ( defaultPerfPlotHours < 1 ) { return 7; }
      else {
           return defaultPerfPlotHours;
      }
   }

   public int getDefaultP2statHours()
   {
      return defaultP2statHours;
   }

   public int getDefaultDPhours()
   {
      return defaultDPhours;
   }

}
