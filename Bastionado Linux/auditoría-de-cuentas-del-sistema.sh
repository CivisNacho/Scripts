#!/bin/bash

echo "Comprobación de que las cuentas de usuario que representen servicios y aplicaciones no pueden ser utilizadas para iniciar sesión..."
awk -F: '$1!~/(root|sync|shutdown|halt|^\+)/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"' && $7!~/((\/usr)?\/sbin\/nologin)/ && $7!~/(\/bin)?\/false/ {print}' /etc/passwd
awk -F: '($1!~/(root|^\+)/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"') {print $1}' /etc/passwd | xargs -I '{}' passwd -S '{}' | awk '($2!~/LK?/) {print $1}'
echo "En caso de que no se hayan ratornado valores, los usuarios estan configurados de forma correcta"
sleep 1
echo "Si se han retornado valores, se recomienda ejecutar una solución automática."
echo -n "Pulse S/s si desea ejecutarla, pulse cualquier otra tecla si desea terminar la auditoría: "
read resp
case $resp in
[S/s])
    echo "Cambiando las cuentas del sistema shell nologin..."
    sleep 1
    awk -F: '$1!~/(root|sync|shutdown|halt|^\+)/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"' && $7!~/((\/usr)?\/sbin\/nologin)/ && $7!~/(\/bin)?\/false/ {print $1}' /etc/passwd | while read -r user; do usermod -s "$(which nologin)" "$user"; done
    echo "Completado."
    echo "Bloqueando cuentas del sistema no root"
    sleep 1
    awk -F: '($1!~/(root|^\+)/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"') {print $1}' /etc/passwd | xargs -I '{}' passwd -S '{}' | awk '($2!~/LK?/) {print $1}' | while read -r user; do usermod -L "$user"; done
    echo "Completado."
;;
[*])
echo "Auditoría finalizada.";;
esac