#!/bin/bash

# ============================================================================ #
# Создание ВМ для учебного SonarQube (ubuntu-server 22.04)                     #
# ============================================================================ #

VM_NAME="SonarQube"
RAM="8192"
VCPUS="4"
DISK_SIZE="20"
OS_VARIANT="ubuntu22.04"
ISO_PATH="/var/lib/libvirt/images/ubuntu-22.04.5-live-server-amd64.iso"
BRIDGE="virbr0"


# Проверка на запуск скрипта с правами суперпользователя
if [ "$EUID" -ne 0 ]; then
  echo 'Ошибка: этот скрипт следует запускать с правами суперпользователя!'
  exit 1
fi

# Проверка существования ВМ
if virsh list --all | grep -q "${VM_NAME}"; then
  echo "Ошибка: ВМ с именем ${VM_NAME} уже существует!"
  exit 1
fi

# Проверка наличия ISO-образа
if [ ! -f "${ISO_PATH}" ]; then
  echo "Ошибка: ISO не найден в ${ISO_PATH}"
  exit 1
fi

# Создание ВМ
virt-install \
  --name="${VM_NAME}" \
  --ram="${RAM}" \
  --vcpus="${VCPUS}" \
  --disk path="/var/lib/libvirt/images/${VM_NAME}.qcow2",size="${DISK_SIZE}",format=qcow2,bus=virtio \
  --os-variant="${OS_VARIANT}" \
  --network bridge="${BRIDGE}" \
  --graphics spice \
  --video qxl \
  --cdrom="${ISO_PATH}" \
  --noautoconsole \
  --cpu host-passthrough \
  --boot uefi \
  --description "SonarQube (Ubuntu 22.04)"

echo "✔ ВМ создана! Подключитесь через SSH после установки."
echo
echo "1. Завершить установку Ubuntu Server через консоль SPICE/VNC"
echo
echo "2. После установки выполнить следующие команды внутри ВМ для установки Docker"
echo
echo " - Установить репозиторий"
echo "   sudo apt update"
echo "   sudo apt install ca-certificates curl -y"
echo "   sudo install -m 0755 -d /etc/apt/keyrings"
echo "   sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc"
echo "   sudo chmod a+r /etc/apt/keyrings/docker.asc"
echo "   echo \\"
echo "     \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \\"
echo "     \$(. /etc/os-release && echo \"\${UBUNTU_CODENAME:-\$VERSION_CODENAME}\") stable\" | \\"
echo "     sudo tee /etc/apt/sources.list.d/docker.list > /dev/null"
echo "   sudo apt update"
echo
echo " - Установить Docker"
echo "   sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y"
echo
echo " - Проверить успешность инсталяции запуском имеджа hello-world"
echo "   sudo docker run hello-world"
echo
echo " - Для возможности запуска Docker без повышения привелегий создать группу docker и добавить своего пользователя в эту группу"
echo "   sudo groupadd docker"
echo "   sudo usermod -aG docker \$USER"
echo "   newgrp docker"
echo "   docker run hello-world"

