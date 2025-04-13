# Manifiestos Kubernetes - Proyecto AT_Cloud

Este repositorio contiene los manifiestos YAML necesarios para desplegar una aplicación web estática utilizando Kubernetes sobre Minikube. La app se sirve con un contenedor Nginx que monta su contenido desde un volumen persistente.

## Estructura del repositorio
AT_Cloud
├──manifiestos/
│	├── deployments/
│	│   └── web-deployment.yaml
│	├── services/
│	│   └── web-service.yaml
│	├── pv-pvc/
│	│   ├── persistent-volume.yaml
│	│   └── persistent-volume-claim.yaml
│	└── README.md
└──static-website/
│	├── index.html
│	├── style.css
│	└── assets/

## Requisitos

- Minikube
- Docker (como driver de Minikube en Windows)
- Git
- PowerShell o terminal compatible

## Pasos de despliegue

1. Iniciar Minikube con perfil y driver Docker:
   ```bash
   minikube start -p proyecto-0311 --driver=docker
   minikube profile proyecto-0311

2. Montar el directorio del sitio web:
   ```bash
   minikube mount "C:/ruta/a/static-website:/mnt/data/sitio-web"
*(dejar esta terminal abierta)*

3. En otra terminal, aplicar los manifiestos:
   ```bash
   kubectl apply -f pv-pvc/
   kubectl apply -f deployments/
   kubectl apply -f services/

4. Verificar que los recursos se hayan creado:
   ```bash
   kubectl get pv,pvc,deploy,svc

5. Acceder a la aplicación:
   ```bash
   minikube service web-service
---
### Autora
Florencia Ortiz 👩‍💻
Trabajo práctico de K8S - 2025