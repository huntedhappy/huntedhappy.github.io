# The Documentation NAP


## 1. NAP?
NAP(NGINX App Protect)은 WAF and DoS Protection을 제공 한다. NGINX Plus에서 제공을 하며 컨테이너 환경에서 App을 보호 하기 위한 솔루션이다. 대부분 컨테이너 환경에서 Ingress를 NGINX로 많이 사용 할 것이다. NGINX Plus 라이센스를 구매 하면 NAP을 사용 할 수 있다.

## 2. 사전 구성
* Docker v18.09&#43;
* GNU Make
* git
* Helm3
* OpenSSL
* https://github.com/OpenVPN/easy-rsa.git
* apt install git \  make \ make-guile 

## 3. 설치
Namespace 생성 후 easy-rsa git clone
```shell
kubectl create ns ingress-nginx

git clone https://github.com/OpenVPN/easy-rsa.git
```
{{&lt; figure src=&#34;/images/nap/1-1.png&#34; title=&#34;easy rsa&#34; &gt;}}

인증서 생성 (인증서 생성은 반드시 이렇게 하지 않아도 된다.)
```shell
cd easy-rsa/easyrsa3/

./easyrsa init-pki
./easyrsa build-ca
```
{{&lt; figure src=&#34;/images/nap/1-2.png&#34; title=&#34;easy rsa 구성#1&#34; &gt;}}
```shell
./easyrsa gen-req wildcard

./easyrsa sign-req server wildcard
```
{{&lt; figure src=&#34;/images/nap/1-3.png&#34; title=&#34;easy rsa 구성#2&#34; &gt;}}

```shell
openssl rsa -in /var/tmp/easy-rsa/easyrsa3/pki/private/wildcard.key -out /var/tmp/easy-rsa/easyrsa3/pki/private/wildcard-unencrypted.key

## 인증서 Secret 생성
kubectl create -n ingress-nginx secret tls wildcard-tls --key /var/tmp/easy-rsa/easyrsa3/pki/private/wildcard-unencrypted.key --cert /var/tmp/easy-rsa/easyrsa3/pki/issued/wildcard.crt

## 안지워도된다.
rm /var/tmp/easy-rsa/easyrsa3/pki/private/wildcard-unencrypted.key
```

{{&lt; figure src=&#34;/images/nap/1-4.png&#34; title=&#34;ssl 인증서 secret 생성&#34; &gt;}}

secret 인증서 확인
```shell
kubectl get secret -n ingress-nginx
```
{{&lt; figure src=&#34;/images/nap/1-5.png&#34; title=&#34;secret 확인&#34; &gt;}}


```shell
cd /var/tmp

## nap을 위한 yaml파일 다운로드
git clone https://github.com/nginxinc/kubernetes-ingress/

## nap을 위한 helm repo 주소 추가
helm repo add nginx-stable https://helm.nginx.com/stable
```

{{&lt; figure src=&#34;/images/nap/1-6.png&#34; title=&#34;git clone&#34; &gt;}}

```shell
cd /var/tmp/kubernetes-ingress/deployments/helm-chart
git checkout v1.11.3
```
{{&lt; figure src=&#34;/images/nap/1-7.png&#34; title=&#34;git checkout&#34; &gt;}}

라이센스 발급 30일 trial을 받을 수 있다. 가입 필요
[:(far fa-file-archive fa-fw): NAP 발급 링크](https://www.nginx.com/free-trial-request-nginx-ingress-controller/)

미리 Harbor에 ingress-nginx project 생성이 되어 있어야함

```shell
REGISTRY=&lt;registry IP or FQDN&gt;
NS=&lt;your namespace&gt;
REGISTRY=10.253.110.4
NS=ingress-nginx
```
{{&lt; figure src=&#34;/images/nap/1-8.png&#34; title=&#34;Harbor 확인&#34; &gt;}}

발급 받은 라이센스를 복사
```shell
mkdir -p /var/tmp/kubernetes-ingress
cp nginx-repo.key nginx-repo.crt  /var/tmp/kubernetes-ingress
```
{{&lt; figure src=&#34;/images/nap/1-9.png&#34; title=&#34;라이센스 복사&#34; &gt;}}

```shell
cd /var/tmp/kubernetes-ingress

make debian-image-nap-plus PREFIX=$REGISTRY/$NS/nginx-plus-ingress TARGET=container
```
{{&lt; figure src=&#34;/images/nap/1-10.png&#34; title=&#34;Docker Pull&#34; &gt;}}

docker image 확인
```shell
docker images
```
{{&lt; figure src=&#34;/images/nap/1-11.png&#34; title=&#34;Docker Image 확인&#34; &gt;}}

Harbor에 Push
```shell
docker image tag 18a49497920c $REGISTRY/$NS/nginx-plus-ingress:1.11.3

docker login &lt;harbor IP&gt;
make push PREFIX=$REGISTRY/$NS/nginx-plus-ingress
```
{{&lt; figure src=&#34;/images/nap/1-12.png&#34; title=&#34;Harbor push#1&#34; &gt;}}
{{&lt; figure src=&#34;/images/nap/1-13.png&#34; title=&#34;Harbor push#2&#34; &gt;}}
{{&lt; figure src=&#34;/images/nap/1-14.png&#34; title=&#34;Harbor push#3&#34; &gt;}}

Helm Value 복사 (원본을 건드리지 않게 하기 위해 별도로 복사를 한다.)
```shell
cd deployments/helm-chart
cp values-plus.yaml values-plus.yaml.orig
```
{{&lt; figure src=&#34;/images/nap/1-15.png&#34; title=&#34;Helm Value 복사&#34; &gt;}}

복사한 파일을 열어 보면 아래와 같이 되어 있는대 수정해줘야 하는 부분을 수정 해준다.

```shell
## vi 편집
vi values-plus.yaml 

## 내용 (imagePullSecretName의 경우 Harbor에 Public으로 만들었으면 상관 없음)
controller:
  replicaCount: 1
  nginxplus: true
  image:
    repository: 10.253.106.46/ingress-nginx/nginx-plus-ingress
    tag: &#34;1.11.3&#34;
  service:
    externalTrafficPolicy: Cluster
  appprotect:
    ## Enable the App Protect module in the Ingress Controller.
    enable: true
  wildcardTLS:
    ## The base64-encoded TLS certificate for every Ingress host that has TLS enabled but no secret specified.
    ## If the parameter is not set, for such Ingress hosts NGINX will break any attempt to establish a TLS connection.
    cert: &#34;&#34;

    ## The base64-encoded TLS key for every Ingress host that has TLS enabled but no secret specified.
    ## If the parameter is not set, for such Ingress hosts NGINX will break any attempt to establish a TLS connection.
    key: &#34;&#34;

    ## The secret with a TLS certificate and key for every Ingress host that has TLS enabled but no secret specified.
    ## The value must follow the following format: `&lt;namespace&gt;/&lt;name&gt;`.
    ## Used as an alternative to specifying a certificate and key using `controller.wildcardTLS.cert` and `controller.wildcardTLS.key` parameters.
    ## Format: &lt;namespace&gt;/&lt;secret_name&gt;
    secret: ingress-nginx/wildcard-tls
  serviceAccount:
    ## The name of the service account of the Ingress controller pods. Used for RBAC.
    ## Autogenerated if not set or set to &#34;&#34;.
    name: ingress-nginx
    ## The name of the secret containing docker registry credentials.
    ## Secret must exist in the same namespace as the helm release.
    imagePullSecretName: &#34;regcred&#34;
```

PSP를 혀용하기 위해 해당 파일을 실행 해준다.
```shell
kubectl apply -f https://raw.githubusercontent.com/f5devcentral/f5-bd-tanzu-tkg-nginxplus/main/nginx-psp.yaml
```
{{&lt; figure src=&#34;/images/nap/1-16.png&#34; title=&#34;psp 허용&#34; &gt;}}

HELM 실행
```shell
kubectl create secret generic regcred --from-file=.dockerconfigjson=$HOME/.docker/config.json --type=kubernetes.io/dockerconfigjson -n ingress-nginx

helm install nap nginx-stable/nginx-ingress -f values-plus.yaml -n ingress-nginx
```

{{&lt; figure src=&#34;/images/nap/1-17.png&#34; title=&#34;helm으로 nap 설치&#34; &gt;}}

설치 확인
```shell
watch -n 1 kubectl -n ingress-nginx get all
```
{{&lt; figure src=&#34;/images/nap/1-18.png&#34; title=&#34;설치 확인&#34; &gt;}}
{{&lt; figure src=&#34;/images/nap/1-19.png&#34; title=&#34;L4 확인&#34; &gt;}}

## 4. WAF
WAF TEST를 위해 웹 구성

### 4.1. TEST WEB 구성
TEST를 하기 위해 제공하는 Manifest를 다운로드 한다.
```shell
wget https://raw.githubusercontent.com/f5devcentral/f5-bd-tanzu-tkg-nginxplus/main/cafe-rbac.yaml
wget https://raw.githubusercontent.com/f5devcentral/f5-bd-tanzu-tkg-nginxplus/main/cafe.yaml
wget https://raw.githubusercontent.com/f5devcentral/f5-bd-tanzu-tkg-nginxplus/main/cafe-ingress.yaml

kubectl apply -f cafe-rbac.yaml -n test
kubectl apply -f cafe.yaml -n test

vi cafe-ingress.yaml (인증서 만들었던 Domain으로 변경)
```
{{&lt; figure src=&#34;/images/nap/2-1.png&#34; title=&#34;Domain을 변경 한다.&#34; &gt;}}

Domain 변경 후 실행
```shell
kubectl apply -f cafe-ingress.yaml -n test
```
{{&lt; figure src=&#34;/images/nap/2-2.png&#34; title=&#34;Ingress 확인.&#34; &gt;}}

POSTMAN으로 접속이 되는지 확인
{{&lt; figure src=&#34;/images/nap/2-3.png&#34; title=&#34;POSTMAN 확인.&#34; &gt;}}

### 4.2. WAF 구성
ELK를 구성 하기 위해 syslog pod를 구성한다.
```shell
wget https://raw.githubusercontent.com/f5devcentral/f5-bd-tanzu-tkg-nginxplus/main/syslog-rbac.yaml
wget https://raw.githubusercontent.com/f5devcentral/f5-bd-tanzu-tkg-nginxplus/main/syslog.yaml

kubectl apply -f syslog-rbac.yaml -n ingress-nginx
```
```shell
kubectl apply -f syslog.yaml -n ingress-nginx
wget https://raw.githubusercontent.com/f5devcentral/f5-bd-tanzu-tkg-nginxplus/main/ap-apple-uds.yaml
wget https://raw.githubusercontent.com/f5devcentral/f5-bd-tanzu-tkg-nginxplus/main/ap-dataguard-alarm-policy.yaml
wget https://raw.githubusercontent.com/f5devcentral/f5-bd-tanzu-tkg-nginxplus/main/ap-logconf.yaml

kubectl apply -f  ap-apple-uds.yaml -n test
kubeclt apply -f  ap-dataguard-alarm-policy.yaml -n test
kubectl apply -f  ap-logconf.yaml -n test
```

ingress에 annotation을 설정
```shell
wget https://raw.githubusercontent.com/f5devcentral/f5-bd-tanzu-tkg-nginxplus/main/cafe-ingress-ap.yaml
kubectl get pod -n ingress-nginx -o wide

## vi 편집 실행
vi cafe-ingress-ap.yaml

apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: cafe-ingress
  annotations:
    appprotect.f5.com/app-protect-policy: &#34;test/dataguard-alarm&#34;
    appprotect.f5.com/app-protect-enable: &#34;True&#34;
    appprotect.f5.com/app-protect-security-log-enable: &#34;True&#34;
    appprotect.f5.com/app-protect-security-log: &#34;test/logconf&#34;
    appprotect.f5.com/app-protect-security-log-destination: &#34;syslog:server=SYSLOG:514&#34;
spec:
  ingressClassName: nginx # use only with k8s version &gt;= 1.18.0
  tls:  - hosts:
    - cafe.vcf.local  ## 인증서와 동일한 도메인으로 변경
  rules:
  - host: cafe.vcf.local ## 인증서와 동일한 도메인으로 변경
    http:
      paths:
      - path: /tea
        backend:
          serviceName: tea-svc
          servicePort: 80
      - path: /coffee
        backend:
          serviceName: coffee-svc
          servicePort: 80
```


```shell
## syslog service ip
SYSLOG_IP=10.101.182.155
vi cafe-ingress-ap.yaml

sed -e &#34;s/SYSLOG/$SYSLOG_IP/&#34; cafe-ingress-ap.yaml &gt; cafe-ingress-ap-syslog.yaml
kubectl apply -n test -f cafe-ingress-ap-syslog.yaml

kubectl get ingress -n test

## 아래 명령어로 annotation을 확인 할 수 있다.
kubrectl get ingress cafe-ingress -n test -o yaml
```

{{&lt; figure src=&#34;/images/nap/2-4.png&#34; title=&#34;Annotation 확인.&#34; &gt;}}

```shell
kubectl get pod -n ingress-nginx

LOG 확인
kubectl -n ingress-nginx exec -it syslog-65d847447d-ghbvq -- tail -f /var/log/messages
```
{{&lt; figure src=&#34;/images/nap/2-5.png&#34; title=&#34;syslog pod 확인.&#34; &gt;}}
{{&lt; figure src=&#34;/images/nap/2-6.png&#34; title=&#34;PostMan 요청 후 REJECT확인.&#34; &gt;}}
{{&lt; figure src=&#34;/images/nap/2-7.png&#34; title=&#34;Pod 로그 확인시 Attack 확인.&#34; &gt;}}

## 5. ELK
LOG를 좀 가시적이게 표현하기 위해 ELK를 구성

### 5.1. Elastic 연동

logstach를 5144로 구성한 이유는 Logstach 구성시 514가 well-known 포트라 5144로 변경
logstash yaml 파일, [:(far fa-file-archive fa-fw): logstash_test.yaml](logstash_test.yaml).

{{&lt; figure src=&#34;/images/nap/5-1.png&#34; title=&#34;logstach 확인.&#34; &gt;}}

ingress 설정에서 syslog server 를 logstash cluster IP로 설정
{{&lt; figure src=&#34;/images/nap/5-2.png&#34; title=&#34;annotation에서 logstach로 syslog IP 변경 .&#34; &gt;}}

해당 파일을 다운로드 받는다.

[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Dashboard 링크 ](https://github.com/f5devcentral/f5-waf-elk-dashboards)

```shell
mkdir /var/tmp/kibana
cd /var/tmp/kibana
cp false-positives-dashboards.ndjson overview-dashboard.ndjson /var/tmp/kibana
```
{{&lt; figure src=&#34;/images/nap/5-3.png&#34; title=&#34;파일 다운로드&#34; &gt;}}


대쉬보드 업로드
```shell
cd /var/tmp

KIBANA_URL= {FQDN or IP}
KIBANA_URL=http://kibana.vcf.local:5601

jq -s . kibana/overview-dashboard.ndjson | jq &#39;{&#34;objects&#34;: . }&#39; | \
curl -k --location --request POST &#34;$KIBANA_URL/api/kibana/dashboards/import&#34; \
--header &#39;kbn-xsrf: true&#39; \
--header &#39;Content-Type: text/plain&#39; -d @- \
| jq

jq -s . kibana/false-positives-dashboards.ndjson | jq &#39;{&#34;objects&#34;: . }&#39; | \
curl -k --location --request POST &#34;$KIBANA_URL/api/kibana/dashboards/import&#34; \
--header &#39;kbn-xsrf: true&#39; \
--header &#39;Content-Type: text/plain&#39; -d @- \
| jq
```

kibana접속 후 index patterns에 waf-logs-* 확인
{{&lt; figure src=&#34;/images/nap/5-4.png&#34; title=&#34;kibana 확인&#34; &gt;}}
{{&lt; figure src=&#34;/images/nap/5-5.png&#34; title=&#34;kibana 대시보드 확인&#34; &gt;}}

[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; 참고문헌 ](https://devcentral.f5.com/s/articles/Deploying-NGINXplus-with-AppProtect-in-Tanzu-Kubernetes-Grid)

---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/nap/  

