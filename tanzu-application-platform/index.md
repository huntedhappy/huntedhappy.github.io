# The Documentation TAP


## 1. VMware TAP?
VMware Tanzu 애플리케이션 플랫폼은 개발자와 운영자가 Kubernetes 플랫폼에서 앱을 보다 쉽게 구축, 배포 및 관리할 수 있도록 도와주는 패키지된 구성 요소 집합입니다.

Tanzu 애플리케이션 플랫폼은 Kubernetes 기반 앱 개발의 내부 루프와 외부 루프 모두에서 워크플로를 단순화합니다.

* 내부 루프: 내부 루프는 개발자가 앱을 코딩하고 테스트하는 로컬 개발 환경을 설명합니다. 내부 루프에서 발생하는 활동에는 코드 작성, 버전 제어 시스템에 커밋, 개발 또는 스테이징 환경에 배포, 테스트 및 추가 코드 변경이 포함됩니다.

* 외부 루프: 외부 루프는 앱을 프로덕션에 배포하고 시간이 지남에 따라 유지 관리하는 단계를 설명합니다. 예를 들어, 클라우드 네이티브 플랫폼에서 외부 루프에는 컨테이너 이미지 빌드, 컨테이너 보안 추가, 지속적 통합(CI) 및 지속적 전달(CD) 파이프라인 구성과 같은 활동이 포함됩니다.

VMware Tanzu 애플리케이션 플랫폼은 보안 및 확장을 지원하는 모든 Kubernetes에서 코드를 실행할 수 있도록 사전 포장된 프로덕션 경로를 개발 팀에 제공합니다. 팀이 조직의 기본 설정에 따라 사용자 지정할 수 있도록 모듈화된 애플리케이션 인식 플랫폼입니다.

### 주의 사항
현재 버그가 있는것으로 보임 Private Harbor 구성시 사설 인증서 문제가 발생 하기 때문에 외부 Registry 활용 필요,
Github 연동시 Integration으로 설정

### 사전 설치
* DOCKER
* GCR (Google Container Registry)
* GitHub
* DNS Records

### Resource requirements
To deploy all Tanzu Application Platform packages, your cluster must have at least:

* 8 CPUs for i9 (or equivalent) available to Tanzu Application Platform components
* 12 CPUs for i7 (or equivalent) available to Tanzu Application Platform components
* 8 GB of RAM across all nodes available to Tanzu Application Platform
* 12 GB of RAM is available to build and deploy applications, including Minikube. VMware recommends 16 GB of RAM for an optimal experience.
* 70 GB of disk space available per node
For the full profile, or use of Security Chain Security Tools - Store, your cluster must have a configured default StorageClass.

## 2. TAP 1.0.1
### Tools and CLI requirements
Installation requires:

* The Kubernetes CLI, kubectl, v1.20, v1.21 or v1.22, installed and authenticated with administrator rights for your target cluster. See Install Tools in the Kubernetes documentation.

### 2.1. TAP
#### 2.1.1 Tanzu Network 등록
{{< admonition tip "Tanzu Network ID/PW" >}}
```shell
export INSTALL_REGISTRY_USERNAME=        #### Tanzu Network ID
export INSTALL_REGISTRY_PASSWORD=        #### Tanzu Network PW
export INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
export TAP_VERSION=1.0.1
```
namespace 생성
```shell
kubectl create ns tap-install
```
tanzu registry 추가
```shell
tanzu secret registry add tap-registry \
  --username ${INSTALL_REGISTRY_USERNAME} --password ${INSTALL_REGISTRY_PASSWORD} \
  --server ${INSTALL_REGISTRY_HOSTNAME} \
  --export-to-all-namespaces --yes --namespace tap-install
```
tanzu repository 추가
```shell
tanzu package repository add tanzu-tap-repository \
  --url registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:$TAP_VERSION \
  --namespace tap-install
```
{{< /admonition >}}

{{< figure src="/images/tap/1-1.png" title="EULA 허용" >}}
{{< figure src="/images/tap/1-2.png" title="EULA 허용" >}}

### 2.2. Tanzu TAP 설치 리스트 확인
{{< admonition tip "Registry / Repository 확인" >}}
```shell
tanzu secret registry list -n tap-install

tanzu package repository list -n tap-install

tanzu package repository get tanzu-tap-repository --namespace tap-install

tanzu package available list --namespace tap-install

tanzu package available list tap.tanzu.vmware.com --namespace tap-install
```
{{< /admonition >}}

