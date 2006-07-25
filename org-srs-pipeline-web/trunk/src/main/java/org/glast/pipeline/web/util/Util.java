package org.glast.pipeline.web.util;

/**
 *
 * @author tonyj
 */
public class Util
{
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
}
