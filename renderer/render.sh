#!/bin/bash

### HOW TO USE
# execute this command with
# ./render.sh run LATITUDE,LONGITUDE RADIUS STYLE_FILE [debug]
#
# Latitude and longitude must be english decimal
# numbers and the radius is given in km.
#

#export MAPBOX_TOKEN="pk.eyJ1IjoiZ2VvcmcxMjMiLCJhIjoiY2p0eWJuM2ViMTIxaTQ0cGZ6d2w3ZXgyNyJ9.UJUBiIs0kfL3WmShaxANOA"
source token.sh

echo "Using token:" $MAPBOX_TOKEN

function render_map() {
  style="$(pwd)/$3"
  echo "Using style file:" $style
  
  [[ "$4" == "debug" ]] && debug="--debug"
  
  export-map "$style" -w=120in -h=166in -d=50 \
    -b=$2 -t=$MAPBOX_TOKEN -o=$1 $debug
}

# first parameter is the center seperated by ','
# second parameter is the radius
function get_coordinates() {
  lat_c=$(echo $1 | cut -d "," -f 1)
  long_c=$(echo $1 | cut -d "," -f 2)

  # https://www.movable-type.co.uk/scripts/latlong.html

  arr=($(python3 <<< "
from math import *

lat_c=$lat_c
long_c=$long_c 
dist=$2

def calc(angle, distance=dist):
  ad = distance / 6378
  lat_r = lat_c / 180 * pi
  long_r = long_c / 180 * pi

  lat_n  = asin(sin(lat_r) * cos(ad) + cos(lat_r) * sin(ad) * cos(angle))
  long_n = long_r + atan2(sin(angle) * sin(ad) * cos(lat_r), cos(ad) - sin(lat_r) * sin(lat_n))

  lat_n = lat_n * 180 / pi
  long_n = long_n * 180 / pi

  return (lat_n, long_n)


def p(t):
  print('\n'.join(map(str, t)))

lat_c, long_c = calc(pi, dist*0.17)

p(calc(0))
p(calc(pi/2))
p(calc(pi))
p(calc(3*pi/2))
"))
  echo "${arr[7]},${arr[4]},${arr[3]},${arr[0]}"
}


function render_poster() {
  folder="../originals/"
  # if [[ ! -e "../build" ]]; then
  #   echo "There's no build folder"
  #   exit 1
  # fi

  mkdir $folder

  # 0. render map
  render_map "$folder/map.png" $1 $2 $3
}
  
if [[ "$1" == "run" ]]; then
  coords=$(get_coordinates $2 $3)
  # echo $coords
  render_poster $coords $4 $5
fi
