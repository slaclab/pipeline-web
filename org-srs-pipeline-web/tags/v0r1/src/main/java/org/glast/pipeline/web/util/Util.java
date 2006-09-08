package org.glast.pipeline.web.util;

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
      String result = status;
      if (result.startsWith("END_")) result = result.substring(4);
      result = result.substring(0,1).toUpperCase() + result.substring(1).toLowerCase();
      return result;
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
   public static String formatTimestamp(oracle.sql.TIMESTAMP timestamp) throws SQLException
   {
      return timestamp == null ? "" : format.format(timestamp.timestampValue());
   }
}
