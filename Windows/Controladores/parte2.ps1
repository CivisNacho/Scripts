#
## Gestión de errores
#

$error.clear()
$ErrorActionPreference = "Stop"

#
## Añadir roles de Controlador
#
try {
Add-WindowsFeature AD-Domain-Services, DNS
}
catch { "Error a la hora instalar los roles de controlador: $error"; exit}
if (!$error) { "Roles de controlador instalados correctamente."}

#
# Configuración como controlador de dominio.
#

$dominio = Read-Host 'Nombre de dominio'
$admin = Read-Host 'Usuario administrador'

try {
    Install-ADDSDomainController `
    -DomainName "$dominio" `
    -Credential (Get-Credential "$dominio\$admin") `
    -InstallDns:$true
}
catch { "Error a la hora de promover el controlador de dominio: $error; exit" }
if (!$error) { "Configurado como controlador de dominio en $dominio." }
Start-Sleep -Seconds 3