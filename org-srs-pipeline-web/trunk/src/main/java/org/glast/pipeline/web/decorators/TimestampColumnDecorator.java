package org.glast.pipeline.web.decorators;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Comparator;
import java.util.Locale;
import javax.servlet.jsp.PageContext;
import org.displaytag.decorator.DisplaytagColumnDecorator;
import org.displaytag.properties.MediaTypeEnum;
/**
 *
 * @author tonyj
 */
public class TimestampColumnDecorator implements DisplaytagColumnDecorator, Comparator
{
   private Format format;
   public TimestampColumnDecorator()
   {
      this("dd-MMM-yyyy HH:mm:ss",Locale.US);
   }
   public TimestampColumnDecorator(String pattern, Locale locale)
   {
      format = new SimpleDateFormat(pattern,locale);
   }
   
   public Object decorate(Object columnValue, PageContext pageContext, MediaTypeEnum media)
   {
      if (columnValue == null) return null;
      try
      {
         if (columnValue instanceof oracle.sql.TIMESTAMP)
         {
            columnValue = ((oracle.sql.TIMESTAMP) columnValue).timestampValue();
         }
      }
      catch (SQLException x) { x.printStackTrace(); } 
      try
      {
         return format.format(columnValue);
      }
      catch (IllegalArgumentException x)
      {
         return columnValue;
      }
   }

   public int compare(Object o1, Object o2)
   {
      try
      {
         Timestamp ts1 = ((oracle.sql.TIMESTAMP) o1).timestampValue();
         Timestamp ts2 = ((oracle.sql.TIMESTAMP) o2).timestampValue();
         return ts1.compareTo(ts2);
      }
      catch (SQLException x) { return 0; } 
   }
}
