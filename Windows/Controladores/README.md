# Actualizar controladores de Dominio

*Guía breve para actualizar un controlador de dominio usando Windows Server Core y scripts.*

## Instalación de Windows Server Core

*La instalación de ejemplo se ha hecho con una máquina virtual en vCenter.*

Arrancaremos desde la imagen y cambiaremos la distribución de teclado, presionaremos Install, diremos que no tenemos clave de producto, elegiremos la versión **Windows Server 2022 Standard**, elegiremos la opción personalizada y el disco en el que se instalará Windows.

![Teclado](../doc/Server-Core/teclado.jpg)

![Edición](../doc/Server-Core/edicion.jpg)

![Personalizada](../doc/Server-Core/personalizada.png)

![Disco](../doc/Server-Core/disco.jpg)


## Post-Instalación

Una vez terminada la instalación, habrá que configurar la red y habilitar el escritorio remoto (para poder subir los scripts).

Windows Server Core cuenta con un menú llamado SConfig desde el que podremos realizar fácilmente la configuración inicial del equipo.

![SConfig](../doc/Server-Core/sconfig.jpg)

### Red

Para instalar la red seguiremos estos pasos, la configuración se realiza introduciendo una entrada desde el teclado y presionando intro para confirmar, la configuración de red es la número 8, por lo que habrá que escribir 8 y presionar intro.

Una vez ahí elegiremos la interfaz, que queremos configurar escribiendo su número de índice y presionando intro.

Ahí veremos tres opciones, la primera es para asignar **IP**, **máscara de red** y **puerta de enlace**, deberemos seleccionar la opción de IP estática. La configuración que he elegido yo ha sido:

| **IP**        | **Máscara de Red**           | **Gateway**  |
| ------------- |:-------------:| -----:|
| 172.20.10.22      | 255.255.255.0 | 172.20.10.1 |

Luego en la segunda opción, elegiremos como servidores DNS a los controladores de dominio ya existentes, **si no lo hacemos la máquina no podrá resolver el dominio ni unirse a él.**

Existe la posibilidad de que la máquina sea incapaz de liberar el DHCP de forma automática, en ese caso podremos utilizar los siguientes comandos para desactivar el DHCP y configurar la dirección IP.

```PowerShell
Remove-NetIPAddress -InterfaceAlias Ethernet0 -confirm:$False
```
```PowerShell
New-NetIPAddress -InterfaceAlias Ethernet0 -IPAddress 172.20.10.22 -PrefixLength 24 -DefaultGateway 172.20.10.1
```


### Escritorio Remoto

La configuración del escritorio remoto será tanto de lo mismo, presionaremos en el siguiente orden *7 > Intro > e > Intro > 2 > Intro > Intro*.


### Instalar software por disco

En caso de desear instalar alguna clase de software por disco podremos hacerlo de la siguiente forma:

* Abriremos PowerShell (15).
* Abriremos la unidad de disco que por defecto será D:, en caso de que no lo fuere, es posible listar los volúmenes montados en Windows con el siguiente comando:
```PowerShell
Get-PSDrive -PSProvider 'FileSystem'
```
* Ejecutaremos la instalación con *.\setup.exe* o equivalente.
* Nos dejaremos guiar por el isntalador gráfico y reiniciaremos la máquina.


## Promover a controlador

Subiremos mediante RDP los scripts *parte1.ps1* y *parte2.ps1* al servidor, ahí los ejecutaremos y se terminará de configurar la máquina y también se unirá al dominio y se convertirá en controlador.
*parte1.ps1*:
```PowerShell
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
```

*parte2.ps1*:
```PowerShell
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
```
## Cambio en los Roles Maestros

Bastará con seguir la siguiente [guía de Microsoft](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/upgrade-domain-controllers#:~:text=Add%20a%20new%20domain%20controller%20with%20a%20newer%20version%20of%20Windows%20Server), de ella tomaremos este comando, en el que **"DC03-10"** es el nombre del servidor al que queremos transferir los roles maestros, los comandos habrá que ponerlos en el servidor que posea los roles maestros:
**ES OBLIGATORIO UTILIZAR EL MÓDULO DE ACTIVE DIRECTORY PARA POWERSHELL**
```PowerShell
Move-ADDirectoryServerOperationMasterRole -Identity "DC03-10" -OperationMasterRole 0,1,2,3,4
```

Podremos comprobar que los roles maestros han cambiado con los siguentes comandos:
```PowerShell
Get-ADDomain | FL InfrastructureMaster, RIDMaster, PDCEmulator
```
```PowerShell
Get-ADForest | FL DomainNamingMaster, SchemaMaster
```

El resultado deberá ser similar a este, *(mi controlador se llama DC-Core)*:

![Cambio-rol-maestro](../doc/Server-Core/roles-cambiados.jpg)


## Instalar herramientas de administración en la estación.

Bastará con ejecutar el siguiente script en una máquina unida a nuestro dominio:

```PowerShell
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

if ($admin = "True") {
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
```
## Degradar el controlador de dominio.

**A continuación se explica como degradar el controlador de dominio, sin embargo, parece ser que se crean errores sin previo aviso que terminan impidiendo que el dominio funcione, se recomienda no degradar ningún controlador.**

Para degradar el controlador de dominio será necesario quitarle los roles al servidor, de forma automática Windows nos dirá que degrademos el controlador.

![Remove](../doc/Server-Core/remove.jpg)

Presionaremos en *Active Directory Domain Services* y ahí nos saldrá un mensaje de error indicándonos que debemos degradar el controlador, será lo que haremos.

![Demote](../doc/Server-Core/demote.jpg)

Dejaremos todas las opciones por defecto salvo la de *Remove DNS delegation*. Si nos encontramos con que no podemos avanzar en el wizard, es posible que debamos forzar al controlador de dominio, la opción está en la primera pestaña.

![Credenciales](../doc/Server-Core/credenciales.jpg)