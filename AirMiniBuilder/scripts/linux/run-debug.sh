#!/bin/sh

# edit path to your AIR SDK!
SDK=$HOME/bin/AdobeAIRSDK

cd `dirname $0`/../../bin-debug
$SDK/bin/adl AirMiniBuilder-app.xml