{{< figure src="/images/tap/2-1.png" title="Registry 리스트 확인" >}}
{{< figure src="/images/tap/2-2.png" title="Repository 리스트 확인" >}}
{{< figure src="/images/tap/2-3.png" title="Package 리스트 확인" >}}

### 2.3. Tanzu TAP 설치
Private Harbor의 경우 사설 인증서가 문제가 있으므로 외부에서 제공하는 Registry 사용하는 필요. 

{{< admonition tip "TAP 설치" >}}

GCR에서 키값을 json으로 다운로드 받은 후 service_account_key[변수] 저장
```shell
tanzu secret registry add registry-credentials --server gcr.io --username _json_key --password "$(cat main-xxxx-xxx-xxxx.json)" --namespace tap-install
service_account_key="$(cat main-xxxx-xxx-xxxx.json)"
```
실행 파일 설정
```shell
cat <<EOF > gcr-tap-values.yaml
profile: full
ceip_policy_disclosed: true # The value must be true for installation to succeed

buildservice:
  kp_default_repository: "gcr.io/{Registry ID}/build-service"
  kp_default_repository_username: _json_key
  kp_default_repository_password: '$(echo $service_account_key)'
  tanzunet_username: ""                             ## Tanzu Network ID
  tanzunet_password: ""                             ## Tanzu Network Password
  descriptor_name: "tap-1.0.0-full"
  enable_automatic_dependency_updates: true

supply_chain: basic

cnrs:
  domain_name: tkg.io

accelerator:
  server:
    service_type: "ClusterIP"

ootb_supply_chain_basic:
  registry:
    server: "gcr.io"
    repository: "{Registry ID}/supply_chain"
  gitops:
    #repository_prefix: git@github.com:vmware-tanzu/
    #branch: main
    #user_name: supplychain
    #user_email: supplychain
    #commit_message: supplychain@cluster.local
    #ssh_secret: git-ssh  
    ssh_secret: ""
  cluster_builder: default
  service_account: default

learningcenter:
  ingressDomain: "tkg.io"
  ingressClass: contour
  ingressSecret:
    secretName: workshops.example.com-tls

contour:
  envoy:
    service:
      type: LoadBalancer

tap_gui:
  service_type: ClusterIP
  ingressEnabled: "true"
  ingressDomain: "tkg.io"
  app_config:
    app:
      baseUrl: http://tap-gui.tkg.io
      support:
        url: https://tanzu.vmware.com/support
        items:
          - title: Contact Support
            icon: email
            links:
              - url: https://tanzu.vmware.com/support
                title: Tanzu Support Page
          - title: Documentation
            icon: docs
            links:
              - url: https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/index.html
                title: Tanzu Application Platform Documentation
    integrations:
      github: # Other integrations available see NOTE below
        - host: github.com
          token: "{GIT TOKEN}"

    catalog:
      locations:
        - type: url
          target: https://github.com/huntedhappy/tanzu-java-web-app/catalog-info.yaml

    backend:
      baseUrl: http://tap-gui.tkg.io
      cors:
        origin: http://tap-gui.tkg.io

#    ##Existing values file above (OIDC)
#    auth:
#      allowGuestAccess: true
#      environment: development
#      loginPage:
#        github:
#          title: Github Login
#          message: Enter with your GitHub account
#      providers:
#        github:
#          development:
#            clientId: 
#            clientSecret: 
#            ## uncomment if using GitHub Enterprise
#            # enterpriseInstanceUrl:

metadata_store:
  app_service_type: LoadBalancer # (optional) Defaults to LoadBalancer. Change to NodePort for distributions that don't support LoadBalancer

grype:
  namespace: "tap-install" # (optional) Defaults to default namespace.
EOF
```
TAP 설치
```shell
tanzu package install tap -p tap.tanzu.vmware.com -v $TAP_VERSION --values-file gcr-tap-values.yml -n tap-install
```
{{< /admonition >}}

{{< figure src="/images/tap/3-1.png" title="TAP 설치 완료" >}}

