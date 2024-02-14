# The Documentation LDAPS(AD)


## 1. LDAP Over SSL
대략 설명 보다. 이미지를 많이 첨부

LDAPS를 구성 할 경우 IP로 ldapsearch를 하면 실패하는 경우를 보게 될 것이다.
FQDN인증서를 확인 하면 FQDN만 구성이 되어 있는 것을 알 수 있다. 
그래서 SAN으로 구성하면서 IP도 포함되게 구성을 해보자.

{{&lt; figure src=&#34;/images/ldaps/1-1.png&#34; title=&#34;Ldaps 인증서 확인&#34; &gt;}}

### 1.1. certreq.req 설정
```shell
## 아래 IP로 ldapsearch를 하게 되면 에러가 난다. 만약 IP로도 가능하게 하려면 인증서 변경이 필요하다.
ldapsearch -x -H ldaps://10.253.241.2 -D &#39;cn=administrator,cn=users,dc=tkg,dc=io&#39; -w &#39;Passw0rd&#39; -b &#39;ou=tanzu,dc=tkg,dc=io&#39;
## 에러
ldap_sasl_bind(SIMPLE): Can&#39;t contact LDAP server (-1)
```
{{&lt; figure src=&#34;/images/ldaps/1-2.png&#34; title=&#34;Ldaps Falied&#34; &gt;}}

윈도우에서 certlm.msc 실행

{{&lt; figure src=&#34;/images/ldaps/1-3.png&#34; title=&#34;certlm.msc&#34; &gt;}}

certlm.msc &gt; 개인용 &gt; 모든 작업 &gt; 고급 작업 &gt; 사용자 지정 요청 만들기

{{&lt; figure src=&#34;/images/ldaps/1-4.png&#34; title=&#34;certlm #1&#34; &gt;}}
{{&lt; figure src=&#34;/images/ldaps/1-5.png&#34; title=&#34;certlm #2&#34; &gt;}}
{{&lt; figure src=&#34;/images/ldaps/1-6.png&#34; title=&#34;certlm #3&#34; &gt;}}
{{&lt; figure src=&#34;/images/ldaps/1-7.png&#34; title=&#34;certlm #4&#34; &gt;}}
{{&lt; figure src=&#34;/images/ldaps/1-8.png&#34; title=&#34;certlm #5&#34; &gt;}}
{{&lt; figure src=&#34;/images/ldaps/1-9.png&#34; title=&#34;certlm #6&#34; &gt;}}
{{&lt; figure src=&#34;/images/ldaps/1-10.png&#34; title=&#34;certlm #7&#34; &gt;}}
{{&lt; figure src=&#34;/images/ldaps/1-11.png&#34; title=&#34;certlm #8&#34; &gt;}}
{{&lt; figure src=&#34;/images/ldaps/1-12.png&#34; title=&#34;certlm #9&#34; &gt;}}
{{&lt; figure src=&#34;/images/ldaps/1-13.png&#34; title=&#34;certlm #10&#34; &gt;}}
{{&lt; figure src=&#34;/images/ldaps/1-14.png&#34; title=&#34;certlm #11&#34; &gt;}}

인증서 생성
```powershell
certreq -submit -sttrib &#34;CertificateTemplate:webserver&#34; certreq.req certreq.cer
```
{{&lt; figure src=&#34;/images/ldaps/1-15.png&#34; title=&#34;certlm #12&#34; &gt;}}

### 1.2. 인증서 등록

certlm.msc &gt; 개인용 &gt; 인증서 &gt; 모든 작업 &gt; 가져오기

{{&lt; figure src=&#34;/images/ldaps/1-16.png&#34; title=&#34;인증서 등록#1&#34; &gt;}}
{{&lt; figure src=&#34;/images/ldaps/1-17.png&#34; title=&#34;인증서 등록#2&#34; &gt;}}
{{&lt; figure src=&#34;/images/ldaps/1-18.png&#34; title=&#34;인증서 등록#3&#34; &gt;}}
{{&lt; figure src=&#34;/images/ldaps/1-19.png&#34; title=&#34;인증서 등록#4&#34; &gt;}}
{{&lt; figure src=&#34;/images/ldaps/1-20.png&#34; title=&#34;인증서 등록#5&#34; &gt;}}
{{&lt; figure src=&#34;/images/ldaps/1-21.png&#34; title=&#34;인증서 등록#6&#34; &gt;}}

등록 확인
{{&lt; figure src=&#34;/images/ldaps/1-22.png&#34; title=&#34;인증서 등록 확인#1&#34; &gt;}}
{{&lt; figure src=&#34;/images/ldaps/1-23.png&#34; title=&#34;인증서 등록 확인#2&#34; &gt;}}

Ldapsearch를 IP로 했을 때 성공 하는 것을 확인 할 수 있다.
{{&lt; figure src=&#34;/images/ldaps/1-24.png&#34; title=&#34;인증서 등록 확인#2&#34; &gt;}}






---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/ko/ldaps/  

