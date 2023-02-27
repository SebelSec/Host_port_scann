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
        echo
        clear
    else
        filtered=$(echo "$myhosts" | grep -F "[$number]" | cut -d ']' -f2)
        optionsScann $filtered
        select_scann $filtered  
        clear
    fi
}

