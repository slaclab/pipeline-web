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
   private JobControlClient jc = new JobControlClient();
   private JobStatus statusCache;
   private Format dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
   
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
      ServletRequest request = getPageContext().getRequest();
      StringBuffer buffer = new StringBuffer();
      Map param = request.getParameterMap();
      for (Iterator i = param.entrySet().iterator(); i.hasNext(); )
      {
         Map.Entry entry = (Map.Entry) i.next();
         String[] values = (String[]) entry.getValue();
         for (int j=0; j<values.length; j++)
         {
            buffer.append(entry.getKey().toString());
            buffer.append('=');
            buffer.append(values[j]);
            buffer.append('&');
         }
      }
      Map map = (Map) getCurrentRowObject();
      Object processinstance = map.get("processinstance");
      buffer.append("pi=");
      buffer.append(processinstance);
      return "<a href=\"log.jsp?"+buffer+"\">Log</a>&nbsp;:&nbsp;"+
             "<a href=\"run.jsp?"+buffer+"\">Files</a>";
   }
   public String getTaskLinks()
   {
      ServletRequest request = getPageContext().getRequest();
      StringBuffer buffer = new StringBuffer();
      Map param = request.getParameterMap();
      for (Iterator i = param.entrySet().iterator(); i.hasNext(); )
      {
         Map.Entry entry = (Map.Entry) i.next();
         String[] values = (String[]) entry.getValue();
         for (int j=0; j<values.length; j++)
         {
            buffer.append(entry.getKey().toString());
            buffer.append('=');
            buffer.append(values[j]);
            buffer.append('&');
         }
      }
      Map map = (Map) getCurrentRowObject();
      Object id = map.get("id");
      buffer.append("process=");
      buffer.append(id);

      return "<a href=\"stats.jsp?"+buffer+"\">Stats</a>";
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
}
