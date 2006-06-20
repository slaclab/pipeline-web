/*
 * Process.java
 *
 * Created on June 9, 2006, 1:09 PM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
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
   private int processPK;
   private int taskPK;
   private String name;
   private String type;
   private String code;
 
   // high-level constructs:
   private Task task;
   private Map<Process, String> processDependencyMap = new HashMap<Process, String>();
   private List<Task> subTaskCreationList = new ArrayList<Task>();
   
   
   
   /** Creates a new instance of Process */
   public Process(Task _task, ResultSet rs) throws SQLException {
      try {
         processPK = rs.getInt("PROCESS");
         taskPK = rs.getInt("TASK");
         name = rs.getString("PROCESSNAME");
         type = rs.getString("PROCESSTYPE");
         code = rs.getString("PROCESSCODE");
         
         task = _task;
      } finally {};
   }

   public void buildDependencyList(Connection conn) throws SQLException {
      PreparedStatement stmt = conn.prepareStatement("select Process, ProcessingStatus from ProcessStatusCondition where DependentProcess = ?");
      try {
         stmt.setInt(1, getProcessPK());
         ResultSet rs = stmt.executeQuery();
         while (rs.next()) {
            Process p = getTask().findProcess(rs.getInt("PROCESS"));
            if (p != null)
               processDependencyMap.put(p, rs.getString("PROCESSINGSTATUS"));
         }
      } finally {
         stmt.close();
      }
   }
   
   public void buildSubTaskCreationList(Connection conn) throws SQLException {
      PreparedStatement stmt = conn.prepareStatement("select SubTask from CreateSubTaskCondition where Process = ?");
      try {
         stmt.setInt(1, getProcessPK());
         ResultSet rs = stmt.executeQuery();
         while (rs.next()) {
            Task t = getTask().findTask(rs.getInt("SUBTASK"));
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
   public String getCode() { return code; }
   public int getProcessPK() { return processPK; }
   public Map<Process, String> getProcessDependencyMap() { return processDependencyMap; }
   public List<Task> getSubTaskCreationList() { return subTaskCreationList; }
      
   public void print(int depth) {
      String indent = "";
      for (int i=0; i<depth; i++) {
         indent += "    ";
      }
      System.out.println(indent + "Process(" + getName() + ") is:");
      indent += "  ";
      System.out.println(indent + "Type(" + getType().toString() + ")");
      
      // format and print process code:
      System.out.println(indent + "{");
      String prettyCode = indent + "  " + getCode();  // first line
      prettyCode = prettyCode.replace("\n", "\n" + indent + "  "); // subsequent lines
      System.out.println(prettyCode);
      System.out.println(indent + "}");
      
      // list dependencies:
      for (Map.Entry<Process,String> e : getProcessDependencyMap().entrySet()) {
         System.out.println(indent + "Requires " + e.getKey().getTask().getName() + "." + e.getKey().getName() + " " + e.getValue());
      }
      
      // list SubTasks we can create:
      for (Task t : getSubTaskCreationList()) {
         System.out.println(indent + "Creates streams of Task(" + t.getName() + ")");
      }
   }
}
