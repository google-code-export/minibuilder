#!/bin/sh

# edit path to your AIR SDK!
SDK=$HOME/bin/flex/air-sdk-1.5.3

cd `dirname $0`/../../bin-debug
$SDK/bin/adl AirMiniBuilder-app.xml
