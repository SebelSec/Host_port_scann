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
hostInNetToScann=""
selectToScann="No selected"

#colores
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
    echo -e "\n \n [+] Saliendo..."
    tput cnorm; exit 1 #recuperar cursor
}

trap ctrl_c INT





function selectIface(){  #Función que selecciona la interfaz
    clear
    declare -i index=0  
    declare -i number=0

    echo -e "${purpleColour}------------  Adaptadores disponibles  ----------------\n\n${endColour}"

    listed_ifaces=$(echo -e "$base_ifaces" | while read line; do
        index+=1
        echo -e "\t ${greenColour}[$index]${endColour} ${grayColour} ---> $line ${endColour}"
    done
    )

    echo -e "$listed_ifaces"
    echo -e "\n \t ${greenColour}[0]${endColour} ${grayColour}---> Atras..${endColour}"
    echo -e "\n" 
    echo -e "${purpleColour}--------------------------------------------------------${endolour}\n"
    echo -e "${grayColour}[!] Seleccione opción por número: \n${endColour}"

    read number

    selectedIface="$( echo $listed_ifaces | grep -F "[$number]" | awk '{print $4}')" #Al grepear [$number], no falla la validación

    if [ $number -eq 0 ]; then
        selectedIface="No seleccionado"
        read -rs -p"Presiona una tecla para continuar";echo
        clear
    elif [ ${#selectedIface} -gt 0 ]; then
        clear
        #Seleccionada la interfaz, asignamos las variables de red
        echo -e "${grayColour}\n ------------------------------------------------- \n${endColour}"
        echo -e "${greenColour}\n ¡Adaptador ${selectedIface} seleccionado!\n${endColour}"
        echo -e "${grayColour}\n ------------------------------------------------- \n${endColour}"


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
    clear
    if [ "$selectedIface" != "No seleccionado" ];
    then
   
    
        echo -e "${turquoiseColour}\n -------------- Información de adaptador ${yellowColour}[ $selectedIface ]${endColour} ${turquoiseColourColour}---------------\n\n${endColour}"
        echo -e "\t ${greenColour}IP:${grayColour} $ip \n ${endColour}"
        echo -e "\t ${greenColour}Máscara de subred:${grayColour} $netmask /$netPrefix\n${endColour}"
        echo -e "\t ${greenColour}Cantidad posible de host:${grayColour} $hosts \n${endColour}"

        echo -e "${turquoiseColour}\n -----------------------------------------------------------------------------\n${endColour}"
        read -rs -p"Presiona una tecla para continuar";echo
        clear
    else
        clear
    fi
}


function host_list(){
    clear

    if [ "$selectedIface" != "No seleccionado" ];
        then
        echo -e "${yellowColour}=================  Equipos en red  ==================${endColour}"

            
                declare -i counter=0
                selectToScann="No selected"
                
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

                hostInNetInfo=$(echo -e $allHosts | sed 's/ /\n/g' | while read -r line; 
                do
                    counter+=1
                    (timeout 1 ping -c 1 "$line" &>/dev/null) && echo -e "\n \t ${greenColour}[$counter]${endColour} ---> ${grayColour} $line ${endColour}\n" &    
                done; wait)

                hostInNetToScann=$( echo -e "$hostInNetInfo" | awk '{print $4}' )

                echo -e "$hostInNetInfo \n"
                echo -e "\n \t ${blueColour}[A]${endColour} ---> ${grayColour}Escanear todos\n${endColour}"
                echo -e "\n \t ${redColour}[0]${endColour} ---> Atras \n"
                echo -e "\n"
                echo -e "${yellowColour}=====================================================${endColour}"

                echo -e "Seleccionar un equipo u opción A (Escanear Todos)"
                read selectToScann

                echo "$hostInNetInfo" | grep -F "[$selectToScann]"

                if [ $? -ne 0 ] && [ "$selectToScann" != "A" ] && [ "$selectToScann" != "0" ];then
                    echo "opcion invalida (Saliendo al menú..)"
                elif [ "$selectToScann" -eq "0" ];
                then
                    selectToScann="No selected"
                    clear
                elif [ "$selectToScann" == "A" ];
                then

                    optionsScann "Todos los equipos"
                    select_scann
                    clear
                    optionsScann="No selected"

                else
                    hostInNetToScann=$(echo "$hostInNetInfo" | grep -F "[$selectToScann]" | awk '{ print $4 }')
                    clear
                    echo -e "${grayColour} \n  ------------------------------------------------- \n${endColour}"
                    echo -e "${greenColour} \n \t  ¡Host ${yellowColour} ${hostInNetToScann} ${endColour} ${greenColour}seleccionado!\n ${endColour}"
                    echo -e "${grayColour} \n ------------------------------------------------- \n${endColour}"
       
                   read -rs -p"Presiona una tecla para escanear";echo
                    

                    optionsScann $hostInNetToScann
                    select_scann $hostInNetToScann  
                    clear
                fi
            
        read -rs -p"Presiona una tecla para continuar";echo
        clear

        else
            clear
        fi
}

function optionsScann(){
    clear
    echo -e "${redColour}\n---------------------  Seleccionar tipo de escaneo  ------------------------------${endColour}"
    echo -e "${redColour}\n                        Detectando puertos ${grayColour}[ $1 ]${endColour}${redColour} \n ${endColour}"
    echo -e "${redColour}------------------------------------------------------------------------------------\n ${endColour}"
    echo -e " \t ${greenColour}[1] ${endColour} ${grayColour} Básico puertos mas utilizados \n ${endColour}"
    echo -e " \t ${greenColour}[2] ${endColour} ${grayColour} Escaneo profundo de host [ 65536 puertos ] (Solo un host por escaneo) \n ${endColour}"
    echo -e " \t ${greenColour}[0] ${endColour} ${grayColour} atras.. \n ${endColour}"
    echo -e "${redColour} \n------------------------------------------------------------------------------------\n ${endColour}"
    echo -e "${grayColour} \n Seleccione una opción\n ${endColour}"

}


function select_scann(){
    scann_type=""
    read scann_type

    case $scann_type in
        1)  
            escaneo_base 
            host_list
        ;;
        2)
            if [ $selectToScann == "A" ];then
                clear
                echo "No se puede realizar un escaneo extenso de todos los equipos"
                read -rs -p"Presiona una tecla para continuar";echo 
            else
                escaneo_extenso 
            fi
            host_list
        ;;
        0)
            clear
        ;;
        *)
            optionsScann $1
            echo -e "\n Opción inválida \n"
            read scann_type
        ;;
        esac
}

