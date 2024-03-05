# bitnami-mariadb-backup-sidecar

Bitnami MariaDB Backup sidecar with backup plans
- [x] Daily backup with 7 days retention
- [x] Monthly backup with 365 days retention

## Showcase

- [ ] Adjust [crontab/root](crontab/root) according to your needs (i.e. every 10 minutes)
- [ ] Adjust [kustomize/demo/secret/bitnami-mariadb-backup-sidecar.yaml](kustomize/demo/secret/bitnami-mariadb-backup-sidecar.yaml) according to your needs.
- [ ] Build the image from source, push to your registry provider.
- [ ] Apply 
  
  ```yaml
  kubectl apply -k kustomize/demo
  ```

## Build image from source

With Docker

```bash
docker build -t fauzanelka/bitnami-mariadb-backup-sidecar:latest .
```

## Usage

Create environment variables secret with the reference below

```yaml
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: mariadb-backup-env
stringData:
  CRON_TZ: America/New_York
  MARIADB_HOST: localhost
  MARIADB_DATABASE: test
  MARIADB_USER: root
  MARIADB_PASSWORD: root
  DAILY_BACKUP_DIR: /mnt/backup-daily
  MONTHLY_BACKUP_DIR: /mnt/backup-monthly
  RCLONE_S3_PROVIDER: AWS
  RCLONE_S3_ACCESS_KEY_ID: 
  RCLONE_S3_SECRET_ACCESS_KEY: 
  RCLONE_S3_REGION: us-east-1
  RCLONE_S3_ENDPOINT: s3.us-east-1.amazonaws.com
  RCLONE_S3_BUCKET_DAILY: test-bucket
  RCLONE_S3_BUCKET_MONTHLY: test-bucket
```

Apply

```bash
kubectl apply -f mariadb-backup-env.yaml
```

Create two persistent volume claim for daily and monthly backup storage with the reference below

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mariadb-backup-daily
spec:
  resources:
    requests:
      storage: 8Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
```

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mariadb-backup-monthly
spec:
  resources:
    requests:
      storage: 8Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
```

Apply

```bash
kubectl apply -f mariadb-backup-daily.yaml
kubectl apply -f mariadb-backup-monthly.yaml
```

Get bitnami/mariadb current release values and output to yaml file

```bash
helm -n <namespace> get values <release> -oyaml > current-release-values.yaml
```

Append extraVolumes and sidecars with the reference below

```yaml
...
primary:
  extraVolumes:
    - name: backup-daily
      persistentVolumeClaim:
        claimName: mariadb-backup-daily
    - name: backup-monthly
      persistentVolumeClaim:
        claimName: mariadb-backup-monthly
  sidecars:
    - name: mariadb-backup
      image: ghcr.io/fauzanelka/bitnami-mariadb-backup-sidecar:11.2-debian-11
      imagePullPolicy: Always
      envFrom:
        - secretRef:
            name: mariadb-backup-env
      volumeMounts:
        - mountPath: /mnt/backup-daily
          name: backup-daily
        - mountPath: /mnt/backup-monthly
          name: backup-monthly
...
```

Apply

```bash
helm -n <namespace> upgrade -f current-release-values.yaml --version <chart-version> <release> bitnami/mariadb
```