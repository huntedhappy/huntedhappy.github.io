# The Documentation EKS


## 1. EKS(Amazon Elastic Kubernetes Service)?
Kubernetes를 실행하는 데 사용할 수 있는 관리형 서비스이다. 마스터노드, 워커노드를 설치, 작동 및 유지관리를 할 필요 없는 솔루션이다.

우선 문서가 너무 잘되어 있지만 그래도 나름 예전에 EKS를 테스트 했었던 지라 내가 테스트 했던 방법을 공유하고자 한다.

참고 문헌 [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; AWS ](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/what-is-eks.html)

### 1.1. 사전설치

우선 OS의 따라 설치해야 되는 것들이 조금 있다. (chocolatey를 설치한 이유는 chocolatey를 통해 eksctl을 배포 하기 위함)

{{&lt; admonition info &#34;설치 Tool&#34; &gt;}}
Chocolatey 설치 링크 [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; chocolatey ](https://chocolatey.org/install)
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(&#39;https://community.chocolatey.org/install.ps1&#39;))
```

eksctl 설치 링크 [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; AWS eksctl ](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/eksctl.html)

```powershell
chocolatey install -y eksctl aws-iam-authenticator
```

kubectl 설치 링크 [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; AWS kubectl ](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/install-kubectl.html)

링크를 보게 되면 버전별로 다운로드 받을 수 있게 되어 있다.
```powershell
curl -o kubectl.exe https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/windows/amd64/kubectl.exe
``` 
awscli 설치링크 [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; AWS awscli ](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
```powershell
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
aws --version
```
{{&lt; /admonition &gt;}}

## 1.2. VPC 생성
CloudFormation을 통해 vpc를 자동으로 생성 해준다. 아래 링크는 현재 최신상태인지 확인이 가능.

eks vcp cloudformation 최신 상태 확인 링크 [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; AWS eks vcp ](https://docs.aws.amazon.com/eks/latest/userguide/creating-a-vpc.html)


eks vcp cloudformation 최신 파일 링크 [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; AWS eks vcp download ](https://amazon-eks.s3.us-west-2.amazonaws.com/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml)

위에 받은 파일로 cloudformation을 설정 해주면 된다.
{{&lt; figure src=&#34;/images/eks/1-1.png&#34; title=&#34;cloud formation 설정#1&#34; &gt;}}
{{&lt; figure src=&#34;/images/eks/1-2.png&#34; title=&#34;cloud formation 설정#2&#34; &gt;}}
원하는 N/W으로 수정 후 그 이후에는 그냥 NEXT 후 CREATE만 하면 VPC가 구성이 된다.
{{&lt; figure src=&#34;/images/eks/1-3.png&#34; title=&#34;cloud formation 설정#3&#34; &gt;}}
{{&lt; figure src=&#34;/images/eks/1-4.png&#34; title=&#34;cloud formation 설정#4&#34; &gt;}}
{{&lt; figure src=&#34;/images/eks/1-5.png&#34; title=&#34;cloud formation 설정#5&#34; &gt;}}
완료가 되면 보는 바와 같이 VPC가 생성이 된 것을 확인 할 수 있다.
{{&lt; figure src=&#34;/images/eks/1-6.png&#34; title=&#34;VPC 확인&#34; &gt;}}
{{&lt; figure src=&#34;/images/eks/1-7.png&#34; title=&#34;Route Table 확인&#34; &gt;}}
{{&lt; figure src=&#34;/images/eks/1-8.png&#34; title=&#34;IGW 확인&#34; &gt;}}
{{&lt; figure src=&#34;/images/eks/1-9.png&#34; title=&#34;NAT GW 확인&#34; &gt;}}

### 1.3. private key등록
aws에서 ec2에 접속하기 위한 security 키를 sshkeygen으로 publickey 생성
{{&lt; figure src=&#34;/images/eks/1-10.png&#34; title=&#34;public key 생성#1&#34; &gt;}}
{{&lt; figure src=&#34;/images/eks/1-11.png&#34; title=&#34;public key 생성#2&#34; &gt;}}
{{&lt; figure src=&#34;/images/eks/1-12.png&#34; title=&#34;Notepad로 복사&#34; &gt;}}

### 1.4. EKS 실행
{{&lt; admonition info &#34;EKS 실행&#34; &gt;}}
그리고 아래와 같이 명령어를 넣어 준다.
```powershell
eksctl create cluster \
 --name aws-eks \
 --region us-east-2 \
 --nodegroup-name aws-node \
 --node-type t3.medium \
 --nodes 3 \
 --nodes-min 1 \
 --nodes-max 4 \
 --ssh-access \
 --ssh-public-key huntedhappy.pub \
 --with-oidc \
 --managed
```
구성 EKS 연동 및 확인
aws eks update-kubeconfig --name aws-eks
{{&lt; /admonition &gt;}}

Cloud Formation이 자동으로 돌아간다
{{&lt; figure src=&#34;/images/eks/1-13.png&#34; title=&#34;Cloud Formation&#34; &gt;}}
IAM에서 OIDC가 생성 되었는지 확인 한다. OIDC는 CSI를 EFS로 구성 할 떄 필요 하다.
{{&lt; figure src=&#34;/images/eks/1-14.png&#34; title=&#34;OIDC 생성 확인&#34; &gt;}}

## 2. CSI EFS구성 (작성예정)

## IAM
참고로 IAM은 아래와 같이 구성 하였다.
{{&lt; figure src=&#34;/images/eks/1-15.png&#34; title=&#34;IAM&#34; &gt;}}


---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/eks/  