### 2.4. Tanzu TAP RBAC 설정
{{< admonition tip "RBAC 설정" >}}
```shell
dockerconfigjson="$(kubectl get secret tbs-builder-secret-gen-placeholder-secret -n tap-install -o jsonpath={.data.\\.dockerconfigjson})"
```
```shell
cat <<EOF | tee rbac.yaml
apiVersion: v1
kind: Secret
metadata:
  name: tap-registry
  annotations:
    secretgen.carvel.dev/image-pull-secret: ""
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: $(echo $dockerconfigjson)
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: default
secrets:
  - name: registry-credentials
imagePullSecrets:
  - name: registry-credentials
  - name: tap-registry
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: default
rules:
- apiGroups: [source.toolkit.fluxcd.io]
  resources: [gitrepositories]
  verbs: ['*']
- apiGroups: [source.apps.tanzu.vmware.com]
  resources: [imagerepositories]
  verbs: ['*']
- apiGroups: [carto.run]
  resources: [deliverables, runnables]
  verbs: ['*']
- apiGroups: [kpack.io]
  resources: [images]
  verbs: ['*']
- apiGroups: [conventions.apps.tanzu.vmware.com]
  resources: [podintents]
  verbs: ['*']
- apiGroups: [""]
  resources: ['configmaps']
  verbs: ['*']
- apiGroups: [""]
  resources: ['pods']
  verbs: ['list']
- apiGroups: [tekton.dev]
  resources: [taskruns, pipelineruns]
  verbs: ['*']
- apiGroups: [tekton.dev]
  resources: [pipelines]
  verbs: ['list']
- apiGroups: [kappctrl.k14s.io]
  resources: [apps]
  verbs: ['*']
- apiGroups: [serving.knative.dev]
  resources: ['services']
  verbs: ['*']
- apiGroups: [servicebinding.io]
  resources: ['servicebindings']
  verbs: ['*']
- apiGroups: [services.apps.tanzu.vmware.com]
  resources: ['resourceclaims']
  verbs: ['*']
- apiGroups: [scanning.apps.tanzu.vmware.com]
  resources: ['imagescans', 'sourcescans']
  verbs: ['*']
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: default
subjects:
  - kind: ServiceAccount
    name: default
EOF
```
{{< /admonition >}}

### 2.5. workload 실행
INGRESS IP 확인
```shell
kubectl get svc -n tap-install

kubectl get httpproxy -A
```
{{< figure src="/images/tap/3-2.png" title="ingress 및 DNS 확인" >}}
{{< figure src="/images/tap/4-1.png" title="gui 접속 후 Tanzu Java Web App 실행" >}}
{{< figure src="/images/tap/4-2.png" title="gui 접속 후 Tanzu Java Web App 실행" >}}
{{< figure src="/images/tap/4-3.png" title="gui 접속 후 Tanzu Java Web App 실행" >}}
{{< figure src="/images/tap/4-4.png" title="gui 접속 후 Tanzu Java Web App 다운로드" >}}

{{< admonition tip "GIT PUSH" >}}

미리 GIT에 프로젝트 생성 후 다운로드 받은 ZIP파일 PUSH

```shell
unzip tanzu-java-web-app.zip

git init
git remote add origin git@github.com:huntedhappy/tanzu-java-web-app
git add .
git commit -m 'first'
git push origin main
```
apps workload 실행
```shell
tanzu apps workload create tanzu-java-web-app \
 --git-repo https://github.com/huntedhappy/tanzu-java-web-app \
 --git-branch main \
 --type web \
 --label apps.tanzu.vmware.com/has-tests=true \
 --yes \
 -n tap-install
```
배포 상태 확인
```shell
tanzu apps cluster-supply-chain list

tanzu apps workload tail tanzu-java-web-app --since 10m --timestamp -n tap-install

kubectl get workload,gitrepository,pipelinerun,images.kpack,podintent,app,services.serving -n tap-install
```
{{< /admonition >}}

## 3. TAP 1.1.0

Repository를 설정한다. 여기서는 GCR을 사용하기 때문에 GCR의 정보를 입력

```shell
export INSTALL_REGISTRY_HOSTNAME=gcr.io
export TAP_VERSION=1.1.0
```

TANZU NET 및 GCR docker login 후 GCR에 이미지들을 다운로드 
```shell
docker login registry.tanzu.vmware.com

docker login -u _json_key --password-stdin https://gcr.io < {gcr key}

imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:${TAP_VERSION} --to-repo ${INSTALL_REGISTRY_HOSTNAME}/{gcr project}/tap-packages

```

