/*
 * ProcessInstanceInstance.java
 */

package org.glast.pipeline.web.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.glast.pipeline.web.util.Stream;

/**
 *
 * @author dflath
 */
public class ProcessInstance
{
   // primitives from DB record:
   private int processInstancePK;
   private int streamPK;
   private int processPK;
   private String status;
   private String name;
   private String type;
 
   // high-level constructs:
   private Stream stream;
   private Map<ProcessInstance, String> processInstanceStatusDependencyMap = new HashMap<ProcessInstance, String>();
   private List<ProcessInstance> processInstanceCompletionDependencyList = new ArrayList<ProcessInstance>();
   private List<Stream> subStreamCreationList = new ArrayList<Stream>();
   
   
   
   /** Creates a new instance of ProcessInstance */
   public ProcessInstance(Stream stream, ResultSet rs) throws SQLException {
      try {
         processInstancePK = rs.getInt("PROCESSINSTANCE");
         streamPK = rs.getInt("STREAM");
         processPK = rs.getInt("PROCESS");
         status = rs.getString("PROCESSINGSTATUS");
         name = rs.getString("PROCESSNAME");
         type = rs.getString("PROCESSTYPE");
         
         this.stream = stream;
      } finally {};
   }

   public void buildProcessInstanceStatusDependencyList(Connection conn) throws SQLException {
      PreparedStatement stmt = conn.prepareStatement("select PI.ProcessInstance, PSC.ProcessingStatus from ProcessInstance PI, Process P, ProcessStatusCondition PSC where PI.Process = P.Process and P.Process = PSC.Process and PSC.DependentProcess = ? and (PI.Stream = ? or PI.Stream in (select Stream from Stream where ParentStream = ?))");
      try {
         stmt.setInt(1, getProcessPK());
         stmt.setInt(2, getStreamPK());
         stmt.setInt(3, getStreamPK());
         ResultSet rs = stmt.executeQuery();
         while (rs.next()) {
            ProcessInstance p = getStream().findProcessInstance(rs.getInt("PROCESSINSTANCE"));
            if (p != null)
               processInstanceStatusDependencyMap.put(p, rs.getString("PROCESSINGSTATUS"));
         }
      } finally {
         stmt.close();
      }
   }
   
   public void buildProcessInstanceCompletionDependencyList(Connection conn) throws SQLException {
      PreparedStatement stmt = conn.prepareStatement("select PI.ProcessInstance from ProcessInstance PI, Process P, ProcessCompletionCondition PCC where PI.Process = P.Process and P.Process = PCC.Process and PCC.DependentProcess = ? and (PI.Stream = ? or PI.Stream in (select Stream from Stream where ParentStream = ?))");
      try {
         stmt.setInt(1, getProcessPK());
         stmt.setInt(2, getStreamPK());
         stmt.setInt(3, getStreamPK());
         ResultSet rs = stmt.executeQuery();
         while (rs.next()) {
            ProcessInstance p = getStream().findProcessInstance(rs.getInt("PROCESSINSTANCE"));
            if (p != null)
               processInstanceCompletionDependencyList.add(p);
         }
      } finally {
         stmt.close();
      }
   }
   
   public void buildSubStreamCreationList(Connection conn) throws SQLException {
      PreparedStatement stmt = conn.prepareStatement("select S.Stream from Stream S, Task T, CreateSubTaskCondition CSTC where S.Task = T.Task and T.Task = CSTC.SubTask and CSTC.Process = ? and S.ParentStream = ?");
      try {
         stmt.setInt(1, getProcessPK());
         stmt.setInt(2, getStreamPK());
         ResultSet rs = stmt.executeQuery();
         while (rs.next()) {
            Stream t = getStream().findStream(rs.getInt("STREAM"));
            if (t != null)
               subStreamCreationList.add(t);
         }
      } finally {
         stmt.close();
      }      
   }
   
   // field accessors:
   public Stream getStream() { return stream; }
   public String getType() { return type; }
   public String getName() { return name; }
   public String getStatus() { return status; };
   public int getProcessInstancePK() { return processInstancePK; }
   public int getProcessPK() { return processPK; }
   public int getStreamPK() { return streamPK; }
   public Map<ProcessInstance, String> getProcessInstanceStatusDependencyMap() { return processInstanceStatusDependencyMap; }
   public List<ProcessInstance> getProcessInstanceCompletionDependencyList() { return processInstanceCompletionDependencyList; }
   public List<Stream> getSubStreamCreationList() { return subStreamCreationList; }
      
   public void print(int depth) {
      String indent = "";
      for (int i=0; i<depth; i++) {
         indent += "    ";
      }
      System.out.println(indent + "ProcessInstance(" + getName() + ") is:");
      indent += "  ";
      System.out.println(indent + "Type  (" + getType() + ")");
      System.out.println(indent + "Status(" + getStatus() + ")");
      
      // list processInstanceing status dependencies:
      for (Map.Entry<ProcessInstance,String> e : getProcessInstanceStatusDependencyMap().entrySet()) {
         System.out.println(indent + "Requires " + e.getKey().getStream().getName() + "." + e.getKey().getName() + " " + e.getValue());
      }

      // list processInstanceing status dependencies:
      for (ProcessInstance p : getProcessInstanceCompletionDependencyList()) { 
         System.out.println(indent + "Requires completion of " + p.getStream().getName() + "." + p.getName());
      }
      
      // list SubStreams we can create:
      for (Stream s : getSubStreamCreationList()) {
         System.out.println(indent + "Created sub-Stream(" + s.getName() + ")");
      }
   }
}
