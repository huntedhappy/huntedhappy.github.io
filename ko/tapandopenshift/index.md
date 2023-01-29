# Tap install on Openshift


## 1. TANZU APPLICATION PLATFORM ON OPENSHIFT

Tanzu Application Platform은 VMware에서 제공하는 CI/CD 솔루션입니다. 기본 VMware제품들은 대부분 VMware 솔루션에 Dependency가 있었습니다. 
그러나 TAP의 경우는 K8S 환경이면 어디든 설치가 된다는 컨셉으로 나온 것이 아닌가 싶습니다. 
1.3.x 부터 OPENSHIFT에서도 지원을 한다고 해서 한번 설치를 진행 해 보았으며 어떻게 설치를 할 수 있는지 한번 알아 보도록 하겠습니다.

기본적으로 OPENSHIFT는 설치가 되어 있다는 것을 가정으로 TAP를 설치를 진행을 하겠습니다.
참고로 OPENSHIFT의 경우 TAP에서 지원하는 것은 4.10 , 4.11 두가지를 지원 합니다.

{{< figure src="/images/tapandopenshift/0-0.png" title="ocp 지원 버전" >}}

{{< figure src="/images/tapandopenshift/0-1.png" title="ocp 설치 버전" >}}
{{< figure src="/images/tapandopenshift/0-2.png" title="ocp 설치 버전" >}}

> 설치 버전
> * Openshift Version 4.11.9
> * Tanzu Application Platform 1.4.0
> * TBS 1.9.0
> * AVI 22.1.2

> 처음에 Openshift(Openshift를 잘 모르다 보니)를 통해 TAP를 배포하려고 하다 보니 여러가지 이슈가 발생했는대, 해결이 안되는 부분이 AVI 그러니까 외부 로드밸런서를 사용하지 않고 Openshift가 가지고 있는 Ingress를 사용하려고 했는대 실패를 하였습니다. 또한 문제는 Openshift를 잘 몰라서 그럴 수 있겠지만, 내가 원하는 Domain을 설정 하는 것도 어려운 부분이 있었습니다. 그래서 우선 별도로 AVI를 구성하여 설치를 진행 후 TAP 설치를 하였습니다. 그리고 설명이 부족한 부분이 많을 수 있는대, 설명 할 것이 너무 많기 때문에 좀더 Install에 대해서 집중을 해서 글을 작성 하였습니다.

아래에 route에 포함되어 있지 않은 도메인을 차단 하는것인지.. 여기 route에 tap를 구성 후 tap-gui 또는 어플리케이션의 대해서 어떻게 설정 해야 되는지는 아직 의문이 남아 있습니다.
{{< figure src="/images/tapandopenshift/0-4.png" title="oc route 확인" >}}

AVI 와 Openshift를 연동시 생성 되는 VIP가 많아서 이 부분도 당황 스러운 부분이 있었지만, 이 부분도 깊게 파고 들지는 않았습니다. 우선 목표는 TAP를 구성 하기 위함이 크기 때문입니다.
{{< figure src="/images/tapandopenshift/0-3.png" title="AVI 상태" >}}

## 2. KAPP 설치 
기본적으로 KAPP이 설치가 되어 있지 않기 때문에 KAPP 설치가 필요 합니다. 이유는 TAP이라는 솔루션이 Tanzu라는 명령어를 통해 설치가 되기 때문에 입니다.

```shell
## package를 설치 할 수 있게 kapp-contoller 설치
kubectl apply -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/latest/download/release.yml

## tanzu에서 secret을 생성 할 수 있게 secretget-controller 설치
kubectl apply -f https://github.com/carvel-dev/secretgen-controller/releases/latest/download/release.yml

```
kapp을 설치를 하게 되면 이제 tanzu package repository 및  secret repository를 등록 할 수 있습니다.

{{< figure src="/images/tapandopenshift/1-1.png" title="package 및 reository" >}}

그러면 위와 같이 list를 확인 할 수 있습니다. 위에 controller를 설치를 하지 않으면 에러가 발생 하는 것을 알 수 있습니다. 에러 내용은 아래와 같습니다.
```shell
kapp contoller를 설치를 안할 경우 발생하는 에러
## Error: failed to check for the availability of 'packaging.carvel.dev' API: failed to discover unmatched GroupVersionResources: the server is currently unable to handle the request
## Error: exit status 1

secret contoller를 설치를 안할 경우 발생하는 에러
## Error: secret plugin can not be used as 'secretgen.carvel.dev/v1alpha1' API is not available in the cluster
## Error: exit status 1
```

