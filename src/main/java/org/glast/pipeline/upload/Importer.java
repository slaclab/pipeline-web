package org.glast.pipeline.upload;

import java.io.IOException;
import java.io.Reader;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.Namespace;
import org.jdom.input.SAXBuilder;

/**
 * Imports an XML file into the pipeline database
 * @author tonyj
 * @version $Id: Importer.java,v 1.2 2006-02-01 21:49:22 tonyj Exp $
 */
public class Importer
{
   public void execute(Connection connection, String userName, Reader xml) throws SQLException, JDOMException, IOException
   {
      DatabaseUtilities dbu = new DatabaseUtilities(connection);
      
      SAXBuilder builder = new SAXBuilder(true);
      builder.setFeature("http://apache.org/xml/features/validation/schema", true);
      Document doc = builder.build(xml);
      Element pipeline = doc.getRootElement();
      
      int user_pk = -1;
      try
      {
         user_pk = dbu.getGlastUser_PKByName(userName);
      }
      catch (SQLException x)
      {
         user_pk = dbu.createGlastUser(userName);
      }
      
      Namespace ns = pipeline.getNamespace();
      
      String taskName = pipeline.getChildTextNormalize("name",ns);
      int taskType = dbu.getTaskTypeByName(pipeline.getChildTextNormalize("type",ns));
      String datasetBasePath = pipeline.getChildTextNormalize("dataset-base-path",ns);
      String runLogPath = pipeline.getChildTextNormalize("run-log-path",ns);
      String comment = pipeline.getChildTextNormalize("notation",ns);
      
      int oldTask_pk;
      try
      {
         oldTask_pk = dbu.getTaskPKByName(taskName);
      }
      catch (SQLException x)
      {
         oldTask_pk = 0;
      }
      if (oldTask_pk != 0) dbu.deleteTaskByPK(oldTask_pk);
      
      int task_pk = dbu.createTask(user_pk,taskName,taskType,comment,datasetBasePath,runLogPath);
      
      Map<String,Integer> dsMap = new HashMap<String,Integer>();
      List<Element> files = (List<Element>) pipeline.getChildren("file",ns);
      for (Element file : files)
      {
         String name = file.getAttributeValue("name");
         int dstype_fk = dbu.getDSTypeByName(file.getAttributeValue("type"));
         int dsFileType_fk = dbu.getDSFileTypeByName(file.getAttributeValue("file-type"));
         String filePath = file.getChildTextNormalize("path",ns);
         if (filePath == null || filePath.length() == 0) filePath = file.getTextNormalize(); // 1.0 compatibility
         if (filePath == null || filePath.length() == 0) filePath = "/"; // 1.0 compatibility
         String fileComment = file.getChildTextNormalize("notation",ns);
         int ds_pk = dbu.createDataset(task_pk, dstype_fk, dsFileType_fk, name, filePath, user_pk, fileComment);
         dsMap.put(name,ds_pk);
      }
      
      List<Element> foreignFiles = (List<Element>) pipeline.getChildren("foreign-input-file",ns);
      for (Element file : foreignFiles)
      {
         String name = file.getAttributeValue("name");
         String foreignPipeline = file.getAttributeValue("pipeline");
         String foreignName = file.getAttributeValue("file");
         try
         {
            int ds_pk = dbu.getForeignDataset(foreignPipeline,foreignName);
            dsMap.put(name,ds_pk);
         }
         catch (SQLException x)
         {
            throw new JDOMException("Count not find dataset "+foreignName+" in pipline "+foreignPipeline,x);
         }
      }
      
      int sequence = 1;
      List<Element> steps = (List<Element>) pipeline.getChildren("processing-step",ns);
      for (Element step : steps)
      {
         String taskProcessName = step.getAttributeValue("name");
         String appName = step.getAttributeValue("executable");
         String batchConfig = step.getAttributeValue("batch-job-configuration");
         String processComment = step.getChildTextNormalize("notation",ns);
         
         Element executable = findChild(pipeline,"executable",appName);
         String appVersion = executable.getAttributeValue("version");
         String command = executable.getTextNormalize();
         
         Element batchJobConfiguration = findChild(pipeline,"batch-job-configuration",batchConfig);
         int group_fk = dbu.getBatchGroupByName(batchJobConfiguration.getAttributeValue("group"));
         int queue_fk = dbu.getBatchQueueByName(batchJobConfiguration.getAttributeValue("queue"));
         String workingDirectory = batchJobConfiguration.getChildTextNormalize("working-directory",ns);
         String batchLogPath = batchJobConfiguration.getChildTextNormalize("log-file-path",ns);
         
         int process_pk = dbu.createTaskProcess(task_pk,taskProcessName,sequence++,appName,appVersion,command, queue_fk, group_fk, batchLogPath, user_pk, processComment, workingDirectory);
         
         List<Element> inputFiles = (List<Element>) step.getChildren("input-file",ns);
         addFiles(dbu,process_pk,dsMap,inputFiles,true);
         
         List<Element> outputFiles = (List<Element>) step.getChildren("output-file",ns);
         addFiles(dbu,process_pk,dsMap,outputFiles,false);
      }
   }
   private void addFiles(DatabaseUtilities dbu, int process_pk, Map<String,Integer> dsMap,  List<Element> files, boolean read) throws SQLException
   {
      for (Element file : files)
      {
         String fileName = file.getAttributeValue("name");
         int ds_pk = dsMap.get(fileName);
         dbu.insertTP_DS(process_pk,ds_pk,read);
      }
   }
   private Element findChild(Element parent, String name, String attributeValue) throws JDOMException
   {
      List<Element> children = (List<Element>) parent.getChildren(name,parent.getNamespace());
      for (Element child : children)
      {
         if (attributeValue.equals(child.getAttributeValue("name"))) return child;
      }
      throw new JDOMException("No "+name+" element with name="+attributeValue+" found.");
   }
}
