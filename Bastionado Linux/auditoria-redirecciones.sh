#!/bin/bash

if [ $USER = "root" ]
then
    echo ""
    echo "Comprobando el estado de IP Forwarding e ICMP Broadcast..."
    echo ""
    RESUL1=`sysctl net.ipv4.conf.all.send_redirects`
    RESUL2=`sysctl net.ipv4.conf.default.send_redirects`
    RESUL3=`grep -E "^\s*net\.ipv4\.conf\.all\.send_redirects" /etc/sysctl.conf/etc/sysctl.d/*`
    RESUL4=`grep -E "^\s*net\.ipv4\.conf\.default\.send_redirects" /etc/sysctl.conf/etc/sysctl.d/*`

    if [ $RESUL1 = "net.ipv4.conf.all.send_redirects = 0" ]
        then
            echo "Las redirecciones están deshabilitadas."
            echo ""
        else
            echo -n "Las redirecciones están habilitadas, ¿desea corregirlo? [S/s], [*]: "
            read resp
            case $resp in
            [S/s])
                echo "Desactivando las redirecciones..."
                sleep 1
                sysctl -w net.ipv4.conf.all.send_redirects=0;;
            [*])
                echo "Las redirecciones seguirán habilitadas.";;
    fi
    if [ $RESUL2 = "net.ipv4.conf.default.send_redirects = 0" ]
        then
            echo "Las redirecciones por defecto están deshabilitadas."
            echo ""
        else
            echo -n "Las redirecciones por defecto están habilitadas, ¿desea corregirlo? [S/s], [*]: "
            read resp
            case $resp in
            [S/s])
                echo "Desactivando las redirecciones por defecto..."
                sleep 1
                sysctl -w net.ipv4.conf.default.send_redirects=0;;
            [*])
                echo "Las redirecciones seguirán habilitadas.";;
    fi
fi