#!/bin/sh
TEXTURE_TOOL=/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/texturetool

$TEXTURE_TOOL -e PVRTC --bits-per-pixel-2 -o "$SRCROOT/Resources/butterfly_2.pvr" -f PVR "$SRCROOT/Resources/butterfly.png"
$TEXTURE_TOOL -e PVRTC --bits-per-pixel-4 -o "$SRCROOT/Resources/butterfly_4.pvr" -f PVR "$SRCROOT/Resources/butterfly.png"
