# The Documentation Openshift



## 1. Openshift
`오픈시프트 오리진(OpenShift Origin)`은 오픈시프트 온라인, 오픈시프트 데디케이티드, 오픈시프트 컨테이너 플랫폼에 사용되는 업스트림 커뮤니티 프로젝트이다. 도커 컨테이너 패키징 코어와 쿠버네티스 컨테이너 클러스터 관리 기능을 기반에 두고 개발된 오리진은 애플리케이션 수명 관리 기능과 데브옵스 도구를 통해 증강된다. 오리진은 오픈 소스 애플리케이션 컨테이너 플랫폼을 제공한다. 오리진 프로젝트의 모든 소스 코드는 깃허브에서 아파치 라이선스 (버전 2.0)을 통해 이용이 가능하다.[4]

`오픈시프트 온라인(OpenShift Online)`은 레드햇의 퍼블릭 클라우드 애플리케이션 개발 및 호스팅 서비스이다. 온라인은 오리진 프로젝트 소스 코드의 버전 2를 제공하였으며, 아파치 라이선스 버전 2.0 하에서 이용이 가능하다.[5] 온라인은 리소스 할당 기어(gear) 하에서 구동되는 미리 빌드된 카트리지를 통해 다양한 언어, 프레임워크 데이터베이스를 지원한다. 개발자들은 오픈시프트 카트리지 API를 통해 다른 언어, 데이터베이스, 구성 요소를 추가할 수 있다.[6] 오픈시프트 3의 선호로 사용이 권장되지 않는다(deprecated).

`오픈시프트 데디케이티드(OpenShift Dedicated)`는 레드햇의 매니지드 프라이빗 클러스터 기능으로, 도커가 제공하는 애플리케이션 컨테이너의 코어를 기반으로 빌드되며 레드햇 엔터프라이즈 리눅스의 토대 위에 쿠버네티스가 제공하는 오케스트레이션 및 관리가 포함되어 있다. 아마존 웹 서비스(AWS)와 구글 클라우드 플랫폼(GCP) 마켓플레이스를 통해 이용이 가능하다.

`오픈시프트 컨테이너 플랫폼(OpenShift Container Platform)`은 레드햇의 사내(on-premises) 프라이빗 PaaS 제품으로, 도커가 제공하는 애플리케이션 컨테이너의 코어를 기반으로 빌드되며 레드햇 엔터프라이즈 리눅스의 토대 위에 쿠버네티스가 제공하는 오케스트레이션 및 관리가 포함되어 있다.

