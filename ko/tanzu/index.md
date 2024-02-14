# The Documentation Tanzu


## 1. VMware TANZU?
2019년 8월 VMware에서 처음으로 TANZU 포트 폴리오를 발표 했다. VM웨어의 대표 제품군인 ‘브이스피어(vSphere)’를 쿠버네티스 네이티브 플랫폼으로 바꾸겠다고 선언했다. 이를 위해 VM웨어는 ‘프로젝트 퍼시픽(Project Pacific)’을 진행했다. 

&gt; {{&lt; figure src=&#34;/images/tanzu/1-1.png&#34; title=&#34;Tanzu Portfolio&#34; &gt;}}

처음에는 VCF(VMware Cloud Foundation)라는 솔루션을 같이 설치 하면서 배포 해야 되었던 vsphere with tanzu가 현재는 VCF를 구성하지 않아도 설치가 가능하도록 변하게 되었다.


{{&lt; admonition info &#34;VCF(VMware Cloud Foundation)?&#34;&gt;}}
VMware 제품군을 자동으로 설치 해주는 솔루션이다. Excel, JSON파일을 읽어 드려 vSphere, vCenter, vSAN 그리고 NSX-T를 한번에 배포 해주는 솔루션
{{&lt; /admonition &gt;}}

### 1.1. vsphere with tanzu?
vsphere with tanzu는 말그대로 vsphere 에서 컨테이너를 바로 올리는 컨셉으로 나왔다. 용어로 TKGS라고도 불린다. Tanzu를 서비스형태로 올릴 수 있다고 해서 TKGS라고 불리며, 말그대로 vCenter에서 서비스 형태로 설치를 할 수 있기 때문이다. 하지만 vCenter에 종속이 되버리기 때문에 vCenter가 업그레이드가 되어야 K8S의 버전을 올릴수 있다. 정확히 말하면 vsphere위에 올릴 경우는 이벤트 형식으로 올리고, 프로덕션의 경우 TKC위에다가 POD를 올리는 것이 낫지 않을까 싶다. 

그래서 컨셉은 아래와 같다.

&gt; {{&lt; figure src=&#34;/images/tanzu/1-2.png&#34; title=&#34;TKGS&#34; &gt;}}

{{&lt; admonition info &#34;TKC(Tanzu Kubernetes Cluster)?&#34;&gt;}}
TKC는 별도로 클러스터를 배포 하는 것이다. vmware에서 배포되는 Supervisor가 관리를 하게 되며, 네임스페이스에 TKC를 배포 하여 사용 할 수 있다.
{{&lt; /admonition &gt;}}

자세한 TKGS의 대한 설명은 링크를 걸어 두도록 하겠다. [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; VMware TKGS](https://docs.vmware.com/kr/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-4D0D375F-C001-4F1D-AAB1-1789C5577A94.html)

### 1.2. Tanzu Kubernetes Grid?
TKGM이라고 하며, 예전 Pivotal에서 PKS가 이렇게 변한 것이 아닐까 싶다. 예전 Pivotal에서는 bosh라는 관리 솔루션을 통해 PKS를 배포 하여 클러스터를 구성 하였다. 그렇다고 TKG가 기존에 없었던 솔루션은 아니다 6.7에서 이미 TKG는 있었지만 많은 사람들이 사용하지는 않았다. 그리고 Pivotal이 VMware로 인수 되면서 Tanzu로 변화하고 있는 것으로 알고 있다. TKGM은 TKGS와는 다른게 별도로 관리 클러스터를 배포해야 한다. TKGS같은 경우에는 Supervisor가 그 역할을 하였다.
그리고 TKC를 배포하는 형식이다. 

자세한 TKG의 대한 설명은 링크를 걸어 두도록 하겠다. [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; VMware TKG](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-tkg-concepts.html)

### 1.3. Tanzu Kubernetes Integrated?
기존 Pivotal에서 Bosh로 배포한 PKS라고 보면 될거 같다. 현재는 사용하지 않을 것 같으므로 설명은 패스 하겠다.

자세한 TKGI의 대한 설명은 링크를 걸어 두도록 하겠다. [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; VMware TKGI](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid-Integrated-Edition/index.html)



---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/ko/tanzu/  

