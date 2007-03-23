package org.glast.pipeline.web.decorators;

import java.util.logging.Level;
import javax.servlet.jsp.PageContext;
import org.displaytag.decorator.DisplaytagColumnDecorator;
import org.displaytag.properties.MediaTypeEnum;
/**
 *
 * @author tonyj
 */
public class LogLevelColumnDecorator implements DisplaytagColumnDecorator
{
   public Object decorate(Object columnValue, PageContext pageContext, MediaTypeEnum media)
   {
      return Level.parse(columnValue.toString());
   }
}
