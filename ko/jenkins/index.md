# The Documentation Jenkins



## Jenkins?
Jenkins는 아무래도 많이 사용하는 CI/CD 일것이다. 우선 컨테이너 환경에서 CI를 구성하기 위해서 Jenkins를 구성 하였고, 클러스터가 많은 환경에서도 접근을 할 수 있게 (물론 컨테이너로 구성을 해도 되나. 굳이 컨테이너로 구성할 필요성이 있나 싶어 별도의 VM으로 구성)
VM형태로 설치를 하였다.

{{&lt; admonition tip &#34;CI/CD&#34; &gt;}}
CI/CD는 애플리케이션 개발 단계를 자동화하여 애플리케이션을 보다 짧은 주기로 고객에게 제공한다. 
CI (Continuous Integration) CI를 통해 개발자들은 코드 변경사항을 공유 브랜치로 다시 병합하는 작업을 더욱 수월하게 자주 수행 할 수 있다.
CD (Continuous Delivery || Continuous Deploy) 두용어는 상호 교환적으로 사용됨.
* Continuous Deliver의 경우 코드 변경 , 병합으로부터 Prodcution에 적합한 빌드를 제공하여 모든 단계에 테스트 및 릴리스를 자동화한다.
* Continuous Deploy는 어플리케이션을 프로덕션으로 릴리스 작업을 자동화
{{&lt; /admonition &gt;}}

{{&lt; figure src=&#34;/images/jenkins/0-1.png&#34; title=&#34;CICD&#34; &gt;}}

참고 문헌 [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Redhat ](https://www.redhat.com/ko/topics/devops/what-is-ci-cd)

## 1. 설치
{{&lt; admonition example &#34;Jenkins Install&#34; &gt;}}
JAVA Install
```shell
apt update &amp;&amp; apt upgrade 

sudo apt search openjdk

sudo apt install openjdk-11-jdk -y

java --version
```
Jenkins Install
```shell
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c &#39;echo deb https://pkg.jenkins.io/debian-stable binary/ &gt; /etc/apt/sources.list.d/jenkins.list&#39;

sudo apt update -y
sudo apt install jenkins -y

systemctl restart jenkins
systemctl enable jenkins
```
패스워드 확인
```shell
cat /var/lib/jenkins/secrets/initialAdminPassword
```
{{&lt; /admonition &gt;}}

### 1.1. 설치 완료
{{&lt; figure src=&#34;/images/jenkins/1-1.png&#34; title=&#34;접속 화면 #1&#34; &gt;}}
{{&lt; figure src=&#34;/images/jenkins/1-2.png&#34; title=&#34;접속 화면 #2&#34; &gt;}}
{{&lt; figure src=&#34;/images/jenkins/1-3.png&#34; title=&#34;접속 화면 #3&#34; &gt;}}

## 2. SSL 설정
인증서 설치, [:(far fa-file-archive fa-fw): root.sh](root.sh).

{{&lt; admonition example &#34;Jenkins SSL 구성&#34; &gt;}}
인증서 생성
```shell
export domain=jenkins.tkg.io
```
root.sh에 있는 파일 내용을 복사해서 shell 실행
```shell
. root.sh
```
인증서 권한 변경
```shell
chmod 700 /data/cert
chmod 600 /data/cert/yourdomain.com.cert
chmod 600 /data/cert/yourdomain.com.key
```
Jenkins 파일 변경
```shell
vi /etc/default/jenkins

HTTP_PORT=8080             ### ---&gt; 이부분을 찾아서 아래 부분을 채워 넣어주자.
HTTP_PORT_DISABLE=-1       ### HTTP DISABLE
HTTPS_CERT=/data/cert/yourdomain.com.cert      ### 인증서
HTTPS_KEY=/data/cert/yourdomain.com.key        ### KEY

### args 마지막 줄에 빨간 부분을 채워서 넣어준다.
JENKINS_ARGS=&#34;--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT --httpPort=$HTTP_PORT_DISABLE --httpsPort=$HTTP_PORT --httpsCertificate=$HTTPS_CERT --httpsPrivateKey=$HTTPS_KEY&#34;

### jenkins restart
systemctl restart jenkins
```
{{&lt; /admonition &gt;}}
### 2.1. 설치 완료
{{&lt; figure src=&#34;/images/jenkins/2-1.png&#34; title=&#34;HTTPS 접속 화면 #1&#34; &gt;}}

### 2.2. NGINX로 HTTPS 구성
{{&lt; admonition example &#34;NGINX PROXY 구성&#34; &gt;}}
NGINX 가상 서버 구성
```shell
vi  /etc/nginx/sites-available/jenkins

server {
    server_name jenkins.tkg.io;

    location / {
        proxy_redirect off;
        proxy_pass_header Server;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass https://127.0.0.1:8080/;
    }

    listen 443 ssl;
    ssl_certificate /data/cert/yourdomain.com.crt;
    ssl_certificate_key /data/cert/yourdomain.com.key;
    ssl_client_certificate /data/cert/ca.crt;
}

server {
    if ($host = jenkins.tkg.io) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    listen 80;
    server_name jenkins.tkg.io;
    return 404; # managed by Certbot
}
```
symbolic link 연결
```shell
 cd /etc/nginx/sites-enabled

 ln -s  /etc/nginx/sites-available/jenkins .
```
{{&lt; /admonition &gt;}}
{{&lt; figure src=&#34;/images/jenkins/2-2.png&#34; title=&#34;NGINX로 연결 후 HTTPS 접속 화면 #1&#34; &gt;}}
## 3. SLACK 연동
SLACK을 연동하여 메시지를 받을 수 있게 구성을 한다.

### 3.1. SLCAK 설정
{{&lt; figure src=&#34;/images/jenkins/3-1.png&#34; title=&#34;SLACK 접속&#34; &gt;}}

APP 등록
{{&lt; figure src=&#34;/images/jenkins/3-2.png&#34; title=&#34;SLACK APP 추가#1&#34; &gt;}}
{{&lt; figure src=&#34;/images/jenkins/3-3.png&#34; title=&#34;SLACK APP 추가#2&#34; &gt;}}
{{&lt; figure src=&#34;/images/jenkins/3-4.png&#34; title=&#34;SLACK APP 추가#3&#34; &gt;}}
{{&lt; figure src=&#34;/images/jenkins/3-5.png&#34; title=&#34;SLACK APP 추가#4&#34; &gt;}}

위에 내용까지 설정을 하면 Jenkins를 어떻게 설정하라고 나오는대 좀 오래 되었나보다. 요즘에 변경된 부분의 대해서 설정 하는 방법을 나열한다.

### 3.2. JENKINS 설정
{{&lt; figure src=&#34;/images/jenkins/3-6.png&#34; title=&#34;Jenkins Slack Plugin 설치#1&#34; &gt;}}
{{&lt; figure src=&#34;/images/jenkins/3-7.png&#34; title=&#34;Jenkins Slack Plugin 설치#2&#34; &gt;}}
{{&lt; figure src=&#34;/images/jenkins/3-8.png&#34; title=&#34;Jenkins Slack Plugin 설치#3&#34; &gt;}}
{{&lt; figure src=&#34;/images/jenkins/3-9.png&#34; title=&#34;Jenkins Slack 설정#1&#34; &gt;}}
{{&lt; figure src=&#34;/images/jenkins/3-10.png&#34; title=&#34;Jenkins Slack 설정#2&#34; &gt;}}
{{&lt; figure src=&#34;/images/jenkins/3-11.png&#34; title=&#34;Jenkins Slack Credentials 설정&#34; &gt;}}
{{&lt; figure src=&#34;/images/jenkins/3-12.png&#34; title=&#34;Jenkins Slack 설정 테스트&#34; &gt;}}

---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/ko/jenkins/  

