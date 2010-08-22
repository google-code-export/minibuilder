#!/bin/sh

# edit path to your AIR SDK!
SDK=$HOME/bin/AdobeAIRSDK

echo "Creating certificate, this might take a while..."
$SDK/bin/adt -certificate -cn minibuilder 1024-RSA certificate.p12 pass
