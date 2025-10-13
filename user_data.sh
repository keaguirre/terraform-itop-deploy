#!/bin/bash
set -e

# Log todo
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=========================================="
echo "Starting iTop initialization"
echo "Date: $(date)"
echo "=========================================="

# Esperar a que cloud-init termine
echo "Waiting for cloud-init to finish..."
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
  sleep 1
done
echo "Cloud-init finished"

# Montar EFS
echo "Mounting EFS ${efs_id}..."
/usr/local/bin/mount-efs.sh ${efs_id} ${aws_region}

# Inicializar iTop
echo "Initializing iTop..."
/usr/local/bin/initialize-itop.sh

echo "=========================================="
echo "iTop initialization completed"
echo "Date: $(date)"
echo "=========================================="