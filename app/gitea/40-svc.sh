#!/bin/bash

NODE_PORTS=${NODE_PORTS:-22}
NODE_SSH_PORT=$(echo $NODE_PORTS | { read NODE_SSH_PORT NODE_REST_PORTS ; echo $NODE_SSH_PORT ; })

ACTION=$1
case $ACTION in
	"on")
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Service
metadata:
  name: web
  namespace: app-gitea
spec:
  ports:
    - name: web
      port: 3000
      protocol: TCP
  selector:
    app: gitea
---
apiVersion: v1
kind: Service
metadata:
  name: ssh
  namespace: app-gitea
spec:
  type: NodePort
  ports:
    - name: ssh
      port: 22
      nodePort: ${NODE_SSH_PORT}
      protocol: TCP
  selector:
    app: gitea
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: app-gitea
spec:
  ports:
    - name: postgres
      port: 5432
      protocol: TCP
  selector:
    app: postgres
EOF
	;;
	"off")
		kubectl delete -n app-gitea svc web
		kubectl delete -n app-gitea svc ssh
		kubectl delete -n app-gitea svc postgres
		;;
	*)
		echo $(basename $0) on/off
		;;
esac