function escaneo_base(){
	clear

     if [ ${#hostInNetToScann} -le 5 ]; then

        clear
    else

	    echo "${yellowColour}======== Escaneo básico TCP ==========${endColour}"
		hostWithPorts="0"
        clear
        tput bold; echo "${redColour}[!]${endColour} Escaneando, espere porfavor ..."
		myports=$(
        echo $hostInNetToScann | sed 's/ /\n/g' | while read -r line; do
            echo -e "${yellowColour}\n--------- Resultados host [ $line ]--------\n${endColour}"

            cat ./portList.txt | while read -r port;
            do
                (timeout 2 bash -c "> /dev/tcp/$line/$port")2>/dev/null && echo "${greenColour}\n \t Port $port TCP --> open${endColour}"
            done
            echo -e "${redColour}\n \t No hay mas puertos abiertos \n${endColour}"
        done
        )
        tput sgr0
        
        clear
        echo -e "---------------------último escaneo------------------\n $myports \n" | tee ./portLog.txt
        read -rs -p"Presiona una tecla para volver atras";echo 
        
    fi
}

function escaneo_extenso(){
	clear
    if [ ${#hostInNetToScann} -le 5 ]; then
        clear
    else

        tput cnorm; echo -e "\n ${redColour}Escaneando los 65536 puertos posibles, esto demorará bastante ... ${yellowColour} \n\n------------ Resultados host [ $hostInNetToScann ] ------------\n${endColour}"   
		exist="0"
        for port in $(seq 1 65536);
		do  
            timeout 1 bash -c "> /dev/tcp/$hostInNetToScann/$port" 2>/dev/null 
            if [ $? -eq "0" ];
            then
                echo -e "\t ${greenColour}Port $port TCP --> open \n${endColour}"
                exist="1"
            fi 
        done | tee ./portLog.txt

        if [ "$exist" -ne "1" ];
        then
            echo -e "\n ${redColour}No hay puertos abiertos${endColour} \n"
        else
            echo -e "\n ${redColour}No hay mas puertos abiertos${endColour} \n"
        fi
        
        read -rs -p"Presiona una tecla para continuar";echo 
        tput cnorm
        clear
    fi
}





function ifacesopt(){  #Muestra las opciones y elige el menú
    echo -e "${purpleColour}\n------------  Adaptador actual:${endColour} ${grayColour}[ $selectedIface ]${endColour} ${purpleColour}------------------\n\n${endColour}"
    echo -e "\t ${greenColour}[ 1 ]${endColour} ---> Seleccionar adaptador de red \n"
    echo -e "\t ${greenColour}[ 2 ]${endColour} ---> Ver log último escaneo \n"

    if [ "$selectedIface" != "No seleccionado" ]; then
        echo -e "\t ${greenColour}[ 3 ]${endColour} ${grayColour}---> Escanear equipos de la red \n${endColour}"
        echo -e "\t ${greenColour}[ 4 ]${endColour} ${grayColour}---> Ver información del adaptador de red${endColour}"
    fi
    echo -e "\n \t ${redColour}[ 0 ]${endColour} ---> Salir \n\n"
    echo -e "${purpleColour}--------------------------------------------------------------\n${endColour}"
    echo -e "${grayColour}Elija una opción:${endColour}"
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
            clear
            cat ./portLog.txt
            echo "(ctrl + mayus + up) Para subir en el archivo"
            read -rs -p"Presiona una tecla para continuar";echo 
            clear
            ifacesopt
            read menuOpt
        ;;
        3) 
            host_list
            ifacesopt
            read menuOpt
        ;;
        4) 
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