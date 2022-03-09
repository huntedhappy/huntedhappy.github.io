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

### Tools and CLI requirements
Installation requires:

* The Kubernetes CLI, kubectl, v1.20, v1.21 or v1.22, installed and authenticated with administrator rights for your target cluster. See Install Tools in the Kubernetes documentation.

## 2. TAP
### 2.1. Tanzu Network 등록
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

## 3. Visural Studio 

### 3.1. Extenstion 설정
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

### 3.2. Live Update Start
해당 부분을 수정 하면 자동으로 GIT에 업데이트가 되면서 바뀌는것을 볼수 있다.
{{< figure src="/images/tap/6-1.png" title="수정#1" >}}
{{< figure src="/images/tap/6-4.png" title="수정#2" >}}
{{< figure src="/images/tap/6-2.png" title="수정#3" >}}
{{< figure src="/images/tap/6-3.png" title="수정#4" >}}


