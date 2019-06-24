#!/bin/bash

APPNAME=${APPNAME:-nextcloud}

NEXTCLOUD_VERSION=${NEXTCLOUD_VERSION:-nextcloud:16.0.1}

ACTION=$1
case $ACTION in
"on")
	cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nextcloud
  namespace: app-${APPNAME}
  labels:
    app: nextcloud
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nextcloud
  template:
    metadata:
      labels:
        app: nextcloud
    spec:
      containers:
        - image: ${NEXTCLOUD_VERSION}
          name: nextcloud
          imagePullPolicy: IfNotPresent
          envFrom:
            - configMapRef:
                name: nextcloud-env
          env:
            - name: NEXTCLOUD_ADMIN_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: passwords
                  key: admin-password
            - name: MYSQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: passwords
                  key: user-password
          ports:
            - name: web
              containerPort: 80
              protocol: TCP
          volumeMounts:
            - mountPath: /var/www/html/data
              name: data
              subPath: data
            - mountPath: /var/www/html/config
              name: data
              subPath: config
            - mountPath: /var/www/html/custom_apps
              name: data
              subPath: custom_apps
            - mountPath: /var/www/html/themes
              name: data
              subPath: themes
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: normal
EOF
	;;
"off")
	kubectl delete -n app-${APPNAME} deploy nextcloud
	;;
*)
	echo $(basename $0) on/off
	;;
esac
