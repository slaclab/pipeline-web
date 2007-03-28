<%@page contentType="text/xml"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<?xml version="1.0" encoding="UTF-8"?>
<xs:schema targetNamespace="http://glast-ground.slac.stanford.edu/pipeline" 
           xmlns:xs="http://www.w3.org/2001/XMLSchema" 
           xmlns="http://glast-ground.slac.stanford.edu/pipeline" 
           elementFormDefault="qualified" 
           version="1.2"
>
   
   <xs:element name="pipeline">
      <xs:complexType>
         <xs:sequence>
            <xs:element ref="variables" minOccurs="0"/>  
            <xs:element ref="task" maxOccurs="unbounded"/>
         </xs:sequence>
      </xs:complexType>
   </xs:element>
   
   <xs:element name="variables">
      <xs:complexType>
         <xs:sequence>
            <xs:element ref="var" maxOccurs="unbounded"/>
         </xs:sequence>
      </xs:complexType>
   </xs:element>
   
   <xs:element name="var">
      <xs:complexType>
         <xs:simpleContent>
            <xs:extension base="xs:string">
               <xs:attribute name="name" type="NameType" use="required"/>
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
         <xs:attribute name="priority" type="StatusType"/>
      </xs:complexType>
   </xs:element>
   <xs:element name="process">
      <xs:complexType>
         <xs:sequence>
            <xs:element name="notation" type="NotationType" minOccurs="0"/>
            <xs:element ref="variables" minOccurs="0"/>
            <xs:choice>
               <xs:element ref="script"/>
               <xs:element ref="job"/>
            </xs:choice>
            <xs:element ref="depends" minOccurs="0"/>
            <xs:element ref="createsSubtasks" minOccurs="0"/>
         </xs:sequence>
         <xs:attribute name="name" type="NameType" use="required"/>
      </xs:complexType>
   </xs:element>
   <xs:element name="script">
      <xs:complexType mixed="true">
         <xs:attribute name="language" type="LanguageType" default="python"/>
      </xs:complexType>      
   </xs:element>
   <xs:element name="job">
      <xs:complexType  mixed="true">
         <xs:sequence>
            <xs:element ref="environment" minOccurs="0"/>
         </xs:sequence>
         <xs:attribute name="executable" type="PathType"/>
         <xs:attribute name="maxCPU" type="PathType"/>
         <xs:attribute name="maxWallClock" type="PathType"/>
         <xs:attribute name="maxMemory" type="PathType"/>
         <xs:attribute name="workingDir" type="PathType"/>
         <xs:attribute name="batchOptions" type="PathType"/>
         <xs:attribute name="queue" type="NameType"/>
         <xs:attribute name="allocationGroup" type="NameType"/>
         <xs:attribute name="jobName" type="PathType"/>
         <xs:attribute name="priority" type="NameType"/>
         <xs:attribute name="logFile" type="PathType"/>
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
         <sql:query var="data">select PROCESSINGSTATUS from PROCESSINGSTATUS</sql:query>
         <c:forEach var="row" items="${data.rows}">
            <xs:enumeration value="${row.PROCESSINGSTATUS}"/>
         </c:forEach> 
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
