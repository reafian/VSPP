#! /bin/bash

# Asset Details
provider_id=CHA
#resource_id=TITL0000000001827829
resource_id=TITL0200000004553465
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

echo "Remeber to use ssh ppfe (or whatever) to make the connection to Traxis"
echo "Gotta love VPN changes that break things..."

details=$(curl -s "http://${server}:8443/traxis/web/Title/crid:~~2F~~2Fschange.com~~2F${provider_id}~~2F${resource_id}/Contents/Props/Aliases" | tr -d '\r')

echo $details | grep -q ERestServcieResourceNotFound
if [[ $? == 0 ]]
then
  echo "An error occurred: The file does not exist in Adrenalin."
  exit 1
fi

echo $details | grep -q 'resultCount="0"'
if [[ $? == 0 ]]
then
  echo "An error occurred: There are not assets with these attributes."
  exit 1
fi

name=$(curl -s "http://${server}:8443/traxis/web/Title/crid:~~2F~~2Fschange.com~~2F${provider_id}~~2F${resource_id}/Props/Name" | grep Name | cut -d\> -f2 | cut -d\< -f1)
backoffice_id=$(echo $details | grep VodBackOfficeId | cut -d\> -f6- | cut -d\< -f1)
echo Fetching $name using a backoffice_id of: $backoffice_id
#
#http --body  --follow "http://${ms}/sdash/${backoffice_id}/index.mpd/Manifest?providerID=${provider_id}&assetID=${resource_id}&macid=${mac_id}&device=${device}" --output manifest.xml --download
curl -s -o "${name}.xml" -L "http://${ms}/sdash/${backoffice_id}/index.mpd/Manifest?providerID=${provider_id}&assetID=${resource_id}&macid=${mac_id}&device=${device}"

echo "File written to: ${name}.xml"