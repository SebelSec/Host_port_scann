#!/bin/bash

function ctrl_c(){
    echo -e "\n \n [+] Saliendo..."
    tput cnorm; exit 1 #recuperar cursor
}

trap ctrl_c INT


opt="Sin seleccionar"
ip_base=$(ip a | tail -n 4 | head -1 | awk '{print $2}' | cut -d '.' -f1-3)
prefix_net_mask=$(ip a | tail -n 4 | head -1 | awk '{print $2}' | cut -d '/' -f2)


function options1(){
	echo -e "---------------------Datos de red------------------------------\n"
	echo -e "Red ----> [ ${ip_base}.0 ]     Mascara de subred ----> [ ${prefix_net_mask}] \n"
	echo "----------------------------------------------------------------"
	echo "[1] Ver equipos en red"
	echo "[2] Cambiar máscara subred"
	echo "[0] Salir"
}
function optionsScann(){
    clear
    echo -e "\n---------------------Seleccionar tipo de escaneo TCP------------------------------"
    echo -e "                        Escaneando equipo [ $1 ]                                "
    echo "----------------------------------------------------------------\n"
    echo "[1] Basico puertos mas utilizados"
    echo "[2] Escaneo profundo de host[ 65536 puertos ]"
    echo "[3] Masivo todos los host y todos los puertos"
    echo "[0] atras.."
}


function select_scann(){
    scann_type=""
    read scann_type

    case $scann_type in
        1)  
            escaneo_base $1
            host_list
        ;;
        2)
            escaneo_extenso $1
            host_list
        ;;
        0)
            echo "Saliste"
            exit
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
	echo "======== Escaneo basico TCP =========="
        
        
		myports=$(cat ./ports.txt | while read -r port;
		do
			(timeout 1 bash -c "> /dev/tcp/$1/$port")2>/dev/null && echo "tcp $port ---> open" & 
		done; wait) 

        echo -e "\n host [ $1 ] \n"  
        if [ ${#myports} -le 10 ];
        then
            echo -e "\n No se encontraron puertos \n Haga el escaneo profundo no sea miserable \n"
            read -rs -p"Presiona una tecla para continuar";echo 
            clear
        else
            echo "$myports"
            read -rs -p"Presiona una tecla para continuar";echo 
            clear
        fi
}

function escaneo_extenso(){
	clear
        tput bold; echo -e "\n Analizando host [ $1 ] | TCP\n \n Sea paciente ¡¡Son 65536 puertos!!! \n"  
		exist="0"
        for port in $(seq 1 65536);
		do  
            timeout 1 bash -c "> /dev/tcp/$1/$port" 2>/dev/null 
            if [ $? -eq "0" ];
            then
                echo "port $port --> open"
                exist="1"
            fi 
        done; wait

        if [ "$exist" -ne "1" ];
        then
            echo "No hay puertos abiertos"
        fi
        
        read -rs -p"Presiona una tecla para continuar";echo 
        tput cnorm
        clear
}


function host_list(){
	clear
	echo "========  Seleccionar equipo para escanear  =========="

    let i="0"

	hosts=$(for host in $(seq 1 254);
		do
			(timeout 1 ping -c 1 "${ip_base}.$host")&>/dev/null && echo "${ip_base}.$host" &
		done; wait 
	)
    
	myhosts=$(echo $hosts | sed 's/ /\n/g' | while read -r line;
	do
        let "i=$i+1"
        echo -e "\n[$i]$line"
	done;wait)
    
    echo -e "$myhosts \n"
    echo -e "\n[0] Atras.."
    echo -e "Ingrese número de host [*]"

    number=""
	read number

    if [ "$number" -eq "0" ];
    then
        number=""
        clear
    else
        filtered=$(echo "$myhosts" | grep -F "[$number]" | cut -d ']' -f2)
        optionsScann $filtered
        select_scann $filtered  
        clear
    fi
}







function main(){

    clear
    case $opt in
        1)
            host_list
            # read -rs -p"Presiona una tecla para continuar";echo 
            options1
            read opt
        ;;
        2)
            options1
            read opt
        ;;
		"Sin seleccionar")
            options1
			read opt
        ;;
        0)
            echo "Saliste"
            exit
        ;;
        *)
            options1
            echo -e "\n Opción inválida \n"
            read opt
        ;;
        esac
}

while [ true ];
do
    main
done