## 3. TANZU FRAMEWORK 및 Pcakage Image Repository 업로드
TANZU FRAMEWORK다운로드는 Tanzu Net에서 다운로드를 받을 수 있다. 
TANZU APPLICATION PLATFORM 설치는 1.4.0으로 진행 

```shell
tar xvf tanzu-framework-linux-amd64-v0.25.4.1.tar
tanzu plugin install -l ./cli/ all

## 이미지를 받기 위해 tanzu net에 로그인 한다.
docker login registry.tanzu.vmware.com -u {tanzuusername}

## 이후에 내부 또는 gcr 등등 repository에 로그인 한다. 테스트는 내부 Harbor를 사용한다.
docker login infra-harbor.huntedhappy.kro.kr -u admin

## TAP Package 내부 Harbor에 업로드
imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:1.4.0 --to-repo infra-harbor.huntedhappy.kro.kr/tap-packages/1.4.0
```
## 4. TAP Package 등록

```shell
## namespace 생성
kubectl create ns tap-install 

## Harbor Secret 사용할 경우
kubectl create secret docker-registry registry-credentials --docker-server=infra-harbor.huntedhappy.kro.kr --docker-username=admin --docker-password=${INSTALL_REGISTRY_PASSWORD} -n tap-install

## package repository 추가
tanzu package repository add tanzu-tap-repository \
  --url harbor-infra.huntedhappy.kro.kr/tap-packages/1.4.0 \
  --namespace tap-install

## TBS 설치
imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/full-tbs-deps-package-repo:1.9.0 --to-tar=tbs-full-deps-1.9.0.tar

## TBS Harobr업로드
imgpkg copy --tar tbs-full-deps-1.9.0.tar --to-repo harbor-infra.huntedhappy.kro.kr/tap/tbs-full-deps/1.9.0 --include-non-distributable-layers

## TBS Repository 등록
tanzu package repository add tbs-full-deps-repository \
  --url infra-harbor.huntedhappy.kro.kr/tap/tbs-full-deps/1.9.0 \
  --namespace tap-install
```

## 5. 설치

TAP같은 경우 멀티 클러스터를 지원 하지만, 테스트는 full 기반으로 테스트를 진행 하였습니다.

설치는 ootb_supply_chain_testing_scanning 로 테스트를 진행 했지만. 좀 복잡 할 수 있기 때문에
여기에는 ootb_supply_chain_basic으로 기술 합니다.

