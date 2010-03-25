#!/bin/sh

# edit path to your AIR SDK!
SDK=$HOME/bin/flex/air-sdk-1.5.3

echo "Creating certificate, this might take a while..."
$SDK/bin/adt -certificate -cn minibuilder 1024-RSA certificate.p12 pass
