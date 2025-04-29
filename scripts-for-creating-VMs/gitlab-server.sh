#!/bin/bash

# ============================================================================ #
# Создание ВМ для учебного GitLab сервера (ubuntu-server 22.04)                #
# ============================================================================ #

VM_NAME="GitLab-Server"          # Имя виртуальной машины
RAM="4096"                       # 4ГБ RAM (минимум для GitLab)
VCPUS="4"                        # 4 vCPU
DISK_SIZE="40"                   # 40ГБ
OS_VARIANT="ubuntu22.04"
ISO_PATH="/var/lib/libvirt/images/ubuntu-22.04.5-live-server-amd64.iso"
BRIDGE="virbr0"                  # Используем bridge для сети

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
  echo "Ошибка: ISO-образ не найден по пути ${ISO_PATH}"
  echo "Скачайте Ubuntu Server 22.04 и поместите в указанную директорию"
  exit 1
fi

# Создание ВМ
echo "➤ Создаем виртуальную машину для GitLab..."
virt-install \
  --name="${VM_NAME}" \
  --ram="${RAM}" \
  --vcpus="${VCPUS}" \
  --disk path="/var/lib/libvirt/images/${VM_NAME}.qcow2",size="${DISK_SIZE}",format=qcow2 \
  --os-variant="${OS_VARIANT}" \
  --network bridge="${BRIDGE}" \
  --graphics spice \
  --video qxl \
  --cdrom="${ISO_PATH}" \
  --noautoconsole \
  --cpu host-passthrough \
  --boot uefi \
  --description "Учебный сервер GitLab"

echo "✔ ВМ успешно создана!"
echo
echo "Мои дальнейшие шаги:"
echo
echo "1. Завершить установку Ubuntu Server через консоль SPICE/VNC"
echo
echo "2. После установки выполнить следующие команды внутри ВМ для установки GitLab сервера:"
echo "   sudo apt update && sudo apt upgrade -y"
echo "   curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash"
echo "   sudo apt install gitlab-ce"
echo
echo "3. Настроить external_url в /etc/gitlab/gitlab.rb:"
echo "   sudo nano /etc/gitlab/gitlab.rb"
echo "   Необходимо настроить:"
echo "   external_url 'https://<IP-адрес-ВМ>'"
echo "   nginx['redirect_http_to_https'] = true"
echo "   letsencrypt['enable'] = false  # Отключить Let's Encrypt (если он отключен, можно использовать http)"
echo "   * Есть ещё параметры для указания файлов сертификатов:"
echo "     nginx['ssl_certificate'] = \"/etc/gitlab/ssl/gitlab.local.crt\""
echo "     nginx['ssl_certificate_key'] = \"/etc/gitlab/ssl/gitlab.local.key\""
echo "     но с ними я не работал *"
echo
echo "4. Сгенерировать самоподписанный сертификат, если собираюсь использовать https:"
echo "   sudo mkdir -p /etc/gitlab/ssl"
echo "   sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \\"
echo "     -keyout /etc/gitlab/ssl/<IP-адрес-ВМ>.key \\"
echo "     -out /etc/gitlab/ssl/<IP-адрес-ВМ>.crt \\"
echo "     -subj \"/CN=<IP-адрес-ВМ>\""
echo
echo "5. Применить настройки:"
echo "   sudo gitlab-ctl reconfigure"
echo
echo "6. Проверить доступ:"
echo "   https://<IP-адрес-ВМ> или http://<IP-адрес-ВМ>"
