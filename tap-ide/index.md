# The Documentation VisualStudioCode in TAP


TANZU TAP 1.6 이전 버전에서는 윈도우에서 VisualStudioCode에서 라이브 업데이트를 구성하기 위해서는 Docker Desktop이 필요 했다. 

하지만 TANZU TAP 1.6 버전부터는 Docker Desktop이 필요 없이 클러스터를 통해서 바로 테스트를 하고 이미지를 하버에 업로드가 가능하다. 

** 정확히 TAP의 문제였는지 TILT의 문제였는지는 모르지만, 아마도 TILT에서는 기존 Docker Desktop이 무조건 필요 했던거 보면 어쩌면 TANZU TAP의 버전 문제는 아닐 수도 있다. 중요한건 지금은 필요없다는 것이다.

신규로 나온 Local Source Proxy의 기능을 통해서 가능 한것으로 보인다.

해당 내용을 보자면 아래와 같다.

LSP의 경우 개발자에게 로컬 소스 코드를 TAP 클러스터에 원활하게 그리고 안전하게 업로드 할 수 있으며 또한 사용자 친화적인 접근 방식을 제공 한다고 한다. 

해당 패키지는 iterate 및 full 프로파일에서만 지원하며, 만약 제외를 하고 싶으면 local-source-proxy.apps.tanzu.vmware.com 을 tap-values.yaml에서 제외 하면 된다.

로컬 소스 프록시를 사용하면 개발자는 아래와 같은 이득을 얻을 수 있다.
&gt; 엔트 포인트, 자격 증명, 인증서 등 레지스트리 세부 사항을 알 필요 없이 외부 레지스트리를 사용 할 수 있다. 기존에는 Source주소를 적었어야 한다. 이를 통해 개발자 워크스테이션에 레지스트리 자격 증명을 배포해야 하는 플랙폼 및 앱 운영자의 부담이 줄어든다.
&gt; 소스 이미지 위치를 제공하지 않고 IDE 확장을 포함한 모든 매커니즘을 통해 로컬 소스에서 워크로드를 배포한다. 개발자는 로컬 컴퓨터에서 레지스트리 자격 증명을 관리하거나 로컬 소스가 업로드된 위치를 추적하지 않고도 어플리케이션을 원할하게 배포 할 수 있다. 

** 위에 말은 반은 맞고 반은 틀린거 같다. 윈도우에서는 레지스트리의 자격증명을 안넣으면 에러가 난다.

Tilt 파일을 생성 할 때 아래와 같이 --source-image를 없어도 된다고 나와 있지만 실제적으로 해보면 리눅스는 필요 없으나, 윈도우에서는 안된다. 

{{&lt; figure src=&#34;/images/tap-ide/1-1.png&#34; title=&#34;LSP 구조&#34; &gt;}}


```shell
## Linux일 경우 아래와 같이 SOURCE_IMAGE를 지정 하지 않아도 된다. 그러므로 개발자는 레지스트리 정보를 몰라도 된다.

LOCAL_PATH = os.getenv(&#34;LOCAL_PATH&#34;, default=&#39;.&#39;)
NAMESPACE = os.getenv(&#34;NAMESPACE&#34;, default=&#39;tap-install&#39;)

k8s_custom_deploy(
    &#39;tanzu-java-web-app-test&#39;,
    apply_cmd=&#34;tanzu apps workload apply -f config/workload.yaml --live-update&#34; &#43;
               &#34; --namespace &#34; &#43; NAMESPACE &#43;
               &#34; --local-path &#34; &#43; LOCAL_PATH &#43;
               &#34; --yes &gt;/dev/null&#34; &#43;
               &#34; &amp;&amp; kubectl get workload tanzu-java-web-app-test --namespace &#34; &#43; NAMESPACE &#43; &#34; -o yaml&#34;,
    delete_cmd=&#34;tanzu apps workload delete -f config/workload.yaml --namespace &#34; &#43; NAMESPACE &#43; &#34; --yes&#34;,
    deps=[&#39;pom.xml&#39;, &#39;./target/classes&#39;],
    container_selector=&#39;workload&#39;,
    live_update=[
      sync(&#39;./target/classes&#39;, &#39;/workspace/BOOT-INF/classes&#39;)
    ]
)

k8s_resource(&#39;tanzu-java-web-app-test&#39;, port_forwards=[&#34;8080:8080&#34;],
            extra_pod_selectors=[{&#39;carto.run/workload-name&#39;: &#39;tanzu-java-web-app-test&#39;, &#39;app.kubernetes.io/component&#39;: &#39;run&#39;}])
allow_k8s_contexts(&#39;iterate-cluster-admin@iterate-cluster&#39;)
```

```shell
## 반면 Windows에서는 SOURCE IMAGE를 안넣으면 에러가 나는 것을 확인 할 수 있다. 
SOURCE_IMAGE = os.getenv(&#34;SOURCE_IMAGE&#34;, default=&#39;harbor-infra.huntedhappy.kro.kr/app/supply_chain&#39;)
LOCAL_PATH = os.getenv(&#34;LOCAL_PATH&#34;, default=&#39;.&#39;)
NAMESPACE = os.getenv(&#34;NAMESPACE&#34;, default=&#39;tap-install&#39;)

k8s_custom_deploy(
    &#39;tanzu-java-web-app-test&#39;,
    apply_cmd=&#34;tanzu apps workload apply -f config/workload.yaml --live-update&#34; &#43;
               &#34; --namespace &#34; &#43; NAMESPACE &#43;
               &#34; --source-image &#34; &#43; SOURCE_IMAGE &#43; 
               &#34; --local-path &#34; &#43; LOCAL_PATH &#43;
               &#34; --yes &gt;/null&#34; &#43;
               &#34; &amp;&amp; kubectl get workload tanzu-java-web-app-test --namespace &#34; &#43; NAMESPACE &#43; &#34; -o yaml&#34;,
    delete_cmd=&#34;tanzu apps workload delete -f config/workload.yaml --namespace &#34; &#43; NAMESPACE &#43; &#34; --yes&#34;,
    deps=[&#39;pom.xml&#39;, &#39;./target/classes&#39;],
    container_selector=&#39;workload&#39;,
    live_update=[
      sync(&#39;./target/classes&#39;, &#39;/workspace/BOOT-INF/classes&#39;)
    ]
)

k8s_resource(&#39;tanzu-java-web-app-test&#39;, port_forwards=[&#34;8080:8080&#34;],
            extra_pod_selectors=[{&#39;carto.run/workload-name&#39;: &#39;tanzu-java-web-app-test&#39;, &#39;app.kubernetes.io/component&#39;: &#39;run&#39;}])
allow_k8s_contexts(&#39;iterate-cluster-admin@iterate-cluster&#39;)
```

LSP의 설정이 제대로 들어 갔는지 확인이 필요 하다.
```shell
tanzu apps lsp health

## 아래와 같이 나오면 정상적으로 동작 하고 있는 것이다.
user_has_permission: true
reachable: true
upstream_authenticated: true
overall_health: true
message: All health checks passed
```

강화 된 것은 IDE 환경에서 어플리케이션의 모니터링을 할 수 있다는 점이다. 

{{&lt; figure src=&#34;/images/tap-ide/2-1.png&#34; title=&#34;Visual Studio Code에서 Application Monitoring&#34; &gt;}}


---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/tap-ide/  

