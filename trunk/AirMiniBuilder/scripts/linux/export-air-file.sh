#!/bin/sh

# edit path to your AIR SDK!
SDK=$HOME/bin/flex/air-sdk-1.5.3
APP_NAME="AirMiniBuilder"



cd `dirname $0`
HERE=`pwd`

# prepare output files - copy nonsource files to bin-debug
cd $HERE/../..
java -jar java/MBCompiler/reccopy.jar src bin-debug


cd bin-debug

$SDK/bin/adt -package \
	-storetype pkcs12 -keystore $HERE/certificate.p12 \
	../release/$APP_NAME.air \
	*-app.xml \
	.

