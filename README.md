## About
This project provides a complete infrastructure provisioning solution that automates the deployment of applications with integrated Argo CD support. It also sets up a default metrics app as part of the initial deployment process. Alongwith domain assigned to cluster for external access via ingress.

## Pre-requisites
Following binaries installation are required to run the scripts
*kind*
*kubectl*
*helm*
Use script to cross-verify installations,
```sh pre-requisites.sh```

## Steps to deploy
Docker/Docker desktop standard installation for running kubernetes cluster
Alter domain if required in ```cluster-start.sh``` script for custom domain name (```default: mykubernetescluster.com``` ).

Run the script-
```./cluster-start.sh 2>&1 | tee -a cluster-start.log```

## Verification
Create hosts entry for dns resolution

In windows, go to ```C:\Windows\System32\drivers\etc``` path, and add follwoing entry in hosts file,
````127.0.0.1 argocd.mykubernetescluster.com metrics-app.mykubernetescluster.com````

In Ubuntu/linux, edit hosts file directly ```/etc/hosts```, and add following entry,
```127.0.0.1 argocd.mykubernetescluster.com metrics-app.mykubernetescluster.com```

Open browser with 
    ```http://argocd.mykubernetescluster.com:30000```

## Metrics app 

Go to browser to run following,
```http://metrics-app.mykubernetescluster.com:30000/counter```

Response must be,
```Counter value: 1```
After refresh it respond with error,
```The server encountered an internal error and was unable to complete your request. Either the server is overloaded or there is an error in the application.```

Possible causes and fixes-
