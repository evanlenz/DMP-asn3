<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs">

  <xsl:output method="text"/>

  <!-- Here's the whole piece, using my ad hoc language for describing it -->
  <xsl:variable name="event-groups">
    <event-group base="60" length="1" single-voice="yes"/>

    <event-group base="38" length="1" delay="6000"/>
    <event-group base="39" length="1"/>
    <event-group base="35" length="2"/>
    <event-group base="41" length="3" down="yes"/>
    <event-group base="30" length="1"/>
    <event-group base="30" length="1"/>
    <event-group base="43" length="4"/>
    <event-group base="40" length="1"/>
    <event-group base="40" length="1"/>
    <event-group base="38" length="1"/>

    <event-group base="47" length="1" delay="7500"/>
    <event-group base="46" length="1"/>
    <event-group base="45" length="1"/>
    <event-group base="44" length="1"/>
    <event-group base="44" length="3" down="yes"/>
    <event-group base="38" length="1"/>
    <event-group base="38" length="2" down="yes"/>
    <event-group base="37" length="1"/>
    <event-group base="37" length="1"/>
    <event-group base="37" length="1" delay="4000"/>
    <event-group base="37" length="1" delay="4000"/>
  </xsl:variable>

  <!-- Notes grouped in events -->
  <xsl:variable name="notes">
    <all>
      <xsl:apply-templates mode="event-group" select="$event-groups"/>
    </all>
  </xsl:variable>

          <!-- Expand an event-group into one or more (ascending or descending) events -->
          <xsl:template mode="event-group" match="event-group">
            <xsl:variable name="group"  select="."/>
            <xsl:variable name="length" select="@length"/>
            <xsl:variable name="down"   select="@down"/>
            <xsl:for-each select="1 to @length">
              <!-- ascending or descending -->
              <xsl:sort select="if (not($down)) then . else ($length - .)"/>
              <event base="{$group/@base + .}">
                <xsl:copy-of select="$group/@delay"/>
                <xsl:for-each select="if ($group/@single-voice) then 1 else (1 to 3)">
                  <note/>
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


  <!-- Render each note as a message in the qlist -->
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


<!-- Below are all the rules for determining the various note parameters -->

  <!-- Default delay at the beginning of each event -->
  <xsl:template mode="msg-delay" match="note[1]">3000</xsl:template>

  <!-- But don't delay the very first event -->
  <xsl:template mode="msg-delay" match="event[1]/note" priority="1">
    <xsl:text>    </xsl:text> <!-- for readability purposes only -->
  </xsl:template>

  <!-- If a delay is explicitly specified, then use it -->
  <xsl:template mode="msg-delay" match="event[@delay]/note[1]" priority="2">
    <xsl:value-of select="../@delay"/>
  </xsl:template>

  <!-- Otherwise, don't insert a delay (the note is to be played simultaneously with the previous one) -->
  <xsl:template mode="msg-delay" match="note">
    <xsl:text>    </xsl:text> <!-- for readability purposes only -->
  </xsl:template>


  <!-- Pitch is whatever @base is, plus fixed intervals above it (triads) -->
  <xsl:template mode="pitch" match="note[1]">
    <xsl:value-of select="../@base"/>
  </xsl:template>
  <xsl:template mode="pitch" match="note[2]">
    <xsl:value-of select="../@base + 10"/>
  </xsl:template>
  <xsl:template mode="pitch" match="note[3]">
    <xsl:value-of select="../@base + 25"/>
  </xsl:template>


  <!-- Constant amplitude; mitigated by natural amplitude changes at different frequencies -->
  <xsl:template mode="amplitude" match="note">110</xsl:template>


  <!-- Constant duration for notes -->
  <xsl:template mode="duration" match="note">8000</xsl:template>

  <!-- Except for the last chord, which lasts longer -->
  <xsl:template mode="duration" match="event[last()]/note">12000</xsl:template>


  <!-- We're only using one sample (numbered 1) -->
  <xsl:template mode="sample" match="note">1</xsl:template>


  <!-- Start a half second into our sample audio file in each case -->
  <xsl:template mode="start" match="note">500</xsl:template>


  <!-- Relatively long rise and decay times help with the molasses-like feel -->
  <xsl:template mode="rise"  match="note">1000</xsl:template>
  <xsl:template mode="decay" match="note">1000</xsl:template>

  <!-- Last chord fades out for longer -->
  <xsl:template mode="decay" match="event[last()]/note">4000</xsl:template>

</xsl:stylesheet>
