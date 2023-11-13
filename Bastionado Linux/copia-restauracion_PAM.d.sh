#!/bin/bash

echo -n "¿Desea crear una copia de seguridad o restaurar pam.d? C/c R/r: "
read resp
case $resp in
[Cc])
        cp /etc/pam.d/common-account /etc/pam.d/common-account.bak
        cp /etc/pam.d/common-auth /etc/pam.d/common-auth.bak
        cp /etc/pam.d/common-password /etc/pam.d/common-password.bak
        cp /etc/pam.d/common-session /etc/pam.d/common-session.bak
        cp /etc/login.defs /etc/login.defs.bak


echo "Copia de seguridad creada";;
[Rr])
        cat /etc/pam.d/common-account.bak > /etc/pam.d/common-account
        cat /etc/pam.d/common-auth.bak > /etc/pam.d/common-auth
        cat /etc/pam.d/common-password.bak > /etc/pam.d/common-password
        cat /etc/pam.d/common-session.bak > /etc/pam.d/common-session
        cat /etc/login.defs.bak > /etc/login.defs
        echo "Restaurado";;
*) echo "Incorrecto, C/c para realizar copia de seguridad, R/r para recuperar la copia";;
esac
