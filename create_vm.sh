#!/bin/bash

# Verifica que se hayan pasado los parámetros correctos
if [ "$#" -lt 7 ]; then
    echo "Uso: $0 <nombre_vm> <tipo_sistema_operativo> <numero_cpus> <ram_gb> <vram_mb> <tamano_disco_gb> <nombre_controlador_sata> <nombre_controlador_ide>"
    exit 1
fi

# Parámetros
NOMBRE_VM=$1
TIPO_OS=$2
NUM_CPUS=$3
RAM_GB=$4
VRAM_MB=$5
TAMANO_DISCO_GB=$6
CONTROLADOR_SATA=$7
CONTROLADOR_IDE=$8

# Ruta para el disco duro virtual
VHD_PATH="$HOME/VirtualBox VMs/$NOMBRE_VM/$NOMBRE_VM.vdi"

# Convertir RAM y tamaño de disco a MB y MB/GB
RAM_MB=$(($RAM_GB * 1024))
DISCO_MB=$(($TAMANO_DISCO_GB * 1024))

# Crear la máquina virtual
VBoxManage createvm --name "$NOMBRE_VM" --ostype "$TIPO_OS" --register

# Configurar CPU, RAM y VRAM
VBoxManage modifyvm "$NOMBRE_VM" --cpus $NUM_CPUS --memory $RAM_MB --vram $VRAM_MB

# Crear el disco duro virtual
VBoxManage createmedium disk --filename "$VHD_PATH" --size $DISCO_MB --format VDI

# Crear y configurar el controlador SATA
VBoxManage storagectl "$NOMBRE_VM" --name "$CONTROLADOR_SATA" --add sata --controller IntelAhci
VBoxManage storageattach "$NOMBRE_VM" --storagectl "$CONTROLADOR_SATA" --port 0 --device 0 --type hdd --medium "$VHD_PATH"

# Crear y configurar el controlador IDE para CD/DVD
VBoxManage storagectl "$NOMBRE_VM" --name "$CONTROLADOR_IDE" --add ide
VBoxManage storageattach "$NOMBRE_VM" --storagectl "$CONTROLADOR_IDE" --port 1 --device 0 --type dvddrive --medium emptydrive

# Imprimir la configuración final de la máquina virtual
echo "Máquina Virtual '$NOMBRE_VM' creada con la siguiente configuración:"
VBoxManage showvminfo "$NOMBRE_VM"

# No olvides los permisos chmod +x create_vm.sh
# Asi ejecutas ./create_vm.sh "MiLinuxVM" "Ubuntu_64" 2 4 128 20 "ControladorSATA" "ControladorIDE"
