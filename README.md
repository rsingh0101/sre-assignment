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
<img src="https://github.com/rsingh0101/sre-assignment/blob/main/img/Argo-cd.png?raw=true" style="width: 100%;">
## Metrics app 

Go to browser to run following,
```http://metrics-app.mykubernetescluster.com:30000/counter```
<img src="https://github.com/rsingh0101/sre-assignment/blob/main/img/counter-ingress.png?raw=true" style="width: 100%;">
Response must be,
```Counter value: 1```
After refresh it respond with error,
```The server encountered an internal error and was unable to complete your request. Either the server is overloaded or there is an error in the application.```
<img src="https://github.com/rsingh0101/sre-assignment/blob/main/img/counter-error.png?raw=true" style="width: 100%;">

## Root Cause analysis

<img src="https://github.com/rsingh0101/sre-assignment/blob/main/img/counter-error-rca.png?raw=true" style="width: 100%;">

File ```"/usr/local/lib/python3.12/random.py"```, line 319, in randrange
    raise ```ValueError(f"empty range in randrange({start}, {stop})")```
```ValueError: empty range in randrange(180, 31)```


The arguments are in the wrong order — random.randint(a, b) expects a <= b. Here, 180 > 30, which results in empty range.

## Fix

To correct the error caused by invalid ```randrange(180, 31)``` logic in the metrics app code, the offending logic was externalized into a ConfigMap and mounted into the container as a volume. This allows runtime replacement of the application code without needing to rebuild the image.

```yaml
metricsFix:
  enabled: true
  fileName: metrics.py
  mountPath: /app/metrics.py
  content: |
    import random
    import threading
    import time

    def trigger_background_collection():
        delay = random.randint(30, 180)  # Corrected range: min < max
        threading.Thread(target=collect_metrics_after_delay, args=(delay,)).start()

    def collect_metrics_after_delay(delay):
        time.sleep(delay)
        print(f"[METRICS] Background metrics collected after {delay} seconds")

```
After changing templates and values file, re-applying changes to sync new changes in argocd server.

<img src="https://github.com/rsingh0101/sre-assignment/blob/main/img/counter-error-fix-1.png?raw=true" style="width: 100%;">
<img src="https://github.com/rsingh0101/sre-assignment/blob/main/img/counter-error-fix-2.png?raw=true" style="width: 100%;">

Now the counter is updating normally with no internal server error caused by logic error in code.
