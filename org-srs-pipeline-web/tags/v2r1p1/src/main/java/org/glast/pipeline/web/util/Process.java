/*
 * Process.java
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
import org.glast.pipeline.web.util.Task;

/**
 *
 * @author dflath
 */
public class Process
{
   // primitives from DB record:
   private long processPK;
   private long taskPK;
   private String name;
   private String type;
 
   // high-level constructs:
   private Task task;
   private Map<Process, String> processStatusDependencyMap = new HashMap<Process, String>();
   private List<Process> processCompletionDependencyList = new ArrayList<Process>();
   private List<Task> subTaskCreationList = new ArrayList<Task>();
   
   
   
   /** Creates a new instance of Process */
   public Process(Task _task, ResultSet rs) throws SQLException {
      try {
         processPK = rs.getLong("PROCESS");
         taskPK = rs.getLong("TASK");
         name = rs.getString("PROCESSNAME");
         type = rs.getString("PROCESSTYPE");
         
         task = _task;
      } finally {};
   }

   public void buildProcessStatusDependencyList(Connection conn) throws SQLException {
      PreparedStatement stmt = conn.prepareStatement("select Process, ProcessingStatus from ProcessStatusCondition where DependentProcess = ?");
      try {
         stmt.setLong(1, getProcessPK());
         ResultSet rs = stmt.executeQuery();
         while (rs.next()) {
            Process p = getTask().findProcess(rs.getLong("PROCESS"));
            if (p != null)
               processStatusDependencyMap.put(p, rs.getString("PROCESSINGSTATUS"));
         }
      } finally {
         stmt.close();
      }
   }
   
   public void buildProcessCompletionDependencyList(Connection conn) throws SQLException {
      PreparedStatement stmt = conn.prepareStatement("select Process from ProcessCompletionCondition where DependentProcess = ?");
      try {
         stmt.setLong(1, getProcessPK());
         ResultSet rs = stmt.executeQuery();
         while (rs.next()) {
            Process p = getTask().findProcess(rs.getLong("PROCESS"));
            if (p != null)
               processCompletionDependencyList.add(p);
         }
      } finally {
         stmt.close();
      }
   }
   
   public void buildSubTaskCreationList(Connection conn) throws SQLException {
      PreparedStatement stmt = conn.prepareStatement("select SubTask from CreateSubTaskCondition where Process = ?");
      try {
         stmt.setLong(1, getProcessPK());
         ResultSet rs = stmt.executeQuery();
         while (rs.next()) {
            Task t = getTask().findTask(rs.getLong("SUBTASK"));
            if (t != null)
               subTaskCreationList.add(t);
         }
      } finally {
         stmt.close();
      }      
   }
   
   // field accessors:
   public Task getTask() { return task; }
   public String getType() { return type; }
   public String getName() { return name; }
   public long getProcessPK() { return processPK; }
   public Map<Process, String> getProcessStatusDependencyMap() { return processStatusDependencyMap; }
   public List<Process> getProcessCompletionDependencyList() { return processCompletionDependencyList; }
   public List<Task> getSubTaskCreationList() { return subTaskCreationList; }
      
   public void print(int depth) {
      String indent = "";
      for (int i=0; i<depth; i++) {
         indent += "    ";
      }
      System.out.println(indent + "Process(" + getName() + ") is:");
      indent += "  ";
      System.out.println(indent + "Type(" + getType().toString() + ")");
      
      // list processing status dependencies:
      for (Map.Entry<Process,String> e : getProcessStatusDependencyMap().entrySet()) {
         System.out.println(indent + "Requires " + e.getKey().getTask().getName() + "." + e.getKey().getName() + " " + e.getValue());
      }

      // list processing status dependencies:
      for (Process p : getProcessCompletionDependencyList()) { 
         System.out.println(indent + "Requires completion of all " + p.getTask().getName() + "." + p.getName());
      }
      
      // list SubTasks we can create:
      for (Task t : getSubTaskCreationList()) {
         System.out.println(indent + "Creates streams of Task(" + t.getName() + ")");
      }
   }
}
