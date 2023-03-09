#!/bin/bash

#colores
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


(


    echo -e "${redColour}
                          ⢀⡴⠟⠛⠛⠛⠛⠛⢦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                ⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠋⠀⠀⠀⠀⠀⠀⠀⠀⠙⠿⣦⡀⠀⠀⠀⠀⠀⠀⠀
                ⠀⠀⠀⠀⠀⠀⠀⣰⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⣆⠀⠀⠀⠀⠀⠀
                ⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ⠘⡇⠀⠀⠀⠀⠀
                ⠀⠀⠀⠀⠀⠀⢘⡧⠀⠀⢀⣀⣤⡴⠶⠶⢦⣤⣀⡀⠀⠀  ⢻⠀⠀⠀⠀⠀⠀
                ⠀⠀⠀⠀⠀⠀⠘⣧⡀⠛⢻⡏⠀⠀⠀⠀⠀⠀⠉⣿⠛⠂⣼⠇⠀⠀⠀⠀⠀⠀
                ⠀⠀⠀⠀⢀⣤⡴⠾⢷⡄⢸⡇⠀⠀⠀⠀⠀⠀⢀⡟⢀⡾⠷⢦⣤⡀⠀⠀⠀⠀
                ⠀⠀⠀⢀⡾⢁⣀⣀⣀⣻⣆⣻⣦⣤⣀⣀⣠⣴⣟⣡⣟⣁⣀⣀⣀⢻⡄⠀⠀⠀
                ⠀⠀⢀⡾⠁⣿⠉⠉⠀⠀⠉⠁⠉⠉⠉⠉⠉⠀⠀⠈⠁⠈⠉⠉⣿⠈⢿⡄⠀⠀
                ⠀⠀⣾⠃⠀⣿⠀⠀⠀⠀⠀⠀⣠⠶⠛⠛⠷⣤⠀⠀⠀⠀⠀⠀⣿⠀⠈⢷⡀⠀
                ⠀⣼⠃⠀⠀⣿⠀⠀⠀⠀⠀⢸⠏⢤⡀⢀⣤⠘⣧⠀⠀⠀⠀⠀⣿⠀⠀⠈⣷⠀
                ⢸⡇⠀⠀⠀⣿⠀⠀⠀⠀⠀⠘⢧⣄⠁⠈⣁⣴⠏⠀⠀⠀⠀⠀⣿⠀⠀⠀⠘⣧
                ⠈⠳⣦⣀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠻⠶⠶⠟⠀⠀⠀⠀⠀⠀⠀⣿⠀⢀⣤⠞⠃
                ⠀⠀⠀⠙⠷⣿⣀⣀⣀⣀⣀⣠⣤⣤⣤⣤⣀⣤⣠⣤⡀⠀⣤⣄⣿⡶⠋⠁⠀⠀
                ⠀⠀⠀⠀⠀⢿⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣿⠀⠀⠀
                ⠀
          ========= Bienvenido/a a Port scan ==========⠀    

${endColour}"

sleep 3


base_ifaces=$(ifconfig | grep "flags" | grep -v "LOOPBACK" | cut -d ":" -f1)
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


function ctrl_c(){
    clear
    echo -e "${redColour}\n \n [+] Saliendo...${endColour}"
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

    selectedIface="$( echo -e "$listed_ifaces" | grep -F "[$number]" | awk '{print $4}')" #Al grepear [$number], no falla la validación

    if [ $number -eq 0 ]; then
        selectedIface="No seleccionado"
        echo "Presione una tecla para continuar"
        read -rs -p" Presione";echo
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
        echo "Presione una tecla para continuar"
        read -rs -p" Presione";echo
        clear
    else
        echo "[!] No existe la interfaz"
        selectedIface="No seleccionado"
        echo "Presione una tecla para continuar"
        read -rs -p" Presione";echo
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
        echo "Presione una tecla para continuar"
        read -rs -p" Presione";echo
        clear
    else
        clear
    fi
}


function host_list(){ #Escaneo en búsqueda de dispositivos dentro de la red
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
                    (timeout 2 ping -c 1 "$line" &>/dev/null) && echo -e "\n \t ${greenColour}[$counter]${endColour} ---> ${grayColour} $line ${endColour}" &    
                done; wait)

                hostInNetToScann=$( echo -e "$hostInNetInfo" | awk '{print $4}' )

                echo -e "$hostInNetInfo \n"
                echo -e "\n \t ${blueColour}[A]${endColour} ---> ${grayColour}Escanear todos los equipos (Puede demorar)\n${endColour}"
                echo -e "\n \t ${redColour}[0]${endColour} ---> Atras \n"
                echo -e "\n"
                echo -e "${yellowColour}=====================================================${endColour}"

                echo -e "Seleccionar un equipo, opción A (Escanear Todos) o 0 para salir \n"
                echo -e "${turquoiseColour}\n (ctrl + mayus + up) Para subir  \n ${endColour}"
                read selectToScann

                echo "$hostInNetInfo" | grep -F "[$selectToScann]"

                if [ $? -ne 0 ] && [ "$selectToScann" != "A" ] && [ "$selectToScann" != "0" ];then
                    echo "Opción inválida (Saliendo al menú..)"
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
                    echo "Presione una tecla ir al menú de escaneo"
                    read -rs -p"";echo
                    

                    optionsScann $hostInNetToScann
                    select_scann $hostInNetToScann  
                    clear
                fi
            
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
                echo "Presione una tecla para continuar"
                read -s -p"pre";echo 
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
        tput bold; echo -e "${redColour} [!] ${endColour} Escaneando puertos, espere porfavor ..."
		
        echo $hostInNetToScann | sed 's/ /\n/g' | while read -r line; do
            echo -e "${yellowColour}\n--------- Resultados host [ $line ]--------\n${endColour}" | tee ./portLog.txt
            cat ./portList.txt | while read -r port;
                do
                    ((timeout 1 echo "" > /dev/tcp/$line/$port)2>/dev/null && echo -e "${greenColour}\n \t Port $port TCP --> open${endColour}" | tee -a ./portLog.txt) &
                done; wait
                sleep 0.001
           done; wait
            sleep 1
            echo -e "\n${blueColour} Finalizando escaneo..${endColour}\n"
            sleep 3
            echo -e "\n ${redColour}No hay mas puertos abiertos${endColour} \n"    

        echo "Presiona una tecla para continuar"
        read -rs -p "pres ";echo 
        clear
        
    fi
}

