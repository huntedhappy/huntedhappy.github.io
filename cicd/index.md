# The Documentation SupplyChain on TAP


## TANZU SUPPLYCHAIN
&gt; 아래 내용은 기본적으로 VMWARE의 TAP솔루션을 알고 있다는 가정하에 작성을 하였습니다.

CI/CD는 (Continuous Integration/Continuous Delivery) 지속적인 통합 및 지속적인 배포입니다. 

예를 들어: 
1. 사용자는 IDE 환경 (IntelliJ or visual studio or eclipse)에서 소스코드를 수정 및 디버깅을 합니다. 
2. 이 후에 수정된 소스코드를 GIT에 PUSH를 합니다. 
3. JENKINS에서는 GIT에 수정된 소스를 Webhook 또는 Polling을 통해 변경을 감지 합니다.
4. JENKINS에서 수정된 코드를 통해 Docker Image를 생성을 합니다.
5. 생성된 Docker Image를 이미지 레포지토리에 업로드 합니다.
6. Docker Image가 변경이 되었기 때문에 CD를 위해 별도의 GIT Project에 변경된 이미지를 수정 합니다.
7. CD 솔루션을 통해 (ARGO 등) GIT이 변경이 되었으므로 컨테이너이미지를 업데이트 합니다.

* MANIFEST의 경우 HELM or KUSTOMIZATION or 각각 생성 할 수도 있습니다. 

&gt; 1. JENKINS의 PIPELINE figure 1-1 와 같이 구성 할 수 있습니다. 
&gt; 2. SLACK을 연동 후 원하는 문자로 알림을 받을 수 있습니다. figure 1-2

