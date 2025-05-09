# 📦 Manifiestos Kubernetes - Proyecto AT_Cloud

Este repositorio contiene los manifiestos YAML necesarios para desplegar una aplicación web estática utilizando **Kubernetes sobre Minikube**.  
La app se sirve a través de un contenedor **Nginx**, que monta su contenido desde un **volumen persistente**.

---


## 📚 Estructura general
```plaintext
AT0311
├── 0311AT_Cloud/
│   ├── deployments/
│   │   └── web-deployment.yaml
│   ├── services/
│   │   └── web-service.yaml
│   ├── pv-pvc/
│   │   ├── persistent-volume.yaml
│   │   └── persistent-volume-claim.yaml
│   └── README.md
└── static-website/
    ├── index.html
    ├── style.css
    └── assets/
```

## 🛠️ Requisitos

- Minikube
- Docker (como driver de Minikube en Windows)
- Git
- PowerShell o terminal compatible
- Contar con clave SSH.

## 🚀Pasos de despliegue

1. Crear directorio base
   En `C:/`, crea un directorio llamado `AT0311`:
   ```bash
   mkdir AT0311

2. Clonar los repositorios:
   
   Dentro del directorio `AT0311`:

   - Para la página web: Primero realiza un fork del repositorio original, luego clónalo con:
     ```bash
     git clone git@github.com:floor096/static-website.git
    **Importante:** Verifique que no existe un repositorio con el mismo nombre en su cuenta de GitHub antes de hacer el fork, ya que esto podría causar conflictos.

   - Para los manifiestos: Clona directamente el repositorio con:
     ```bash
     git clone git@github.com:floor096/0311AT_Cloud.git

3. Iniciar Minikube:
   Iniciar Minikube con un perfil personalizado y driver Docker.
   ```bash
   minikube start -p proyecto-0311AT --driver=docker
   minikube profile proyecto-0311AT

4. Montar el sitio web:
   Ejecuta el siguiente comando, reemplazando `C:/ruta/a/static-website` por la ruta real donde se encuentra la carpeta `static-website` dentro de tu directorio:

   ```bash
   minikube mount "C:/ruta/a/static-website:/mnt/data/sitio-web" 
   ```

   Nota: Debes mantener esta terminal abierta mientras trabajas con el clúster.

5. Aplicar los manifiestos:
   Desde otra terminal, y ubicado dentro de la carpeta de los manifiestos, ejecuta:
   ```bash
   kubectl apply -f pv-pvc/
   kubectl apply -f deployments/
   kubectl apply -f services/

6. Verificar recursos:
   Comprueba que todo se creó correctamente:
   ```bash
   kubectl get pv,pvc,deploy,svc

7. Acceder a la aplicación:
   Levanta el servicio en el navegador:
   ```bash
   minikube service web-service

8. Realizar cambios :
   Debes abrir otra terminal para ejecutar comandos adicionales mientras trabajas en tu aplicación.
   Una vez desplegada, puedes editar los archivos HTML, CSS o imágenes en la carpeta `static-website` de tu máquina local. Gracias al montaje del directorio, los cambios se reflejarán automáticamente en el navegador al refrescar la página.

   ```bash
   # Ejemplo: modifica el archivo index.html
   # Al guardar los cambios y refrescar el navegador, verás las actualizaciones


## Despliegue automático
   1. Descargar el archivo despliegue-bash.sh
   2. Dar permisos de ejecución:

   ```bash
   chmod +x despliegue-bash.sh
   ```

   3. Ejecutar el script y seguir las intrucciones en pantalla:
   
   ```bash
   ./despliegue-bash.sh
   ```
   El script indicará cuando abrir una segunda terminal y continuar con el despliegue.
 

---
### 👩‍💻 Autora
Florencia Ortiz - Trabajo práctico de K8S - 2025