/*
 * GraphVizProperties.java
 *
 * Created on March 8, 2007, 11:19 AM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.srs.pipeline.web.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *
 * @author dflath
 */
public class GraphVizProperties {
   private interface GVProperty {
      public String propertyName();
      public String propertyString();
   };
   
   public static enum RankDir implements GVProperty {
      LR, TB;
      public String propertyName() {
         return "rankdir";
      }
      public String propertyString() {
         return propertyName() + "=\"" + this.toString() + "\"";
      }
   };
   
   private Map<String,GVProperty> propertyMap = new HashMap<String,GVProperty>();
   
   /** Creates a new instance of GraphVizProperties with default setup*/
   public GraphVizProperties() {
      addProperty(RankDir.TB);
   }
   
   public void addProperty(GVProperty property) {
      propertyMap.put(property.propertyName(), property); // use map to allow overwriting of default properties but no duplicates
   }

   public List<String> getProperties() {
      List propList = new ArrayList<String>();
      for (GVProperty prop : propertyMap.values())
         propList.add(prop.propertyString());
      return propList;
   }
}
