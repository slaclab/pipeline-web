/*
 * Task.java
 *
 * Created on June 9, 2006, 1:09 PM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.glast.pipeline.web.util;

import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
      
import java.util.List;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import oracle.jdbc.pool.OracleDataSource;

/**
 *
 * @author dflath
 */
public class Task
{
   // primitives from db record:
   private int taskPK;
   private int parentTaskPK;
   private String name;
   private int version;
   private int revision;
   private String type;
   private String status;
   
   // high-level constructs:
   private Task parentTask;
   private Process creatingProcess;
   private List<Task> subTaskList = new ArrayList<Task>();
   private List<Process> processList = new ArrayList<Process>();

   protected void init(ResultSet rs, Connection conn) throws SQLException {
      taskPK = rs.getInt("TASK");
      parentTaskPK = rs.getInt("PARENTTASK");
      name = rs.getString("TASKNAME");
      version = rs.getInt("VERSION");
      revision = rs.getInt("REVISION");
      type = rs.getString("TASKTYPE");
      status = rs.getString("TASKSTATUS");
      
      // create sub-tasks:
      while(rs.next())
         subTaskList.add(new Task(rs,conn));
      
      // create processes:
      PreparedStatement stmt = conn.prepareStatement("select * from Process where Task = ?");
      try {
         stmt.setInt(1, taskPK);
         ResultSet processCursor = stmt.executeQuery();
         while (processCursor.next())
            processList.add(new Process(this, processCursor));
      } finally {
         stmt.close();
      }
   }
   
   protected Task(ResultSet rs, Connection conn) throws SQLException {
      init(rs, conn);
   }
   
   /** Creates a new instance of Task */
   public Task(int task_pk, Connection conn) throws Exception, SQLException
   {
      PreparedStatement stmt = conn.prepareStatement("select * from Task start with Task=? connect by prior Task = ParentTask");
      try {
         stmt.setInt(1, task_pk);
         ResultSet rs = stmt.executeQuery();
         if (rs.next()) {
           init(rs, conn);
         } else {
            throw(new Exception("Invalid task primary key[" + task_pk + "]!"));
         }
                  
         // Create Dependencies...
         calculateDependencies(conn);
         
      } finally {
         stmt.close();
      }
   }
   
   // field accessors:
   public Task getParentTask() { return parentTask; }
   public String getName() { return name; }
   public String getType() { return type; }
   public String getStatus() { return status; }
   public List<Task> getSubTaskList() { return subTaskList; } // TODO:  Should this return an iterator?
   public List<Process> getProcessList() { return processList; } // TODO:  Should this return an iterator?
   public int getDbTask() { return taskPK; }
   
   public Task findTask(int _dbTask) {
      // check if it's me:
      if (getDbTask() == _dbTask)
         return this;

      // not me, check children:
      for (Task _task : getSubTaskList()) {
         Task t = _task.findTask(_dbTask);
         if (t != null)
            return t;
      }
      
      // couldn't find it:
      return null;
   }
   
   public Process findProcess(int _dbProcess) {
      // try to find the process at this task level:
      for (Process _process : getProcessList()) {
         if (_process.getProcessPK() == _dbProcess) {
            return _process;
         }
      }
      
      // process is not at this task level, check sub tasks recursively:
      for (Task _task : getSubTaskList()) {
         Process p = _task.findProcess(_dbProcess);
         // don't want to kill recursion early, there may be more subTasks to check:
         if (p != null) 
            return p;
      }
      
      // we never found it.
      return null;
   }
   
   public void calculateDependencies(Connection conn) throws SQLException {
      try {
         // find process dependencies:
         for (Process p : getProcessList()) {
            p.buildDependencyList(conn);
            p.buildSubTaskCreationList(conn);
         }
      } finally {}
            
      // recurse down subTask chain:
      for (Task t : getSubTaskList())
         t.calculateDependencies(conn);
   }
   
