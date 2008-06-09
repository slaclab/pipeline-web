package org.glast.pipeline.web.decorators;

import java.util.Comparator;

/**
 * A comparator for stream paths (nn.mm)
 * @author tonyj
 */
public class TaskPathComparator implements Comparator
{
   public int compare(Object o1, Object o2)
   {
      String[] ss1 = o1.toString().split("\\.");
      String[] ss2 = o2.toString().split("\\.");
      for (int i=0; i<Math.max(ss1.length,ss2.length); i++)
      {
         
         String s1 = i>=ss1.length ? "" : ss1[i];
         String s2 = i>=ss2.length ? "" : ss2[i];
         int diff = s1.compareTo(s2);
         if (diff != 0) return diff;
      }
      return 0;
   }
   
}
