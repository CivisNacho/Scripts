#!/bin/bash

if [ $USER = "root" ]
then
    clear
    echo "Comprobando que IPv6 está deshabilitado..."
    echo ""
    IP6RESUL=`ip -6 address`
    
    if [ -z $IP6RESUL ]
    then
        echo "IPv6 está deshabilitado"
        echo ""
        read -p "El script se pausará hasta que pulse la tecla Intro, asegúrese de remediar los errores de ser necesario."
        clear
    else
        echo -n "IPv6 está habilitado en caso de que desee deshabilitarla escriba S/s,
        cualquier otra tecla en caso de que desee omitir: "
        read resp
        case $resp in
            [S/s])
                echo "Deshabilitando IPV6..."
                sleep 1
                sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ ipv6.disable=1"/' "/etc/default/grub"
                update-grub
                echo "Completado."
            ;;
            [*])
            echo -e "Omitiendo.\n";;
        esac
        echo "Instrucciones en la página 177 del CIS Ubuntu 20.04\n"
    fi
    
    echo "Comprobando ICMP redirect..."
    echo ""
    echo "El resultado de los comandos que se ejecuten a continuación debería retornar =0."
    echo ""
    # Comprueba si la redirección ICMP está habilitada.
    redireccionICMP=$(sysctl net.ipv4.conf.all.send_redirects)
    if [[ "$redireccionICMP" == *"net.ipv4.conf.all.send_redirects = 1"* ]];
    then
        echo -n "La redirección ICMP está habilitada, en caso de que desee deshabilitarla escriba S/s,
        cualquier otra tecla en caso de que desee omitir: "
        read resp
        case $resp in
            [S/s])
                echo "Deshabilitando la redirección ICMP..."
                sleep 1
                sysctl -w net.ipv4.conf.all.send_redirects=0
                sysctl -w net.ipv4.conf.all.accept_redirects=0
                echo "Completado."
            ;;
            [*])
            echo -e "Omitiendo.\n";;
        esac
    else
        echo -e "La redirección ICMP está deshabilitada.\n"
    fi
    
    
    # Comprobación de redirección ICMP en todas las interfaces.
    redireccionIcmpGlobal=$(sysctl net.ipv4.conf.default.send_redirects)
    if [[ "$redireccionIcmpGlobal" == *"net.ipv4.conf.all.send_redirects = 1"* ]];
    then
        echo -n "La redirección ICMP en las interfaces está habilitada, en caso de que desee deshabilitarla escriba S/s,
        cualquier otra tecla en caso de que desee omitir: "
        read resp
        case $resp in
            [S/s])
                echo "Deshabilitando la redirección ICMP..."
                sleep 1
                sysctl -w net.ipv4.conf.default.send_redirects=0
                sysctl -w net.ipv4.conf.default.accept_redirects=0
                echo "Completado."
            ;;
            [*])
            echo -e "Omitiendo.\n";;
        esac
    else
        echo -e "La redirección ICMP en las interfaces está deshabilitada.\n"
    fi
    grep -E "^\s*#?\s*net\.ipv4\.conf\.all\.accept_redirects\s*=\s*1"
    grep -E "^\s*net\.ipv4\.conf\.all\.send_redirects" /etc/sysctl.conf /etc/sysctl.d/*
    echo ""
    grep -E "^\s*net\.ipv4\.conf\.default\.send_redirects" /etc/sysctl.conf /etc/sysctl.d/*
    echo ""
    echo ""
    echo "Hasta aquí las comprobaciones"
    echo ""
    echo "En caso de no retrornar los resultados esperados, modifique el siguente archivo:"
    echo "sudo nano /etc/sysctl.conf"
    echo ""
    echo "Luego configure estos parámetros"
    echo "net.ipv4.conf.all.accept_redirects = 0"
    echo "net.ipv4.conf.default.accept_redirects = 0"
    echo "net.ipv4.conf.all.send_redirects = 0"
    echo "net.ipv4.conf.default.send_redirects = 0"
    echo ""
    echo "Y ejecute los siguientes comandos también:"
    echo ""
    echo "sysctl -w net.ipv4.route.flush=1"
    echo ""
    read -p "El script se pausará hasta que pulse la tecla Intro, asegúrese de remediar los errores de ser necesario."
    clear
    
    echo "Comprobando que IP Forwarding está deshabilitado..."
    echo "Los comandos ejecutados a continuación deberían retornar =0, y nada más."
    echo ""
    sysctl net.ipv4.ip_forward
    echo ""
    `grep -E -s "^\s*net\.ipv4\.ip_forward\s*=\s*1" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf`
    echo ""
    echo "En caso de que la auditoría no haya resultado satisfactoria ejecute el siguiente comando:"
    echo ""
    echo 'grep -Els "^\s*net\.ipv4\.ip_forward\s*=\s*1" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf | while read filename; do sed -ri "s/^\s*(net\.ipv4\.ip_forward\s*)(=)(\s*\S+\b).*$/# *REMOVED* \1/" $filename; done; sysctl -w net.ipv4.ip_forward=0; sysctl -w net.ipv4.route.flush=1'
    echo ""
    read -p "El script se pausará hasta que pulse la tecla Intro, asegúrese de remediar los errores de ser necesario."
    clear
    
    echo "Comprobando que las respuestas ICMP Broadcast están deshabilitadas..."
    echo ""
    echo "El resultado de los comandos que se ejecuten a continuación debería retornar tres salidas =1."
    echo ""
    sysctl net.ipv4.icmp_echo_ignore_broadcasts
    grep "net\.ipv4\.icmp_echo_ignore_broadcasts" /etc/sysctl.conf /etc/sysctl.d/*
    echo ""
    echo "En caso de que la auditoría no haya resultado satisfactoria ejecute las siguientes soluciones:"
    echo "sudo nano /etc/sysctl.conf"
    echo ""
    echo "Configure el siguiente parámetro:"
    echo "net.ipv4.icmp_echo_ignore_broadcasts = 1"
    echo ""
    echo ""
    echo "Ejecute los siguientes comandos:"
    echo "sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1"
    echo "sysctl -w net.ipv4.route.flush=1"
    echo ""
    read -p "El script se pausará hasta que pulse la tecla Intro, asegúrese de remediar los errores de ser necesario."
    clear
    
    echo "Comprobando que solamente se registran paquetes ICMP estándar, rechazando bogus..."
    echo ""
    echo ""
    echo "El resultado de los comandos que se ejecuten a continuación debería retornar tres salidas con =1."
    echo ""
    sysctl net.ipv4.icmp_ignore_bogus_error_responses
    grep "net.ipv4.icmp_ignore_bogus_error_responses" /etc/sysctl.conf /etc/sysctl.d/*
    echo ""
    echo "En caso de que la auditoría no haya resultado satisfactoria ejecute las siguientes soluciones:"
    echo ""
    echo "sudo nano /etc/sysctl.conf"
    echo ""
    echo "Modificar el siguiente parámetro"
    echo "net.ipv4.icmp_ignore_bogus_error_responses = 1"
    echo ""
    echo "Ejecutar los siguientes comandos"
    echo ""
    echo "sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1"
    echo "sysctl -w net.ipv4.route.flush=1"
    echo ""
    read -p "El script se pausará hasta que pulse la tecla Intro, asegúrese de remediar los errores de ser necesario."
    clear
    
    
    echo "Comprobando que reverse path filtering está activado..."
    echo ""
    echo "El resultado de los comandos que se ejecuten a continuación debería retornar salidas con =1."
    echo ""
    sysctl net.ipv4.conf.all.rp_filter
    echo ""
    sysctl net.ipv4.conf.default.rp_filter
    echo ""
    echo "En caso de que la auditoría no haya resultado satisfactoria ejecute las siguientes soluciones:"
    echo ""
    echo "sudo nano /etc/sysctl.conf"
    echo ""
    echo "Modificar los siguientes parámetros:"
    echo ""
    echo "net.ipv4.conf.all.rp_filter = 1"
    echo "net.ipv4.conf.default.rp_filter = 1"
    echo ""
    echo "Ejecutar los siguientes comandos:"
    echo "sysctl -w net.ipv4.conf.all.rp_filter=1"
    echo "sysctl -w net.ipv4.conf.default.rp_filter=1"
    echo "sysctl -w net.ipv4.route.flush=1"
    echo ""
    read -p "El script se pausará hasta que pulse la tecla Intro, asegúrese de remediar los errores de ser necesario."
    clear
    
    echo "Comprobando que TCP SYN Cookies está habilitado..."
    echo ""
    echo "El resultado de los comandos que se ejecuten a continuación debería retornar salidas con =1."
    echo ""
    sysctl net.ipv4.tcp_syncookies
    grep "net\.ipv4\.tcp_syncookies" /etc/sysctl.conf /etc/sysctl.d/*
    echo ""
    echo "En caso de que la auditoría no haya resultado satisfactoria ejecute las siguientes soluciones:"
    echo ""
    echo "sudo nano /etc/sysctl.conf"
    echo ""
    echo "Modificar los siguientes parámetros:"
    echo ""
    echo "net.ipv4.tcp_syncookies = 1"
    echo ""
    echo "Ejecutar los siguientes comandos:"
    echo "sysctl -w net.ipv4.tcp_syncookies=1"
    echo "sysctl -w net.ipv4.route.flush=1"
    echo ""
    read -p "El script se pausará hasta que pulse la tecla Intro, asegúrese de remediar los errores de ser necesario."
    clear
    
    echo "Comprobando que protocolos no necesarios están deshabilitados..."
    echo ""
    echo "Ejecute sustituyendo protocolo por los siguientes protocolos:"
    echo "dccp sctp rds tipc"
    echo ""
    echo "sudo nano /etc/modprobe.d/protocolo.conf"
    echo ""
    echo "Añada:"
    echo ""
    echo "install protocolo /bin/true"
    echo ""
    read -p "El script se pausará hasta que pulse la tecla Intro, asegúrese de remediar los errores de ser necesario."
    clear
fi