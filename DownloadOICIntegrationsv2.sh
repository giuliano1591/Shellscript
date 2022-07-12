#!/bin/bash

echo "Download OIC integrations"
echo " * Current Version 1.3 * "
#
# History
# =====================================
# Version 1.0  Matias Gallinoti
# Version 1.1 Tomas Eugez / Giuliano Valentinuzzi
# Version 1.2 Tomas Eugez / Giuliano Valentinuzzi
# =====================================

[ ! -d "INTEGRATIONS/" ] && mkdir -p "INTEGRATIONS/"
[ ! -d "JSON_LIST/" ] && mkdir -p "JSON_LIST/"
[ ! -d "INTEGRATION_LIST/" ] && mkdir -p "INTEGRATION_LIST/"
#valida que no exista la carpeta INTEGRATIONS, si no existe la crea.

#change your own credentials and url for use.



user=$1  
pass=$2
url=$3


sup1=/ic/api/integration/v1/integrations
urlfull1=$url$sup1
userpass=""$user:$pass""; 

position=1
cant=1
curl --user ""$userpass""  -i -X GET -H "Accept:application/json" "$urlfull1?offset=$position&limit=$cant" >> responseOriginal_withHeader.json;

VarTotalResult=$(tail -1 responseOriginal_withHeader.json | jq '.totalResults ')   #giu: asigno a variable el json sin el header http y a su vez le busco el item totalresult que la cantidad totalResults
					
position=2
while(($position <= $VarTotalResult))
do
	echo -e "Van descargando: $position integraciones. de  un total de $VarTotalResult................\n"

	curl --user ""$userpass""  -i -X GET -H "Accept:application/json" "$urlfull1?offset=$position&limit=$cant" >> responseOriginal_withHeader.json;
	tail -1 responseOriginal_withHeader.json >>responseOriginal_NoHeader.json;
	jq '.items | .[] | .id,.status ' responseOriginal_NoHeader.json | sed 's/"//g' | sed 's/|/%7C/' >>resultIdIntegrations2014v2.txt;  #giu: recupera de la integracion  del json y lo coloca en el file de salida para dsp buscarlo

	while read line
	do
		newname=${line/'%7C'/#}

		read lineStatus
		echo $newname $lineStatus

		if [ "${lineStatus}" = "ACTIVATED" ]; then
			sup2=/ic/api/integration/v1/integrations/$line/archive
			urlfull2=$url$sup2
		
			#curl --user $userpass -i -X GET -o $newname.iar $urlfull2
			echo Dowloading... $newname
			curl --user ""$userpass"" -i -X GET -o $newname.iar $urlfull2
		else
			echo NO Dowloading... $newname
		fi
	done < resultIdIntegrations2014v2.txt
	
	mv *.iar  INTEGRATIONS/ 2>/dev/null
	mv *.json JSON_LIST/ 2>/dev/null
	mv *.txt  INTEGRATION_LIST/ 2>/dev/null

	position=$(($position+1))
done

#todos los archivos descargardos los muevo a sus respectivas carpetas para ordenar

echo -e "Descarga finalizada exitosamente. \n"
#rm responseOriginal16v2.json
#rm responseOriginal17v2.json
#rm resultIdIntegrations2014v2.txt

#https://amysimpsongrange.com/2021/08/11/oic-integration-lifecycle-using-rest/