namespace 및 secret 생성 후 tanzu package Repository 생성
```shell
tanzu secret registry add tap-registry --server gcr.io --username _json_key --password "$(cat {gcr key})" --export-to-all-namespaces --yes -n tap-install

tanzu secret registry add registry-credentials --server gcr.io --username _json_key --password "$(cat {gcr key})" --export-to-all-namespaces --yes -n tap-install


tanzu package repository add tanzu-tap-repository \
  --url ${INSTALL_REGISTRY_HOSTNAME}/main-tokenizer-343509/tap-packages:$TAP_VERSION \
  --namespace tap-install 

## Repository가 생성이 되었으면 설치 가능한 packages를 확인
tanzu package available list tap.tanzu.vmware.com --namespace tap-install
```
권한 설정
```shell
kubectl annotate secret tap-registry -n tap-install secretgen.carvel.dev/image-pull-secret=""

kubectl patch sa default -n tap-install --type 'json' -p '[{"op":"add","path":"/secrets","value":["name":"registry-credentials","name":"tap-registry"]}]'
kubectl patch sa default -n tap-install --type 'json' -p '[{"op":"add","path":"/imagePullSecrets","value":["name":"registry-credentials","name":"tap-registry"]}]'

cat <<EOF | kubectl -n tap-install apply -f -
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
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-permit-app-viewer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: app-viewer
subjects:
  - kind: Group
    name: "namespace-developers"
    apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: namespace-dev-permit-app-viewer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: app-viewer-cluster-access
subjects:
  - kind: Group
    name: "namespace-developers"
    apiGroup: rbac.authorization.k8s.io
EOF
```
TAP 1.1.0 설치

GCR에서 키값을 json으로 다운로드 받은 후 service_account_key[변수] 저장
```shell
tanzu secret registry add registry-credentials --server gcr.io --username _json_key --password "$(cat main-xxxx-xxx-xxxx.json)" --namespace tap-install
service_account_key="$(cat main-xxxx-xxx-xxxx.json)"
```
실행 파일 설정
```shell
cat <<EOF > gcr-tap-values.yaml
profile: full
ceip_policy_disclosed: true # The value must be true for installation to succeed

buildservice:
  kp_default_repository: "gcr.io/{Registry ID}/build-service"
  kp_default_repository_username: _json_key
  kp_default_repository_password: '$(echo $service_account_key)'
  tanzunet_username: ""                             ## Tanzu Network ID
  tanzunet_password: ""                             ## Tanzu Network Password
  descriptor_name: "full"
  enable_automatic_dependency_updates: true

supply_chain: basic

cnrs:
  domain_name: tkg.io

accelerator:
  server:
    service_type: "ClusterIP"

ootb_supply_chain_basic:
  registry:
    server: "gcr.io"
    repository: "{Registry ID}/supply_chain"
  gitops:
    #repository_prefix: git@github.com:vmware-tanzu/
    #branch: main
    #user_name: supplychain
    #user_email: supplychain
    #commit_message: supplychain@cluster.local
    #ssh_secret: git-ssh  
    ssh_secret: ""
  cluster_builder: default
  service_account: default

learningcenter:
  ingressDomain: "tkg.io"
  ingressClass: contour
  ingressSecret:
    secretName: workshops.example.com-tls

contour:
  envoy:
    service:
      type: LoadBalancer

tap_gui:
  service_type: ClusterIP
  ingressEnabled: "true"
  ingressDomain: "tkg.io"
  app_config:
    app:
      baseUrl: http://tap-gui.tkg.io
      support:
        url: https://tanzu.vmware.com/support
        items:
          - title: Contact Support
            icon: email
            links:
              - url: https://tanzu.vmware.com/support
                title: Tanzu Support Page
          - title: Documentation
            icon: docs
            links:
              - url: https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/index.html
                title: Tanzu Application Platform Documentation
    integrations:
      github: # Other integrations available see NOTE below
        - host: github.com
          token: "{GIT TOKEN}"

    catalog:
      locations:
        - type: url
          target: https://github.com/huntedhappy/tanzu-java-web-app/catalog-info.yaml

    backend:
      baseUrl: http://tap-gui.tkg.io
      cors:
        origin: http://tap-gui.tkg.io

#    ##Existing values file above (OIDC)
#    auth:
#      allowGuestAccess: true
#      environment: development
#      loginPage:
#        github:
#          title: Github Login
#          message: Enter with your GitHub account
#      providers:
#        github:
#          development:
#            clientId: 
#            clientSecret: 
#            ## uncomment if using GitHub Enterprise
#            # enterpriseInstanceUrl:

metadata_store:
  app_service_type: LoadBalancer # (optional) Defaults to LoadBalancer. Change to NodePort for distributions that don't support LoadBalancer

grype:
  namespace: "tap-install" # (optional) Defaults to default namespace.
EOF
```

