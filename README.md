# 🚀 Test tecnico EXSquared LATAM - Alain Cervantes 🚀

[![Minikube](https://img.shields.io/badge/Minikube-v1.26-blue)](https://minikube.sigs.k8s.io/docs/) 
[![Docker](https://img.shields.io/badge/Docker-20.10.8-blue)](https://www.docker.com/products/docker-desktop)
[![NodeJS](https://img.shields.io/badge/NodeJS-v14.17-green)](https://nodejs.org/en/)
[![Express](https://img.shields.io/badge/Express-v4.17.1-lightgrey)](https://expressjs.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.21-blue)](https://kubernetes.io/)
[![CI/CD](https://img.shields.io/badge/CI--CD-AzureDevOps-blueviolet)](https://azure.microsoft.com/en-us/services/devops/)
[![Terraform](https://img.shields.io/badge/Terraform-v1.3.7-623ce4)](https://www.terraform.io/)

## 📄 Manual del Test Técnico

Puedes descargar o visualizar el manual completo del test técnico en formato PDF aquí:

[📥 Descargar Manual del Test Técnico](Test-Solutions-and-Explanations-AlainCervantes.pdf)

## 🌟 Descripción

Este proyecto se ha creado una infraestructura de recursos en **Azure** utilizando **Terraform**, que incluye una máquina virtual, una base de datos, y un balanceador de carga. ademas una demostración de una **aplicación full-stack** que utiliza **MongoDB, NodeJS, Express, Docker**, y **Kubernetes (Minikube)**. 

Las características clave de este proyecto incluyen:

- **Terraform** para la creación de infraestructura en **Azure**, con recursos como:
  - Máquina virtual (VM)
  - Base de datos
  - Balanceador de carga
  - Redes virtuales
- **Node.js** como servidor con una API **Express** que interactúa con **MongoDB**.
- **Docker** para la contenedorización de la aplicación.
- **Kubernetes** y **Minikube** para ejecutar y gestionar el despliegue localmente.
- **Pipeline de CI/CD** con **Azure DevOps** para automatizar las compilaciones y los despliegues.

## 🛠 Tecnologías Utilizadas

- **Terraform** - Gestión de infraestructura como código (IaC) en Azure.
- **Node.js** - Entorno de ejecución para el backend.
- **Express** - Framework para crear APIs robustas.
- **MongoDB** - Base de datos NoSQL.
- **Docker** - Contenedorización de la aplicación.
- **Kubernetes (Minikube)** - Clúster local de Kubernetes.
- **Azure DevOps** - Plataforma para pipelines de CI/CD.

## ⚙️ Instrucciones de Configuración

### Pre-requisitos:

- Docker y Docker Compose
- Minikube instalado localmente
- Terraform instalado
- Cuenta en Azure con permisos para crear recursos
- Node.js y npm instalados

### Pasos para Ejecutar Localmente:

1. **Clonar el repositorio**:

    ```bash
    [git clone https://github.com/Alaincp89/Test-Solutions-and-Explanations.git)
    cd Test-Solutions-and-Explanations
    ```

2. **Instalar dependencias**:

    ```bash
    npm install
    ```

3. **Ejecutar la aplicación con Docker**:

    ```bash
    docker-compose up --build
    ```

4. **Acceder a la aplicación**:

    Navega a `http://localhost:3000` para ver la aplicación en funcionamiento.

5. **Desplegar con Minikube**:

    ```bash
    minikube start
    eval $(minikube docker-env)
    docker build -t miapp:1 .
    kubectl apply -f kubernetes/k8s.yml
    ```

    Para acceder al servicio en Minikube, ejecuta:

    ```bash
    minikube service miapp-service
    ```

6. **Desplegar la infraestructura en Azure con Terraform**:

    - Dirígete a la carpeta de **Terraform** en el proyecto:

    ```bash
    cd terraform/
    ```

    - Inicializa y despliega la infraestructura en Azure:

    ```bash
    terraform init
    terraform apply
    ```

    Terraform creará los siguientes recursos en Azure:
    - Máquina Virtual (VM)
    - Base de Datos
    - Balanceador de Carga
    - Redes Virtuales

---

## 🧪 Testing Pipeline

### Descripción del Pipeline

Este proyecto utiliza **Azure DevOps** para automatizar el proceso de construcción, prueba y despliegue. El pipeline realiza las siguientes tareas:

1. **Verificar versiones**: Asegura que las versiones de Docker, Minikube y Kubernetes CLI (`kubectl`) estén correctamente instaladas.
2. **Iniciar Minikube**: Asegura que Minikube esté en ejecución.
3. **Construir la Imagen Docker**: Verifica si la imagen Docker `miapp:1` ya existe, y si es así, la elimina antes de construir una nueva.
4. **Desplegar en Kubernetes**: Aplica la configuración de Kubernetes (Deployment y Service) en Minikube.
5. **Desplegar la Infraestructura en Azure**: Utiliza Terraform para crear y gestionar la infraestructura en Azure.
6. **Validar el Despliegue**: Verifica el estado de los pods, servicios en Minikube, y la infraestructura en Azure.

### Principales Pasos del Pipeline:

- **Verificar Docker, Minikube y kubectl**:
    Asegura que el entorno esté correctamente configurado antes de iniciar la aplicación.

    ```bash
    docker version
    minikube version
    kubectl version --client
    ```

- **Iniciar Minikube**:
    Inicia un clúster de Kubernetes local utilizando Minikube.

    ```bash
    minikube start
    ```

- **Construir la Imagen Docker**:
    El pipeline automáticamente construye o reconstruye la imagen Docker de la aplicación si es necesario.

    ```bash
    docker build -t miapp:1 .
    ```

- **Desplegar en Kubernetes**:
    Despliega la aplicación en Minikube usando la configuración de Kubernetes (`kubernetes/k8s.yml`).

    ```bash
    kubectl apply -f kubernetes/k8s.yml
    ```

- **Desplegar Infraestructura en Azure**:
    Utiliza Terraform para crear la infraestructura en Azure, asegurando que los recursos necesarios estén disponibles antes de desplegar la aplicación.

    ```bash
    terraform apply
    ```

## 🌍 Arquitectura del Proyecto

El siguiente diagrama representa la arquitectura del proyecto tanto a nivel local (con Minikube) como en la nube (Azure):

```plaintext
+------------------------------------------------------------+
|                                                            |
|      Clúster Local de Kubernetes (Minikube)                |
|                                                            |
|  +-----------------------------------------------------+   |
|  |    Red Interna (mired)                              |   |
|  |                                                     |   |
|  |  +----------------------------------------------+   |   |
|  |  |   Contenedor Docker (my_node)                |   |   |
|  |  |   - Imagen: miapp:1                          |   |   |
|  |  |   - Basado en Dockerfile                     |   |   |
|  |  |   - Servicio API Express                     |   |   |
|  |  +----------------------------------------------+   |   |
|  |                                                     |   |
|  |  +----------------------------------------------+   |   |
|  |  |   Contenedor Docker (my_mongo)               |   |   |
|  |  |   - Imagen: mongo                            |   |   |
|  |  |   - Base de datos MongoDB                    |   |   |
|  |  +----------------------------------------------+   |   |
|  +-----------------------------------------------------+   |
|                                                            |
+------------------------------------------------------------+


 |          Terraform Infra          |

+---------------------------------------------------+
|                                                   |
|            Infraestructura en Azure               |
|                                                   |
|  +----------------+    +---------------------+    |
|  |  Máquina       |    |  Base de Datos      |    |
|  |  Virtual       |    +---------------------+    |
|  +----------------+  +-----------------------+    |
|                      |  Balanceador de Carga |    |
|                      +-----------------------+    |
+---------------------------------------------------+