참고문헌  [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Openshift ](https://ko.wikipedia.org/wiki/%EC%98%A4%ED%94%88%EC%8B%9C%ED%94%84%ED%8A%B8)

## 2. 사전구성
### 2.1. DNS 구성

|  Common  | Component Name | Cluster Name | BaseDomain | A Record |
| ------------------------- | -------------- | ------------ | ---------- | -------- |
|          | api | openshift | vcf.local | 10.253.107.254 |
|          | api-int| openshift | vcf.local | 10.253.107.254 |
|     *    | apps| openshift | vcf.local | 10.253.107.10 |
| console-openshift-console | apps| openshift | vcf.local | 10.253.107.10 |
|     *    | apps| openshift | vcf.local | 10.253.107.10 |
|          | bootstrap| openshift | vcf.local | 10.253.107.10 |
|          | master0 | openshift | vcf.local | 10.253.107.11 |
|          | master1 | openshift | vcf.local | 10.253.107.12 |
|          | master2 | openshift | vcf.local | 10.253.107.13 |
|          | worker1 | openshift | vcf.local | 10.253.107.14 |
|          | worker2 | openshift | vcf.local | 10.253.107.15 |
|          | worker3 | openshift | vcf.local | 10.253.107.16 |

{{&lt; figure src=&#34;/images/openshift/1-3.png&#34; title=&#34;DNS 구성&#34; &gt;}}

### 2.2. DHCP 구성
DHCP 구성 - NSXT로 구성을 하였다.

{{&lt; figure src=&#34;/images/openshift/1-4.png&#34; title=&#34;DHCP 구성#1&#34; &gt;}}
{{&lt; figure src=&#34;/images/openshift/1-5.png&#34; title=&#34;DHCP 구성#2&#34; &gt;}}
{{&lt; figure src=&#34;/images/openshift/1-6.png&#34; title=&#34;DHCP 구성#3&#34; &gt;}}

## 3. 파일 다운로드

OC를 다운로드 하기 위해 redhat에 가입 하고 Login 필요

OC 다운로드 링크  [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; OC 다운로드 링크 ](https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/auth?client_id=cloud-services&amp;redirect_uri=https%3A%2F%2Fconsole.redhat.com%2Fopenshift%2Finstall&amp;state=3c149436-35f6-4385-9739-68ad3e7cfb3e&amp;response_mode=fragment&amp;response_type=code&amp;scope=openid&amp;nonce=50b0191c-64a2-4655-81da-8ee6e7665375)

{{&lt; figure src=&#34;/images/openshift/1-1.png&#34; title=&#34;OC 다운로드#1&#34; &gt;}}
PullSecret을 저장해 둔다. {{&lt; figure src=&#34;/images/openshift/1-2.png&#34; title=&#34;OC 다운로드#2&#34; &gt;}}

압축을 해제 하고 환경변수를 별도로 구성하지 않게 /usr/local/bin 에다가 copy를 한다.
```shell
tar -xzvf openshift-client-linux.tar.gz

tar -xzvf openshift-install-linux.tar.gz

mv oc kubectl openshift-install /usr/local/bin

oc version

openshift-install version
```

sshkeygen을 생성 한다.
```shell
ssh-keygen -t ed25519 -N &#39;&#39; -f ~/.ssh/id_rsa
	
eval &#34;$(ssh-agent -s)&#34;

ssh-add ~/.ssh/id_rsa
```


## 4. vCenter SSH thumbprint 얻기
```shell
openssl s_client -servername vcsa01.vcf.local -connect vcsa01.vcf.local:443 | openssl x509 | tee ca.crt

cp ca.crt /usr/local/share/ca-certificates/

update-ca-certificates
```


## 5. Temp Image

[:(far fa-file-archive fa-fw): RHCOS Download Link](https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/)

```shell
wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-vmware.x86_64.ova
```
또는 아래와 같이 GUI에서 다운로드 받을 수 있다.

{{&lt; figure src=&#34;/images/openshift/5-1.png&#34; title=&#34;RHCOS OVA GUI 다운로드#2&#34; &gt;}}
{{&lt; figure src=&#34;/images/openshift/5-2.png&#34; title=&#34;RHCOS OVA GUI 다운로드#2&#34; &gt;}}
{{&lt; figure src=&#34;/images/openshift/5-3.png&#34; title=&#34;RHCOS OVA GUI 다운로드#3&#34; &gt;}}
{{&lt; figure src=&#34;/images/openshift/5-4.png&#34; title=&#34;RHCOS OVA GUI 다운로드#4&#34; &gt;}}

### 5.1. Temp 구성
{{&lt; figure src=&#34;/images/openshift/5-5.png&#34; title=&#34;vSphere Temp Upload#1&#34; &gt;}}
{{&lt; figure src=&#34;/images/openshift/5-6.png&#34; title=&#34;vSphere Temp Upload#2&#34; &gt;}}
{{&lt; figure src=&#34;/images/openshift/5-7.png&#34; title=&#34;vSphere Temp Upload#3&#34; &gt;}}
{{&lt; figure src=&#34;/images/openshift/5-8.png&#34; title=&#34;vSphere Temp Upload#4&#34; &gt;}}
{{&lt; figure src=&#34;/images/openshift/5-9.png&#34; title=&#34;vSphere Temp Upload#5&#34; &gt;}}
{{&lt; figure src=&#34;/images/openshift/5-10.png&#34; title=&#34;vSphere Temp Upload#6&#34; &gt;}}
{{&lt; figure src=&#34;/images/openshift/5-11.png&#34; title=&#34;vSphere Temp Upload#7&#34; &gt;}}
{{&lt; figure src=&#34;/images/openshift/5-12.png&#34; title=&#34;vSphere Temp Upload#8&#34; &gt;}}

## 6. OC Install
{{&lt; admonition tip &#34;SSL 구성&#34; &gt;}}

install-config.yaml 참조
```shell
apiVersion: v1
baseDomain: vcf.local
compute:
- architecture: amd64
  hyperthreading: Enabled
  name: worker
  platform: {}
  replicas: 3
controlPlane:
  architecture: amd64
  hyperthreading: Enabled
  name: master
  platform: {}
  replicas: 3
metadata:
  creationTimestamp: null
  name: ocp
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineNetwork:
  - cidr: 10.0.0.0/16
  networkType: OpenShiftSDN
  serviceNetwork:
  - 172.30.0.0/16
platform:
  vsphere:
    apiVIP: 10.253.107.254
    cluster: OBCLUSTER
    datacenter: OBDC
    defaultDatastore: vsanDatastore
    ingressVIP: 10.253.107.253
    network: LS-MGMT-10.253.107.x
    password: Openbase!234
    username: administrator@vsphere.local
    vCenter: vcsa01.vcf.local
  fips: false
publish: External
pullSecret: &#39;full secret 넣어줘야함&#39;
sshKey: |
  ssh-ed25519 AAAAC

```
ocp 실행
```shell
mkdir ocp
cp install-config.yaml ocp
openshift-install create install-config --dir=ocp
```
Manifest 변경
```shell
openshift-install create manifests --dir ocp

cd ~/ocp/openshift
rm -rf 99_openshift-cluster-api_master-*
rm -rf 99_openshift-cluster-api_worker-machineset-0.yaml

cd ~/ocp/manifests/

vi cluster-scheduler-02-config.yml

apiVersion: config.openshift.io/v1
kind: Scheduler
metadata:
  creationTimestamp: null
  name: cluster
spec:
  mastersSchedulable: false    ### true &gt; false change
  policy:
    name: &#34;&#34;
status: {}
```
ignition 실행
```shell
openshift-install create ignition-configs --dir ocp
```
L4 VIP로 설정 필요
```shell
cat &lt;&lt; EOF | tee append-bootstrap.ign
{
  &#34;ignition&#34;: {
    &#34;config&#34;: {
      &#34;merge&#34;: [
        {
          &#34;source&#34;: &#34;http://10.253.107.254:8080/bootstrap.ign&#34; ## L4 VIP로 변경
        }
      ] 
    },
    &#34;version&#34;: &#34;3.1.0&#34;
  }
}
EOF
```
BASE64 실행
```shell
base64 -w0 append-bootstrap.ign &gt; append-bootstrap.64
base64 -w0 master.ign &gt; master.64
base64 -w0 worker.ign &gt; worker.64
```
웹 구성에서 파일을 다운로드 할 수 있게 file 폴더 구성 후 ign을 복사 한다.
```shell
mkdir -p /usr/share/nginx/html/files
cp *.ign /usr/share/nginx/html/files/
chmod 644 /usr/share/nginx/html/files/*.ign
```
{{&lt; /admonition &gt;}}

## 7. NGINX

NGINX 설치
```shell
apt update &amp;&amp; apt upgrade -y

make로 설치
apt install gcc libpcre3 libpcre3-dev libssl-dev make -y

mkdir -p /var/tmp/src &amp;&amp; cd /var/tmp/src
wget http://nginx.org/download/nginx-1.20.2.tar.gz
tar -xzf nginx-1.20.2.tar.gz
cd nginx-1.20.2

./configure --prefix=/var/www/html --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --with-pcre  --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid --with-http_ssl_module --with-http_image_filter_module=dynamic --modules-path=/etc/nginx/modules --with-http_v2_module --with-stream=dynamic --with-http_addition_module --with-http_mp4_module --with-stream

make
make install

vi /lib/systemd/system/nginx.service

[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target
        
[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true
        
[Install]
WantedBy=multi-user.target

```
nginx.conf 설정 
```shell
## 아래 내용 추가
vi etc/nginx/nginx.conf 

worker_processes auto;                    ## 추가  
error_log /var/log/nginx/error.log;       ## 추가
pid /run/nginx.pid;                       ## 추가

include /etc/nginx/stream.conf.d/*.conf;  ## 추가

http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format  main  &#39;$remote_addr - $remote_user [$time_local] &#34;$request&#34; &#39;
                      &#39;$status $body_bytes_sent &#34;$http_referer&#34; &#39;
                      &#39;&#34;$http_user_agent&#34; &#34;$http_x_forwarded_for&#34;&#39;;

    access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       8081;
        server_name  localhost;

        location / {
            root   html;
            index  index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    include /etc/nginx/conf.d/*.conf;   ## 추가
}

```
웹 구성
```shell
cat &lt;&lt; EOF | tee /etc/nginx/conf.d/openshift.conf
server {
    listen       8080;
    server_name  localhost;


    location / {
        root   /usr/share/nginx/html/files;
        autoindex on;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

}
EOF

```
nginx 테스트 및 실행
```shell
nginx -t
systemctl restart nginx
systemctl enable nginx
```

{{&lt; figure src=&#34;/images/openshift/7-1.png&#34; title=&#34;NGINX 확인&#34; &gt;}}

## 8. Temp 이미지로 VM 구성
`Temp를 활용하여 bootstrap , master 3개 , worker 3개를 배포한다.`

{{&lt; figure src=&#34;/images/openshift/8-1.png&#34; title=&#34;Image 구성#1&#34; &gt;}}
{{&lt; figure src=&#34;/images/openshift/8-2.png&#34; title=&#34;Image 구성#2&#34; &gt;}}
{{&lt; figure src=&#34;/images/openshift/8-3.png&#34; title=&#34;Image 구성#3&#34; &gt;}}
base64로 변경한 값을 여기서 넣어 준다.
bootstrap : cat append-bootstrap.64 , 마스터 : cat master.64 , Worker : cat worker.64 의 값을 넣어 주면 됨
{{&lt; figure src=&#34;/images/openshift/8-4.png&#34; title=&#34;Image 구성#4&#34; &gt;}}

## 9. L4 구성
`L4장비가 없을 경우 / L4장비가 있을 경우를 생각해서 NGINX도 포함 시킴`

### 9.1. NSXT L4 구성
```shell
## 설명
ocp_8080 : jumphost (nginx에서 파일을 땡기기 위해 구성)

## 배포 완료 후 bootstrap은 삭제 해도 됨
ocp-master-and-boot-machine-22623 : bootstrap 및 master
ocp_master-and-boot-api-6443: bootstrap 및 master

## Openshift는 Route를사용 하기 때문에 설정
ocp_443, ocp_80 : master 및 worker
```
{{&lt; figure src=&#34;/images/openshift/9-1.png&#34; title=&#34;L4 구성#1&#34; &gt;}}
{{&lt; figure src=&#34;/images/openshift/9-2.png&#34; title=&#34;L4 구성#2&#34; &gt;}}

### 9.2. NGINX L4 구성
```shell

## LB 설정
cat &lt;&lt; EOF | tee /etc/nginx/stream.conf.d/lb.conf

stream{
    upstream ocp_k8s_api {
        #round-robin;
        server 10.253.107.10:6443; #bootstrap
        server 10.253.107.11:6443; #master1
        server 10.253.107.12:6443; #master2
        server 10.253.107.13:6443; #master3
    }
    server {
        listen 6443;
        proxy_pass ocp_k8s_api;
    }


    upstream ocp_m_config {
        #round-robin;
        server 10.253.107.10:22623; #bootstrap
        server 10.253.107.11:22623; #master1
        server 10.253.107.12:22623; #master2
        server 10.253.107.13:22623; #master3
    }
    server {
        listen 22623;
        proxy_pass ocp_m_config;
    }

    upstream ocp_http {
        #round-robin;
        server 10.253.107.11:80; #master1
        server 10.253.107.12:80; #master2
        server 10.253.107.13:80; #master3
        server 10.253.107.14:80; #worker1
        server 10.253.107.15:80; #worker2
        server 10.253.107.16:80; #worker3
    }
    server{
        listen 80;
        proxy_pass ocp_http;
    }

    upstream ocp_https {
        #round-robin;
        server 10.253.107.11:443; #master1
        server 10.253.107.12:443; #master2
        server 10.253.107.13:443; #master3
        server 10.253.107.14:443; #worker1
        server 10.253.107.15:443; #worker2
        server 10.253.107.16:443; #worker3   
    }
    server{
        listen 443;
        proxy_pass ocp_https;
    }
}
EOF


## nginx restart

nginx -t
systemctl restart nginx
```
## 10. 완료 후 확인
```shell
export KUBECONFIG=&lt;installation_directory&gt;/auth/kubeconfig

예시
export KUBECONFIG=~/ocp/auth/kubeconfig

oc whoami

oc get clusterversion
```
{{&lt; figure src=&#34;/images/openshift/10-1.png&#34; title=&#34;완료#1&#34; &gt;}}

```sehll
oc get clusteroperators

oc describe clusterversion

oc get clusterversion -o jsonpath=&#39;{.items[0].spec}{&#34;\n&#34;}&#39;
```
{{&lt; figure src=&#34;/images/openshift/10-2.png&#34; title=&#34;완료#2&#34; &gt;}}
{{&lt; figure src=&#34;/images/openshift/10-3.png&#34; title=&#34;완료#3&#34; &gt;}}


## 11. New Worker Node Add
```shell
## PENDING 확인
kubectl get csr

## PENDING 확인 후 적용
oc adm certificate approve csr-bghmp csr-hd9x8 csr-hlngb
oc adm certificate approve csr-gpgv9 csr-n6lqm csr-zfws6 
```
{{&lt; figure src=&#34;/images/openshift/11-1.png&#34; title=&#34;worker Node 추가&#34; &gt;}}

## 12. 계정

Local 또는 AD을 통해 계정을 관리 할 수 있다.

### 12.1. Local 계정 생성

아래는 htpasswd를 사용 하는 방법의 대해서 구성 한다.

```shell
## 우분투
apt install apache2-utils -y

# 유저 정보
# htpasswd -Bbc htpasswd {username} &#39;{password}&#39;
$ htpasswd -Bbc htpasswd my1208 &#39;Passw0rd&#39;

cat htpasswd

oc --user=admin create secret generic htpasswd \
    --from-file=htpasswd -n openshift-config

oc get secret -n openshift-config
```
{{&lt; figure src=&#34;/images/openshift/11-2.png&#34; title=&#34;유저 추가&#34; &gt;}}
{{&lt; figure src=&#34;/images/openshift/11-3.png&#34; title=&#34;secret 확인&#34; &gt;}}

secret 추가
```shell
cat &lt;&lt; EOF | tee oauth-config.yaml
# oauth-config.yaml
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: Local Password
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpasswd
EOF

oc replace -f oauth-config.yaml

## shows current user
oc whoami

## shows cluster web console URL
oc whoami --show-console

## shows cluster API URL
oc whoami --show-server

## shows current OAuth token
oc whoami --show-token
```

{{&lt; figure src=&#34;/images/openshift/11-4.png&#34; title=&#34;GUI 접속#1&#34; &gt;}}
{{&lt; figure src=&#34;/images/openshift/11-5.png&#34; title=&#34;GUI 접속#2&#34; &gt;}}

### 12.2. AD 연동

LDPAS를 구성하기 위한 configmap 생성
```sehll
oc create configmap ca-config-map --from-file=ca.crt=/path/to/ca -n openshift-config
```
만약 LDAPS로 구성을 하지 않았으면 insecure: true, ca 항목을 삭제, url을 ldap으로 변경을 해주면 된다.

```shell
oc apply -n openshift-config -f - &lt;&lt; EOF
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: ldapidp
    mappingMethod: claim
    type: LDAP
    ldap:
      attributes:
        id:
        - dn
        email:
        - mail
        name:
        - sAMAccountName
        preferredUsername:
        - sAMAccountName
      bindDN: cn=administrator,cn=users,dc=tkg,dc=io
      bindPassword:
        name: ldap-secret
      ca:
        name: ca-config-map
      insecure: false
      url: &#34;ldaps://tanzu-dns.tkg.io/ou=tanzu,dc=tkg,dc=io?sAMAccountName&#34;
EOF
```

{{&lt; figure src=&#34;/images/openshift/12-1.png&#34; title=&#34;GUI 접속&#34; &gt;}}
 
 ### 12.3. 수동 GROUP-SYNC

 ```shell
 vi ldapsync.yaml

 # LDAP is case insensitive, but OpenShift is not, so all LDAP parameters have been converted to lower case as per https://access.redhat.com/solutions/3232051 (under &#34;Case Sensitivity&#34;)
kind: LDAPSyncConfig
apiVersion: v1
url: ldaps://tanzu-dns.tkg.io:636
insecure: false
ca: &#34;/data/cert/ldapserver.pem&#34;                       ### ldaps 인증서의 실제 위치 / 파일
bindDN: cn=administrator,cn=users,dc=tkg,dc=io
bindPassword: &#34;Password&#34;
rfc2307:
    groupsQuery:
        baseDN: &#34;ou=tanzu,dc=tkg,dc=io&#34;
        scope: sub
        filter: (objectClass=group)
        derefAliases: never
        timeout: 0
        pageSize: 0
    groupUIDAttribute: dn
    groupNameAttributes: [ cn ]
    groupMembershipAttributes: [ member ]
    usersQuery:
        basedn: &#34;ou=tanzu,dc=tkg,dc=io&#34;
        scope: sub
        derefAliases: never
        pageSize: 0
    userUIDAttribute: dn
    userNameAttributes: [ cn ]
    tolerateMemberNotFoundErrors: true
    tolerateMemberOutOfScopeErrors: true
    
## 적용전 제대로 받아오는지 확인을 한다.
oc adm groups sync --sync-config=ldapsync.yaml

## 확인이 끝나면 적용한다.
oc adm groups sync --sync-config=ldapsync.yaml --confirm

## 권한 설정
oc adm policy add-cluster-role-to-group cluster-admin tkg

## 권한 삭제
oc adm policy remove-cluster-role-from-group cluster-admin tkg

```

{{&lt; figure src=&#34;/images/openshift/12-2.png&#34; title=&#34;GROUP 확인 및 적용&#34; &gt;}}

### 12.4 CronJob Group-Sync

위에서 LDAP을 연동 하였다면 cm , secret 이 생성 된 것을 확인 할 수 있다.

```shell
## password 이름 확인
password=`oc get secret -n openshift-authentication | grep v4-0-config-user-idp-0 | awk &#39;{print $1}&#39;`
oc get secret -n openshift-authentication $password  -o jsonpath={.data}

## 인증서 이름 확인
ca=`oc get cm -n openshift-authentication | grep v4-0-config-user | awk &#39;{print $1}&#39;`
oc get cm -n openshift-authentication $ca -o jsonpath={.items[0].data} | awk &#39;{print $1}&#39;
```

그리고 계정 및 권한 설정을 해준다.
```shell
cat &lt;&lt; EOF | tee ldap-sync-sa-clusterrole.yaml
kind: ServiceAccount
apiVersion: v1
metadata:
  name: ldap-group-syncer
  namespace: openshift-authentication
  labels:
    app: cronjob-ldap-group-sync

---
kind: ServiceAccount
apiVersion: v1
metadata:
  name: ldap-group-syncer
  namespace: openshift-authentication
  labels:
    app: cronjob-ldap-group-sync
root@ubuntu:/var/tmp/oc/ldaps#
root@ubuntu:/var/tmp/oc/ldaps# cat clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ldap-group-syncer
  labels:
    app: cronjob-ldap-group-sync
rules:
  - apiGroups:
      - &#39;&#39;
      - user.openshift.io
    resources:
      - groups
    verbs:
      - get
      - list
      - create
      - update

---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ldap-group-syncer
  labels:
    app: cronjob-ldap-group-sync
subjects:
  - kind: ServiceAccount
    name: ldap-group-syncer
    namespace: openshift-authentication
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ldap-group-syncer
EOF
```

LDAP의 자동 Sync를 구성하기 위해 config-map 및 job 설정
witelist / balcklist의 경우 ldapsearch에서 distinguishedName: CN=test test,OU=tanzu,DC=tkg,DC=io 이부분의 이름으로 넣어야함. , 만약 별도로 witelist / blacklist가 필요 없으면 제거 해도 된다.

```shell
cat &lt;&lt; EOF | tee ldap-sync-cm-cron.yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: ldap-group-syncer
  namespace: openshift-authentication
  labels:
    app: cronjob-ldap-group-sync
data:
  ldap-group-sync.yaml: |
    kind: LDAPSyncConfig
    apiVersion: v1
    url: ldaps://tanzu-dns.tkg.io
    bindDN: cn=administrator,cn=users,dc=tkg,dc=io
    bindPassword:
      file: &#34;/etc/secrets/bindPassword&#34;                   ## 위에서 설명한 secret, cronjob에서 voluemount 후 적용
    insecure: false
    ca: &#34;/ldap-sync/ca/ca.crt&#34;                            ## 위에서 설명한 configmap, cronjob에서 voluemount 후 적용
    rfc2307:
        groupsQuery:
            baseDN: &#34;ou=tanzu,dc=tkg,dc=io&#34;
            scope: sub
            derefAliases: never
            filter: (objectclass=group)
        groupUIDAttribute: dn
        groupNameAttributes: [ cn ]
        groupMembershipAttributes: [ member ]
        usersQuery:
            baseDN: &#34;ou=tanzu,dc=tkg,dc=io&#34;
            scope: sub
            derefAliases: never
            pageSize: 0
        userUIDAttribute: dn
        userNameAttributes: [ sAMAccountName ]
        tolerateMemberNotFoundErrors: true
        tolerateMemberOutOfScopeErrors: true
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: ldap-group-syncer-whitelist
  namespace: openshift-authentication
  labels:
    app: cronjob-ldap-group-sync
data:
  whitelist.txt: |
    CN=kim dokyung,OU=tanzu,DC=tkg,DC=io

---
kind: ConfigMap
apiVersion: v1
metadata:
  name: ldap-group-syncer-blacklist
  namespace: openshift-authentication
  labels:
    app: cronjob-ldap-group-sync
data:
  blacklist.txt: |
    CN=tkg,OU=tanzu,DC=tkg,DC=io

---
kind: CronJob
apiVersion: batch/v1beta1
metadata:
  name: ldap-group-syncer
  namespace: openshift-authentication
  labels:
    app: cronjob-ldap-group-sync
spec:
  schedule: &#34;*/1 * * * *&#34;
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 5
  failedJobsHistoryLimit: 5
  jobTemplate:
    metadata:
      labels:
        app: cronjob-ldap-group-sync
    spec:
      backoffLimit: 0
      template:
        metadata:
          labels:
            app: cronjob-ldap-group-sync
        spec:
          containers:
            - name: ldap-group-sync
              image: &#34;registry.redhat.io/openshift4/ose-cli:v4.7&#34;
              command:
                - &#34;/bin/bash&#34;
                - &#34;-c&#34;
                - oc adm groups sync --whitelist=/etc/whitelist/whitelist.txt --blacklist=/etc/blacklist/blacklist.txt --sync-config=/etc/config/ldap-group-sync.yaml --confirm
              volumeMounts:
                - mountPath: &#34;/etc/blacklist&#34;
                  name: &#34;ldap-sync-volume-blacklist&#34;
                - mountPath: &#34;/etc/whitelist&#34;
                  name: &#34;ldap-sync-volume-whitelist&#34;
                - mountPath: &#34;/etc/config&#34;
                  name: &#34;ldap-sync-volume&#34;
                - mountPath: &#34;/etc/secrets&#34;
                  name: &#34;ldap-bind-password&#34;
                - mountPath: &#34;/ldap-sync/ca&#34;
                  name: &#34;ldap-sync-ca&#34;
          volumes:
            - name: &#34;ldap-sync-volume-blacklist&#34;                  ## volumes을 모두 연결하여 assign
              configMap:
                name: &#34;ldap-group-syncer-blacklist&#34;
            - name: &#34;ldap-sync-volume-whitelist&#34;                  ## volumes을 모두 연결하여 assign
              configMap:
                name: &#34;ldap-group-syncer-whitelist&#34;           
            - name: &#34;ldap-sync-volume&#34;                            ## volumes을 모두 연결하여 assign
              configMap:
                name: &#34;ldap-group-syncer&#34;
            - name: &#34;ldap-sync-ca&#34;                                ## volumes을 모두 연결하여 assign
              configMap:
                name: &#34;v4-0-config-user-idp-0-ca&#34; 
            - name: &#34;ldap-bind-password&#34;                          ## volumes을 모두 연결하여 assign
              secret:
                secretName: &#34;v4-0-config-user-idp-0-bind-password&#34;
          restartPolicy: &#34;Never&#34;
          terminationGracePeriodSeconds: 30
          activeDeadlineSeconds: 500
          dnsPolicy: &#34;ClusterFirst&#34;
          serviceAccountName: &#34;ldap-group-syncer&#34;
          serviceAccount: &#34;ldap-group-syncer&#34;
EOF
```

이후에 자동으로 싱크가 되는 것을 알수 있다. 만약에 그룹을 추가 했는대 그 그룹만 막고 싶으면 blacklist, 또는 기존에 있는 것만 하고 자동 싱크 하고 싶으면 witelist를 적용 하면된다. 
흠 생각에는 그냥 witelist 방식으로만 적용하면 될 것으로 보인다. 만약에 필요 하다면 필요 없이 모든 그룹을 자동 싱크 하겠따면 witelist / blaklist는 필요 없다.

자동 싱크가 되었으면 해당하는 그룹에 권한을 준다.
```shell
## 권한 설정
oc adm policy add-cluster-role-to-group cluster-admin tkg

## 권한 삭제
oc adm policy remove-cluster-role-from-group cluster-admin tkg
```

{{&lt; figure src=&#34;/images/openshift/12-3.png&#34; title=&#34;자동 sync 구성 완료&#34; &gt;}}

---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/ko/openshift/  