TANZU 설치
```shell
tanzu package install tap -p tap.tanzu.vmware.com -v $TAP_VERSION --values-file gcr-tap-values.yaml -n tap-install
```

### 3.1. MultiCluster
{{< figure src="/images/tap/3-3.png" title="MultiCluster" >}}

3개의 클러스터를 생성한다. 여기서는 아래와 같이 구성 하였다.


* tkgm01-tkc-dev02 = build

* tkgm02-tkc-dev03 = run

* tkgm03-tkc-dev04 = view



{{< admonition tip "이미지를 Repository에 저장한다." >}}
```shell
export INSTALL_REGISTRY_HOSTNAME=gcr.io
export TAP_VERSION=1.1.0

## Tanzu Network에 로그인을 한다.
docker login registry.tanzu.vmware.com -u {ID} --password-stdin < ./password.txt

## GCR에 로그인을 한다.
docker login -u _json_key --password-stdin https://gcr.io < {togken}}.json

## 이미지를 GCR에 복사 한다.
imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:${TAP_VERSION} --to-repo ${INSTALL_REGISTRY_HOSTNAME}/main-tokenizer-343509/tap-packages
```
* 모든 이미지가 GCR에 저장이 완료 되면 Repository를 각각의 클러스터에 등록 해준다.
```shell
## Cluster 변경
kubectl use-context {cluster context}
## NameSpace 생성
kubectl create ns tap-install
## GCR 접속 Secret 생성
tanzu secret registry add tap-registry --server gcr.io --username _json_key --password "$(cat {gcr-key}.json)"  --export-to-all-namespaces --yes -n tap-install


tanzu secret registry add registry-credentials --server gcr.io --username _json_key --password "$(cat {gcr-key}.json)" --export-to-all-namespaces --yes -n tap-install

## Tanzu Package Repository 추가
tanzu package repository add tanzu-tap-repository \
  --url ${INSTALL_REGISTRY_HOSTNAME}/main-tokenizer-343509/tap-packages:$TAP_VERSION \
  --namespace tap-install 

## Tanzu Package Repository 확인
tanzu package repository list -n tap-install

```
* 각각의 클러스터의 맞는 tap을 설치 해준다.
* build-tap-values.yaml
```shell
cat << EOF | tee build-tap-values.yaml
profile: build
ceip_policy_disclosed: true
buildservice:
  kp_default_repository: "gcr.io/{gcr project}/tap-packages"
  kp_default_repository_username: _json_key
  kp_default_repository_password: {gcr key}
  tanzunet_username: ""                             ## Tanzu Network ID
  tanzunet_password: ""                                     ## Tanzu Network Password
  descriptor_name: "full"
  enable_automatic_dependency_updates: true

supply_chain: basic

ootb_supply_chain_basic:
  registry:
    server: "gcr.io"
    repository: "{gcr project}/supply_chain"
  gitops:
    ssh_secret: ""
  cluster_builder: default
  service_account: default


grype:
  namespace: "tap-install" # (optional) Defaults to default namespace.
  targetImagePullSecret: tap-registry
EOF
```
* run-tap-values.yaml
```shell
cat << EOF | tee run-tap-values.yaml
profile: run
ceip_policy_disclosed: true # Installation fails if this is not set to true. Not a string.
supply_chain: basic

cnrs:
  domain_name: tkg.io

contour:
  envoy:
    service:
      type: LoadBalancer #NodePort can be used if your Kubernetes cluster doesn't support LoadBalancing

appliveview_connector:
  backend:
    sslDisabled: "true"
    host: appliveview.tkg.io
EOF
```
* 클러스터를 변경 하면서 TAP을 설치 해준다.
```shell
kubectl use-context {TAP 클러스터}

tanzu package install tap -p tap.tanzu.vmware.com -v 1.1.0 -f build-tap-values.yaml -n tap-install

tanzu package install tap -p tap.tanzu.vmware.com -v 1.1.0 -f run-tap-values.yaml -n tap-install
```
* build 와 run 클러스터에 TAP 설치가 완료 되었다면 클러스터의 URL 과 TOKEN을 확인한다.
```shell
CLUSTER_URL=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
CLUSTER_TOKEN=$(kubectl -n tap-gui get secret $(kubectl -n tap-gui get sa tap-gui-viewer -o=json \
| jq -r '.secrets[0].name') -o=json \
| jq -r '.data["token"]' \
| base64 --decode)

echo CLUSTER_URL: $CLUSTER_URL
echo CLUSTER_TOKEN: $CLUSTER_TOKEN
```
* view-tap-values.yaml
```shell
cat << EOF | tee view-tap-values.yaml
profile: view
ceip_policy_disclosed: true # Installation fails if this is not set to true. Not a string.

contour:
  envoy:
    service:
      type: LoadBalancer #NodePort can be used if your Kubernetes cluster doesn't support LoadBalancing

learningcenter:
  ingressDomain: "tkg.io"

tap_gui:
  service_type: ClusterIP
  ingressEnabled: "true"
  ingressDomain: "tkg.io"
  app_config:
    app:
      baseUrl: http://tap-gui.tkg.io
    catalog:
      locations:
        - type: url
          target: https://GIT-CATALOG-URL/catalog-info.yaml
    backend:
      baseUrl: http://tap-gui.tkg.io
      cors:
        origin: http://tap-gui.tkg.io
    kubernetes:
      serviceLocatorMethod:
        type: 'multiTenant'
      clusterLocatorMethods:
        - type: 'config'
          clusters:
            - url: https://10.253.125.252:6443
              name: tkgm01-tkc-dev02
              authProvider: serviceAccount
              skipTLSVerify: true
              serviceAccountToken: eyJhbGciOiJSUzI1NiIsImtpZCI6InZ4S25KYi1SVW96UmJmdnVXc2lSODlza1NTV0RBRkd1aG1acHI5Qy0xdjAifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJ0YXAtZ3VpIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InRhcC1ndWktdmlld2VyLXRva2VuLTk1c3EyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InRhcC1ndWktdmlld2VyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiNzJhOTY2ZGEtYzA2ZS00OTIyLTk5Y2YtM2ZjYTMwNmNkNWM5Iiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OnRhcC1ndWk6dGFwLWd1aS12aWV3ZXIifQ.Vit66qxirDMNcZlUHaDaNXJAWpU-J0o5wfBXK8U2kVnoP3RMcAGrSTodoZ3fnsNtTlPKSCMlw9I7m591Kcly1HL8CPLwkLH-P2Ew26eurQHvVb-NGQUFAIRSdrN6Ig6J5Xg09D5D8wGMJTk7egSud8cj5A1z1bT1ctLCX1N2WrqO3Hrcu0o8XHgSoiogTP_ELU8B2E93kHqdCPeh0xbY9pkTEvXRQun9PTeag6jepd7eNUgCXMab4jYxsEXDbJ3PPbDusuleY2LpcObYaWuuYMyRc5QSVG5EBlEKfaXnEvslTNxdohdEQwQOHwABKC4Au-KBYbzy2s_MI40g2K79iw
            - url: https://10.253.125.253:6443
              name: tkgm01-tkc-dev03
              authProvider: serviceAccount
              skipTLSVerify: true
              serviceAccountToken: eyJhbGciOiJSUzI1NiIsImtpZCI6Ii0tYzNpVm9HbXdfTkxqREZhU1ZXeEY0RXJCY29Sc0lwWkl5WW9XdENsYzgifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJ0YXAtZ3VpIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InRhcC1ndWktdmlld2VyLXRva2VuLWs0aHQ2Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InRhcC1ndWktdmlld2VyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiNTBiNjMxYjktYjRlOS00ZjhhLThmZDgtNDAwMDE3ZWZkOTJmIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OnRhcC1ndWk6dGFwLWd1aS12aWV3ZXIifQ.DL4nTskvqSvEXwi0HN2rNk61UD3DquvCnRxrFZZT2cM7L7WznTlqdXFxXsqlabE9zcS3nTLQ2NWDjx2qrJEdiAzqr6rOGXkFzYeyuE9kvzcTnVbHYYlagA8UMCjeQUAw0DtTGip3UFqPoXUGdwlZHYR7e1VQcaSmdnFc0UVTrDlpDdGQgJujDvyiU18-pa7BeizBkPJbKPVOgn0sP5M_zZh5Rtzb4-PKc1pYiAG7lg_05U7w_5rfMeoaLFN0H36BKUpGHb7inakGjnR3Z7_6iPe7x4FUR4zK-WZFCT4LbckfR0NKaDGHCaGoMSqQ-W2j6GFdK1wRVGhnortD8mC4ww

metadata_store:
  app_service_type: LoadBalancer # (optional) Defaults to LoadBalancer. Change to NodePort for distributions that don't support LoadBalancer

appliveview:
  ingressEnabled: "true"
  ingressDomain: tkg.io
EOF
```
* view 클러스터에 TAP 설치
```shell
tanzu package install tap -p tap.tanzu.vmware.com -v 1.1.0 -f view-tap-values.yaml -n tap-install
```
* 설치 완료 후 build 와 run cluster에 권한 부여
```shell
kubectl apply -f - << EOF
apiVersion: v1
kind: Namespace
metadata:
  name: tap-gui
---
apiVersion: v1
kind: ServiceAccount
metadata:
  namespace: tap-gui
  name: tap-gui-viewer
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tap-gui-read-k8s
subjects:
- kind: ServiceAccount
  namespace: tap-gui
  name: tap-gui-viewer
roleRef:
  kind: ClusterRole
  name: k8s-reader
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: k8s-reader
rules:
- apiGroups: ['']
  resources: ['pods', 'services', 'configmaps']
  verbs: ['get', 'watch', 'list']
- apiGroups: ['apps']
  resources: ['deployments', 'replicasets']
  verbs: ['get', 'watch', 'list']
- apiGroups: ['autoscaling']
  resources: ['horizontalpodautoscalers']
  verbs: ['get', 'watch', 'list']
- apiGroups: ['networking.k8s.io']
  resources: ['ingresses']
  verbs: ['get', 'watch', 'list']
- apiGroups: ['networking.internal.knative.dev']
  resources: ['serverlessservices']
  verbs: ['get', 'watch', 'list']
- apiGroups: [ 'autoscaling.internal.knative.dev' ]
  resources: [ 'podautoscalers' ]
  verbs: [ 'get', 'watch', 'list' ]
- apiGroups: ['serving.knative.dev']
  resources:
  - configurations
  - revisions
  - routes
  - services
  verbs: ['get', 'watch', 'list']
- apiGroups: ['carto.run']
  resources:
  - clusterconfigtemplates
  - clusterdeliveries
  - clusterdeploymenttemplates
  - clusterimagetemplates
  - clusterruntemplates
  - clustersourcetemplates
  - clustersupplychains
  - clustertemplates
  - deliverables
  - runnables
  - workloads
  verbs: ['get', 'watch', 'list']
- apiGroups: ['source.toolkit.fluxcd.io']
  resources:
  - gitrepositories
  verbs: ['get', 'watch', 'list']
- apiGroups: ['source.apps.tanzu.vmware.com']
  resources:
  - imagerepositories
  verbs: ['get', 'watch', 'list']
- apiGroups: ['conventions.apps.tanzu.vmware.com']
  resources:
  - podintents
  verbs: ['get', 'watch', 'list']
- apiGroups: ['kpack.io']
  resources:
  - images
  - builds
  verbs: ['get', 'watch', 'list']
- apiGroups: ['scanning.apps.tanzu.vmware.com']
  resources:
  - sourcescans
  - imagescans
  verbs: ['get', 'watch', 'list']
- apiGroups: ['tekton.dev']
  resources:
  - taskruns
  - pipelineruns
  verbs: ['get', 'watch', 'list']
- apiGroups: ['kappctrl.k14s.io']
  resources:
  - apps
  verbs: ['get', 'watch', 'list']
EOF
```
* 모든 클러스터에 개발자의 대한 권한을 부여
```shell
kubectl annotate secret tap-registry -n tap-install secretgen.carvel.dev/image-pull-secret=""

kubectl patch sa default -n tap-install --type 'json' -p '[{"op":"add","path":"/secrets","value":["name":"registry-credentials","name":"tap-registry"]}]'
kubectl patch sa default -n tap-install --type 'json' -p '[{"op":"add","path":"/imagePullSecrets","value":["name":"registry-credentials","name":"tap-registry"]}]'

kubectl apply -f - -n tap-install << EOF
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
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-permit-app-viewer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: app-viewer
subjects:
  - kind: Group
    name: "namespace-developers"
    apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: namespace-dev-permit-app-viewer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: app-viewer-cluster-access
subjects:
  - kind: Group
    name: "namespace-developers"
    apiGroup: rbac.authorization.k8s.io
EOF
```
* Build Cluster로 컨텍스트 변경 후 App을 배포한다.
```shell
export DEVELOPER_NAMESPACE=tap-install

tanzu apps workload create tanzu-java-web-app \
 --git-repo https://github.com/huntedhappy/tanzu-java-web-app \
 --git-branch main \
 --type web \
 --label app.kubernetes.io/part-of=tanzu-java-web-app \
 --yes \
 -n ${DEVELOPER_NAMESPACE}
```
{{< /admonition >}}

