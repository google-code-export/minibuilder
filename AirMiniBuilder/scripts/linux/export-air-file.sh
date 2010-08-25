#!/bin/sh

# edit path to your AIR SDK!
SDK=$HOME/bin/AdobeAIRSDK



cd `dirname $0`
HERE=`pwd`

# prepare output files - copy nonsource files to bin-debug
cd $HERE/../..
java -jar scripts/reccopy.jar src bin-debug

cd bin-debug
# package air
$SDK/bin/adt -package \
	-storetype pkcs12 -keystore $HERE/certificate.p12 -storepass pass \
	../release/AirMiniBuilder.air \
	*-app.xml \
	.

echo "package deb installer"
#package native
$SDK/bin/adt -package -target native \
	../release/AirMiniBuilder.deb \
	../release/AirMiniBuilder.air