{{&lt; figure src=&#34;/images/supplychain/1-1.png&#34; title=&#34;1-1 JENKINS PIPELINE&#34; &gt;}}

{{&lt; figure src=&#34;/images/supplychain/1-2.png&#34; title=&#34;1-2 SLACK ALERT&#34; &gt;}}

위와 같이 JENKINS와 ARGO 를 통해 CI/CD를 구성 할 수 있습니다. 하지만 각각 구성하기 위해서는 JENKINS 그리고 ARGO의 대해서도 이해가 필요 합니다. 또한 K8S에 배포를 하기 위해서는 MANIFEST의 대해서도 이해가 필요 합니다. 가령 Deployment, statfulset, ingress 등등의 대해서도, 이해가 필요 하며 HELM 또는 KUSTOMIZAION을 사용한다면 해당 오픈소스의 대해서도 이해가 필요 합니다.

TANZU APPLICATION PLATFORM은 여러 이해가 필요 한부분을 workload.yaml을 구성하면 SUPPLYCHAIN을 통해 CI/CD 구성을 사용자가 각각 구성 할 필요 없이 제공을 하고 있습니다. 


[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; TANZU APPLICATION PLATFORM?](https://huntedhappy.github.io/tanzu-application-platform/)

[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; VMWARE TANZU TAP](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.4/tap/overview.html)

{{&lt; figure src=&#34;/images/supplychain/1-3.png&#34; title=&#34;1-3 SUPPLYCHAIN&#34; &gt;}}

기본적으로 하나의 클러스터에 3가지중 하나의 SUPPLYCHAIN을 제공 하고 있습니다. DEFULAT의 경우 위의 설명 드린 대로 사용자는 workload.yaml을 적절하게 작성을 하게 되면 CI/CD가 동작 합니다. 

아래 그림과 같이 workload.yaml 실행을 통해 supplychain이 순차적으로 동작을 하게 됩니다.
{{&lt; figure src=&#34;/images/supplychain/1-4.png&#34; title=&#34;1-4 SUPPLYCHAIN&#34; &gt;}}

GUI에서 확인을 해보면 아래와 같습니다. 
{{&lt; figure src=&#34;/images/supplychain/1-5.png&#34; title=&#34;1-5 SUPPLYCHAIN&#34; &gt;}}

그리고 두번째의 경우는 추가적으로 TEKTON을 통해 소스코드를 테스팅 할 수 있습니다. 
그리고 마지막의 경우는 GRYPE을 통해 소스 및 이미지에 보안 취약점이 있는지 확인을 합니다.

GUI에서 확인을 해보면 아래와 같이 취약점에 대해서 확인 할 수 있습니다.
{{&lt; figure src=&#34;/images/supplychain/1-6.png&#34; title=&#34;1-6 SUPPLYCHAIN&#34; &gt;}}

&gt; 하지만 위에서 설명 드린 대로 하나의 클러스터에는 3가지중 하나만 사용을 할 수 있습니다. 추가적인 supplychain을 구성 하고 싶을수도 있을 것입니다. 동일한 서비스의 대해서 빠르게 개발을 위해 BASIC으로 구성을 하고 싶을 것이며, QA/STAGING은 소스/이미지에 보안취약점이 있는지 잘 생성을 했는지 확인을 하고 싶을 것입니다. 물론 클러스터를 분리해서 구성 할 수도 있을 것입니다. 하지만 리소스 부족으로 분리를 할 수 없을 경우 하나의 클러스터에 모두 구성이 필요할수도 있을수 있습니다. 만약 그런 상황이 발생하면 3개중에 하나의 supplychain만 사용이 가능하기 때문에 한가지를 선택 해야 합니다. 그렇기 때문에 supplychain을 추가 하는 방법이 필요 할 수 있습니다. 

아래와 같이 기본적으로 제공 하고 있습니다. 
{{&lt; figure src=&#34;/images/supplychain/1-7.png&#34; title=&#34;1-7 SUPPLYCHAIN&#34; &gt;}}


{{&lt; admonition tip &#34;SUPPLYCHAIN ADD&#34; &gt;}}
```shell
cat &lt;&lt; &#39;EOF&#39; &gt; basic_supply_chain.yaml
#@ load(&#34;@ytt:data&#34;, &#34;data&#34;)
#@ load(&#34;@ytt:assert&#34;, &#34;assert&#34;)

#@ data.values.registry.server or assert.fail(&#34;missing registry.server&#34;)
#@ data.values.registry.repository or assert.fail(&#34;missing registry.repository&#34;)


---
apiVersion: carto.run/v1alpha1
kind: ClusterSupplyChain
metadata:
  name: source-to-url-with-custom-support
spec:
  resources:
  - name: source-provider
    params:
      - name: serviceAccount
        value: #@ data.values.service_account
      - name: gitImplementation
        value: #@ data.values.git_implementation
    templateRef:
      kind: ClusterSourceTemplate
      name: source-template
  - name: image-provider
    params:
    - name: serviceAccount
      value: #@ data.values.service_account
    - name: registry
      value:
        ca_cert_data: &#34;&#34;
        repository: #@ data.values.registry.repository
        server: #@ data.values.registry.server
    - default: default
      name: clusterBuilder
    - default: ./Dockerfile
      name: dockerfile
    - default: ./
      name: docker_build_context
    sources:
    - name: source
      resource: source-provider
    templateRef:
      kind: ClusterImageTemplate
      options:
      - name: kpack-template
        selector:
          matchFields:
          - key: spec.params[?(@.name==&#34;dockerfile&#34;)]
            operator: DoesNotExist
      - name: kaniko-template
        selector:
          matchFields:
          - key: spec.params[?(@.name==&#34;dockerfile&#34;)]
            operator: Exists
  - images:
    - name: image
      resource: image-provider
    name: config-provider
    params:
    - name: serviceAccount
      value: #@ data.values.service_account
    templateRef:
      kind: ClusterConfigTemplate
      name: convention-template
  - configs:
    - name: config
      resource: config-provider
    name: app-config
    templateRef:
      kind: ClusterConfigTemplate
      options:
      - name: config-template
        selector:
          matchLabels:
            apps.tanzu.vmware.com/workload-type: web
      - name: server-template
        selector:
          matchLabels:
            apps.tanzu.vmware.com/workload-type: server
      - name: worker-template
        selector:
          matchLabels:
            apps.tanzu.vmware.com/workload-type: worker
  - configs:
    - name: app_def
      resource: app-config
    name: service-bindings
    templateRef:
      kind: ClusterConfigTemplate
      name: service-bindings
  - configs:
    - name: app_def
      resource: service-bindings
    name: api-descriptors
    templateRef:
      kind: ClusterConfigTemplate
      name: api-descriptors
  - configs:
    - name: config
      resource: api-descriptors
    name: config-writer
    params:
    - default: default
      name: serviceAccount
    - name: registry
      value:
        ca_cert_data: &#34;&#34;
        repository: #@ data.values.registry.repository
        server: #@ data.values.registry.server
    templateRef:
      kind: ClusterTemplate
      name: config-writer-template
  - name: deliverable
    params:
    - name: registry
      value:
        ca_cert_data: &#34;&#34;
        repository: #@ data.values.registry.repository
        server: #@ data.values.registry.server
    templateRef:
      kind: ClusterTemplate
      name: external-deliverable-template
  selector:
    apps.tanzu.vmware.com/custom: &#34;true&#34;
  selectorMatchExpressions:
  - key: apps.tanzu.vmware.com/workload-type
    operator: In
    values:
    - web
    - server
    - worker
EOF

 ytt -f basic_supply_chain.yaml -v registry.repository=tap/supply_chain -v registry.server=harbor-infra.huntedhappy.kro.kr -v service_account=default -v git_implementation=go-git | kubectl apply -f -
```
{{&lt; /admonition &gt;}}

위와 같이 추가하게 되면 별도로 SUPPLYCHAIN이 추가 된 것을 확인 할 수 있다. 
{{&lt; figure src=&#34;/images/supplychain/1-8.png&#34; title=&#34;1-8 SUPPLYCHAIN&#34; &gt;}}


그리고 아래와 같이 다른 workload.yaml과는 다른 SUPPLYCHAIN이 등록 된 것을 확인 할 수 있습니다. 
{{&lt; figure src=&#34;/images/supplychain/1-9.png&#34; title=&#34;1-9 SUPPLYCHAIN&#34; &gt;}}

---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/cicd/  

