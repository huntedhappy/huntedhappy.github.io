# The Documentation Tanzu &amp; OTKA


## 1. TANZU와 OKTA 연동

TANZU는 기본적으로 LDAPS 또는 OIDC와 연동이 가능합니다. 그 중에 OKTA 서비스를 활용하여 TANZU와 OKTA를 연동 하겠습니다.
OKTA는 기본적으로 30일간 무료로 사용이 가능합니다.

## 2. OKTA 구성

OKTA접속 후 관리자로 변경

{{&lt; figure src=&#34;/images/okta/1-1.png&#34; title=&#34;관리자로 변경&#34; &gt;}}

Application 추가

{{&lt; figure src=&#34;/images/okta/1-2.png&#34; title=&#34;Apps 추가&#34; &gt;}}
{{&lt; figure src=&#34;/images/okta/1-3.png&#34; title=&#34;Apps 추가&#34; &gt;}}

redirect URIs는 kubectl get svc를 통해 확인
{{&lt; figure src=&#34;/images/okta/1-4.png&#34; title=&#34;Apps 추가&#34; &gt;}}

{{&lt; figure src=&#34;/images/okta/1-5.png&#34; title=&#34;Redirect URIs 확인&#34; &gt;}}

{{&lt; figure src=&#34;/images/okta/1-6.png&#34; title=&#34;Sign On 수정&#34; &gt;}}

Group을 생성은 Optional
{{&lt; figure src=&#34;/images/okta/1-7.png&#34; title=&#34;Groups 생성 및 Assignment&#34; &gt;}}

{{&lt; figure src=&#34;/images/okta/1-8.png&#34; title=&#34;APP Assign&#34; &gt;}}

{{&lt; figure src=&#34;/images/okta/1-9.png&#34; title=&#34;APP Assign&#34; &gt;}}
{{&lt; figure src=&#34;/images/okta/1-11.png&#34; title=&#34;APP Assign&#34; &gt;}}

## 3. TANZU 구성

OIDC_IDENTITY_PROVIDER_CLIENT_SECRET를 base64로 변경 필요

```shell
echo -n &#39;{CLIENT SECRETS}&#39; | base64
```

TANZU MGMT 에서 OIDC 부분을 찾은 후 파일 수정
```shell

IDENTITY_MANAGEMENT_TYPE: &#34;oidc&#34;

#! Settings for IDENTITY_MANAGEMENT_TYPE: &#34;oidc&#34;
CERT_DURATION: 2160h
CERT_RENEW_BEFORE: 360h
IDENTITY_MANAGEMENT_TYPE: oidc
OIDC_IDENTITY_PROVIDER_CLIENT_ID: 0oa2i[...]NKst4x7
OIDC_IDENTITY_PROVIDER_CLIENT_SECRET: &lt;encoded:LVVnMFNsZFIy[...]TMTV3WUdPZDJ2Xw==&gt;
OIDC_IDENTITY_PROVIDER_GROUPS_CLAIM: groups
OIDC_IDENTITY_PROVIDER_ISSUER_URL: https://dev-[...].okta.com
OIDC_IDENTITY_PROVIDER_SCOPES: openid,profile,email,groups,offline_access
OIDC_IDENTITY_PROVIDER_USERNAME_CLAIM: email
```

## 4. SA 생성 후 TEST

SA 생성
```shell
kubectl create clusterrolebinding id-mgmt-test-user --clusterrole cluster-admin --user {mail address}
```

TEST
```shell
tanzu mc kubeconfig get --export-file=tanzu-cli-tkgm02

kubectl get pod -A --kubeconfig tanzu-cli-tkgm02
```

{{&lt; figure src=&#34;/images/okta/2-1.png&#34; title=&#34;TEST&#34; &gt;}}
{{&lt; figure src=&#34;/images/okta/2-2.png&#34; title=&#34;TEST&#34; &gt;}}
{{&lt; figure src=&#34;/images/okta/2-3.png&#34; title=&#34;TEST&#34; &gt;}}
{{&lt; figure src=&#34;/images/okta/2-4.png&#34; title=&#34;TEST&#34; &gt;}}
{{&lt; figure src=&#34;/images/okta/2-5.png&#34; title=&#34;TEST&#34; &gt;}}


---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/tanzu-okta/  

