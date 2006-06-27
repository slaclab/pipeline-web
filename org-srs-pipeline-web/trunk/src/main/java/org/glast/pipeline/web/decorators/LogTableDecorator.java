package org.glast.pipeline.web.decorators;

import java.util.Map;
import org.displaytag.decorator.TableDecorator;
/**
 * User to decorate the log viewer table
 * @author tonyj
 */
public class LogTableDecorator extends TableDecorator
{
   public String getException()
   {
      Map map = (Map) getCurrentRowObject();
      Number hasException = (Number) map.get("hasException");
      return hasException.intValue() == 0 ? "" : "<a href=\"exception.jsp?log="+map.get("log")+"\"><img src=\"img/error.gif\"></a>";
   }
   
}