```shell
vi tap-full-vaules.yaml

profile: full
ceip_policy_disclosed: true

buildservice:
  kp_default_repository: "infra-harbor.huntedhappy.kro.kr/tap/tap-packages"
  kp_default_repository_secret:
    name: "registry-credentials"
    namespace: "tap-install"
  exclude_dependencies: true

springboot_conventions:
  autoConfigureActuators: true

policy:
  tuf_enable: true

accelerator:
  domain: huntedhappy.kro.kr
  ingress:
    include: true
    enable_tls: true
  tls:
    secret_name: share-secret
    namespace: tap-install
  server:
    service_type: "ClusterIP"
    watched_namespace: "accelerator-system"
  samples:
    include: false

shared:
  kubernetes_distribution: "openshift" # To be passed only for OpenShift. Defaults to "".
  ingress_issuer: default-ca-issuer
  image_registry:
    secret:
      name: "registry-credentials"
      namespace: "tap-install"
  ingress_domain: "huntedhappy.kro.kr"
#  ca_cert_data: |

appliveview:
  ingressEnabled: true
  sslDisabled: false
  tls:
    namespace: tap-install
    secretName: share-secret

appliveview_connector:
  backend:
    sslDisabled: false
    host: appliveview.huntedhappy.kro.kr

cnrs:
  domain_name: huntedhappy.kro.kr
  domain_template: "{{.Name}}.{{.Domain}}"
  default_tls_secret: tap-install/share-secret

scanning:
  metadataStore:
    url: "" # Disable embedded integration since it's deprecated

metadata_store:
  ns_for_export_app_cert: "*"
  ingress_domain: huntedhappy.kro.kr
  app_service_type: ClusterIP
  ingress_enabled: "true"
  targetImagePullSecret: "registry-credentials"
  tls:
    secretName: share-secret
    namespace: tap-install

supply_chain: basic

ootb_supply_chain_basic:
  registry:
    server: "infra-harbor.huntedhappy.kro.kr"
    repository: "app/supply_chain"

grype:
  namespace: "tap-install" # (optional) Defaults to default namespace.
  targetImagePullSecret: "registry-credentials"

tap_gui:
  service_type: ClusterIP
  ingressEnabled: "true"
  ingressDomain: "huntedhappy.kro.kr"
  tls:
    namespace: tap-install
    secretName: share-secret
  app_config:
    organization:
      name: 'huntedhappy'

    app:
      title: 'huntedhappy TAP'
      baseUrl: https://tap-gui.huntedhappy.kro.kr
      support:
        url: https://tanzu.vmware.com/support
        items:
          - title: Contact Support
            icon: email
            links:
              - url: https://tanzu.vmware.com/support
                title: Tanzu Support Page
          - title: Documentation
            icon: doc
            links:
              - url: https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/index.html
                title: Tanzu Application Platform Documentation

    backend:
      baseUrl: https://tap-gui.huntedhappy.kro.kr
      cors:
        origin: https://tap-gui.huntedhappy.kro.kr


contour:
  certificates.duration: 87600h
  certificates.renewBefore: 360h
  envoy:
    service:
      type: LoadBalancer

excluded_packages:
- policy.apps.tanzu.vmware.com
- learningcenter.tanzu.vmware.com
- workshops.learningcenter.tanzu.vmware.com
```
```shell
## rback 설정
cat << EOF | kubectl apply -f -
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
automountServiceAccountToken: false
---
apiVersion: v1
kind: Secret
metadata:
  name: tap-gui-viewer
  namespace: tap-gui
  annotations:
    kubernetes.io/service-account.name: tap-gui-viewer
type: kubernetes.io/service-account-token
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
  resources: ['pods', 'pods/log', 'services', 'configmaps']
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
  - mavenartifacts
  verbs: ['get', 'watch', 'list']
- apiGroups: ['conventions.carto.run']
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
  - scanpolicies
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
```shell
## rolebding 설정
cat << EOF | kubectl apply -f -
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
```shell
kubectl patch sa default -n tap-install --type 'json' -p '[{"op":"add","path":"/secrets","value":["name":"registry-credentials"]}]'
kubectl patch sa default -n tap-install --type 'json' -p '[{"op":"add","path":"/imagePullSecrets","value":["name":"registry-credentials"]}]'

```
```shell
## TANZU PACKAGE 1.4.0 설치
tanzu package install tap -p tap.tanzu.vmware.com -v 1.4.0 -f tap-full-vaules.yaml -n tap-install

## TBS 설치
tanzu package install full-tbs-deps -p full-tbs-deps.tanzu.vmware.com -v 1.9.0 -n tap-install
```

## 6. 설치 완료

{{< figure src="/images/tapandopenshift/1-2.png" title="설치 완료#1" >}}

Sample App Test
{{< figure src="/images/tapandopenshift/1-3.png" title="설치 완료#2" >}}

Sample App Test를 하게 될 경우 아래와 같은 문구가 나오는대 왜 나오는지는 아직 파악 하지 못하였습니다. 하지만 SAMPLE APP 배포는 잘 동작 하는 것을 확인 할 수 있습니다.

* I0129 14:54:36.521207 2768383 request.go:682] Waited for 1.007213447s due to client-side throttling, not priority and fairness, request: GET:https://api.openshift.huntedhappy.kro.kr:6443/apis/console.openshift.io/v1alpha1?timeout=32s

배포가 완료 되면 httpproxy,pod,deliverable을 확인 하여 httpproxy에 설정된 도메인으로 접속 할 수 있다.
{{< figure src="/images/tapandopenshift/1-8.png" title="FQDN 확인" >}}

{{< figure src="/images/tapandopenshift/1-4.png" title="설치 완료#2" >}}
{{< figure src="/images/tapandopenshift/1-5.png" title="TAP GUI 화면#1" >}}
{{< figure src="/images/tapandopenshift/1-6.png" title="TAP GUI 화면#2" >}}
{{< figure src="/images/tapandopenshift/1-7.png" title="TAP GUI 화면#2" >}}

설치가 완료 되면 TAP의 대해서는 Visual Sutudio Code, IntelliJ 환경에서도 잘 동작하는 것을 확인 할 수 있습니다.

* 나중에 추가적인 설명을 할 수 있으면 적을 수 있도록 하겠습니다.
