# The Documentation Tanzu & OTKA


## 1. TANZU와 OKTA 연동

TANZU는 기본적으로 LDAPS 또는 OIDC와 연동이 가능합니다. 그 중에 OKTA 서비스를 활용하여 TANZU와 OKTA를 연동 하겠습니다.
OKTA는 기본적으로 30일간 무료로 사용이 가능합니다.

## 2. OKTA 구성

OKTA접속 후 관리자로 변경

{{< figure src="/images/okta/1-1.png" title="관리자로 변경" >}}

Application 추가

{{< figure src="/images/okta/1-2.png" title="Apps 추가" >}}
{{< figure src="/images/okta/1-3.png" title="Apps 추가" >}}

redirect URIs는 kubectl get svc를 통해 확인
{{< figure src="/images/okta/1-4.png" title="Apps 추가" >}}

{{< figure src="/images/okta/1-5.png" title="Redirect URIs 확인" >}}

{{< figure src="/images/okta/1-6.png" title="Sign On 수정" >}}

Group을 생성은 Optional
{{< figure src="/images/okta/1-7.png" title="Groups 생성 및 Assignment" >}}

{{< figure src="/images/okta/1-8.png" title="APP Assign" >}}

{{< figure src="/images/okta/1-9.png" title="APP Assign" >}}
{{< figure src="/images/okta/1-10.png" title="APP Assign" >}}
{{< figure src="/images/okta/1-11.png" title="APP Assign" >}}

## 3. TANZU 구성

OIDC_IDENTITY_PROVIDER_CLIENT_SECRET를 base64로 변경 필요

```shell
echo -n '{CLIENT SECRETS}' | base64
```

TANZU MGMT 에서 OIDC 부분을 찾은 후 파일 수정
```shell

IDENTITY_MANAGEMENT_TYPE: "oidc"

#! Settings for IDENTITY_MANAGEMENT_TYPE: "oidc"
CERT_DURATION: 2160h
CERT_RENEW_BEFORE: 360h
IDENTITY_MANAGEMENT_TYPE: oidc
OIDC_IDENTITY_PROVIDER_CLIENT_ID: 0oa2i[...]NKst4x7
OIDC_IDENTITY_PROVIDER_CLIENT_SECRET: <encoded:LVVnMFNsZFIy[...]TMTV3WUdPZDJ2Xw==>
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
tanzu mc kubeconfig get --export-file=tanzu-cli-cjenm-tkgm02

kubectl get pod -A --kubeconfig tanzu-cli-cjenm-tkgm02
```


{{< figure src="/images/okta/2-1.png" title="TEST" >}}
{{< figure src="/images/okta/2-2.png" title="TEST" >}}
{{< figure src="/images/okta/2-3.png" title="TEST" >}}
{{< figure src="/images/okta/2-4.png" title="TEST" >}}
{{< figure src="/images/okta/2-5.png" title="TEST" >}}

