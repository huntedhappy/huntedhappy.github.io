# The Documentation Harbor

## Harbor에 VM Disk가 부족 하게 되면 사이즈를 늘려보자 

## 1. Harbor VM DISK 증설

```shell
df -h

fdisk -l

## 아래와 같이 에러가 나온다면
>> GPT PMBR size mismatch 

## parted로 fix를 해보자
parted /dev/sda
p > f

```
{{< figure src="/images/harbor/1-1.png" title="Disk 상태 확인" >}}
{{< figure src="/images/harbor/1-2.png" title="Disk 증설" >}}
{{< figure src="/images/harbor/1-3.png" title="Disk 증설 후" >}}

```shell
## 그리고 온라인 상태에서 디스크가 보이지 않은 경우는 아래와 같이 하자.
ls /sys/class/scsi_host

for line in $(ls /sys/class/scsi_host)
do
 echo "- - -" > /sys/class/scsi_host/$line/scan
done

ls -lat /dev/sd*
```
{{< figure src="/images/harbor/1-4.png" title="Disk 증설 후 SCAN" >}}
{{< figure src="/images/harbor/1-5.png" title="디스크 증설 확인#1" >}}
{{< figure src="/images/harbor/1-6.png" title="디스크 증설 확인#2" >}}

```shell
pvs
lvs
pvcreate /dev/sdb
vgextend ubuntu-vg /dev/sdb
lvextend /dev/mapper/ubuntu--vg-ubuntu--lv /dev/sdb
resize2fs -p /dev/mapper/ubuntu--vg-ubuntu--lv
```

{{< figure src="/images/harbor/1-7.png" title="Disk 확인 및 증설#1" >}}
{{< figure src="/images/harbor/1-8.png" title="Disk 확인 및 증설#2" >}}

## 2. TANZU에 Pacakge로 설치 한 Harbor 사이즈 증설
```shell
kubectl -n tanzu-system-registry get pvc --selector=component=registry --show-labels

## 아래 storage 용량을 설정한다.

cat << EOF > harbor-registry-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  finalizers:
  - kubernetes.io/pvc-protection
  labels:
    app: harbor
    component: registry
    kapp.k14s.io/app: "1610567506920108209"
    kapp.k14s.io/association: v1.034269eb21810ed9131cc41a27c729d4
  name: harbor-registry-200gb
  namespace: tanzu-system-registry
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 200Gi
  storageClassName: default
  volumeMode: Filesystem
EOF

## 그리고 pvc 생성 후 pod를 삭제 하기 위해 0으로 변경
kubectl -n tanzu-system-registry apply -f harbor-registry-pvc.yaml
kubectl -n tanzu-system-registry scale deployment harbor-registry --replicas=0
watch -n 5 kubectl get pod -n tanzu-system-registry
```
```shell
## volumemount 및 volumes을 설정 해준다.
kubectl -n tanzu-system-registry edit deployment harbor-registry

## 아래 항목을 찾는다.
      volumeMounts:
        - mountPath: /storage
          name: registry-data
        - mountPath: /etc/registry/passwd
          name: registry-htpasswd
          subPath: passwd
        - mountPath: /etc/registry/config.yml
          name: registry-config
          subPath: config.yml
        - mountPath: /etc/harbor/ssl/registry
          name: registry-internal-certs

## 마지막줄에 아래 내용을 추가 한다.
        - mountPath: /storage2
          name: registry-data2

## 아래 항목을 찾는다.
    volumes:
      - name: registry-htpasswd
        secret:
          defaultMode: 420
          items:
          - key: REGISTRY_HTPASSWD
            path: passwd
          secretName: harbor-registry-htpasswd
      - configMap:
          defaultMode: 420
          name: harbor-registry-ver-6
        name: registry-config
      - name: registry-internal-certs
        secret:
          defaultMode: 420
          secretName: harbor-registry-internal-tls
## 마지막줄에 아래 내용을 추가 한다.
      - name: registry-data2
        persistentVolumeClaim:
          claimName: harbor-registry-200gb

## pod를 생성 한다.
kubectl -n tanzu-system-registry scale deployments.apps harbor-registry --replicas=1
watch -n 5 kubectl get pod -n tanzu-system-registry

## pod에 접속 하여 storage repository를 확인 한 후 신규로 연결된 storage2에 Copy.
kubectl -n tanzu-system-registry get po --selector=component=registry
registry=$(kubectl -n tanzu-system-registry get po --selector=component=registry | awk '{print $1}' | grep  harbor)
kubectl -n tanzu-system-registry exec -ti $registry -- /bin/bash
df -h /storage
ls storage/docker/registry/v2/repositories/library/
cp -rfp /storage/* /storage2/

## pod 삭제
kubectl -n tanzu-system-registry scale deployment harbor-registry --replicas=0
watch -n 5 kubectl get pod -n tanzu-system-registry

## 위에 설정한 volumemount 및 volumes 삭제
kubectl -n tanzu-system-registry edit deployment harbor-registry


## 새로 생성 한 pvc 확인
newpvc=$(kubectl get pv |grep 200gb | awk '{print $1}')
kubectl patch pv $newpvc -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'

kubectl get pv | grep harbor-registry
kubectl -n tanzu-system-registry delete pvc --selector=component=registry

## pv에서 아래 내용 삭제
newpv=$(kubectl get pv | grep 200gb | awk '{print $1}')
kubectl edit pv $newpv

## 아래 항목을 찾은 후 claimRef 내용을 삭제 해준다.
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: harbor-registry-100gb
    namespace: tanzu-system-registry
    resourceVersion: "5894668"
    uid: 326b24df-dd6f-4679-af84-6530013aed22
```

### pvc 생성
```shell
cat << EOF > harbor-registry-200gb.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  finalizers:
  - kubernetes.io/pvc-protection
  labels:
    app: harbor
    component: registry
    kapp.k14s.io/app: "1610567506920108209"
    kapp.k14s.io/association: v1.034269eb21810ed9131cc41a27c729d4
  name: harbor-registry
  namespace: tanzu-system-registry
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 200Gi
  storageClassName: default
  volumeName: $newpvc
  volumeMode: Filesystem
EOF

## pvc 생성
kubectl apply -f harbor-registry-200gb.yaml -n tanzu-system-registry

## pod 생성
kubectl -n tanzu-system-registry scale deployment harbor-registry --replicas=1
watch -n 5 kubectl get pod -n tanzu-system-registry
## Delete로 변경
kubectl patch pv $newpvc -p '{"spec":{"persistentVolumeReclaimPolicy":"Delete"}}'

## 확인
registry=$(kubectl -n tanzu-system-registry get po --selector=component=registry | awk '{print $1}' | grep  harbor)
kubectl -n tanzu-system-registry exec -ti $registry -- /bin/bash
df -h /storage
```
{{< figure src="/images/harbor/2-3.png" title="증설 전" >}}
{{< figure src="/images/harbor/2-2.png" title="증설 후 확인" >}}
{{< figure src="/images/harbor/2-1.png" title="Docker Image 확인" >}}
