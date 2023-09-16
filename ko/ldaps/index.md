# The Documentation LDAPS(AD)


## 1. LDAP Over SSL
대략 설명 보다. 이미지를 많이 첨부

LDAPS를 구성 할 경우 IP로 ldapsearch를 하면 실패하는 경우를 보게 될 것이다.
FQDN인증서를 확인 하면 FQDN만 구성이 되어 있는 것을 알 수 있다. 
그래서 SAN으로 구성하면서 IP도 포함되게 구성을 해보자.

{{< figure src="/images/ldaps/1-1.png" title="Ldaps 인증서 확인" >}}

### 1.1. certreq.req 설정
```shell
## 아래 IP로 ldapsearch를 하게 되면 에러가 난다. 만약 IP로도 가능하게 하려면 인증서 변경이 필요하다.
ldapsearch -x -H ldaps://10.253.241.2 -D 'cn=administrator,cn=users,dc=tkg,dc=io' -w 'Passw0rd' -b 'ou=tanzu,dc=tkg,dc=io'
## 에러
ldap_sasl_bind(SIMPLE): Can't contact LDAP server (-1)
```
{{< figure src="/images/ldaps/1-2.png" title="Ldaps Falied" >}}

윈도우에서 certlm.msc 실행

{{< figure src="/images/ldaps/1-3.png" title="certlm.msc" >}}

certlm.msc > 개인용 > 모든 작업 > 고급 작업 > 사용자 지정 요청 만들기

{{< figure src="/images/ldaps/1-4.png" title="certlm #1" >}}
{{< figure src="/images/ldaps/1-5.png" title="certlm #2" >}}
{{< figure src="/images/ldaps/1-6.png" title="certlm #3" >}}
{{< figure src="/images/ldaps/1-7.png" title="certlm #4" >}}
{{< figure src="/images/ldaps/1-8.png" title="certlm #5" >}}
{{< figure src="/images/ldaps/1-9.png" title="certlm #6" >}}
{{< figure src="/images/ldaps/1-10.png" title="certlm #7" >}}
{{< figure src="/images/ldaps/1-11.png" title="certlm #8" >}}
{{< figure src="/images/ldaps/1-12.png" title="certlm #9" >}}
{{< figure src="/images/ldaps/1-13.png" title="certlm #10" >}}
{{< figure src="/images/ldaps/1-14.png" title="certlm #11" >}}

인증서 생성
```powershell
certreq -submit -sttrib "CertificateTemplate:webserver" certreq.req certreq.cer
```
{{< figure src="/images/ldaps/1-15.png" title="certlm #12" >}}

### 1.2. 인증서 등록

certlm.msc > 개인용 > 인증서 > 모든 작업 > 가져오기

{{< figure src="/images/ldaps/1-16.png" title="인증서 등록#1" >}}
{{< figure src="/images/ldaps/1-17.png" title="인증서 등록#2" >}}
{{< figure src="/images/ldaps/1-18.png" title="인증서 등록#3" >}}
{{< figure src="/images/ldaps/1-19.png" title="인증서 등록#4" >}}
{{< figure src="/images/ldaps/1-20.png" title="인증서 등록#5" >}}
{{< figure src="/images/ldaps/1-21.png" title="인증서 등록#6" >}}

등록 확인
{{< figure src="/images/ldaps/1-22.png" title="인증서 등록 확인#1" >}}
{{< figure src="/images/ldaps/1-23.png" title="인증서 등록 확인#2" >}}

Ldapsearch를 IP로 했을 때 성공 하는 것을 확인 할 수 있다.
{{< figure src="/images/ldaps/1-24.png" title="인증서 등록 확인#2" >}}





