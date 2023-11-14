#
## Script para configurar la estación.
#

#
## Gestión de errores
#

$error.clear()
$ErrorActionPreference = "Stop"

#
## Comprobar si el script se está ejecutando como administrador.
#

$admin = [Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544'

if ($admin -eq "True") {
    #
    ## Instalar el paquete de idioma necesario.
    #

    if (Get-InstalledLanguage -Language en-US) {
        Write-Output "Todos los paquetes de idiomas necesarios están instalados."
    } else {
            Write-Output "Instalando paquete de idiomas de Estados Unidos."
            try {
                Install-Language en-US
            }
            catch {
                "Error a la hora de instalar el paquete de idiomas: $error"; exit
            }
            if (!$error) { "Paquetes de idiomas instalados correctamente." }
        }
    #
    ## Instalar RSAT
    #
        try {
        Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability –Online
        }
        catch {
            "Error a la hora de instalar RSAT: $error"; exit
        }
        if (!$error) { "RSAT instalados correctamente." }
  } else {
    Write-Output "Es necesario ejecutar este script como administrador."
  }