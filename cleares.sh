#!/bin/bash

cd Resources || exit
find . -type d -maxdepth 1 |grep -vFx "." |grep -vE "kext|CX8200" |xargs rm -rf
find . -name "layout*" |grep -v "layout3.xml" |xargs rm -f
find . -name "Platforms*" |grep -v "PlatformsM.xml" |xargs rm -f
for counter in {1..4}
do
    /usr/libexec/PlistBuddy -c "delete Files:Platforms:1" CX8200/Info.plist
    /usr/libexec/PlistBuddy -c "delete Files:Layouts:1" CX8200/Info.plist
done

counter=0
until ! Device=$(/usr/libexec/PlistBuddy -c "print :$counter:Device" Controllers.plist);
do
  if [ "$Device" -ne 40305 ] ;
  then
    /usr/libexec/PlistBuddy -c "delete :$counter" Controllers.plist
  else
    counter=$((counter + 1))
  fi
done

Vendors=$(/usr/libexec/PlistBuddy -c "print" Vendors.plist |grep "=" |awk '{print $1}')
for Vendor in $Vendors
do
  if [ "${Vendor}" != "Conexant" ] ;
  then
    /usr/libexec/PlistBuddy -c "delete $Vendor" Vendors.plist
  fi
done

counter=0
until ! CodecID=$(/usr/libexec/PlistBuddy -c "print IOKitPersonalities:as.vit9696.AppleALC:HDAConfigDefault:$counter:CodecID" PinConfigs.kext/Contents/Info.plist);
do
  if [ "$CodecID" -ne 351346696 ] ;
  then
    echo "$CodecID"
    /usr/libexec/PlistBuddy -c "delete IOKitPersonalities:as.vit9696.AppleALC:HDAConfigDefault:$counter" PinConfigs.kext/Contents/Info.plist
  else
    if [[ $(/usr/libexec/PlistBuddy -c "print IOKitPersonalities:as.vit9696.AppleALC:HDAConfigDefault:$counter:LayoutID" PinConfigs.kext/Contents/Info.plist) -ne 3 ]] ;
    then
      /usr/libexec/PlistBuddy -c "delete IOKitPersonalities:as.vit9696.AppleALC:HDAConfigDefault:$counter" PinConfigs.kext/Contents/Info.plist
    else
      counter=$((counter + 1))
    fi
  fi
done