   public void print() { print(0); }
   public void print(int depth) {
      String indent = "";
      for (int i=0; i<depth; i++) {
         indent += "    ";
      }
      System.out.println(indent + "Task(" + getName() + ") is:");
      indent += "  ";
      System.out.println(indent + "Type(" + getType() + ")");
      System.out.println(indent + "Status(" + getStatus() + ")");

      // tell Processes to print:
      if (getProcessList().size() > 0) {
         System.out.println(indent + "Processes:");
         for (Process process : getProcessList()) {
            process.print(depth + 1);
         }
      }
      
      // tell sub Tasks to print:
      if (getSubTaskList().size() > 0) {
         System.out.println(indent + "Sub-Tasks:");
         for (Task task : getSubTaskList()) {
            task.print(depth + 1);
         }
      }
   }
   
   int draw(Writer writer, String indent, int cluster, Map<Task, Process> subTaskCreatorMap) throws IOException 
   {
      String indentIn = indent; // save original indent for header and footer
      indent += "\t"; // indent body of this subgraph one more tab

      // draw task:
      writer.write(indentIn + "subgraph cluster" + cluster + " {\n"); // header (subgraph id)
      writer.write(indent + "label=\"" + getName() + "\";\n"); // title
      writer.write(indent + "color=blue;\n"); // for the border
      
      // draw processes:
      for (Process p : getProcessList()) {
         // name and label the node:
         writer.write(indent + p.getProcessPK() + " [label=\"" + p.getName() + "\"];\n");
         // connect, with edges, processes we depend upon:
         for (Map.Entry<Process, String> e: p.getProcessDependencyMap().entrySet()) {
            Process dp = e.getKey();
            writer.write(indent + dp.getProcessPK() + "->" + p.getProcessPK() + " [label=\"" + e.getValue() + "\"];\n");
         }
         
         // add a map entry for eatch SubTask this process can create streams for:
         for (Task t : p.getSubTaskCreationList()) {
            subTaskCreatorMap.put(t, p);
         }
      }

      // draw subTasks:
      for (Task t : getSubTaskList()) {
         cluster = t.draw(writer, indent, ++cluster, subTaskCreatorMap);
      }
                        
      writer.write(indentIn + "}\n"); // footer
      if (subTaskCreatorMap.containsKey(this)) {
         int someProc = getProcessList().get(0).getProcessPK();
         writer.write(indentIn + subTaskCreatorMap.get(this).getProcessPK() + " -> " + someProc + "[lhead=cluster"+ cluster +", style=dashed, color=red];\n");
         subTaskCreatorMap.remove(this);
      }

      return cluster;
   }
   
   public void draw(Writer writer) throws IOException {
      try {
         String indent = "\t";
         
         // write the header:
         writer.write("digraph G {\n");
         writer.write(indent + "compound=true;\n");

         // enter the recursive drawing routine:
         Map<Task, Process> subTaskCreatorMap = new HashMap<Task, Process>();
         draw(writer, indent, 0, subTaskCreatorMap);

         // write the footer:
         writer.write("}\n");
      } finally {
         writer.close();
      }
   }
   
   public static void main(String args[]) throws Exception, SQLException, IOException {
      try {
         OracleDataSource ds = new OracleDataSource();
         ds.setURL("jdbc:oracle:thin:@glast-oracle02.slac.stanford.edu:1521:GLASTDEV");
         String user = System.getProperty("db.username","GLAST_DP_TEST");
         String password = System.getProperty("db.username","BT33%Q9]MU");
         Connection conn =  ds.getConnection(user,password);
         conn.setAutoCommit(false);
         
         Task testTask = new Task(267, conn);
         
         // print it:
         testTask.print();
         
         // draw it to a file:
         FileWriter fw = new FileWriter("c:\\test.dot");
         testTask.draw(fw);
         
         // draw it to a string:
         StringWriter sw = new StringWriter();
         testTask.draw(sw);
         System.out.println(sw.toString()); // print StringWriter to stdout
         System.out.println(sw.toString());
         
         GraphViz gv = new GraphViz(null);
//         byte[] buf = gv.get_img_stream(new File("c:\\test.dot"));
         byte[] buf = gv.getGraph(sw.toString());
         FileOutputStream fos = new FileOutputStream("c:\\test.gif");
//         File f = new File("c:\\test.gif");
//         gv.writeGraphToFile(buf, f);
         fos.write(buf);
         fos.close();
      } finally {}
   }
   
}
