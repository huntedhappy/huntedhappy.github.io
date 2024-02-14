# The Documentation Tanzu Community Edition with TAP


## 1. TANZU Community Edition?

Tanzu Community Edition은 무료로 사용 가능한 VMware에서 제공하는 Kubernetes 플랫폼으로 손쉽게 클러스터를 구성 할 수 있는 솔루션이다. 
유료 서비스인 TKG 플랫폼의 모든 기능을 사용 할 수 있지만, 몇가지 제약적인 부분이 있을 수 있다. 가령 하나의 클러스터만 배포를 할 수 있는 단점이 있을 수 있으며 별도로 솔루션의 대한 이슈 및 설치의 대해서 지원을 받지 못한다.

하지만 TKG 솔루션의 대해서 사전에 테스트 환경을 구축 함으로 Kubernetes 플랫폼의 손쉬운 배포 와 VMware에서 제공하는 오픈소스 에코 시스템을 통해 확장의 대해서도 손쉽게 구현을 할 수 있을 것이다.

아래에 제공하는 오픈소스를 효율적으로 구성을 할 수 있다.
{{< figure src="/images/tce/1-1.png" title="Eco System" >}}

## 2. TANZU Community Edition 구성

[<i class="fas fa-link"></i> Docker 설치 링크](https://docs.docker.com/desktop/install/windows-install/)
[<i class="fas fa-link"></i> KIND 설치 링크](https://kind.sigs.k8s.io/)

KIND Kubernetes 클러스터는 싱글 노드에서 구축을 할 수 있으며, 비슷한 솔루션으로는 MINIKUBE, K3S등이 있다.
구성환경은 윈도우 10, i7-4770 CPU 16GB 이며 아래는 gitops를 사용하지 않았으며, 마찬가지로 gitops로 구성하여 git에 소스를 머지 할 수도 있지만 여기서는 해당 기능의 대해서는 넣지 않았다.

{{< admonition tip "KIND Install" true >}}
```shell
# MAC OS
# for Intel Macs
[ $(uname -m) = x86_64 ]&& curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-darwin-amd64
# for M1 / ARM Macs
[ $(uname -m) = arm64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-darwin-arm64
chmod +x ./kind
mv ./kind /some-dir-in-your-PATH/kind
```
```powershell
# WINDOWS
curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.17.0/kind-windows-amd64
Move-Item .\kind-windows-amd64.exe c:\some-dir-in-your-PATH\kind.exe
```
```shell
# Linux
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```
{{< /admonition >}}


{{< admonition tip "KIND Cluster 생성" true >}}
kind-expose-port.yaml 파일 생성 후 아래 내용 추가
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
 - role: control-plane
   extraPortMappings:
   - containerPort: 31443 # expose port 31443 of the node to port 80 on the host for use later by Contour ingress (envoy)
     hostPort: 443
   - containerPort: 31080 # expose port 31080 of the node to port 80 on the host for use later by Contour ingress (envoy)
     hostPort: 80
```
```powershell
# 실행
kind create cluster --config kind-expose-port.yaml --image kindest/node:v1.23.12
```
{{< /admonition >}}

{{< figure src="/images/tce/1-2.png" title="Kind Cluster 확인" >}}


{{< admonition tip "Pivnet 다운로드 " true >}}
```powershell
curl.exe -Lo pivnet-windows-amd64-3.0.1.exe https://github.com/pivotal-cf/pivnet-cli/releases/download/v3.0.1/pivnet-windows-amd64-3.0.1
Move-Item .\pivnet-windows-amd64-3.0.1.exe c:\tmc\pivnet.exe

pivnet login --api-token=<API Token>

## TANZU NET에서 EULA Accept 필요
```
{{< /admonition >}}

{{< admonition tip "Tanzu CLI Install" true >}}

```shell
# tanzu application framework download
pivnet dlpf -p tanzu-application-platform -r 1.3.2 -g *framework*
```

```shell
# Linux
tar xvf tanzu-framework-*-amd64-*.tar
install cli/core/v0.25.0/tanzu-core-*_amd64 /usr/local/bin/tanzu
export TANZU_CLI_NO_INIT=true
```

```powershell
# Windows
Expand-Archive -Force tanzu-framework-*-amd64-*.zip c:\tmc
Copy-Item C:\tmc\cli\core\v0.25.0/tanzu-core-*_amd64* c:\tmc\tanzu.exe

# Version 확인
tanzu version
-----------------
version: v0.25.0
buildDate: 2022-08-25
sha: 6288c751-dirty

# Plugin 설치
tanzu plugin install --local c:\tmc\cli all
```
{{< /admonition >}}

{{< admonition tip "Cluster Essentials Install" true >}}

```shell
# tanzu-cluster-essentials download
pivnet dlpf -p tanzu-cluster-essentials -r 1.3.0 -g *essentials*
```
```powershell
tar xzvf tanzu-cluster-essentials-windows-amd64-1.3.0.tgz -C c:\tmc

$Env:TANZUNET_USERNAME=''
$Env:TANZUNET_PASSWORD=''
$Env:INSTALL_BUNDLE='registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle:1.3.0'
$Env:INSTALL_REGISTRY_HOSTNAME='registry.tanzu.vmware.com'
$Env:INSTALL_REGISTRY_USERNAME=$Env:TANZUNET_USERNAME
$Env:INSTALL_REGISTRY_PASSWORD=$Env:TANZUNET_PASSWORD

c:\tmc\install.bat -y
```
{{< /admonition >}}

만약 원하는 OS만 받고 싶으면 해당 하는 파일이름을 -g {설치하고자 하는 OS 선택}
{{< figure src="/images/tce/1-3.png" title="TKGM Downloads" >}}
{{< figure src="/images/tce/1-4.png" title="essentials Downloads" >}}

구성된 KIND cluster에 TAP iterate를 설치하여 source를 테스트 하고 빠르게 build를 함으로 개발의 민첩성을 제공 할 수 있다.
별도의 클러스터를 구성해서 사용 할 수 있지만, 이렇게 TCE를 구성함으로 인해서 노트북에서도 생성 후 테스트를 할 수 있다.

{{< figure src="/images/tce/1-5.png" title="iterate에 포함된 opensource" >}}

{{< admonition tip "Tanzu Application Install" true >}}
```shell
kubectl create ns tap-install

kubectl create secret docker-registry tap-registry --docker-server=registry.tanzu.vmware.com --docker-username=$Env:TANZUNET_USERNAME --docker-password=$Env:TANZUNET_PASSWORD -n tap-install

tanzu package repository add tanzu-tap-repository --url registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:1.3.2 -n tap-install --wait=false

# plugin 확인
tanzu package available list --namespace tap-install

# GIT 환경변수 등록
$Env:GITHUB_USERNAME=github-name
$Env:GITHUB_TOKEN=api-token

# tap-values.yaml
shared:
  ingress_domain: huntedhappy.kro.kr
  image_registry:
    project_path: ghcr.io/$Env:GITHUB_USERNAME
    username: $Env:GITHUB_USERNAME
    password: $Env:GITHUB_TOKEN
    
ceip_policy_disclosed: true
profile: iterate

supply_chain: basic

contour:
  contour:
    replicas: 1
  envoy:
    service:
      type: NodePort
      nodePorts:
        http: 31080
        https: 31443
    hostPorts:
      enable: true

cnrs:
  domain_template: "{{.Name}}.{{.Domain}}"
  provider: local

excluded_packages:
- policy.apps.tanzu.vmware.com
- image-policy-webhook.signing.apps.tanzu.vmware.com
- eventing.tanzu.vmware.com
- sso.apps.tanzu.vmware.com

# TAP 설치
tanzu package install tap -p tap.tanzu.vmware.com -v 1.3.2 -f tap-values.yaml -n tap-install

# Namespace 생성
kubectl get app -n tap-install
```

{{< /admonition >}}

{{< admonition tip "Workload 실행 파일 생성" true >}}
```shell
# git-repository-credentials 생성
kubectl create secret docker-registry git-repository-credentials --docker-server ghcr.io --docker-username $Env:GITHUB_USERNAME --password $Env:GITHUB_TOKEN -n tap-install

# rbac.yaml 생성
apiVersion: v1
kind: ServiceAccount
metadata:
  name: default
secrets:
- name: git-registry-credentials
imagePullSecrets:
- name: git-registry-credentials
- name: tap-registry
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: default-permit-deliverable
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: deliverable
subjects:
  - kind: ServiceAccount
    name: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: default-permit-workload
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: workload
subjects:
- kind: ServiceAccount
  name: default

# rbac 실행
kubectl apply -f rbac.yaml -n tap-install
```
```shell
# 새 파일 생성
tanzu-java-web-app.yaml

# 아래 내용 추가
apiVersion: carto.run/v1alpha1
kind: Workload
metadata:
  labels:
    apps.tanzu.vmware.com/workload-type: web
spec:
  params:
  - name: annotations
    value:
      autoscaling.knative.dev/minScale: "1"
  source:
    git:
      ref:
        branch: main
      url: https://github.com/sample-accelerators/tanzu-java-web-app

# workload 실행
kubectl apply -f tanzu-java-web-app.yaml -n tap-install
```
{{< /admonition >}}

{{< admonition tip "Workload 확인" true >}}
```shell
tanzu app workload get tanzu-java-web-app -n tap-install

kubectl get pod, httpproxy -n tap-install
```
{{< /admonition >}}

{{< figure src="/images/tce/2-1.png" title="Workload 확인" >}}
{{< figure src="/images/tce/2-2.png" title="Workload 확인" >}}
{{< figure src="/images/tce/2-3.png" title="Result" >}}
