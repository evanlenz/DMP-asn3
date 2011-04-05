<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs">

  <xsl:output method="text"/>

  <xsl:variable name="event-groups">
    <event-group base="38" length="2"/>
    <event-group base="35" length="2"/>
    <event-group base="41" length="3" down="yes"/>
    <event-group base="30" length="1"/>
    <event-group base="30" length="1"/>
    <event-group base="43" length="4"/>
    <event-group base="40" length="1"/>
    <event-group base="40" length="1"/>
    <event-group base="38" length="1"/>
  </xsl:variable>

  <!-- Notes grouped in events -->
  <!-- TODO: add more info or structure here as necessary, to drive more
             rules to be written below -->
  <xsl:variable name="notes">
    <all>
      <xsl:apply-templates mode="event-group" select="$event-groups"/>
    </all>
  </xsl:variable>

          <xsl:template mode="event-group" match="event-group">
            <xsl:variable name="group"  select="."/>
            <xsl:variable name="length" select="@length"/>
            <xsl:variable name="down"   select="@down"/>
            <xsl:for-each select="1 to @length">
              <xsl:sort select="if (not($down)) then . else ($length - .)"/>
              <event pos="{.}" base="{$group/@base + .}">
                <xsl:for-each select="1 to 3">
                  <note pos="{.}"/>
                </xsl:for-each>
              </event>
            </xsl:for-each>
          </xsl:template>

  <xsl:template match="/">
    <xsl:result-document href="debug-tree.xml" method="xml" indent="yes">
      <xsl:copy-of select="$notes"/>
    </xsl:result-document>
    <xsl:text># This list was automatically generated using generate.xsl;&#xA;</xsl:text>
    <xsl:apply-templates select="$notes/all/event/note"/>
  </xsl:template>

  <xsl:template match="note">
    <xsl:apply-templates mode="msg-delay" select="."/>
    <xsl:text> note </xsl:text>
    <xsl:apply-templates mode="pitch"     select="."/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates mode="amplitude" select="."/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates mode="duration"  select="."/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates mode="sample"    select="."/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates mode="start"     select="."/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates mode="rise"      select="."/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates mode="decay"     select="."/>
    <xsl:text>;&#xA;</xsl:text> <!-- linefeed -->
  </xsl:template>


<!-- Below are all the rules for determining the various note parameters
     based on the position of the notes in the input (see $notes above) -->

<!-- TODO: Update and add more rules below that together define the final composition -->

  <!-- Delay at the beginning of each event -->
  <xsl:template mode="msg-delay" match="note[1]">3000</xsl:template>

  <!-- But don't delay the very first event -->
  <xsl:template mode="msg-delay" match="event[1]/note" priority="1">
    <xsl:text>    </xsl:text> <!-- for readability purposes only -->
  </xsl:template>

  <xsl:template mode="msg-delay" match="note">
    <xsl:text>    </xsl:text> <!-- for readability purposes only -->
  </xsl:template>


  <!-- Pitch is based only on position currently... -->
  <!--
  <xsl:template mode="pitch" match="note">
    <xsl:value-of select="50 + (@pos mod 20) + (../@pos * 2)"/>
  </xsl:template>
  -->
  <xsl:template mode="pitch" match="note[1]">
    <xsl:value-of select="../@base"/>
  </xsl:template>
  <xsl:template mode="pitch" match="note[2]">
    <xsl:value-of select="../@base + 10"/>
  </xsl:template>
  <xsl:template mode="pitch" match="note[3]">
    <xsl:value-of select="../@base + 25"/>
  </xsl:template>

  <!-- Constant amplitude for now -->
  <xsl:template mode="amplitude" match="note">110</xsl:template>

  <!-- Constant duration for now -->
  <xsl:template mode="duration" match="note">8000</xsl:template>

  <!-- we're only using one sample (numbered 1) -->
  <xsl:template mode="sample" match="note">1</xsl:template>


  <xsl:template mode="start" match="note">500</xsl:template>
  <xsl:template mode="rise"  match="note">1000</xsl:template>
  <xsl:template mode="decay" match="note">1000</xsl:template>

</xsl:stylesheet>
