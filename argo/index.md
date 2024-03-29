# The Documentation Argo-CD


gitops explain ing.....
---

## ARGO?
CI/CD에서 CD를 아르고로 선택한 이유는 인프라 변경 사항에 대한 추적이 좀 가능 하기도 하며 또한 구성 및 배포가 쉽다라고 생각 했다.

설치 환경은 Tanzu 1.4 버전으로 진행


{{&lt; admonition tip &#34;CI/CD&#34; &gt;}}
CI/CD는 애플리케이션 개발 단계를 자동화하여 애플리케이션을 보다 짧은 주기로 고객에게 제공한다. 
CI (Continuous Integration) CI를 통해 개발자들은 코드 변경사항을 공유 브랜치로 다시 병합하는 작업을 더욱 수월하게 자주 수행 할 수 있다.
CD (Continuous Delivery || Continuous Deploy) 두용어는 상호 교환적으로 사용됨.
* Continuous Deliver의 경우 코드 변경 , 병합으로부터 Prodcution에 적합한 빌드를 제공하여 모든 단계에 테스트 및 릴리스를 자동화한다.
* Continuous Deploy는 어플리케이션을 프로덕션으로 릴리스 작업을 자동화
{{&lt; /admonition &gt;}}

{{&lt; figure src=&#34;/images/jenkins/0-1.png&#34; title=&#34;CICD&#34; &gt;}}

참고 문헌 [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Redhat ](https://www.redhat.com/ko/topics/devops/what-is-ci-cd)

## 1. Requirements

helm 설치, [:(far fa-file-archive fa-fw): Helm](https://github.com/helm/helm/releases).

## 2. 환경
vSphere : 7.0

vSAN

NSX : 3.2

AVI : 21.1.1

Tanzu 1.4

## 3. 설치
{{&lt; admonition tip &#34;ARGO Install&#34; &gt;}}
{{&lt; version 0.2.0 &gt;}}

Namespace 생성
```shell
kubectl create ns argocd
```
Helm Repo 등록
```shell
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```
&gt; Optional : Helm 에서 value 값을 수정 하고 싶으면 별도로 다운로드
```shell
helm show values argo/argo-cd &gt; argocd.yaml
```
&gt; Optional : HTTPS로 구성을 하려고 한다면 인증서 등록을 해준다.
```shell
kubectl create secret tls argo-tls --cert=/data/cert/yourdomain.com.crt --key=/data/cert/yourdomain.com.key -n argocd
```
수정이 필요 없으면 바로 시작 하면 된다. 
```shell
helm install argocd argo/argo-cd -n argo
```
접속 하기 위해 Portfoward를 하자
```shell
kubectl port-forward service/argocd-server -n argo 8080:443
```
ID는 admin 이며, PW는 별도의 명령으로 알아 낼수 있다.
```shell
kubectl -n argo get secret argocd-initial-admin-secret -o jsonpath=&#34;{.data.password}&#34; | base64 -d
```
{{&lt; /admonition &gt;}}

![접속 페이지](/images/ARGO/3-1.png &#34;접속 페이지&#34;)
![User Info](/images/ARGO/3-2.png &#34;User Info&#34;)

## 4. Auth - LDAP Integration
{{&lt; admonition tip &#34;LDAP Integration&#34; &gt;}}

LDAP을 연동 하기 위해선 values 값을 다운로드 하는 것이 좋다.
```shell
helm show values argo/argo-cd &gt; argocd.yaml
vi argocd.yaml
```
다운로드 받은 Yaml파일중에 dex부분을 수정한다, 없으면 추가 한다.
```shell
    dex.config: |
      connectors:
      - type: ldap
        name: Ldap
        id: ldap
        config:
          # Ldap server address
          host: tanzu-dns.tkg.io:389
          insecureNoSSL: true
          insecureSkipVerify: true
          startTLS: false
          bindDN: &#34;$dex.ldap.bindDN&#34;
          bindPW: &#34;$dex.ldap.bindPW&#34;
          usernamePrompt: Username
          userSearch:
            baseDN: &#34;ou=tanzu,dc=tkg,dc=io&#34;
            filter: (objectClass=person)
            username: sAMAccountName
            idAttr: DN
            emailAttr: mail
            nameAttr: sAMAccountName
          groupSearch:
            baseDN: &#34;ou=tanzu,dc=tkg,dc=io&#34;
            filter: (objectClass=person)
            userAttr: DN
            groupAttr: member
            nameAttr: name
```
그리고 Secret을 생성 해준다.
```shell
kubectl -n argo patch secrets argocd-secret --patch &#34;{\&#34;data\&#34;:{\&#34;dex.ldap.bindPW\&#34;:\&#34;$(echo &#39;Passw0rd&#39; | base64 -w 0)\&#34;}}&#34;
kubectl -n argo patch secrets argocd-secret --patch &#34;{\&#34;data\&#34;:{\&#34;dex.ldap.bindDN\&#34;:\&#34;$(echo cn=administrator,cn=users,dc=tanzu,dc=io | base64 -w 0)\&#34;}}&#34;
```
HELM 실행 
```shell
helm install argocd argo/argo-cd -n argo \
--set server.extraArgs[0]=--insecure \
-f argocd.yaml
```
접속 하기 위해 Portfoward를 하자
```shell
kubectl port-forward service/argocd-server -n argo 8080:443
```
ID는 admin 이며, PW는 별도의 명령으로 알아 낼수 있다.
```shell
kubectl -n argo get secret argocd-initial-admin-secret -o jsonpath=&#34;{.data.password}&#34; | base64 -d
```
{{&lt; /admonition &gt;}}

### 4.1. RBAC 적용
RBAC을 적용 해주어 Admin 권한으로 접속이 되는지 확인
{{&lt; admonition tip &#34;LDAP Integration&#34; &gt;}}

confimap을 수정 해서 RBAC의 대한 설정을 해준다.
```shell
kubectl edit cm argocd-rbac-cm -n argo
```
configmap을 수정 하면 아래 내용이 있으면 수정 하고 없으면 추가 해준다.
```shell
apiVersion: v1
data:
  policy.csv: |
    p, role:my1208, applications, *, my1208/*, allow
    p, role:my1208, projects, get, my1208, allow
    p, role:my1208, repositories, get, *, allow
    p, role:my1208, clusters, get, *, allow
    g, my1208, role:admin
    p, role:none, *, *, */*, deny
    g, tkg, role:readonly
    g, my1208@openbase.co.kr, role:admin
  policy.default: role:none
  scopes: &#39;[groups,email]&#39;
```
Pod를 재 실행 해 준다.
```shell
delete=`kubectl get pod -n argo | grep -v  repo | egrep  &#39;server|dex&#39; | awk &#39;{print $1}&#39; | xargs echo`
kubectl delete pod $delete -n argo
```
{{&lt; /admonition &gt;}}

{{&lt; figure src=&#34;/images/ARGO/4-1.png&#34; title=&#34;접속 화면&#34; &gt;}}

## 5. SLACK 연동
메시지를 SLACK으로 받기 위해 연동

### 5.1. SLACK 설정
[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; SLACK APP 등록 ](https://api.slack.com/apps?new_app=1)
{{&lt; figure src=&#34;/images/ARGO/5-1.png&#34; title=&#34;APP 추가#1&#34; &gt;}}

{{&lt; figure src=&#34;/images/ARGO/5-2.png&#34; title=&#34;APP 추가#2&#34; &gt;}}

APP을 추가하기 위해 APP의 Name 설정 및 workspace를 선택 한다.
{{&lt; figure src=&#34;/images/ARGO/5-3.png&#34; title=&#34;APP 추가#3&#34; &gt;}}
OAuth &amp; Permmissions을 클릭 하면 아래처럼 화면이 나온다.
{{&lt; figure src=&#34;/images/ARGO/5-4.png&#34; title=&#34;APP 추가#4&#34; &gt;}}
Scopes를 찾아서 chat을 찾은후 적용
{{&lt; figure src=&#34;/images/ARGO/5-5.png&#34; title=&#34;APP 추가#5&#34; &gt;}}
그러면 OAuth Tokens for Your Workspace가 활성화 되는 것을 확인 할 수 있다 그리고 Install to Workspaces를 클릭
{{&lt; figure src=&#34;/images/ARGO/5-6.png&#34; title=&#34;APP 추가#6&#34; &gt;}}
{{&lt; figure src=&#34;/images/ARGO/5-7.png&#34; title=&#34;APP 추가#7&#34; &gt;}}
TOKEN을 복사 한다.
{{&lt; figure src=&#34;/images/ARGO/5-8.png&#34; title=&#34;APP 추가#8&#34; &gt;}}
APP을 추가 해준다.
{{&lt; figure src=&#34;/images/ARGO/5-9.png&#34; title=&#34;APP 추가#9&#34; &gt;}}
{{&lt; figure src=&#34;/images/ARGO/5-10.png&#34; title=&#34;APP 추가#10&#34; &gt;}}
새로 만든 APP이 나오는 것을 확인 할 수 있다.
{{&lt; figure src=&#34;/images/ARGO/5-11.png&#34; title=&#34;APP 추가#11&#34; &gt;}}

솔직히 여기 잘 나와 있다. [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; SLACK APP 등록 ](https://argocd-notifications.readthedocs.io/en/stable/services/slack/)

### 5.2. ARGO 설정
ARGO 설정은 별도로 UI에서 제공을 하지 않기 때문에 ConfigMap을 좀 수정 해야 한다. Helm에서 제공을 하긴 하는대 현재는 버그가 있는지 배포가 되지 않아 별도의 방법으로 구성한다. 

{{&lt; admonition example &#34;Slack 연동&#34; &gt;}}
해당 파일을 다운 로드 받은 후 실행
```shell
wget -O argo-noty-secret.yaml https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/v1.2.1/manifests/install.yaml
wget -O argo-noty-config.yaml https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/v1.2.1/catalog/install.yaml

kubectl apply -f argo-noty-secret.yaml -n argo
kubectl apply -f argo-noty-config.yaml -n argo
```
그리고 secret 과 configmap을 수정한다. 사전에 변경해도 상관은 없다.
```shell
kubectl edit secret argocd-notifications-secret -n argo

apiVersion: v1
kind: Secret
metadata:
  name: argocd-notifications-secret
stringData:
  slack-token: xoxb-xxxxxxxxxx-xxxxxxxxxx-xxxxxxx

kubectl edit cm argocd-notifications-cm -n argo

apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-notifications-cm
data:
  service.slack: |
    ## apiURL: &lt;url&gt;                 # optional URL, e.g. https://example.com/api
    token: $slack-token              # 위에 secret을 참고 함 
    ## username: &lt;override-username&gt; # optional username
    ## icon: &lt;override-icon&gt; # optional icon for the message (supports both emoij and url notation)
```

{{&lt; /admonition &gt;}}
Default Definition 참고. [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; SLACK으로 보낼 내용 정리 ](https://argocd-notifications.readthedocs.io/en/stable/services/slack/)


{{&lt; admonition tip&#34;Slack 연동&#34; &gt;}}
테스트를 위해 Application을 배포 한다.
```shell
cat &lt;&lt; EOF | tee guestbook.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  annotations:
    notifications.argoproj.io/subscribe.on-sync-succeeded.slack: dk-devops
    notifications.argoproj.io/subscribe.on-sync-succeeded.slack: dk-devops
    notifications.argoproj.io/subscribe.on-sync-failed.slack: dk-devops
    notifications.argoproj.io/subscribe.on-sync-running.slack: dk-devops
    notifications.argoproj.io/subscribe.on-sync-status-unknown.slack: dev-ops
    notifications.argoproj.io/subscribe.on-deployed.slack: dk-devops
    notifications.argoproj.io/subscribe.on-health-degraded.slack: dk-devops
spec:
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  project: default
  source:
    path: kustomize-guestbook
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
  syncPolicy:
    automated: {}
EOF
```
{{&lt; /admonition &gt;}}

그럼 아래와 같이 Slack으로 메시지가 오는 것을 확인 할 수 있다.

{{&lt; figure src=&#34;/images/ARGO/5-12.png&#34; title=&#34;SLACK 확인&#34; &gt;}}

또는 UI에서 Application에 Annotation을 설정해서 확인 할 수 있다.
{{&lt; figure src=&#34;/images/ARGO/5-13.png&#34; title=&#34;GUI에서 Annotation 설정#1&#34; &gt;}}
{{&lt; figure src=&#34;/images/ARGO/5-14.png&#34; title=&#34;GUI에서 Annotation 설정#2&#34; &gt;}}
{{&lt; figure src=&#34;/images/ARGO/5-15.png&#34; title=&#34;GUI에서 Annotation 설정#3&#34; &gt;}}

---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/argo/  

