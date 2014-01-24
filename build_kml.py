#!/usr/bin/python

import sys
import os
import datetime

img_dir_base = sys.argv[1]

def ground_overlay(begin_date, end_date, img_file):
    return """
    <GroundOverlay>
        <name>{0}</name>
        <TimeSpan>
            <begin>{0}</begin>
            <end>{1}</end>
        </TimeSpan>
        <Icon>
           <href>{2}</href>
        </Icon>
        <LatLonBox>
           <north>90.0</north>
           <south>-90.0</south>
           <east>-180.0</east>
           <west>180.0</west>
        </LatLonBox>
     </GroundOverlay>""".format(begin_date, end_date, img_file)

def screen_overlay(begin_date, end_date, img_file):
    return """
    <ScreenOverlay>
        <name>{0}</name>
        <TimeSpan>
            <begin>{0}</begin>
            <end>{1}</end>
        </TimeSpan>
        <Icon>
           <href>{2}</href>
        </Icon>
        <color>DDFFFFFF</color>
        <overlayXY x="1.0" y="0.0" xunits="fraction" yunits="fraction"/>
        <screenXY x="1.0" y="0.0" xunits="fraction" yunits="fraction"/>
        <size x="0.33" y="0" xunits="fraction" yunits="fraction"/>
     </ScreenOverlay>""".format(begin_date, end_date, img_file)

def header(name, img_file):
    return """
    <ScreenOverlay>
        <name>{}</name>
        <Icon>
           <href>{}</href>
        </Icon>
        <color>DDFFFFFF</color>
        <overlayXY x="0.5" y="1.0" xunits="fraction" yunits="fraction"/>
        <screenXY x="0.5" y="1.0" xunits="fraction" yunits="fraction"/>
        <size x="-1" y="-1" xunits="fraction" yunits="fraction"/>
     </ScreenOverlay>""".format(name, img_file)

def legend(name, img_file):
    return """
    <ScreenOverlay>
        <name>{}</name>
        <Icon>
           <href>{}</href>
        </Icon>
        <overlayXY x="0.0" y="0.0" xunits="fraction" yunits="fraction"/>
        <screenXY x="0.0" y="0.0" xunits="fraction" yunits="fraction"/>
        <size x="0" y="0.2" xunits="fraction" yunits="fraction"/>
     </ScreenOverlay>""".format(name, img_file)

def build_ground_overlays(scenario_name, start_year, end_year, img_dir):
    file = "NCCCSM_SR{}_1_tas-change_{}-{}.jpg".format(scenario_name.upper(),
                                                       start_year, end_year)

    formatted_begin_date = datetime.date(start_year, 1, 1).strftime("%Y-%m")
    formatted_end_date = datetime.date(end_year, 12, 31).strftime("%Y-%m")

    print ground_overlay(formatted_begin_date, formatted_end_date, os.path.join(img_dir, file))

def scenario(name, description=''):
    img_dir = os.path.join(img_dir_base, name.upper())
    
    print """<Folder>
    <name>Scenario {}</name>
    <description>{}</description>
    <styleUrl>#scenario</styleUrl>
    """.format(name.upper(), description)

    print header("Header", os.path.join(img_dir, 'header.png'))

    print """<Folder>
    <name>Overlays</name>
    <styleUrl>#hide-children</styleUrl>
    """

    build_ground_overlays(name, 2010, 2030, img_dir)
    build_ground_overlays(name, 2031, 2045, img_dir)
    build_ground_overlays(name, 2046, 2065, img_dir)
    build_ground_overlays(name, 2066, 2079, img_dir)
    build_ground_overlays(name, 2080, 2110, img_dir)

    print "</Folder>"

    print """<Folder>
    <name>Population chart</name>
    <styleUrl>#hide-children</styleUrl>
    """

    for year in range(2010, 2101, 10):
        file = "plot-{0}.png".format(year)

        formatted_begin_date = datetime.date(year, 1, 1).strftime("%Y-%m")
        formatted_end_date = datetime.date(year + 10, 12, 1).strftime("%Y-%m")

        print screen_overlay(formatted_begin_date, formatted_end_date, os.path.join(img_dir, file))

    print "</Folder>"        
    print "</Folder>"

print """<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
  <name>IPCC Climate Scenarios</name>
  <open>1</open>

  <author>
      <name>Parker Abercrombie</name>
      <uri>http://pabercrombie.com</uri>
      <email>parker@pabercrombie.com</email>
  </author>

  <Style id="scenarioContainer">
    <ListStyle>
      <listItemType>radioFolder</listItemType>
    </ListStyle>
  </Style>

  <Style id="scenario">
    <BalloonStyle>
        <text><![CDATA[
        <h1>$[name]</h1>

        <p>$[description]</p>

        <p>For more information see <a href='http://sedac.ipcc-data.or/Users/parker/projects/school/ge510/project/Makefileg/ddc/sres/index.html'>ipcc-data.org</a></p>
        ]]></text>
    </BalloonStyle>
  </Style>

  <Style id="hide-children">
      <ListStyle>
          <listItemType>checkHideChildren</listItemType>
      </ListStyle>
  </Style>

  <Camera>
      <gx:TimeStamp>
        <when>2011-01-01T05:00:00-08:00</when>
      </gx:TimeStamp>
      <longitude>-100</longitude>
      <latitude>37</latitude>
      <altitude>10000000.0</altitude>
  </Camera>
"""

print """<Folder>
    <name>Scenarios</name>
    <open>1</open>
    <styleUrl>#scenarioContainer</styleUrl>
"""

a1b_description = """Scenario A1B is a future world of very rapid economic growth.
Global population peaks mid-century. New, efficient techologies
are rapidly introduced."""
a2_description = """A future world of regionally oriented economic growth,
and increasing global population. Economic growth is more fragmented and
slower than in other scenarios."""
b1_description = """Scenario B1 is a convergent world with same population as in
A1B. Rapid shift toward a service and information economy, with reductions
in material intensity, and the introduction of clean and resource-efficient technologies."""


scenario('a1b', a1b_description)
scenario('a2', a2_description)
scenario('b1', b1_description)
print "</Folder>"

print legend("Legend", os.path.join(img_dir_base, 'legend.jpg'))

print "</Document></kml>"
