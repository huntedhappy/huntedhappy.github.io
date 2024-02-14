# The Documentation vSAN


## 1. VSAN 개념

VSAN SDS(Software Defined Storage), ESXi 호스트의 로컬 스토리지 리소스를 가상화하고, 서비스 품질 요구 사항에 따라 분할하여 가상 시스템 및 애플리케이션에 할당 할 수 있는 스토리지 풀로 변환.

[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; 참고 문헌](https://docs.vmware.com/kr/VMware-vSphere/7.0/com.vmware.vsphere.vsan-planning.doc/GUID-ACC10393-47F6-4C5A-85FC-88051C1806A0.html)


## 2. VSAN Erasure Coding RAID-5 및 RAID-6

Erasure Coding이란 일부 조각이 누락된 경우에도 원본데이터를 복구할 수 있는 방식으로 데이터를 조각으로 인코딩하고 분할하는 `모든 체계`를 나타내는 일반적인 용어.

&gt; 여기서 더 자세한 내용을 확인 할 수 있을 거 같다.   [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; 참고 문헌](https://www.usenix.org/system/files/login/articles/10_plank-online.pdf)

Reed-Solomon 알고리즘에 기반 한다. (알고리즘의 따라 계산 하는 방법이 달라진다.)

참고로 MINIO에서도 동일한 Erasure Coding이라는 용어가 나오지만, 위에 설명 했듯이 그냥 일반적인 용어이며, VSAN과 MiniO에서 사용하는 부분의 차이도 명확하다 우선 VSAN은 Host가 두개 실패 했을 경우까지만 제공을 한다. 하지만 MiniO에서 사용하는 Erasure Coding은 두개의 실패뿐만 아니라 더 많이 실패해도 복구를 할 수 있다는 점이다.

{{&lt; figure src=&#34;/images/vsan/1-1.png&#34; title=&#34;VSAN 정책&#34; &gt;}}


#### RAID-5

* 물리 장애 실패 = 1
* 내결함성 = 용량
* RAID-1은 물리 용량을 x2 이지만 RAID-5의 용량은 x1.33만 필요
* VSAN구성시 클러스터는 최소 4개의 노드가 필요

{{&lt; figure src=&#34;/images/vsan/1-2.png&#34; title=&#34;스트라이프당 3개의 데이터 &#43; 1개의 패리티 조각이 있는 RAID-5 스트라이핑&#34; &gt;}}

#### RAID-6

* 물리 장애 실패 = 2
* 내결함성 = 용량
* RAID-1은 물리 용량을 x3 이지만 RAID-6의 용량은 x1.5만 필요
* VSAN구성시 클러스터는 최소 6개의 노드가 필요

{{&lt; figure src=&#34;/images/vsan/1-3.png&#34; title=&#34;스트라이프당 4개의 데이터 &#43; 1개의 패리티(P) &#43; 1개의 RS(Q) 신드롬 조각이 있는 RAID-6 스트라이핑&#34; &gt;}}

{{&lt; admonition tip &#34;내결함성?&#34; &gt;}}
시스템을 구성하는 부품의 일부에서 결함(fault) 또는 고장(failure)이 발생하여도 정상적 혹은 부분적으로 기능을 수행할 수 있는 시스템이다.
[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; 참고 문헌](https://ko.wikipedia.org/wiki/%EC%9E%A5%EC%95%A0_%ED%97%88%EC%9A%A9_%EC%8B%9C%EC%8A%A4%ED%85%9C)
{{&lt; /admonition &gt;}}


* vSAN 데이터 보호 공간

|  허용된 실패  | RAID-1 || RAID-5/6 || Erasure Coding save vs Mirroring |
| :----------: | :----: |:-:| :---: | :-: | :--:  |
|       | 필요한 최소 호스트 | 총 용량 요구 사항 | 필요한 최소 호스트 | 총 용량 요구 사항 | |
| FTT=0 | 3 | x1 | N/A | N/A | N/A |
| FTT=1 | 3 | x2 | 4 | x1.33 | 33% 감소 |
| FTT=2 | 5 | x3 | 6 | x1.5 | 50% 감소 |
| FTT=3 | 7 | x4 | N/A | N/A | N/A |

## 3. 성능 vs 용량

앞서 설명한 대로 Erasure Coding을 사용한다는 것은 성능보다 용량을 우선시 한다는 것이다. Erasure Coding은 Software 기반으로 처리를 하기 때문에 CPU를 많이 사용하게 되어 있으며 RAID1보다는 복잡한 계산식으로 인해서 상황에 맞게 선택을 하는 것이 중요하다.

## 4. 고려사항
RAID-5/RAID-6의 경우 vSAN에서 Streched Storage에는 지원 하지 않음, 또한 All-Flash 구성으로 제공해야함. 

#### VSAN Hardware CALCULATE
&gt; [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; VSAN Hardware CALCULATE](https://vsan.virtualappliances.eu/)


[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; 참고 문헌](https://cormachogan.com/2016/02/15/vsan-6-2-part-2-raid-5-and-raid-6-configurations/)

[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; 참고 문헌](https://download3.vmware.com/vcat/vmw-vcloud-architecture-toolkit-spv1-webworks/index.html#page/Storage%20and%20Availability/Architecting%20VMware%20vSAN%206.2/Architecting%20Virtual%20SAN%206.2.2.022.html)

[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; 참고 문헌](https://blogs.vmware.com/virtualblocks/2018/06/07/the-use-of-erasure-coding-in-vsan/)

---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/vsan/  

