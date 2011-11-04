package org.srs.pipeline.web.decorators;

import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Locale;
import javax.servlet.jsp.PageContext;
import org.displaytag.decorator.DisplaytagColumnDecorator;
import org.displaytag.properties.MediaTypeEnum;
/**
 *
 * @author tonyj
 */
public class TimestampColumnDecorator implements DisplaytagColumnDecorator
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
         return format.format(columnValue);
      }
      catch (IllegalArgumentException x)
      {
         return columnValue;
      }
   }
}
