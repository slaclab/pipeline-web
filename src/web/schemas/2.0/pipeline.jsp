<%@page contentType="text/xml"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<?xml version="1.0" encoding="UTF-8"?>
<xs:schema targetNamespace="http://glast-ground.slac.stanford.edu/pipeline" 
           xmlns:xs="http://www.w3.org/2001/XMLSchema" 
           xmlns="http://glast-ground.slac.stanford.edu/pipeline" 
           elementFormDefault="qualified" 
           version="1.2.1">
   <xs:element name="pipeline">
      <xs:annotation>
         <xs:documentation>Defines one or more Pipeline II tasks, as well as global variables</xs:documentation>
      </xs:annotation>
      <xs:complexType>        
         <xs:sequence>
            <xs:element ref="variables" minOccurs="0">
               <xs:annotation>
                  <xs:documentation>Variables defined here apply to all tasks and all processes.</xs:documentation>
               </xs:annotation>
            </xs:element>
            <xs:element ref="task" maxOccurs="unbounded">
               <xs:annotation>
                  <xs:documentation>Defines one or more top level tasks.</xs:documentation>
               </xs:annotation>
            </xs:element>
         </xs:sequence>
      </xs:complexType>
   </xs:element>
   <xs:element name="variables">
      <xs:annotation>
         <xs:documentation>Variables can be defined at the pipeline level, the task level, or within a process.</xs:documentation>
      </xs:annotation>
      <xs:complexType>
         <xs:sequence>
            <xs:element ref="var" maxOccurs="unbounded">
               <xs:annotation>
                  <xs:documentation>Define one or more variables.</xs:documentation>
               </xs:annotation>               
            </xs:element>
         </xs:sequence>
      </xs:complexType>
   </xs:element>
   <xs:element name="var">
      <xs:annotation>
         <xs:documentation>Each variable has a name and a value. The type of the variable is determined 
            based on its value and usage. Variables may be defined in terms of other variables using the 
            $\{n+1\} syntax.
         </xs:documentation>
      </xs:annotation>
      <xs:complexType>
         <xs:simpleContent>
            <xs:extension base="xs:string">
               <xs:attribute name="name" type="NameType" use="required">
                  <xs:annotation>
                     <xs:documentation>The name of the variable.</xs:documentation>
                  </xs:annotation>
               </xs:attribute>
            </xs:extension>
         </xs:simpleContent>
      </xs:complexType>
   </xs:element>
   <xs:element name="prerequisites">
      <xs:complexType>
         <xs:sequence>
            <xs:element ref="prerequisite" maxOccurs="unbounded"/>
         </xs:sequence>
      </xs:complexType>
   </xs:element>
   <xs:element name="prerequisite">
      <xs:complexType>
         <xs:attribute name="name" type="NameType" />
         <xs:attribute name="type" type="VarType" />
      </xs:complexType>
   </xs:element>
   <xs:element name="environment">
      <xs:complexType>
         <xs:sequence>
            <xs:element ref="var" maxOccurs="unbounded"/>
         </xs:sequence>
      </xs:complexType>
   </xs:element>
   <xs:element name="task">
      <xs:complexType>
         <xs:sequence>
            <xs:element name="notation" type="NotationType" minOccurs="0"/>
            <xs:element ref="variables" minOccurs="0"/>
            <xs:element ref="prerequisites" minOccurs="0"/>
            <xs:element ref="process" maxOccurs="unbounded"/>
            <xs:element ref="task" minOccurs="0" maxOccurs="unbounded"/>
         </xs:sequence>
         <xs:attribute name="name" type="NameType" use="required"/>
         <xs:attribute name="type" type="TaskType" use="required"/>
         <xs:attribute name="version" type="VersionType" default="1.0"/>
         <xs:attribute name="priority" type="PriorityType"/>
      </xs:complexType>
   </xs:element>
   <xs:element name="process">
      <xs:annotation>
         <xs:documentation>A executable process, either a script or a job.</xs:documentation>
      </xs:annotation>  
      <xs:complexType>
         <xs:sequence>
            <xs:element name="notation" type="NotationType" minOccurs="0">
               <xs:annotation>
                  <xs:documentation>A comment to be associated with this process.</xs:documentation>
               </xs:annotation>  
            </xs:element>
            <xs:element ref="variables" minOccurs="0">
               <xs:annotation>
                  <xs:documentation>Variables defined within the scope of this process.</xs:documentation>
               </xs:annotation>  
            </xs:element>            
            <xs:choice>
               <xs:element ref="script"/>
               <xs:element ref="job"/>
            </xs:choice>
            <xs:element ref="depends" minOccurs="0">
               <xs:annotation>
                  <xs:documentation>Indicates a process which this process depends on.</xs:documentation>
               </xs:annotation>  
            </xs:element>
            <xs:element ref="createsSubtasks" minOccurs="0">
               <xs:annotation>
                  <xs:documentation>Indicates that this process can create subtasks.</xs:documentation>
               </xs:annotation>  
            </xs:element>
         </xs:sequence>
         <xs:attribute name="name" type="NameType" use="required"/>
         <xs:attribute name="autoRetryMaxAttempts" use="optional" default="0"/>
      </xs:complexType>
   </xs:element>
   <xs:element name="script">
      <xs:complexType mixed="true">
         <xs:attribute name="language" type="LanguageType" default="python"/>
      </xs:complexType>      
   </xs:element>
   <xs:element name="job">
      <xs:annotation>
         <xs:documentation>A batch job. The job may specify either a command to be executed, or may contain
            an embedded bash script.
         </xs:documentation>
      </xs:annotation>  
      <xs:complexType  mixed="true">
         <xs:sequence>
            <xs:element ref="environment" minOccurs="0"/>
         </xs:sequence>
         <xs:attribute name="executable" type="PathType">
            <xs:annotation>
               <xs:documentation>The command to be executed. If specified this will be used instead of any embedded script.</xs:documentation>
            </xs:annotation>  
         </xs:attribute>
         <xs:attribute name="maxCPU" type="PathType">
            <xs:annotation>
               <xs:documentation>The maximum CPU for the job in seconds.</xs:documentation>
            </xs:annotation>  
         </xs:attribute>
         <xs:attribute name="maxWallClock" type="PathType">
            <xs:annotation>
               <xs:documentation>The maximum wall clock time for the job in seconds.</xs:documentation>
            </xs:annotation>  
         </xs:attribute>
         <xs:attribute name="maxMemory" type="PathType">
            <xs:annotation>
               <xs:documentation>The maximum memory to be used (in MBytes).</xs:documentation>
            </xs:annotation>  
         </xs:attribute>
         <xs:attribute name="workingDir" type="PathType">
            <xs:annotation>
               <xs:documentation>The working directory to be used by the job.</xs:documentation>
            </xs:annotation>  
         </xs:attribute>
         <xs:attribute name="batchOptions" type="PathType">
            <xs:annotation>
               <xs:documentation>Additional options to be passed to the job.</xs:documentation>
            </xs:annotation>  
         </xs:attribute>
         <xs:attribute name="queue" type="PathType">
            <xs:annotation>
               <xs:documentation>The queue to which the job will be submitted.</xs:documentation>
            </xs:annotation>  
         </xs:attribute>
         <xs:attribute name="allocationGroup" type="PathType">
            <xs:annotation>
               <xs:documentation>The allocation group to be used for the job.</xs:documentation>
            </xs:annotation>  
         </xs:attribute>
         <xs:attribute name="jobName" type="PathType">
            <xs:annotation>
               <xs:documentation>The name of the job.</xs:documentation>
            </xs:annotation>  
         </xs:attribute>
         <xs:attribute name="priority" type="PathType">
            <xs:annotation>
               <xs:documentation>The priority for the job.</xs:documentation>
            </xs:annotation>  
         </xs:attribute>
         <xs:attribute name="logFile" type="PathType">
            <xs:annotation>
               <xs:documentation>The location where the log file should be saved.</xs:documentation>
            </xs:annotation>  
         </xs:attribute>
      </xs:complexType>
   </xs:element>
   <xs:element name="depends">
      <xs:complexType>
         <xs:sequence>
            <xs:element ref="before" minOccurs="0" maxOccurs="unbounded"/>
            <xs:element ref="after"  minOccurs="0" maxOccurs="unbounded"/>
         </xs:sequence>
      </xs:complexType>      
   </xs:element>
   <xs:element name="createsSubtasks">
      <xs:complexType>
         <xs:sequence>
            <xs:element name="subtask" type="PathType" minOccurs="0" maxOccurs="unbounded"/>
         </xs:sequence>
      </xs:complexType>      
   </xs:element>
   <xs:element name="before">
      <xs:complexType>
         <xs:attribute name="process" type="PathType"  use="required"/>
         <xs:attribute name="status"  type="StatusType" default="SUCCESS"/>
      </xs:complexType>         
   </xs:element>
   <xs:element name="after">
      <xs:complexType>
         <xs:attribute name="process" type="PathType"   use="required"/>
         <xs:attribute name="status"  type="StatusType" default="SUCCESS"/>
      </xs:complexType>         
   </xs:element>
   <xs:simpleType name="LanguageType">
      <xs:restriction base="xs:NMTOKEN">
         <xs:enumeration value="python"/>
      </xs:restriction>
   </xs:simpleType>
   <xs:simpleType name="NameType">
      <xs:restriction base="xs:string">
         <xs:minLength value="1"/>
         <xs:maxLength value="30"/>
      </xs:restriction>
   </xs:simpleType>
   <xs:simpleType name="TaskType">
      <xs:restriction base="xs:string">
         <sql:query var="data">select TASKTYPE from TASKTYPE</sql:query>
         <c:forEach var="row" items="${data.rows}">
            <xs:enumeration value="${row.TASKTYPE}"/>
         </c:forEach> 
      </xs:restriction>
   </xs:simpleType>
   <xs:simpleType name="NotationType">
      <xs:restriction base="xs:string">
         <xs:minLength value="1"/>
         <xs:maxLength value="200"/>
      </xs:restriction>
   </xs:simpleType>
   <xs:simpleType name="PathType">
      <xs:restriction base="xs:string">
         <xs:minLength value="1"/>
         <xs:maxLength value="256"/>
      </xs:restriction>
   </xs:simpleType>
   <xs:simpleType name="StatusType">
      <xs:restriction base="xs:string">
         <xs:enumeration value="DONE"/>
         <sql:query var="data">select PROCESSINGSTATUS from PROCESSINGSTATUS</sql:query>
         <c:forEach var="row" items="${data.rows}">
            <xs:enumeration value="${row.PROCESSINGSTATUS}"/>
         </c:forEach> 
      </xs:restriction>
   </xs:simpleType>
      <xs:simpleType name="PriorityType">
      <xs:restriction base="xs:integer">
      </xs:restriction>
   </xs:simpleType>
   <xs:simpleType name="VarType">
      <xs:restriction base="xs:NMTOKEN">
         <sql:query var="data">select VARTYPE from VARTYPE</sql:query>
         <c:forEach var="row" items="${data.rows}">
            <xs:enumeration value="${fn:toLowerCase(row.VARTYPE)}"/>
         </c:forEach>   
      </xs:restriction>
   </xs:simpleType>
   <xs:simpleType name="VersionType">
      <xs:restriction base="xs:string">
         <xs:minLength value="1"/>
         <xs:maxLength value="12"/>
      </xs:restriction>
   </xs:simpleType>
</xs:schema>