# The Documentation NSXT and Ansible


## 1. Ansible을 통한 NSXT 구성
NSXT를 Ansible로 구성.

Ansible의 대한 보충 설명을 할 수 있으면 추후에 진행 하기로 하고 우선 설정의 대해서 설명을 먼저 하겠다.

먼저.. 이 부분을 블로그로 쓰는게 맞을까라는 고민을 좀 했다. 

이유는 우선 Ansible로 구성이 되어 있기 때문에 코드가 들어가 있다. 그래서 NSXT Ansible Module을 다운로드 받고 나서 추가 된 부분을 Git Hub에 올려 두었다.

## 2. 설치

### 2.1. 파이썬 설치

```shell
yum update -y

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

yum install epel-release yum-utils python3-pip -y

pip3 install --upgrade pip setuptools ansible pyvmomi pyvim requests ruamel.yaml

dnf install libnsl -y
```

파이썬을 설치 후 버전을 변경 하고 싶으면 아래 처럼 구성
```shell
sudo rm /usr/bin/python
sudo update-alternatives --install /usr/bin/python python /usr/bin/python(TAB) ## 설치되어 있는 버전을 확인 할 수 있다.
```
{{< figure src="/images/nsxt/1-1.png" title="파이썬 버전 확인" >}}

```shell
sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.8 2

sudo update-alternatives --config python
```
{{< figure src="/images/nsxt/1-2.png" title="파이썬 버전 선택" >}}


### 2.2. OVF Tool
OVF Tool 다운로드

[<i class="fas fa-link"></i> OVF Tool 다운로드 링크](https://developer.vmware.com/web/tool/4.4.0/ovf)

{{< figure src="/images/nsxt/1-3.png" title="원하는 버전으로 다운로드 받는다." >}}

### 2.3. NSXT Ansible Download
제공한 버전은 3.1 기준으로 구성을 하였다.

{{< figure src="/images/nsxt/1-4.png" title="원하는 버전으로 다운로드 받는다." >}}

### 2.4. Ansible 실행
```shell
ovftool -v 에러가 나오면 dnf install libnsl 설치
ansible-playbook 01_deploy_first_node.yml -vvv
```
{{< figure src="/images/nsxt/1-5.png" title="에러 발생시 dnf install libnsl 설치." >}}

### 2.5. Github

다운로드 NSXT Ansible Module을 압축을 해제 하면 되는대, 그 부분을 별도로 github에 올려두었다.

추가적으로 vars라는 폴더와, 00 ~ 10 번 , answerfile,yml이 추가 된 것을 확인 할 수 있다.

코드를 하나 하나 설명을 하기에는.. 좀 벅찬 느낌이 든다.


```shell
git clone https://github.com/huntedhappy/nsxt3.1
```
