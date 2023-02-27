#!/bin/bash


base_ifaces=$(ifconfig | grep flags | grep -v "LOOPBACK" | cut -d ":" -f1)
menuOpt=""
selectedIface="No seleccionado"   #Interfaz seleccionada sin mas detalles

#variables del adaptador
declare -i netPrefix=0
declare -i base=0
declare -i ips=0
hosts=0
ip=0
netmask=0
netsOct=0
hostsOct=0



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
                #Seleccionada la interfaz, asignamos las variables de red
        echo -e "\n [!] La interfaz seleccionada es [${selectedIface}] \n"
        ip=$(ifconfig $selectedIface | head -n 2 | tail -n 1 | awk '{print $2}')
        netmask=$(ifconfig $selectedIface | head -n 2 | tail -n 1 | awk '{print $4}')
        netPrefix=$(ip a | grep $selectedIface | tail -n 1 | awk '{print $2}' | cut -d "/" -f2)
        let base="32 - $netPrefix"

        let ips=$( echo "2 ^ $base" | bc ) 
        let hosts="$ips - 2"
        baseIp=0

        if [ $netPrefix -le 8 ]; then
            netsOct=1
        elif [ $netPrefix -le 16 ]; then
            netsOct=2
        elif [ $netPrefix -le 24 ]; then
            netsOct=3
        fi

        baseIp=$( echo "$ip" | cut -d "." -f1-${netsOct})
        let hostsOct="4 - $netsOct"

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
   
    
        echo -e "----  Información de interfaz [ $selectedIface ]  -----\n"
        echo -e "IP: $ip \n"
        echo -e "Máscara de subred: $netmask \n"

        echo -e "Cantidad posible de host: $hosts \n"


        
        read -rs -p"Presiona una tecla para continuar";echo
        clear
        menuOpt=""
        menuifaces
    else
        menuOpt=""
        menuifaces
    fi
}


function host_list(){
    clear

    # echo "$hosts"

    echo "========  Equipos en red  =========="

    # if [ $hosts -le 254  ]; then

    #     allhosts=$(for host in $(seq 1 $hosts);
    #         do
    #             (timeout 1 ping -c 1 "${baseIp}.$host")&>/dev/null && echo "${baseIp}.$host" &
    #         done; wait 
    #     )
    #     echo "$allhosts"
    # else
    

           
        IFS='.' read -r a b c d <<< "$ip"  #Dividimos la ip en 4 variables abcd como delimitador usamos "."
        ((d=0))
        allHosts=$( for ((i=1; i<=$hosts; i++)); do
            ((d++))
            if ((d > 255)); then
                d=0
                ((c++))
                if ((c > 255)); then
                c=0
                ((b++))
                if ((b > 255)); then
                    b=0
                    ((a++))
                fi
                fi
            fi
            echo -e "${a}.${b}.${c}.${d}\n"
            done
            )

        echo -e $allHosts | sed 's/ /\n/g' | while read -r line; 
        do
           ping -c 1 "$line" &>/dev/null && echo -e "$line \n" &    
        done; wait

    # fi


   

    read -rs -p"Presiona una tecla para continuar";echo
    clear
    
    #     myhosts=$(echo $hosts | sed 's/ /\n/g' | while read -r line;
    #     do
    #     let "i=$i+1"
    #     echo -e "\n[$i]$line"
    #     done;wait)
    
    # echo -e "$myhosts \n"
    # echo -e "\n[0] Atras.."
    # echo -e "Ingrese número de host [*]"

    # number=""
    #     read number

    # if [ "$number" -eq "0" ];
    # then
    #     number=""
    #     read -rs -p"Presiona una tecla para continuar";echo
    #     exit 0
    # else
    #     filtered=$(echo "$myhosts" | grep -F "[$number]" | cut -d ']' -f2)
    #     optionsScann $filtered
    #     select_scann $filtered  
    #     clear
    # fi
}






function ifacesopt(){  #Muestra las opciones y elige el menú
    echo -e "----------------------------------"
    echo -e "Interfaz de red actual: [ $selectedIface ]"
    echo -e "----------------------------------\n"
    echo -e "[ 1 ] Elegir interfaz de red \n"

    if [ "$selectedIface" != "No seleccionado" ]; then
        echo -e "[ 2 ] Ver equipos de la red \n"
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
        2) 
            host_list
            ifacesopt
            read menuOpt
        ;;
        3) 
            ifaceInfo
            ifacesopt
            read menuOpt
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