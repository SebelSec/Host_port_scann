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
        echo "No existe la interfaz"
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
        netmask=$(ifconfig $selectedIface | head -n 2 | tail -n 1 | awk '{print $4}')

        echo -e "----  Información de interfaz [ $selectedIface ]  -----\n"
        echo -e "IP: $ip \n"
        echo -e "Máscara de subred: $netmask \n"
        
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
        *)
            ifacesopt
            read menuOpt
        ;;
        0) exit 0
        ;;
    esac

}



while [ true ]; do
    menuifaces
done