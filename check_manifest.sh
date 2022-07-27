#! /bin/bash

# Asset Details
provider_id=CHA
#provider_id=UKT
resource_id=TITL0200000004553465
#resource_id=TITL0000000001853962
#env=prod
env=preprod
#env=ft

# General Details
mac_id=aa:bb:cc:dd:ee:ff
device=TiVoAdvert

# Environment Details
if [[ $env == prod ]]
then
  # prod
  #  server=$(grep ${env}_server get_manifest.conf | cut -d= -f2)
  server="localhost"
  ms=$(grep ${env}_ms get_manifest.conf | cut -d= -f2)
elif [[ $env == preprod ]]
then
  # preprod
  #  server=$(grep ${env}_server get_manifest.conf | cut -d= -f2)
  server="localhost"
  ms=$(grep ${env}_ms get_manifest.conf | cut -d= -f2)
elif [[ $env == ft ]]
then
  # ft
  #  server=$(grep ${env}_server get_manifest.conf | cut -d= -f2)
  server="localhost"
  ms=$(grep ${env}_ms get_manifest.conf | cut -d= -f2)
else
  echo "You done goofed, boy!"
fi

name=$(curl -s "http://${server}:8443/traxis/web/Title/crid:~~2F~~2Fschange.com~~2F${provider_id}~~2F${resource_id}/Props/Name" | grep Name | cut -d\> -f2 | cut -d\< -f1)
details=$(curl -s "http://${server}:8443/traxis/web/Title/crid:~~2F~~2Fschange.com~~2F${provider_id}~~2F${resource_id}/Contents/Props/Aliases" | tr -d '\r')
backoffice_id=$(echo $details | grep VodBackOfficeId | cut -d\> -f6- | cut -d\< -f1)
breakpoints=$(echo $details | grep "Genre:other" | cut -d\> -f10- | cut -d\< -f1)
echo Programme = $name 
echo Breakpoints = $breakpoints
echo
echo Manifest
echo ========
echo
#
http --body  --follow "http://multiscreen-dash.vod.mspp.dtv.virginmedia.com/sdash/${backoffice_id}/index.mpd/Manifest?providerID=${provider_id}&assetID=${resource_id}&macid=${mac_id}&device=${device}"

# More generic, less pretty version
#curl -L "http://multiscreen-dash.vod.mspp.dtv.virginmedia.com/sdash/${backoffice_id}/index.mpd/Manifest?providerID=${provider_id}&assetID=${resource_id}&macid=${mac_id}&device=${device}"
