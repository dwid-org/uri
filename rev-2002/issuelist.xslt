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
      <xsl:if test="issuelist/title">
      <title>Issues List for the 
             <xsl:value-of select="issuelist/title" /></title>
      </xsl:if>
    </head>
    <body>
      <xsl:apply-templates/>
    </body>
  </html>
</xsl:template>

<xsl:template match="issuelist">
  <h1>Issues List for the <br />
      <xsl:apply-templates select="title" /></h1>

  <xsl:apply-templates select="links"/>
  <xsl:apply-templates select="summary"/>
  <xsl:apply-templates select="issue" mode="contents"/>
</xsl:template>

<xsl:template match="links">
  <ul>
  <xsl:for-each select="li">
    <xsl:copy-of select="."/>
  </xsl:for-each>
  </ul>
</xsl:template>

<xsl:template match="summary">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="section">
  <table border="1" width="100%" cellpadding="4">
    <tr>
      <th colspan="4" bgcolor="#FFFFCC" align="left"><font size="+2"><xsl:apply-templates select="title"/></font></th>
    </tr> 
    <tr>
      <th nowrap="nowrap">name</th>
      <th>title</th>
      <th>type</th>
      <th>status</th>
    </tr>
    <xsl:apply-templates select="status" mode="summary" />
  </table>
  <br />
</xsl:template>

<xsl:template match="status" mode="summary">
  <xsl:variable name="me"><xsl:value-of select="."/></xsl:variable>
  <xsl:apply-templates
       select="/issuelist/issue[status=$me]"
       mode="summary" />
</xsl:template>

<xsl:template match="/issuelist/issue[*]" mode="summary">
    <tr>
      <td nowrap="nowrap"><a href="#{name}"><xsl:apply-templates select="name" mode="summary"/></a></td>
      <td><xsl:apply-templates select="title" mode="summary"/></td>
      <td><xsl:value-of select="type"/></td>
      <td nowrap="nowrap"><xsl:value-of select="status"/></td>
    </tr>
</xsl:template>

<xsl:template match="issue" mode="contents">
  <br />
  <table border="1" width="100%" cellpadding="4">
  <tr>
   <th bgcolor="#FFFFCC"><font size="+2"><a name="{name}"><xsl:apply-templates select="name" mode="contents"/></a></font></th>
   <th bgcolor="#FFFFCC" align="left"><font size="+1"><xsl:apply-templates select="title" mode="contents"/></font></th>
  </tr>
  <tr>
   <xsl:apply-templates select="status" mode="contents"/>
   <th align="left"><xsl:apply-templates select="type" mode="contents"/></th>
  </tr>
  <xsl:apply-templates select="action|report"/>
  </table>
</xsl:template>

<xsl:template match="status" mode="contents">
  <xsl:choose>
    <xsl:when test="starts-with(.,'fixed') or starts-with(.,'added')">
    <th bgcolor="lightgreen"><xsl:value-of select="."/></th>
    </xsl:when>
    <xsl:when test="starts-with(.,'closed') or starts-with(.,'postponed')">
    <th bgcolor="lightgrey"><xsl:value-of select="."/></th>
    </xsl:when>
    <xsl:otherwise>
    <th><xsl:value-of select="."/></th>
    </xsl:otherwise>
  </xsl:choose>
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