{{< figure src="/images/tap/3-4.png" title="app workload 상태 확인" >}}

* 진행 상태 확인
```shell
tanzu apps workload tail tanzu-java-web-app --since 10m --timestamp -n ${DEVELOPER_NAMESPACE}
```
{{< figure src="/images/tap/3-5.png" title="app workload 진행 상태 확인" >}}

* 생성이 완료 되면 GUI에서 확인
{{< figure src="/images/tap/3-6.png" title="supply chain 확인" >}}

* deliverable이 되었는지 확인 한다. build 클러스터에서는 false로 나오는 것을 우선 확인 할 수 있다.
```shell
kubectl get deliverable -n ${DEVELOPER_NAMESPACE}
```
{{< figure src="/images/tap/3-7.png" title="deliverable 실패 확인" >}}

* deliverable를 yaml파일로 저장한다.
```shell
kubectl get deliverable tanzu-java-web-app -n ${DEVELOPER_NAMESPACE} -oyaml > deliverable.yaml
```
* 저장된 파일에서 ownerReferences와 status 부분을 삭제 한다. 그럼 아래와 비슷할 것이다.
```shell
apiVersion: carto.run/v1alpha1
kind: Deliverable
metadata:
  creationTimestamp: "2022-04-19T07:56:37Z"
  generation: 1
  labels:
    app.kubernetes.io/component: deliverable
    app.kubernetes.io/part-of: tanzu-java-web-app
    app.tanzu.vmware.com/deliverable-type: web
    apps.tanzu.vmware.com/workload-type: web
    carto.run/cluster-template-name: deliverable-template
    carto.run/resource-name: deliverable
    carto.run/supply-chain-name: source-to-url
    carto.run/template-kind: ClusterTemplate
    carto.run/workload-name: tanzu-java-web-app
    carto.run/workload-namespace: tap-install
  name: tanzu-java-web-app
  namespace: tap-install
  resourceVersion: "1451190"
  uid: 23c2d202-0186-4c62-b497-baaa961e3698
spec:
  source:
    image: {image}
```
* run cluster로 변경 후 저장한 deliverable파일을 실행 해준다.
```shell
## RUN Cluster로 변경
kubectl config use-context {run cluster}
kubectl apply -f deliverable.yaml -n ${DEVELOPER_NAMESPACE}
```

