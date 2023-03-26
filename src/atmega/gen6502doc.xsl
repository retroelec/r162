<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:output method="text"/>

  <xsl:template match="/procs">
    <xsl:text>## R162 ATMega service routines</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>### Service routines</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select="proc"/>
    <xsl:text>### Structures</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select="struct"/>
  </xsl:template>

  <xsl:template match="proc">
    <xsl:text>- **</xsl:text>
    <xsl:value-of select="name"/>
    <xsl:text>**: </xsl:text>
    <xsl:value-of select="desce"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select="input"/>
    <xsl:apply-templates select="output"/>
  </xsl:template>

  <xsl:template match="input">
    <xsl:text>  - input parameter</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select="rparam"/>
    <xsl:apply-templates select="mparam"/>
  </xsl:template>

  <xsl:template match="output">
    <xsl:text>  - output parameter</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select="rparam"/>
    <xsl:apply-templates select="mparam"/>
  </xsl:template>

  <xsl:template match="rparam">
    <xsl:text>    - register </xsl:text>
    <xsl:value-of select="name"/>
    <xsl:text>: </xsl:text>
    <xsl:value-of select="desce"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="mparam">
    <xsl:text>    - memory address </xsl:text>
    <xsl:value-of select="name"/>
    <xsl:text>: </xsl:text>
    <xsl:value-of select="desce"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="struct">
    <xsl:text>- **</xsl:text>
    <xsl:value-of select="name"/>
    <xsl:text>**&lt;div id="</xsl:text>
    <xsl:value-of select="name"/>
    <xsl:text>"&gt;&lt;/div&gt;&#10;</xsl:text>
    <xsl:apply-templates select="attr"/>
  </xsl:template>

  <xsl:template match="attr">
    <xsl:text>  - </xsl:text>
    <xsl:value-of select="name"/>
    <xsl:text>: </xsl:text>
    <xsl:value-of select="desce"/>
    <xsl:text> (offset=</xsl:text>
    <xsl:value-of select="offset"/>
    <xsl:text>, size=</xsl:text>
    <xsl:value-of select="size"/>
    <xsl:text>)</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
