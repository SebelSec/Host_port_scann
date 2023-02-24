#!/bin/bash


base_ifaces=$(ifconfig | grep flags | grep -v "LOOPBACK" | cut -d ":" -f1)
menuOpt=""
selectedIface="No seleccionado"   #Interfaz seleccionada sin mas detalles


function selectIface(){  #Función que selecciona la interfaz
    clear
    declare -i index=0  
    declare -i number=0

    echo -e "------Interfaces disponibles-------\n"

    listed_ifaces=$(echo -e "$base_ifaces" | while read line; do
        index+=1
        echo "[$index] --> $line"
    done
    )

    echo $listed_ifaces
    echo -e "\n[0] Atras.. "
    echo -e "\n" 
    echo -e "-----------------------------------\n"
    echo -e "[!] Seleccione interfaz por número \n"

    read number

    selectedIface="$( echo $listed_ifaces | grep -F "[$number]" | awk '{print $3}')" #Al grepear [$number], no falla la validación

    if [ $number -eq 0 ]; then
        selectedIface="No seleccionado"
        read -rs -p"Presiona una tecla para continuar";echo
        clear
    elif [ ${#selectedIface} -gt 0 ]; then
        clear
        echo -e "\n [!] La interfaz seleccionada es [${selectedIface}] \n"
        read -rs -p"Presiona una tecla para continuar";echo
        clear
    else
        echo "[!] No existe la interfaz"
        selectedIface="No seleccionado"
        read -rs -p"Presiona una tecla para continuar";echo
        clear
        selectIface
    fi
}  

function ifaceInfo(){  #Muestra información de la interfaz

    if [ "$selectedIface" != "No seleccionado" ];
    then
        ip=$(ifconfig $selectedIface | head -n 2 | tail -n 1 | awk '{print $2}')
        #netmask=$(ifconfig $selectedIface | head -n 2 | tail -n 1 | awk '{print $4}')
        netmask="255.255.0.0" #Prueba con mascara 254
        declare -i oct1=$(echo "$netmask" | cut -d "." -f1 )
        declare -i oct2=$(echo "$netmask" | cut -d "." -f2 )
        declare -i oct3=$(echo "$netmask" | cut -d "." -f3 )
        declare -i oct4=$(echo "$netmask" | cut -d "." -f4 )
        netIndex=0
        netIndexPos=0  #de 1-4 (cantidad de octetos)
        netHostOct=0  #(cantidad de octetos de host)
        hostCant=0
        


        if [ $oct1 -ne 255 ] && [ $oct1 -ne 0 ]; then
            netIndex=$oct1
            netIndexPos=1
        elif [ $oct2 -ne 255 ] && [ $oct2 -ne 0 ]; then
            netIndex=$oct2
            netIndexPos=2
        elif [ $oct3 -ne 255 ] && [ $oct3 -ne 0 ]; then
            netIndex=$oct3
            netIndexPos=3
        elif [ $oct4 -ne 255 ] && [ $oct4 -ne 0 ]; then
            netIndex=$oct4
            netIndexPos=4
        fi


        if [ $netIndex -ne 0 ]; then  #Calculamos rango max de segmentos

            let netSegs="255 - $netIndex"
        else
            let netSegs=0
            netIndexPos="Solo un segmento de red (No hay índice)"

        fi

        if [ $oct2 -eq 0 ]; then
            netHostOct=3
        elif [ $oct3 -eq 0 ]; then
            netHostOct=2
        elif [ $oct4 -eq 0 ]; then
            netIndex=$oct4
            netHostOct=1
        fi

        let cantSegs="$netSegs + 1";
        let hostCant="$cantSegs * $netHostOct * 255"
        
        #for se in $(seq 0 $netSegs);do let cantSegs+=1; done;  #Calculamos cantidad de segmentos

        echo -e "----  Información de interfaz [ $selectedIface ]  -----\n"
        echo -e "IP: $ip \n"
        echo -e "Máscara de subred: $netmask \n"
        echo -e "Posicion índice de red: ${netIndexPos} \n"
        echo -e "Segmentos de red: Rango [ 0 / $netSegs ] --- Cantidad [ $cantSegs segmentos ] \n"

        echo -e "Cantidad posible de host: $hostCant \n"


        
        read -rs -p"Presiona una tecla para continuar";echo
        clear
        menuOpt=""
        menuifaces
    else
        menuOpt=""
        menuifaces
    fi
}



function ifacesopt(){  #Muestra las opciones y elige el menú
    echo -e "----------------------------------"
    echo -e "Interfaz de red actual: [ $selectedIface ]"
    echo -e "----------------------------------\n"
    echo -e "[ 1 ] Elegir interfaz de red \n"

    if [ "$selectedIface" != "No seleccionado" ]; then
        echo -e "[ 2 ] Ver equipos posibles \n"
        echo -e "[ 3 ] Ver información de la interfaz de red"
    fi

    echo -e "\n[ 0 ] Salir \n"
}


function menuifaces(){
    clear
    case $menuOpt in
        1) 
            selectIface
            ifacesopt
            read menuOpt
        ;;
        2) selectHosts
        
        ;;
        3) ifaceInfo
        
        ;;
        "")
            ifacesopt
            read menuOpt
        ;;
        0) 
            exit 0
        ;;
        *)
            echo "Opción inválida"
            ifacesopt
            read menuOpt
        ;;
    esac

}



while [ true ]; do
    menuifaces
done