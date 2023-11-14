#
## Gestión de errores
#

$error.clear()
$ErrorActionPreference = "Stop"

#
## Configurar zona horaria a hora española
#

$zona = Get-TimeZone | Select-Object -Property Id
try {
    if ( "Romance Standard Time" -eq $zona) {
        Set-TimeZone -Id "Romance Standard Time"
    }
}
catch { "Ha ocurrido el siguente error a la hora de cambiar la zona horaria: $error"; exit}
if (!$error) { "Zona horaria correcta."}
Start-Sleep -Seconds 3

#
## Añadir al dominio
#

$hostname = HOSTNAME.EXE
$dominio = Read-Host "Introduzca el nombre de dominio"
$nombre = Read-Host "Introduzca un nuevo nombre para el servidor"
Start-Sleep -Seconds 1
try {
Add-Computer -ComputerName $hostname -DomainName $dominio -NewName $nombre -Credential $dominio\Administrator -Restart
}
catch { "Error a la hora de unirse al dominio: $error"; exit}
if (!$error) { "Unido correctamente al dominio $dominio." }
Start-Sleep -Seconds 3