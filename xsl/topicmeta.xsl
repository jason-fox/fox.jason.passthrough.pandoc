<?xml version="1.0" encoding="UTF-8"?>
<!--
  This file is part of the DITA-OT Pandoc DITA Plug-in project.
  See the accompanying LICENSE file for applicable licenses.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output omit-xml-declaration="yes" indent="no"  method="text"/>

<xsl:template match="topicmeta|metadata|keywords">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="*">
   <xsl:text> -M </xsl:text>
   <xsl:value-of select="name()"/>
   <xsl:text>="</xsl:text>
   <xsl:value-of select="."/>
   <xsl:text>"</xsl:text>
</xsl:template>

<xsl:template match="data">
 <xsl:text> -M </xsl:text>
   <xsl:value-of select="@name"/>
   <xsl:text>="</xsl:text>
   <xsl:value-of select="@value"/>
   <xsl:text>"</xsl:text>
</xsl:template>

<xsl:template match="permissions">
 <xsl:text> -M permissions="</xsl:text>
   <xsl:value-of select="@view"/>
   <xsl:text>"</xsl:text>
</xsl:template>

<xsl:template match="resourceid">
 <xsl:text> -M resourceid="</xsl:text>
   <xsl:value-of select="@appid"/>
   <xsl:text>"</xsl:text>
</xsl:template>

<xsl:template match="text()"/>


</xsl:stylesheet>