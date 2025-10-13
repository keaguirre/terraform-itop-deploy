#!/bin/bash
set -euo pipefail

# ===== Logging a archivo y consola =====
exec > >(tee /var/log/user-data.log)
exec 2>&1

log() { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] $*"; }

# >>> Solo estas dos las rellena Terraform
EFS_ID="${efs_id}"
AWS_REGION="${aws_region}"

# Variables internas del script (escapadas con $$)
MOUNT_POINT="/var/www/html"
EFS_DNS="$${EFS_ID}.efs.$${AWS_REGION}.amazonaws.com"
DNS_RETRIES=20
SLEEP_SECONDS=6

echo "=========================================="
log "Starting iTop initialization"
echo "=========================================="

# --- Diagnóstico previo rápido ---
log "AMI boot region: $${AWS_REGION}"
log "EFS ID: $${EFS_ID} | DNS: $${EFS_DNS}"
log "Mount point: $${MOUNT_POINT}"

# --- Comprobación DNS con reintentos ---
i=1
resolved=0
while [ "$i" -le "$DNS_RETRIES" ]; do
  if getent hosts "$EFS_DNS" >/dev/null 2>&1; then
    log "DNS resolve OK para $EFS_DNS (intento $i)"
    resolved=1
    break
  fi
  log "DNS aún no resuelve $EFS_DNS (intento $i/$DNS_RETRIES). Reintentando en $SLEEP_SECONDS s..."
  sleep "$SLEEP_SECONDS"
  i=$((i + 1))
done

if [ "$resolved" -ne 1 ]; then
  log "ADVERTENCIA: DNS no resolvió $EFS_DNS tras $DNS_RETRIES intentos. Continuaré e intentaré montar igual."
fi

# --- Crear punto de montaje si no existe ---
if [ ! -d "$MOUNT_POINT" ]; then
  log "Creando $MOUNT_POINT ..."
  mkdir -p "$MOUNT_POINT"
fi

# --- Intentar montaje usando tu script (no abortar si falla) ---
log "Mounting EFS $EFS_ID..."
if /usr/local/bin/mount-efs.sh "$EFS_ID" "$AWS_REGION"; then
  log "mount-efs.sh terminó con código 0"
else
  rc=$?
  log "ERROR: mount-efs.sh retornó código $rc."
fi

# --- Verificación explícita del montaje y diagnóstico ---
if mountpoint -q "$MOUNT_POINT"; then
  EFS_MOUNT_STATUS="OK"
  log "EFS MONTADO CORRECTAMENTE en $MOUNT_POINT"
else
  EFS_MOUNT_STATUS="FAILED"
  log "EFS NO MONTADO en $MOUNT_POINT"
  log "Diagnóstico rápido:"
  log "- df -hT:"; df -hT || true
  log "- /etc/fstab (entradas efs/nfs):"; grep -E "(efs|nfs)" /etc/fstab || true
  log "- getent hosts $EFS_DNS:"; getent hosts "$EFS_DNS" || true
  log "- Últimos mensajes del kernel:"; dmesg | tail -n 50 || true
  echo "EFS mount FAILED at $(date -u '+%Y-%m-%dT%H:%M:%SZ')" > /var/log/efs-mount.failed
fi

echo "------------------------------------------"
log "EFS_MOUNT_STATUS=$EFS_MOUNT_STATUS"
echo "------------------------------------------"

if [ "$EFS_MOUNT_STATUS" = "OK" ]; then
  log "Initializing iTop..."
  /usr/local/bin/initialize-itop.sh || { log "ERROR: initialize-itop.sh falló"; exit 1; }
else
  log "SALTANDO initialize-itop.sh porque el EFS NO está montado."
fi

echo "=========================================="
log "iTop initialization completed (EFS: $EFS_MOUNT_STATUS)"
echo "=========================================="

# Resumen final útil
log "Resumen:"
log " mountpoint $MOUNT_POINT: $(mountpoint -q "$MOUNT_POINT" && echo 'MONTADO' || echo 'NO MONTADO')"
log " df -hT | grep -E '(efs|nfs|$MOUNT_POINT)':"
df -hT | grep -E "(efs|nfs|$MOUNT_POINT)" || true
