<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="iso-8859-1"
  doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
  doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>

<!-- issuelist.xslt: process an issuelist in XML and output XHTML
     Created by Roy Fielding and Julian Reschke
  -->

<xsl:template match="/">
  <html>
    <head>
      <xsl:if test="/issuelist/title">
      <title>Issue list: <xsl:value-of select="/issuelist/title" /></title>
      </xsl:if>
    </head>
    <body>
      <xsl:apply-templates/>
    </body>
  </html>
</xsl:template>

<xsl:template match="issuelist">
  <h1>Issue List</h1>
  <h2><xsl:apply-templates select="title" /></h2>
  <table border="1" width="100%" cellpadding="4">
    <tr>
      <th nowrap="nowrap">name</th>
      <th>title</th>
      <th>type</th>
      <th>status</th>
    </tr>
   <xsl:for-each select="issue">
     <xsl:if test="status='accepted'">
    <tr>
      <td nowrap="nowrap"><a href="#{name}"><xsl:value-of select="name"/></a></td>
      <td><xsl:value-of select="title"/></td>
      <td><xsl:value-of select="type"/></td>
      <td><xsl:value-of select="status"/></td>
    </tr>
     </xsl:if>
   </xsl:for-each>
   <xsl:for-each select="issue">
     <xsl:if test="status='pending'">
    <tr>
      <td nowrap="nowrap"><a href="#{name}"><xsl:value-of select="name"/></a></td>
      <td bgcolor="#FFFFCC"><xsl:value-of select="title"/></td>
      <td><xsl:value-of select="type"/></td>
      <td><xsl:value-of select="status"/></td>
    </tr>
     </xsl:if>
   </xsl:for-each>
   <xsl:for-each select="issue">
     <xsl:if test="status!='pending' and status!='accepted'">
    <tr>
      <td nowrap="nowrap"><a href="#{name}"><xsl:value-of select="name"/></a></td>
      <td><xsl:value-of select="title"/></td>
      <td><xsl:value-of select="type"/></td>
      <td><xsl:value-of select="status"/></td>
    </tr>
     </xsl:if>
   </xsl:for-each>
  </table>
  <xsl:apply-templates select="issue" />
</xsl:template>

<xsl:template match="issue">
  <br />
  <h2><a name="{name}"><xsl:apply-templates select="name"/></a>: 
      <xsl:apply-templates select="title"/></h2>
  <table border="1" width="100%" cellpadding="4">
  <tr>
   <th width="40%"><xsl:apply-templates select="type"/></th>
   <th><xsl:apply-templates select="status"/></th>
  </tr>
  <xsl:apply-templates select="action|report"/>
  </table>
</xsl:template>

<xsl:template match="action|report">
  <tr><td colspan="2">
  <xsl:value-of select="local-name()"/>:
  <a href="mailto:{author/@email}"><xsl:value-of select="author"/></a>,
  <xsl:value-of select="date"/>,
  <xsl:value-of select="where"/>:
  <xsl:copy-of select="pre"/>
  </td></tr>
</xsl:template>

</xsl:transform>