* 확인을 하면 성공한 것을 확인 할 수 있다.
```shell
kubectl get deliverables -n ${DEVELOPER_NAMESPACE}
```
{{< figure src="/images/tap/3-8.png" title="deliverable 상태 확인" >}}
{{< figure src="/images/tap/3-9.png" title="deliverable gui 상태 확인" >}}


## 4. Visual Studio 
IDE를 Visual Studio를 사용하여 동작, 현재는 Visual studio만 지원 하고 있음

### 4.1. Extenstion 설정
```shell
apt search openjdk

apt install openjdk-11-jdk -y
java --version
```
```shell
echo "allow_k8s_contexts('$(kubectl config current-context)')" >> /var/tmp/tap/tanzu-java-web-app/Tiltfile

## 맨아래 해당 context가 들어가 있는 것을 확인 할 수 있다.
cat /var/tmp/tap/tanzu-java-web-app/Tiltfile

ctrl + shift + p
```

{{< figure src="/images/tap/5-1.png" title="VS 설정" >}}
{{< figure src="/images/tap/5-2.png" title="VS 설정" >}}
{{< figure src="/images/tap/5-3.png" title="VS 설정" >}}
{{< figure src="/images/tap/5-4.png" title="VS 설정" >}}

### 4.2. Live Update Start
해당 부분을 수정 하면 자동으로 GIT에 업데이트가 되면서 바뀌는것을 볼수 있다.
{{< figure src="/images/tap/6-1.png" title="수정#1" >}}
{{< figure src="/images/tap/6-4.png" title="수정#2" >}}
{{< figure src="/images/tap/6-2.png" title="수정#3" >}}
{{< figure src="/images/tap/6-3.png" title="수정#4" >}}


