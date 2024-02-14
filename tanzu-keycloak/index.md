# The Documentation Tanzu &amp; Keycloak


## 1. TANZU와 KEYCLOAK 연동

TANZU는 기본적으로 LDAPS 또는 OIDC와 연동이 가능합니다. 그 중에 무료 서비스인 KEYCLOAK을 활용하여 TANZU와 KEYCLOAK 연동

## 2. KEYCLOAK 구성

[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; KEYCLOAK DOWNLOAD LINK](https://www.keycloak.org/downloads)

{{&lt; figure src=&#34;/images/keycloak/1-1.png&#34; title=&#34;keycloak download&#34; &gt;}}

KEYCLOAK 설치
인증서는 사설 인증서로 생성
```shell
## 압축 해제
tar zxvf keycloak-18.0.2.tar.gz

cd keycloak-18.0.2
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=&#39;&#39;

bin/kc.sh start-dev --https-certificate-file {인증서} --https-certificate-key-file {인증서 KEY} --https-port 8443 --hostname {hostname} &amp;
```

reaml 생성
{{&lt; figure src=&#34;/images/keycloak/1-2.png&#34; title=&#34;realm 생성&#34; &gt;}}

필요한 Client Scopes
{{&lt; figure src=&#34;/images/keycloak/1-3.png&#34; title=&#34;Client Scopes&#34; &gt;}}
{{&lt; figure src=&#34;/images/keycloak/1-4.png&#34; title=&#34;Client Scopes&#34; &gt;}}
{{&lt; figure src=&#34;/images/keycloak/1-5.png&#34; title=&#34;Client Scopes&#34; &gt;}}

Clients 생성
{{&lt; figure src=&#34;/images/keycloak/1-6.png&#34; title=&#34;Clients 생성&#34; &gt;}}
{{&lt; figure src=&#34;/images/keycloak/1-7.png&#34; title=&#34;Clients 생성&#34; &gt;}}
{{&lt; figure src=&#34;/images/keycloak/1-8.png&#34; title=&#34;Clients 생성&#34; &gt;}}
{{&lt; figure src=&#34;/images/keycloak/1-9.png&#34; title=&#34;Clients 생성&#34; &gt;}}

{{&lt; figure src=&#34;/images/keycloak/1-10.png&#34; title=&#34;Role&#34; &gt;}}

생성한 Client Scopes를 Default Client Scopes에 이동
{{&lt; figure src=&#34;/images/keycloak/1-11.png&#34; title=&#34;Scopes 선택&#34; &gt;}}

{{&lt; figure src=&#34;/images/keycloak/1-12.png&#34; title=&#34;Groups 설정&#34; &gt;}}
{{&lt; figure src=&#34;/images/keycloak/1-13.png&#34; title=&#34;Groups 설정&#34; &gt;}}

Roles
{{&lt; figure src=&#34;/images/keycloak/1-14.png&#34; title=&#34;Roles 설정&#34; &gt;}}

Groups
{{&lt; figure src=&#34;/images/keycloak/1-15.png&#34; title=&#34;Groups 설정&#34; &gt;}}
{{&lt; figure src=&#34;/images/keycloak/1-16.png&#34; title=&#34;Groups 설정&#34; &gt;}}

Users
{{&lt; figure src=&#34;/images/keycloak/1-17.png&#34; title=&#34;Users 생성&#34; &gt;}}
{{&lt; figure src=&#34;/images/keycloak/1-18.png&#34; title=&#34;Users 생성&#34; &gt;}}

User Password 설정
{{&lt; figure src=&#34;/images/keycloak/1-19.png&#34; title=&#34;User Password 설정&#34; &gt;}}
{{&lt; figure src=&#34;/images/keycloak/1-20.png&#34; title=&#34;User Password 설정&#34; &gt;}}
{{&lt; figure src=&#34;/images/keycloak/1-21.png&#34; title=&#34;Group에 할당&#34; &gt;}}

## 3. TANZU 구성
사설 인증서로 구성을 했기 때문에 당연히 worker Node에도 신뢰된 인증서로 들어가 있어야 하며, 처음 구성시 CA를 넣는 부분이 없기 때문에 배포가 완료 후 CA를 넣어야 함

OIDC 추출
```shell

## management cluster 변경
cluster=tkgm02

echo $IDENTITY_MANAGEMENT_TYPE
export _TKG_CLUSTER_FORCE_ROLE=&#34;management&#34;
export FILTER_BY_ADDON_TYPE=&#34;authentication/pinniped&#34;

tanzu cluster create $cluster --dry-run -f tkgm01.yaml &gt; $cluster-example-secret.yaml

```
위와 같이 하면 아래와 같은 파일을 확인 할 수 있다.
```shell
apiVersion: v1
kind: Secret
metadata:
  annotations:
    tkg.tanzu.vmware.com/addon-type: authentication/pinniped
  labels:
    clusterctl.cluster.x-k8s.io/move: &#34;&#34;
    tkg.tanzu.vmware.com/addon-name: pinniped
    tkg.tanzu.vmware.com/cluster-name: tkgm02
  name: cjenm-tkgm02-pinniped-addon
  namespace: tkg-system
stringData:
  values.yaml: |
    #@data/values
    #@overlay/match-child-defaults missing_ok=True
    ---
    infrastructure_provider: vsphere
    tkg_cluster_role: management
    custom_cluster_issuer: &#34;&#34;
    custom_tls_secret: &#34;&#34;
    http_proxy: &#34;&#34;
    https_proxy: &#34;&#34;
    no_proxy: &#34;&#34;
    identity_management_type: oidc
    pinniped:
      cert_duration: 2160h
      cert_renew_before: 360h
      supervisor_svc_endpoint: https://0.0.0.0:31234
      supervisor_ca_bundle_data: ca_bundle_data_of_supervisor_svc
      supervisor_svc_external_ip: 0.0.0.0
      supervisor_svc_external_dns: null
      upstream_oidc_client_id: {CLIENT ID}
      upstream_oidc_client_secret: {CLIENT SECRET}
      upstream_oidc_issuer_url: https://{KEYCLAOK FQDN}:8443/realms/access
      upstream_oidc_tls_ca_data: {base64로 CA인증서}
      upstream_oidc_additional_scopes:
      - openid
      - profile
      - email
      - groups
      - offline_access
      upstream_oidc_claims:
        username: email
        groups: groups
      supervisor:
        service:
          name: pinniped-supervisor
          type: LoadBalancer
type: tkg.tanzu.vmware.com/addon
```

실행
```shell
kubectl apply -f $cluster-example-secret.yaml -n tkg-system
```

4. 완료 후 테스트


```shell
tanzu mc kubeconfig get --export-file=tanzu-cli-tkgm02

kubectl get pod -A --kubeconfig tanzu-cli-tkgm02
```

{{&lt; figure src=&#34;/images/keycloak/2-1.png&#34; title=&#34;요청&#34; &gt;}}

생성한 계정으로 로그인
{{&lt; figure src=&#34;/images/keycloak/2-2.png&#34; title=&#34;LOGIN&#34; &gt;}}

TOKEN을 얻을 수 있다.
{{&lt; figure src=&#34;/images/keycloak/2-3.png&#34; title=&#34;TOKEN 얻기&#34; &gt;}}

TOKEN을 붙여 넣으면 아래와 같이 요청이 되는 것을 확인 할 수 있다.
{{&lt; figure src=&#34;/images/keycloak/2-4.png&#34; title=&#34;kubectl 요청&#34; &gt;}}

만약 권한이 없다면 아래 처럼 권한이 없다고 나온다.
{{&lt; figure src=&#34;/images/keycloak/2-5.png&#34; title=&#34;kubectl 요청&#34; &gt;}}

---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/tanzu-keycloak/  

