## About
Solution to infrastructure provisiong for automated deployment of application and argocd integration. Additional by default creation of metrics app.

## Pre-requisites
Following binaries installation are required to run the scripts
*kind*
*kubectl*
*helm*

## Steps to deploy
Docker/Docker desktop standard installation for running kubernetes cluster
Alter domain if required in ```cluster-start.sh``` script for custom domain name (```default: mykubernetescluster.com``` ).

Run the script-
```./cluster-start.sh 2>&1 | tee -a cluster-start.log```

## Verification
Create hosts entry for dns resolution

In windows, go to ```C:\Windows\System32\drivers\etc``` path, and add follwoing entry in hosts file,
````127.0.0.1 argocd.mykubernetescluster.com ````

In Ubuntu/linux, edit hosts file directly ```/etc/hosts```, and add following entry,
```127.0.0.1 argocd.mykubernetescluster.com```

Open browser with 
    ```http://argocd.mykubernetescluster.com:30000```

## Metrics app 

Go to browser to run following,
```http://metrics-app.mykubernetescluster.com:30000/counter```

Response must be,
```Counter value: 1```