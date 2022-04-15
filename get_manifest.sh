#! /bin/bash

# Asset Details
provider_id=V4K
#resource_id=TITL0000000001827829
resource_id=TITL0100000000028811
env=prod
#env=preprod
#env=ft

# General Details
mac_id=aa:bb:cc:dd:ee:ff
device=TiVoAdvert

# Environment Details
if [[ $env == prod ]]
then
  # prod
  server=$(grep $prod_server get_manifest.conf | cut -d= -f2)
  ms=$(grep $prod_ms get_manifest.conf | cut -d= -f2)
elif [[ $env == preprod ]]
then
  # preprod
  server=$(grep $preprod_server get_manifest.conf | cut -d= -f2)
  ms=$(grep $preprod_ms get_manifest.conf | cut -d= -f2)
elif [[ $env == ft ]]
then
  # ft
  server=$(grep $ft_server get_manifest.conf | cut -d= -f2)
  ms=$(grep $ft_ms get_manifest.conf | cut -d= -f2)
else
  echo "You done goofed, boy!"
fi

name=$(curl -s "http://${server}:8443/traxis/web/Title/crid:~~2F~~2Fschange.com~~2F${provider_id}~~2F${resource_id}/Props/Name" | grep Name | cut -d\> -f2 | cut -d\< -f1)
details=$(curl -s "http://${server}:8443/traxis/web/Title/crid:~~2F~~2Fschange.com~~2F${provider_id}~~2F${resource_id}/Contents/Props/Aliases" | tr -d '\r')
backoffice_id=$(echo $details | grep VodBackOfficeId | cut -d\> -f6- | cut -d\< -f1)

http --body  --follow "http://${ms}/sdash/${backoffice_id}/index.mpd/Manifest?providerID=${provider_id}&assetID=${resource_id}&macid=${mac_id}&device=${device}" --output manifest.xml --download
#http --body  --follow "http://${ms}/sdash/${backoffice_id}/index.mpd/Manifest?providerID=${provider_id}&assetID=${resource_id}&macid=${mac_id}&device=${device}"

#echo "http://${ms}/sdash/${backoffice_id}/index.mpd/Manifest?providerID=${provider_id}&assetID=${resource_id}&macid=${mac_id}&device=${device}"
# More generic, less pretty version
#curl -L "http://multiscreen-dash.vod.mspp.dtv.virginmedia.com/sdash/${backoffice_id}/index.mpd/Manifest?providerID=${provider_id}&assetID=${resource_id}&macid=${mac_id}&device=${device}"
