package org.srs.pipeline.web.util;

import java.sql.SQLException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Locale;

/**
 *
 * @author tonyj
 */
public class Util
{
   private static final DateFormat format = new SimpleDateFormat("dd-MMM-yyyy HH:mm:ss.SSS",Locale.US);
   
   public static String prettyStatus(String status)
   {
      if (status == null) return "";
      String result = status;
      if (result.startsWith("END_")) result = result.substring(4);
      result = result.substring(0,1).toUpperCase() + result.substring(1).toLowerCase();
      return result;
   }
   
   public static String linkToStreams(String streamIdPath, String streamPath, String separator, String url)
   {
      return linkToPath(streamIdPath, streamPath, separator, url);
   }
   
   public static String linkToTasks(String taskNamePath, String taskPath, String separator, String url)
   {
      return linkToPath(taskNamePath, taskPath, separator, url);
   }
   private static String linkToPath(String namePath, String keyPath, String separator, String url)
   {
      StringBuilder result = new StringBuilder();
      String[] names = namePath.split("\\.");
      String[] keys= keyPath.split("\\.");
      if (names.length != keys.length) throw new IllegalArgumentException("namePath length != keyPath length");
      for (int i=0; i<names.length; )
      {
         String fullUrl = url+keys[i];
         result.append("<a href=\"");
         result.append(fullUrl);
         result.append("\">");
         result.append(names[i]);
         result.append("</a>");
         if (++i == names.length) break;
         result.append(separator);
      }
      return result.toString(); 
   }
   public static String formatTimestamp(java.sql.Timestamp timestamp) throws SQLException
   {
      return timestamp == null ? "" : format.format(timestamp);
      }
   public static int floor(double d)
   {
      return (int) Math.floor(d);
   }
   public static int ceil(double d)
   {
      return (int) Math.ceil(d);
   }
   public static String getPackageVersion(String packageName)
   {
      // Nice idea, but doesn't work since war file is not on classpath. 
      // Need to look for a better solution
      Package p = Package.getPackage(packageName);
      return p == null ? "unknown" : p.getImplementationVersion();
   }
}
