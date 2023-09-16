# The Documentation K10 Install


컨테이너 환경에서 백업을 하기 위한 방법으로 Veeam에서 제공하는 Kasten 설치 

설치 환경은 Tanzu 1.4 버전으로 진행

<!--more-->
## 1. Requirements

helm 설치, [:(far fa-file-archive fa-fw): Helm](https://github.com/helm/helm/releases).

## 2. 환경
vSphere : 7.0

vSAN

NSX : 3.2

AVI : 21.1.1

Tanzu: 1.4

Ingress: Contour

## 3. 설치
Kasten은 백업으로 유명한 Veeam에서 인수를 하여 컨테이너 환경에서 백업을 도와준다.

### 3.1. Helm 설치
```shell
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version
```
### 3.2. Kasten Repo Update
```shell
helm repo add kasten https://charts.kasten.io/
helm repo update
helm search repo kasten
```
![Kasten Repo Check](/images/K10/3-2.png "Kasten Repo Check")

### 3.3. Kasten Install

{{< admonition tip "SSL 구성" >}}
{{< version 0.2.0 >}}

Namespace를 생성 해준다.
```shell
kubectl create ns kasten-io
```
Kasten을 SSL을 구성 하려면 아래와 같이 인증서를 생성 후 Secret을 생성 해준다. 만약 SSL이 필요 없다면 아래는 패스해도 무관 하다.

```shell
kubectl create secret tls kasten-tls --cert=/data/cert/yourodmain.com.crt --key=/data/cert/yourdomain.com.key -n kasten-io
```
helm을 통해 Kasten을 설치 하기 위해 아래와 같이 실행을 한다.
Ingress를 사용하는 방식중 Token으로 접속 할 수 있게 구성 한다.

```shell
helm install k10 kasten/k10 \
--set ingress.create=true \
--set ingress.class=contour \
--set auth.tokenAuth.enabled=true \
--set ingress.tls.enabled=true \
--set ingress.tls.secretName=kasten-tls \
--set ingress.host=kasten.tkg.io \
-n kasten-io
```
만약 HTTPS로 구성 하면 자동으로 SSL Redirect를 해주기 위해서 ingress를 확인 후 Annotation을 설정 해준다.

```sehll
kubectl get ing
kubectl annotate ing k10-ingress -n kasten-io ingress.kubernetes.io/force-ssl-redirect=true
```
{{< /admonition >}}

### 3.4. 배포 완료
![Kasten Complate](/images/K10/3-4.png "Kasten Complate")

### 3.5. Annotation 설정 완료
![Kasten ingress Annotation](/images/K10/3-5.png "Kasten ingress Annotation")

### 3.6. 접속 방법
{{< admonition tip "접속을 하기 위해 유저 생성" >}}
{{< version 0.2.0 >}}

TOKEN으로 접속하기 위해 유저를 생성 한다.
```shell
kubectl create serviceaccount my-kasten-sa --namespace kasten-io
```
TOKEN 확인 방법

```shell
sa_secret=$(kubectl get serviceaccount my-kasten-sa -o jsonpath="{.secrets[0].name}" --namespace kasten-io)
kubectl get secret $sa_secret --namespace kasten-io -ojsonpath="{.data.token}{'\n'}" | base64 --decode
```
우선 Ingress로 구성을 했지만 여기선 포트 포워딩으로 설명 하겠다.

```shell
kubectl --namespace kasten-io port-forward service/gateway 8080:8000
```
포트 포워딩을 위해 다른 SSH를 오픈 한다. 
```shell
ssh root@{포트포워딩 한 OS} -L 8080:localhost:8080
```
접속시 성공을 한 것을 확인 할 수 있다.

```sehll
kubectl get ing
kubectl annotate ing k10-ingress -n kasten-io ingress.kubernetes.io/force-ssl-redirect=true
```
{{< /admonition >}}


## 4. K10 Auth LDAP 설정

{{< admonition tip "K10 Auth 설정" >}}
{{< version 0.2.0 >}}

values 파일을 다운로드 받는다.

```shell
helm show values kasten/k10 > k10.yaml
```
Auth라는 부분을 찾은 후 아래 부분을 수정 해준다.

```shell
  ldap:
    enabled: true
    restartPod: false # Enable this value to force a restart of the authentication service pod
    dashboardURL: "http://kasten.tkg.io/k10" #The URL for accessing K10's dashboard
    host: "tanzu-dns.tkg.io:389"  ##ldap 접속 정보
    insecureNoSSL: true
    insecureSkipVerifySSL: true
    startTLS: false
    bindDN: "cn=administrator,cn=users,dc=tkg,dc=io"
    bindPW: "Passw0rd"
    bindPWSecretName: ""
    userSearch:
      baseDN: "ou=tanzu,dc=tkg,dc=io"
      filter: (objectClass=person)
      username: sAMAccountName
      idAttr: DN
      emailAttr: mail
      nameAttr: sAMAccountName
      preferredUsernameAttr: ""
    groupSearch:
      baseDN: "ou=tanzu,dc=tkg,dc=io"
      filter: (objectClass=group)
      userMatchers:
      - userAttr: DN
        groupAttr: member
      nameAttr: name
    secretName: "" # The Kubernetes Secret that contains OIDC settings
    usernameClaim: "email"
    usernamePrefix: ""
    groupnameClaim: "groups"
    groupnamePrefix: ""
```
아래와 같이 실행을 해준다.
```shell
helm install k10 kasten/k10 \
--set ingress.create=true \
--set ingress.class=contour \
--set ingress.tls.enabled=true \
--set ingress.tls.secretName=kasten-tls \
--set ingress.host="kasten.tkg.io" \
--set auth.k10AdminUsers[0]='my1208@openbase.co.kr' \
--set auth.k10AdminGroups[0]="tkg" \
-f k10.yaml \
-n kasten-io
```
또는 아래와 같이 업그레이드를 해준다. 만약 실패 하면 삭제 후 다시 Install 해주면 된다.
```shell
helm upgrade k10 kasten/k10 \
--set ingress.create=true \
--set ingress.class=contour \
--set ingress.tls.enabled=true \
--set ingress.tls.secretName=kasten-tls \
--set ingress.host="kasten.tkg.io" \
--set auth.k10AdminUsers[0]='my1208@openbase.co.kr' \
--set auth.k10AdminGroups[0]="tkg" \
-f k10.yaml \
-n kasten-io
```
{{< /admonition >}}

### 4.1. 완료 화면
![Kasten Auth Integration](/images/K10/4-1.png "Kasten Auth Integration")
![Kasten Auth Integration](/images/K10/4-2.png "Kasten Auth Integration")

## 5. NFS 연동

> 카스텐에서 스토리지를 저정하기 위해 여러가지 방법이 있지만 우선 NFS 연동을 하여 백업을 하는 방법에 대해서 기술

### 5.1. PVC 생성

```shell
kubectl apply -f kasten-io -f - << EOF
apiVersion: v1
kind: PersistentVolume
metadata:
   name: test-pv
spec:
   capacity:
      storage: 10Gi
   volumeMode: Filesystem
   accessModes:
      - ReadWriteMany
   persistentVolumeReclaimPolicy: Retain
   storageClassName: nfs
   mountOptions:
      - hard
      - nfsvers=3.0
   nfs:
      path: /volume1/Cloud-Home/08.VEEAM
      server: 10.253.1.254

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
   name: test-pvc
   namespace: kasten-io
spec:
   storageClassName: nfs
   accessModes:
      - ReadWriteMany
   resources:
      requests:
         storage: 10Gi

EOF         
```

{{< figure src="/images/K10/5-1.png" title="PVC 생성 완료 확인" >}}

### 5.2. 카스텐 설정

{{< figure src="/images/K10/5-2.png" title="카스텐 Locations 설정" >}}
{{< figure src="/images/K10/5-3.png" title="카스텐 NFS 설정" >}}
{{< figure src="/images/K10/5-4.png" title="카스텐 프로파일 설정 완료 확인" >}}

## 6. MINIO 연동

MINIO를 구성 하려면 먼저 Erasure Code와 Immutability가 되어야 한다.

참고 링크[:(far fa-file-archive fa-fw): MINIO](https://docs.min.io/docs/minio-erasure-code-quickstart-guide.html) 참조

MINIO를 컨테이너 형태로 배포를 하게 되면 우선 Immutability를 지원 하지 않는 것으로 보인다. 그래서 별도로 VM을 생성 해서 진행

### 6.1. VM 설정
VM을 생성 할때 스토리지를 OS가 저장되는 HDD를 제외한 4개를 구성 후 배포를 완료 한다.
{{< figure src="/images/K10/6-1.png" title="VM 생성" >}}

### 6.2 FDISK 생성

{{< admonition tip "VOLUME 생성" >}}
{{< version 0.2.0 >}}

모든 HDD를 FDISK구성 해준다. 순서는 (n > p > t > 8e > w) 로 입력 해준다.

```shell
fdisk /dev/sdb1 
fdisk /dev/sdc1
fdisk /dev/sdd1
fdisk /dev/sde1

Welcome to fdisk (util-linux 2.31.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0xab657906.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 
First sector (2048-209715199, default 2048): 
Last sector, +sectors or +size{K,M,G,T,P} (2048-209715199, default 209715199): 

Created a new partition 1 of type 'Linux' and of size 100 GiB.

Command (m for help): t
Selected partition 1
Hex code (type L to list all codes): 8e
Changed type of partition 'Linux' to 'Linux LVM'.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

VOLUME을 생성해 준다.
```shell
pvcreate /dev/sdb1
vgcreate vg_xfs_minio_1 /dev/sdb1
lvcreate -L +99G -n xfs_minio_1 vg_xfs_minio_1
mkfs.xfs /dev/vg_xfs_minio_1/xfs_minio_1

mkdir /root/xfs_minio_1
mount /dev/vg_xfs_minio_1/xfs_minio_1 /root/xfs_minio_1/

df -hT /root/xfs_minio_1/


pvcreate /dev/sdc1
vgcreate vg_xfs_minio_2 /dev/sdc1
lvcreate -L +99G -n xfs_minio_2 vg_xfs_minio_2
mkfs.xfs /dev/vg_xfs_minio_2/xfs_minio_2

mkdir /root/xfs_minio_2
mount /dev/vg_xfs_minio_2/xfs_minio_2 /root/xfs_minio_2/

df -hT /root/xfs_minio_2/


pvcreate /dev/sdd1
vgcreate vg_xfs_minio_3 /dev/sdd1
lvcreate -L +99G -n xfs_minio_3 vg_xfs_minio_3
mkfs.xfs /dev/vg_xfs_minio_3/xfs_minio_3

mkdir /root/xfs_minio_3
mount /dev/vg_xfs_minio_3/xfs_minio_3 /root/xfs_minio_3/

df -hT /root/xfs_minio_3/


pvcreate /dev/sde1
vgcreate vg_xfs_minio_4 /dev/sde1
lvcreate -L +99G -n xfs_minio_4 vg_xfs_minio_4
mkfs.xfs /dev/vg_xfs_minio_4/xfs_minio_4

mkdir /root/xfs_minio_4
mount /dev/vg_xfs_minio_4/xfs_minio_4 /root/xfs_minio_4/

df -hT /root/xfs_minio_4/
```
부팅 후에도 마운투가 될 수 있게 fstab에 저장해준다. 
blkid로 UUID를 확인
```shell

blkid

echo 'UUID=b6d3f331-deaf-428b-bcb0-c9b48bab2253 /root/xfs_minio_1 xfs defaults 1 1' >> /etc/fstab
echo 'UUID=213694c7-bbaf-45c4-96c8-4e912dc70f3f /root/xfs_minio_2 xfs defaults 1 1' >> /etc/fstab
echo 'UUID=e7aa0e12-3c0c-4e12-a00d-9ebeaab76669 /root/xfs_minio_3 xfs defaults 1 1' >> /etc/fstab
echo 'UUID=ac211fab-162e-4f8a-854b-1960aa43e252 /root/xfs_minio_4 xfs defaults 1 1' >> /etc/fstab
```
{{< /admonition >}}

UUID 확인
{{< figure src="/images/K10/6-2.png" title="UUID 확인" >}}

{{< admonition tip "MINIO & MC 설치" >}}
{{< version 0.2.0 >}}

```shell
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio
mv minio /usr/local/bin/

wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
cp mc /usr/local/bin/
```
설치가 완료 되면 SSL을 생성한다. SSL 생성은 간단 하므로 여기서 표시 하지는 않겠다.
생성된 SSL 인증서와 Key를 minio 폴더로 카피 한다.
```shell
cp yourdomain.com.crt /root/.minio/certs/public.crt
cp yourdomain.com.key /root/.minio/certs/private.key
```
MINIO를 생성 한다.
```shell
mc config host add minio-veeam https://minio.tkg.io minioadmin minioadmin --api S3v4

minio server --address ":443" /root/xfs_minio_1/ /root/xfs_minio_2/ /root/xfs_minio_3/ /root/xfs_minio_4/

mc mb --debug -l minio-veeam/veeam-immutable

mc retention set --default compliance 30d minio-veeam/veeam-immutable
```
{{< /admonition >}}

프로파일 설정
{{< figure src="/images/K10/6-3.png" title="카스텐 프로파일 설정" >}}
{{< figure src="/images/K10/6-4.png" title="카스텐 프로파일 등록 완료 1" >}}
{{< figure src="/images/K10/6-5.png" title="카스텐 프로파일 등록 완료 2" >}}

## 7. 백업 완료
{{< figure src="/images/K10/6-6.png" title="카스텐에서 백업 실행후 완료 확인" >}}
{{< figure src="/images/K10/6-7.png" title="MINIO에서 백업 확인" >}}
