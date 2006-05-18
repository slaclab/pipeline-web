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
}
