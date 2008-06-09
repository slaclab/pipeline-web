package org.glast.pipeline.web.decorators;

import java.util.Comparator;

/**
 * A comparator for stream paths (nn.mm)
 * @author tonyj
 */
public class StreamPathComparator implements Comparator
{
   public int compare(Object o1, Object o2)
   {
      String[] ss1 = o1.toString().split("\\.");
      String[] ss2 = o2.toString().split("\\.");
      for (int i=0; i<Math.max(ss1.length,ss2.length); i++)
      {
         int i1 = i>=ss1.length ? 0 :Integer.parseInt(ss1[i]);
         int i2 = i>=ss2.length ? 0 :Integer.parseInt(ss2[i]);
         if (i1 != i2) return i1-i2;
      }
      return 0;
   }
   
}
