# The Documentation Sops


## VMware TANZU SOPS or ESO?
TANZU APPLICATION PLATFORM을 설치 할 때 GITOPS로 두가지 방식으로 설치 할 수 있다. SOPS 및 ESO 방식으로 설치 할 수 있으며 현재는 베타 버전이며 프로덕션 환경에서는 권장 하지 않는다.

{{&lt; figure src=&#34;/images/sops/1-1.png&#34; title=&#34;warning&#34; &gt;}}

ESO의 경우 외부에 AWS Secrets Manager를 통해서 배포 할 수 있기 때문에 이 문서에서는 SOPS방식으로 배포를 할 예정이다.

{{&lt; figure src=&#34;/images/sops/1-2.png&#34; title=&#34;SOPS&#34; &gt;}}
{{&lt; figure src=&#34;/images/sops/1-3.png&#34; title=&#34;ESO&#34; &gt;}}

 [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; VMware TANZU GITOPS](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/install-gitops-reference.html#choosing-sops-or-eso)

## Prerequisites
- SOPS CLI to view and edit SOPS encrypted files. To install the SOPS CLI, see[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; SOPS documentation](https://github.com/mozilla/sops/releases)in GitHub.
- Age CLI to create an ecryption key used to encrypt and decrypt sensitive data. To install the Age CLI, see[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; age documentation ](https://github.com/FiloSottile/age#installation)in GitHub.
- Completed the [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Prerequisites.](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/prerequisites.html)
- [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Accepted Tanzu Application Platform EULA and installed Tanzu CLI](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/install-tanzu-cli.html) with any required plug-ins.
- Installed [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Cluster Essentials for Tanzu.](https://docs.vmware.com/en/Cluster-Essentials-for-VMware-Tanzu/1.5/cluster-essentials/deploy.html)

## Relocate images to a registry
탄주 네트워크에 있는 도커 이미지들을 내부에 내부 레지스트리에 저장 하는 것을 권장 한다. 탄주 네트워크 레지스트리를 사용 할 시 가동시간을 보장 하지 않기 때문이다.
지원되는 레지스트리는 Harbor, Azure Container Registry, Google Container Registry 및 Quay.io를 제공하고 있습니다. 설정 방법을 알아 보려면 다음 문서를 참조 하면 된다.

- [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Harbor documentation](https://goharbor.io/docs/2.5.0/)
- [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Google Container Registry documentation](https://cloud.google.com/container-registry/docs)
- [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Quay.io documentation](https://docs.projectquay.io/welcome.html)

1. environment variables를 설정 한다.
```shell
export IMGPKG_REGISTRY_HOSTNAME_0=registry.tanzu.vmware.com
export IMGPKG_REGISTRY_USERNAME_0=MY-TANZUNET-USERNAME
export IMGPKG_REGISTRY_PASSWORD_0=MY-TANZUNET-PASSWORD
export IMGPKG_REGISTRY_HOSTNAME_1=MY-REGISTRY
export IMGPKG_REGISTRY_USERNAME_1=MY-REGISTRY-USER
export IMGPKG_REGISTRY_PASSWORD_1=MY-REGISTRY-PASSWORD
export INSTALL_REGISTRY_USERNAME=MY-REGISTRY-USER
export INSTALL_REGISTRY_PASSWORD=MY-REGISTRY-PASSWORD
export INSTALL_REGISTRY_HOSTNAME=MY-REGISTRY
export TAP_VERSION=VERSION-NUMBER
export INSTALL_REPO=TARGET-REPOSITORY
```

2. [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Install the Carvel tool imgpkg CLI.](https://docs.vmware.com/en/Cluster-Essentials-for-VMware-Tanzu/1.5/cluster-essentials/deploy.html#optionally-install-clis-onto-your-path)

```shell
## 이미지 버전 확인
imgpkg tag list -i registry.tanzu.vmware.com/tanzu-application-platform/tap-packages | sort -V

## 이미지 버전을 내부 레지스트리로 복사
imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:${TAP_VERSION} --to-repo ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tap-packages
```

### Create a new Git repository
GIT에 프로젝트를 생성 한다.

```shell
mkdir -p $HOME/tap-gitops
cd $HOME/tap-gitops

git init
git remote add origin git@github.com:my-organization/tap-gitops.git
```
### Download and unpack Tanzu GitOps Reference Implementation (RI)
Tanzu Network에서 Tanzu GitOps Reference Implementation(RI)을 다운로드 받는다.
{{&lt; figure src=&#34;/images/sops/1-4.png&#34; title=&#34;RI를 Download 받는다&#34; &gt;}}

다운로드 받은 RI를 내부 GIT에 업로드 한다.
```shell
tar xvf tanzu-gitops-ri-*.tgz -C $HOME/tap-gitops

cd $HOME/tap-gitops

git add . &amp;&amp; git commit -m &#34;Initialize Tanzu GitOps RI&#34;
git push -u origin
```

### Create cluster configuration
CLUSTER-NAME은 현재 내가 설정한 CLUSTER를 선택한다

```shell
kubectl config get-contexts 

cd $HOME/tap-gitops

./setup-repo.sh CLUSTER-NAME sops

## Git에 업로드 
git add . &amp;&amp; git commit -m &#34;Add full-tap-cluster&#34;
git push
```

### Preparing sensitive Tanzu Application Platform values

```shell
mkdir -p $HOME/tmp-enc
chmod 700 $HOME/tmp-enc
cd $HOME/tmp-enc

age-keygen -o key.txt

cat key.txt
# created: 2023-02-08T10:55:35-07:00
# public key: age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
AGE-SECRET-KEY-my-secret-key

## 아래 내용을 채워 준다.
## 만약에 멀티 클러스터를 구성 하고 싶으면 아래 내용을 분리 해준 후 각각 클러스터별로 실행 해주면 된다.

cat &lt;&lt; EOF &gt; $HOME/tmp-enc/tap-sensitive-values.yaml
---
tap_install:
  sensitive_values:
    shared:
      ingress_domain: &#34;INGRESS-DOMAIN&#34;
      ingress_issuer: # Optional, can denote a cert-manager.io/v1/ClusterIssuer of your choice. Defaults to &#34;tap-ingress-selfsigned&#34;.
    
      image_registry:
        project_path: &#34;SERVER-NAME/REPO-NAME&#34;
        secret:
          name: &#34;KP-DEFAULT-REPO-SECRET&#34;
          namespace: &#34;KP-DEFAULT-REPO-SECRET-NAMESPACE&#34;
    
      kubernetes_distribution: &#34;K8S-DISTRO&#34; # Only required if the distribution is OpenShift and must be used with the following kubernetes_version key.
    
      kubernetes_version: &#34;K8S-VERSION&#34; # Required regardless of distribution when Kubernetes version is 1.25 or later.
    
      ca_cert_data: | # To be passed if using custom certificates.
          -----BEGIN CERTIFICATE-----
          MIIFXzCCA0egAwIBAgIJAJYm37SFocjlMA0GCSqGSIb3DQEBDQUAMEY...
          -----END CERTIFICATE-----
    
    ceip_policy_disclosed: FALSE-OR-TRUE-VALUE # Installation fails if this is not set to true. Not a string.
    
    #The above keys are minimum numbers of entries needed in tap-values.yaml to get a functioning TAP Full profile installation.
    
    #Below are the keys which may have default values set, but can be overridden.
    
    profile: full # Can take iterate, build, run, view.
    
    supply_chain: basic # Can take testing, testing_scanning.
    
    ootb_supply_chain_basic: # Based on supply_chain set above, can be changed to ootb_supply_chain_testing, ootb_supply_chain_testing_scanning.
      registry:
        server: &#34;SERVER-NAME&#34; # Takes the value from the shared section by default, but can be overridden by setting a different value.
        repository: &#34;REPO-NAME&#34; # Takes the value from the shared section by default, but can be overridden by setting a different value.
      gitops:
        ssh_secret: &#34;SSH-SECRET-KEY&#34; # Takes &#34;&#34; as value by default; but can be overridden by setting a different value.
    
    contour:
      envoy:
        service:
          type: LoadBalancer # This is set by default, but can be overridden by setting a different value.
    
    buildservice:
      # Takes the value from the shared section by default, but can be overridden by setting a different value.
      kp_default_repository: &#34;KP-DEFAULT-REPO&#34;
      kp_default_repository_secret: # Takes the value from the shared section above by default, but can be overridden by setting a different value.
        name: &#34;KP-DEFAULT-REPO-SECRET&#34;
        namespace: &#34;KP-DEFAULT-REPO-SECRET-NAMESPACE&#34;
    
    tap_gui:
      metadataStoreAutoconfiguration: true # Creates a service account, the Kubernetes control plane token and the requisite app_config block to enable communications between Tanzu Application Platform GUI and SCST - Store.
      app_config:
        catalog:
          locations:
            - type: url
              target: https://GIT-CATALOG-URL/catalog-info.yaml
    
    metadata_store:
      ns_for_export_app_cert: &#34;MY-DEV-NAMESPACE&#34; # Verify this namespace is available within your cluster before initiating the Tanzu Application Platform installation.
      app_service_type: ClusterIP # Defaults to LoadBalancer. If shared.ingress_domain is set earlier, this must be set to ClusterIP.
    
    scanning:
      metadataStore:
        url: &#34;&#34; # Configuration is moved, so set this string to empty.
    
    grype:
      namespace: &#34;MY-DEV-NAMESPACE&#34; # Verify this namespace is available within your cluster before initiating the Tanzu Application Platform installation.
      targetImagePullSecret: &#34;TARGET-REGISTRY-CREDENTIALS-SECRET&#34;
      # In a single cluster, the connection between the scanning pod and the metadata store happens inside the cluster and does not pass through ingress. This is automatically configured, you do not need to provide an ingress connection to the store.
    
    policy:
      tuf_enabled: false # By default, TUF initialization and keyless verification are deactivated.
    tap_telemetry:
      customer_entitlement_account_number: &#34;CUSTOMER-ENTITLEMENT-ACCOUNT-NUMBER&#34; # (Optional) Identify data for creating the Tanzu Application Platform usage reports.
EOF

export SOPS_AGE_RECIPIENTS=$(cat key.txt | grep &#34;# public key: &#34; | sed &#39;s/# public key: //&#39;)
sops --encrypt tap-sensitive-values.yaml &gt; tap-sensitive-values.sops.yaml

mv tap-sensitive-values.sops.yaml $HOME/tap-gitops/clusters/full-tap-cluster/cluster-config/values/
```

### Generate Tanzu Application Platform installation and Tanzu Sync configuration
```shell
export INSTALL_REGISTRY_HOSTNAME=MY-REGISTRY
export INSTALL_REGISTRY_USERNAME=MY-REGISTRY-USER
export INSTALL_REGISTRY_PASSWORD=MY-REGISTRY-PASSWORD
export GIT_SSH_PRIVATE_KEY=PRIVATE-KEY
export GIT_KNOWN_HOSTS=KNOWN-HOST-LIST
export SOPS_AGE_KEY=AGE-KEY
export TAP_PKGR_REPO=TAP-PACKAGE-OCI-REPOSITORY

cd $HOME/tap-gitops/clusters/full-tap-cluster

./tanzu-sync/scripts/configure.sh
git add cluster-config/ tanzu-sync/
git commit -m &#34;Configure install of TAP 1.5.0&#34;
git push
```

### Deploy Tanzu Sync
```shell
cd $HOME/tap-gitops/clusters/full-tap-cluster

./tanzu-sync/scripts/deploy.sh
```
### 결과
완료가 되면 자동으로 모든게 다 설치가 되는 것을 확인 할 수 있지만.. 솔직히 불편하다.. 그냥 설치하는게 편한거 같은 느낌은..
아직 베타이기 때문일지 모른다.
{{&lt; figure src=&#34;/images/sops/1-5.png&#34; title=&#34;Result&#34; &gt;}}

---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/ko/sops/  

