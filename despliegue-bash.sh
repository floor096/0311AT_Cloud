#!/bin/bash

# =========================
# Script de despliegue AT_Cloud
# =========================

set -e
set -o pipefail

# === Modo continuación ===
CONTINUE_MODE=false
if [ "$1" = "--continue-deployment" ]; then
    CONTINUE_MODE=true
    shift
fi

# === Variables ===
BASE_DIR="${1:-/home/$USER/Desktop/AT0311-bash}"
MANIFESTS_REPO="https://github.com/floor096/0311AT_Cloud.git"
WEBSITE_REPO="https://github.com/floor096/static-website.git"
MINIKUBE_PROFILE="proyecto-0311AT-bash"
MOUNT_PATH="/mnt/data/sitio-web"

# === Verificar dependencias ===
echo "🔍 Verificando herramientas necesarias..."
for cmd in minikube kubectl git mkdir curl; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "❌ Falta la herramienta: $cmd"
        exit 1
    fi
done

# === Verificar Docker ===
if ! docker info &>/dev/null; then
    echo "❌ Docker no está corriendo. Inicia Docker Desktop y volvé a intentar."
    exit 1
fi

# === Crear directorio base ===
create_base_directory() {
    echo "📁 Creando base en $BASE_DIR..."
    mkdir -p "$BASE_DIR"
}

# === Clonar repositorios ===
clone_repositories() {
    cd "$BASE_DIR" || exit 1
    [ -d 0311AT_Cloud ] || git clone "$MANIFESTS_REPO"
    [ -d static-website ] || git clone "$WEBSITE_REPO"
}

# === Iniciar Minikube ===
start_minikube() {
    echo "🚀 Iniciando Minikube con perfil $MINIKUBE_PROFILE..."
    if ! minikube profile list | grep -q "$MINIKUBE_PROFILE"; then
        minikube start -p "$MINIKUBE_PROFILE" --driver=docker
    else
        minikube start -p "$MINIKUBE_PROFILE"
    fi
    minikube profile "$MINIKUBE_PROFILE"
}

# === Montar carpeta del sitio ===
mount_website() {
    WEBSITE_PATH="$BASE_DIR/static-website"
    if [ ! -d "$WEBSITE_PATH" ]; then
        echo "❌ No existe la carpeta del sitio en $WEBSITE_PATH"
        exit 1
    fi
    echo "📦 Montando sitio web: $WEBSITE_PATH → $MOUNT_PATH"
    echo "❗ Dejá esta terminal abierta. En otra terminal, ejecutá: bash $0 --continue-deployment"
    read -p "⏳ Presiona Enter para continuar..."
    minikube mount "$WEBSITE_PATH:$MOUNT_PATH"
}

# === Aplicar manifiestos ===
apply_manifests() {
    cd "${BASE_DIR}/0311AT_Cloud" || exit 1
    echo "📄 Aplicando volúmenes..."
    kubectl apply -f pv-pvc/
    echo "📄 Aplicando deployments..."
    kubectl apply -f deployments/
    echo "📄 Aplicando servicios..."
    kubectl apply -f services/
    echo "⏳ Esperando que el pod inicie..."
    sleep 5
    echo "🔍 Verificando que el PVC esté montado..."
    kubectl describe pod -l app=web | grep web-pvc || {
        echo "❌ El pod no está usando el PVC correctamente."
        exit 1
    }
    wait_for_service_readiness
}

# === Esperar que el servicio esté disponible ===
wait_for_service_readiness() {
    echo "⏳ Esperando que el servicio web-service esté listo..."
    local max_attempts=30
    local attempt=1
    while [ $attempt -le $max_attempts ]; do
        echo "  Intento $attempt de $max_attempts..."
        if kubectl get pods -l app=web | grep -q Running; then
            if minikube service web-service --url -p "$MINIKUBE_PROFILE" >/dev/null 2>&1; then
                echo "✅ Servicio web-service disponible!"
                break
            else
                echo "  Pod ejecutándose, pero el servicio aún no responde..."
            fi
        else
            echo "  Pod aún no está en estado Running..."
        fi
        sleep 5
        attempt=$((attempt + 1))
    done
    if [ $attempt -gt $max_attempts ]; then
        echo "❌ El servicio no estuvo disponible después de $max_attempts intentos."
        exit 1
    fi
}

# === Verificar acceso web ===
access_application() {
    echo "🌐 Verificando acceso web..."
    URL=$(minikube service web-service --url -p "$MINIKUBE_PROFILE")
    echo "📡 Probing $URL ..."
    sleep 5
    if curl -s "$URL" | grep -q "<html"; then
        echo "✅ Sitio disponible correctamente en: $URL"
        echo "🌐 Accedé manualmente al sitio: $URL"
        xdg-open "$URL" 2>/dev/null || true
    else
        echo "❌ El sitio no respondió como se esperaba. Revisa el montaje."
        echo "🌐 Podés intentar acceder igual a: $URL"
        exit 1
    fi
}

# === Instrucciones finales ===
show_instructions() {
    echo ""
    echo "======================="
    echo "✅ DESPLIEGUE COMPLETADO"
    echo "======================="
    echo ""
    echo "🔧 Para detener: minikube stop -p $MINIKUBE_PROFILE"
    echo "🧹 Para borrar:  minikube delete -p $MINIKUBE_PROFILE"
    echo ""
}

# === MAIN ===
main() {
    if [ "$CONTINUE_MODE" = true ]; then
        echo "🔄 Continuando con el despliegue..."
        apply_manifests
        access_application
        show_instructions
        exit 0
    else
        echo "🚀 INICIANDO SCRIPT DE DESPLIEGUE"
        create_base_directory
        clone_repositories
        start_minikube
        mount_website
        # El script se detendrá aquí debido al mount
    fi
}

main
