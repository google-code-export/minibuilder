#!/bin/sh

# edit path to your AIR SDK!
SDK=$HOME/bin/flex/air-sdk-1.5.3



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

