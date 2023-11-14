#!/bin/bash
# En este script se irá incluyendo una versión más moderna de la auditoría de red.

comprobarIPv6() {
    IP6RESUL=$(ip -6 address)ip -6 address
    if [ -z $IP6RESUL ]
    then
        echo -e "IPv6 está deshabilitado\n"
        echo ""
        read -p "Continuará cuando pulse intro."
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
        read -p "Continuará cuando pulse intro."
        clear
    fi
}

if [ $USER = "root" ]
then
    comprobarIPv6
else
    echo "El script debe ejecutarse con permisos de administrador."
fi