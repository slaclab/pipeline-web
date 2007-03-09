/*
 * Task.java
 */

package org.glast.pipeline.web.util;

import java.io.ByteArrayOutputStream;
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
   private long taskPK;
   private long parentTaskPK;
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

   protected void init(ResultSet rs, Connection conn, Task parentTask) throws SQLException {
      taskPK = rs.getLong("TASK");
      parentTaskPK = rs.getLong("PARENTTASK");
      name = rs.getString("TASKNAME");
      version = rs.getInt("VERSION");
      revision = rs.getInt("REVISION");
      type = rs.getString("TASKTYPE");
      status = rs.getString("TASKSTATUS");
      
      this.parentTask = parentTask;
      
      // create processes:
      PreparedStatement stmt = conn.prepareStatement("select * from Process where Task = ?");
      try {
         stmt.setLong(1, taskPK);
         ResultSet processCursor = stmt.executeQuery();
         while (processCursor.next())
            processList.add(new Process(this, processCursor));
      } finally {
         stmt.close();
      }
   }
   
   protected Task(ResultSet rs, Connection conn, Task parentTask) throws SQLException {
      init(rs, conn, parentTask);
   }
   
   /** Creates a new instance of Task */
   public Task(long task_pk, Connection conn) throws SQLException
   {
      PreparedStatement stmt = conn.prepareStatement("select * from Task start with Task=? connect by prior Task = ParentTask");
      try {
         stmt.setLong(1, task_pk);
         ResultSet rs = stmt.executeQuery();
         if (rs.next()) {
            init(rs, conn, null);
            while (rs.next()) {
               Task t = this.findTask(rs.getLong("PARENTTASK"));
               t.getSubTaskList().add(new Task(rs,conn,t));
            }
         } else {
            throw(new RuntimeException("Invalid task primary key[" + task_pk + "]!"));
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
   public long getDbTask() { return taskPK; }
   public long getDbParentTask() { return parentTaskPK; }
   
   public Task findTask(long _dbTask) {
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
   
   public Process findProcess(long _dbProcess) {
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
            p.buildProcessStatusDependencyList(conn);
            p.buildProcessCompletionDependencyList(conn);
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
      int myCluster = cluster; // save my cluster value to draw a link to the process that creates me.

      String indentIn = indent; // save original indent for header and footer
      indent += "\t"; // indent body of this subgraph one more tab
      
      // draw task:
      writer.write(indentIn + "subgraph cluster" + cluster + " {\n"); // header (subgraph id)
      writer.write(indent + "label=\"" + getName() + "\";\n"); // title
      writer.write(indent + "color=blue;\n"); // for the border
      writer.write(indent + "URL=\"task.jsp?task="+taskPK+"\";\n");
      
      // draw processes:
      for (Process p : getProcessList()) {
         // name and label the node:
         writer.write(indent + p.getProcessPK() + " [label=\"" + p.getName() + "\", URL=\"process.jsp?process="+p.getProcessPK()+"\" ];\n");
         // connect, with edges, processes we depend upon:
         for (Map.Entry<Process, String> e: p.getProcessStatusDependencyMap().entrySet()) {
            Process dp = e.getKey();
            writer.write(indent + dp.getProcessPK() + "->" + p.getProcessPK() + " [label=\"" + e.getValue() + "\",fontsize=8];\n");
         }
         // connect, with edges, processes we depend on the completion of:
         for (Process dp : p.getProcessCompletionDependencyList()) {
            writer.write(indent + dp.getProcessPK() + "->" + p.getProcessPK() + " [label=\"ALL DONE\",fontsize=8];\n");
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
         long someProc = getProcessList().get(0).getProcessPK();
         writer.write(indentIn + subTaskCreatorMap.get(this).getProcessPK() + " -> " + someProc + "[lhead=cluster"+ myCluster +", style=dashed, color=red];\n");
         subTaskCreatorMap.remove(this);
      }

      return cluster;
   }

   public void draw(Writer writer, GraphVizProperties gvProperties) throws IOException {
      try {
         String indent = "\t";
         
         // write the header:
         writer.write("digraph G {\n");
         writer.write(indent + "compound=true;\n");
         if (gvProperties == null)
            gvProperties = new GraphVizProperties();

         for (String prop : gvProperties.getProperties())
            writer.write(indent+prop+";\n");
         
         // enter the recursive drawing routine:
         Map<Task, Process> subTaskCreatorMap = new HashMap<Task, Process>();
         draw(writer, indent, 0, subTaskCreatorMap);

         // write the footer:
         writer.write("}\n");
      } finally {
         writer.close();
      }
   }
   
   public void draw(Writer writer) throws IOException {
      draw(writer, new GraphVizProperties());
   }
   
   public static void main(String args[]) throws Exception, SQLException, IOException {
     OracleDataSource ds = new OracleDataSource();
     ds.setURL("jdbc:oracle:thin:@glast-oracle02.slac.stanford.edu:1521:GLASTDEV");
     String user = System.getProperty("db.username","GLAST_DP_TEST");
     String password = System.getProperty("db.username","BT33%Q9]MU");
     Connection conn =  ds.getConnection(user,password);
     conn.setAutoCommit(false);

     Task testTask = new Task(48087, conn);

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
     ByteArrayOutputStream bytes = gv.getGraph(sw.toString());
     FileOutputStream fos = new FileOutputStream("c:\\test.gif");
     bytes.writeTo(fos);
     fos.close();
     bytes = gv.getGraph(sw.toString(),GraphViz.Format.CMAP);
     fos = new FileOutputStream("c:\\test.map");
     bytes.writeTo(fos);
     fos.close();
   }
}
