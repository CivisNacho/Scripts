#!/bin/bash
# auditoría sobre conexiones SSH seguras



if [ $USER = "root" ]
then



       echo ""
       echo Comprobando que el módulo PAM está habilitado para ssh -UsePAM yes-...
        RESUL=`sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep -i usepam`
        if [ "$RESUL"  =  "usepam yes" ]
        then
          echo CORRECTO
        else
          echo ERROR
          echo ""
          echo Se recomienda modificar -usepam- y establecerlo en -UsePAM yes- en -/etc/ssh/sshd_config-
          sleep 1
        fi


        echo "Comprobando que la configuración también está aplicada en el demonio..."
       RESUL=`grep -Eis '^\s*UsePAM\s+no' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf`
        if [ -z "$RESUL" ]
        then
          echo CORRECTO
          echo ""
          echo ""
        else
          echo ERROR
          echo ""
          echo Si usepam ya se ha modificado, se recomienda reiniciar el servicio
          echo ""
          echo "sudo systemctl restart sshd.service"
          echo ""
          echo ""
        fi



       echo Comprobando que está limitado el número de intentos de login...
        RESUL=`sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep maxauthtries`
        if [ "$RESUL"  =  "maxauthtries 4" ]
        then
          echo CORRECTO
          echo ""
          echo ""
        else
          echo ERROR
          echo modificar -MaxAuthTries- en -/etc/ssh/sshd_config-
          echo ""
          echo -MaxAuthTries 4-
          echo ""
          echo ""
        fi



       echo "Comprobando que la configuración también está aplicada en el demonio..."
       RESUL=`grep -Eis '^\s*maxauthtries\s+([5-9]|[1-9][0-9]+)' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf`
        if [ -z "$RESUL" ]
        then
          echo CORRECTO
          echo ""
          echo ""
        else
          echo ERROR
          echo ""
          echo Si MaxAuthTries ya se ha modificado, se recomienda reiniciar el servicio
          echo ""
          echo "sudo systemctl restart sshd.service"
          echo ""
          echo ""
        fi



else
        echo "Necesario ejecutar con permisos de root"
fi


#MaxStartups : Número máximo de conexiones no autenticadas concurrentes. Para evitar DoS configuramos:
#10: número de conexiones no autenticadas permitidas antes de empezar a rechazar nuevas conexiones
#30: porcentaje de conexiones que se empezarán a rechazar tras pasar las 10 iniciales
#60: máximo número de conexiones

       echo "Comprobando -MaxStartups 10:30:60- para evitar ataques DDOS..."
        RESUL=`sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep -i maxstartups`
        if [ "$RESUL"  =  "maxstartups 10:30:60" ]
        then
          echo CORRECTO
          echo ""
          echo ""
        else
          echo ERROR
          echo Se recomienda mofificar -maxstartups- en -/etc/ssh/sshd_config-
          echo ""
          echo "El siguiente valor es recomendado: -MaxStartups 10:30:60-"
          echo ""
          echo ""
          sleep 3
        fi