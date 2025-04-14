# dns-update-job

Very simple script to run as kubernetes job and update my public ip address into a record in cloudflare.

## create the namespace and the secret
```
kubectl create ns
```

```
kubectl create secret generic cloudflare-dns-secret \
  --from-literal=CLOUDFLARE_API_KEY=xxxxxx \
  --from-literal=CLOUDFLARE_EMAIL=your-email@gmail.com \
  --from-literal=DOMAIN=your.domain.com \
  --from-literal=RECORD=your-record \
  -n dns
```


## create the job
```
kubectl apply -f job.yaml -n dns
```

## check job stats:
```
kubectl get jobs -n dns
```
