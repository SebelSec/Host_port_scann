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

    echo -e "\n" 
    echo -e "-----------------------------------\n"
    echo "[!] Seleccione interfaz por número"

    read number

    selectedIface="$( echo $listed_ifaces | grep -F "[$number]" | awk '{print $3}')" #Al grepear [$number], no falla la validación

    echo $listed_ifaces | grep -F "[$number]"

    if [ $? -eq 0 ]; then
        echo "La interfaz seleccionada es $selectedIface"
        read -rs -p"Presiona una tecla para continuar";echo
        clear
        ifacesopt 
    else
        echo "No existe la interfaz"
        selectedIface="No seleccionado"
        read -rs -p"Presiona una tecla para continuar";echo
        clear
        selectIface
    fi
}  

function ifaceInfo(){  #Muestra información de la interfaz

echo "infooo"
    # if [ "$selectedIface" != "No seleccionado" ];
    # then
    #     echo -e "ifconfig $selectedIface"
    # else
    #     menuifaces
    # fi
}



function ifacesopt(){  #Muestra las opciones y elige el menú
    echo "Interfaz de red actual: [ $selectedIface ]"
    echo "----------------------------------"
    echo -e "[ 1 ] Elegir interfaz de red \n"

    if [ "$selectedIface" != "No seleccionado" ]; then
        echo -e "[ 2 ] Ver equipos posibles \n"
        echo -e "[ 3 ] Ver información de la interfaz de red"
    fi

    echo -e "[ 0 ] Salir \n"

    read menuOpt
}


function menuifaces(){
    clear
    ifacesopt
    case $menuOpt in
        1) selectIface;;
        2) selectHosts;;
        3) ifaceInfo;;
        *) echo "opcion inválida";;
        0) exit 0
    esac

}



while [ true ]; do
    menuifaces
done