function escaneo_extenso(){
	clear
    if [ ${#hostInNetToScann} -le 5 ]; then
        clear
    else
        
        tput cnorm; echo -e "\n ${redColour} [!] Escaneando los 65536 puertos posibles, esto demorará mucho ... ${yellowColour} \n\n------------ Resultados host [ $hostInNetToScann ] ------------\n\n${endColour}"   
        echo -e " ${blueColour} Si el escaneo demora demasiado salir con ctrl + c ${endColour}"
        echo -e "\t ${yellowColour} \n\n------------ Resultados host [ $hostInNetToScann ] ------------\n\n${endColour}" > ./portLog.txt
        for port in $(seq 1 65536);
		do  
            (( timeout 1 echo "" > "/dev/tcp/$hostInNetToScann/$port")2>/dev/null && echo -e "\t \n ${greenColour}Port $port TCP --> open \n${endColour}" | tee -a ./portLog.txt) &
            sleep 0.001
        done; wait
        sleep 1
        echo -e "\n${blueColour} Finalizando escaneo..${endColour}\n"
        sleep 3
        echo -e "\n ${redColour}No hay mas puertos abiertos${endColour} \n"
    
        echo "Presiona una tecla para continuar"
        read -rs -p "pres ";echo 
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
            echo -e "${turquoiseColour}\n (ctrl + mayus + up) Para subir en el archivo \n ${endColour}"
            echo "Presione una tecla para continuar"
            read -s -p"pre";echo 
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
    clear
    menuifaces
done

)2>/dev/null