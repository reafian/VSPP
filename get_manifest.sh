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
  ms=$(grep ${env}_ms get_manifest.conf | cut -d= -f2)
elif [[ $env == preprod ]]
then
  # preprod
  ms=$(grep ${env}_ms get_manifest.conf | cut -d= -f2)
elif [[ $env == ft ]]
then
  # ft
  ms=$(grep ${env}_ms get_manifest.conf | cut -d= -f2)
else
  echo "You done goofed, boy!"
fi

echo "Remeber to use ssh ppfe (or whatever) to make the connection to Traxis"
echo "Gotta love VPN changes that break things..."

#
http --body  --follow "http://${ms}/sdash/${backoffice_id}/index.mpd/Manifest?providerID=${provider_id}&assetID=${resource_id}&macid=${mac_id}&device=${device}" --output manifest.xml --download