package org.glast.pipeline.web.decorators;

import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Date;
import org.glast.jobcontrol.JobControlClient;
import org.glast.jobcontrol.JobControlException;
import org.glast.jobcontrol.JobStatus;
import org.glast.jobcontrol.NoSuchJobException;
import org.glast.pipeline.web.util.Util;
import java.util.Iterator;
import java.util.Map;
import javax.servlet.ServletRequest;
import org.displaytag.decorator.TableDecorator;

/**
 *
 * @author tonyj
 */
public class ProcessDecorator extends TableDecorator
{
   private final JobControlClient jc = new JobControlClient();
   private JobStatus statusCache;
   private final Format dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
   
   /** Creates a new instance of ProcessDecorator */
   public ProcessDecorator()
   {
   }
   public String getStatus()
   {
      Map map = (Map) getCurrentRowObject();
      String status = map.get("Status").toString();
      return Util.prettyStatus(status);
   }
   public Number getCpu()
   {
      Map map = (Map) getCurrentRowObject();
      Number cpu = (Number) map.get("Cpu");
      return cpu == null ? null : Integer.valueOf(cpu.intValue()/1000);
   }
   public Number getBytes()
   {
      Map map = (Map) getCurrentRowObject();
      Number bytes = (Number) map.get("Bytes");
      return bytes == null ? null : Integer.valueOf(bytes.intValue()/1024);
   }
   public String getJob()
   {
      Map map = (Map) getCurrentRowObject();
      Object pid = map.get("JobID");
      return pid == null ? null : "<a href=\"job.jsp?id="+pid+"\">"+pid+"</a>";
   }
   private JobStatus getJobStatus() throws JobControlException
   {
      Map map = (Map) getCurrentRowObject();
      Object pid = map.get("JobID");
      if (pid != null)
      {
         int id = Integer.parseInt(pid.toString());
         if (statusCache != null && statusCache.getId() == id) return statusCache;
         try
         {
            statusCache = jc.status(id);
            return statusCache;
         }
         catch (NoSuchJobException x)
         {
            return null;
         }
      }
      else return null;     
   }
   public String getHost() throws JobControlException
   {
      JobStatus status = getJobStatus();
      return status == null ? "?" : status.getHost();
   }
   public String getStarted() throws JobControlException
   {
      JobStatus status = getJobStatus();
      Date date = status == null ? null : status.getStarted();
      return date == null ? "-" : dateFormat.format(date);
   }
   public Number getCpuUsed() throws JobControlException
   {
      JobStatus status = getJobStatus();
      return status == null ? null : Integer.valueOf(status.getCpuUsed());
   }
   public Number getMemoryUsed() throws JobControlException
   {
      JobStatus status = getJobStatus();
      return status == null ? null : Integer.valueOf(status.getMemoryUsed()/1024);
   }
   public Number getSwapUsed() throws JobControlException
   {
      JobStatus status = getJobStatus();
      return status == null ? null : Integer.valueOf(status.getSwapUsed()/1024);
   }
   public String getLinks()
   {
      Map map = (Map) getCurrentRowObject();
      Object processinstance = map.get("processinstance");
      
      StringBuilder result = new StringBuilder();
      if (map.get("ProcessType").toString().equalsIgnoreCase("batch"))
      {
         if (map.get("StartDate") != null)
         {
            result.append("<a href=\"log.jsp?pi="+processinstance+"\">Log</a>&nbsp;:&nbsp;");
            result.append("<a href=\"run.jsp?pi="+processinstance+"\">Files</a>");
         }
      }
      else if (map.get("ProcessType").toString().equalsIgnoreCase("script"))
      {
         result.append("<a href=\"logViewer.jsp?pi="+processinstance+"\">Messages</a>");
      }
      return result.toString();
   }
   public String getSelector()
   {
      Map map = (Map) getCurrentRowObject();
      Object processinstance = map.get("processinstance");
      return "<input type=\"checkbox\" name=\"select\" value=\""+processinstance+"\">";
   }
   public String getStreamSelector()
   {
      Map map = (Map) getCurrentRowObject();
      Object stream = map.get("stream");
      return "<input type=\"checkbox\" name=\"select\" value=\""+stream+"\">";
   }
   public String getTaskLinks()
   {
      Map map = (Map) getCurrentRowObject();
      Object id = map.get("id");
      return "<a href=\"P2stats.jsp?process="+id+"\">Stats</a>";
   }
   
   public TaskWithVersion getTaskWithVersion()
   {
      Map map = (Map) getCurrentRowObject();
      return new TaskWithVersion(map.get("taskName"),map.get("version"),map.get("revision"));
   }
   public String getLastActive()
   {
      Map map = (Map) getCurrentRowObject();
      Date date = (Date) map.get("Last Active");
      return date == null ? "-" : dateFormat.format(date);
   }
   public String getSubmitted()
   {
      Map map = (Map) getCurrentRowObject();
      Date date = (Date) map.get("Submitted");
      return date == null ? "-" : dateFormat.format(date);
   }
   private class TaskWithVersion implements Comparable
   {
      private final String name;
      private int major = 0;
      private int minor = 0;
      TaskWithVersion(Object name, Object version, Object revision)
      {
         this.name = name.toString();
         if (version != null) major = ((Number) version).intValue();
         if (revision != null) minor = ((Number) revision).intValue();
      }
      public String toString()
      {
         if (major == 0 && minor == 0) return name;
         else return name + "("+major+"."+minor+")";
      }

      public int compareTo(Object o)
      {
         TaskWithVersion that = (TaskWithVersion) o;
         int rc = this.name.compareTo(that.name);
         if (rc != 0) return rc;
         rc = this.major - that.major;
         if (rc != 0) return rc;
         rc = this.minor - that.minor;
         return rc;
      }
   }
}
