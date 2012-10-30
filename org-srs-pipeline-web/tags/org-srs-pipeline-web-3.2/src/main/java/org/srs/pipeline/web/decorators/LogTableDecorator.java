package org.srs.pipeline.web.decorators;

import java.util.Map;
import org.displaytag.decorator.TableDecorator;
import org.srs.pipeline.web.util.Util;
/**
 * Used to decorate the log viewer table
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
   public String getTaskLinkPath()
   {
      Map map = (Map) getCurrentRowObject();
      Object path = map.get("taskPath");
      if (path != null)
      {
         Object namePath = map.get("taskNamePath");
         return Util.linkToTasks(namePath.toString(),path.toString(),".","task.jsp?task=");
      }
      else return null;
   }
}
