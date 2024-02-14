# The Documentation Minio


MiniO는 Minimal Object Storage를 의미 하며, 오픈소스 형태로 제공 하는 오브젝트 스토리지이다. 

{{&lt; admonition tip &#34;Object Storage?&#34; &gt;}}
오브젝트 스토리지는 이미지, 오디오 파일, 스프레드시트 또는 바이너리 실행 코드등 문서 처럼 한줄 한문자 바꾸는 형식이 아니라 하나의 파일이 다 바뀌는 것으로 이해하면 쉬울 거 같다.
{{&lt; /admonition &gt;}}

MiniO는 3가지 형태로 도구를 제공 한다.

* MiniO Console / Server - UI / Cloud Storage Server를 구성 할 수 있다.
* MiniO Client(mc,admin) - Minio Server, AWS S3, GCS등등 연결하여 파일 업로드 및 관리등을 할 수 있다.
* MiniO gateway - Minio는 스토리지 Gateway도 지원한다. 예를들어 miniO게이트웨이를 구성 하면 가상머신등에서 Nas를 통해 파일 또는 파일공유 지점으로 miniO안 객체에 엑세스 할 수 있다. 

MiniO는 2가지의 배포 형식을 제공 한다.

* 독립형 배포: 단일 스토리지 볼륨 또는 폴더가 있는 단일 MiniO 서버
* 분산 배포: 모든 서버에 총 스토리지 볼륨이 4개 이상인 하나 이상의 MiniO서버

위의 내용은 Kasten 설치 후 백업 스토리지를 MiniO로 구성하기 위해 간단하게 MiniO가 무엇인지의 대한 설명

아래 내용은 Kasten으로 백업 스토리지를 MiniO로 구성시 Erasure Coding 및 Immutability가 되어야 하는대 이 부분의 대해서 설명 하고자 한다.

## 1. Erasure Coding
Erasure Coding은 클러스터의 여러개 디스크 드라이브 중 몇개가 손실이 발생 하더라도 자동으로 복구 를 할 수 있게 해주는 데이터 중복성 및 가용성 기능이다. Erasure Coding은 RAID 또는 복제와 같은 기술보다 적은 오버헤드로 복구를 제공한다.

### 1.1. Erasure Coding 동작
Erasure Coding은 원본 데이터를 가져와서 데이터가 필요할 때 원본 정보를 재생성하기 위해 부분 집합만 필요로 하는 방식으로 인코딩을 한다. 예를들어 개체 또는 데이터의 원래 값이 95라고 가정하고 x=9 및 y=5가 되도록 나눈다. 인코딩 프로세스는 일련의 방정식을 생성 한다.

이 경우 다음과 같은 방적식을 생성한다고 가정 합니다.

* x &#43; y = 14
* x - y = 4
* 2x &#43; y = 23

객체를 재생성 하려면 이 세 방정식 중 두가지가 필요 하므로 디코딩 할 수 있습니다. 따라서 방정식을 풀면 x와 y에 대한 값을 얻을 수 있습니다.

3개의 방정식이 있지만 그 중 2개에서 원래 정보를 얻을 수 있기 때문에 데이터를 조각으로 나누고 인코딩하여 여러위치에 저장하는 데이터 보호 체계 입니다.

요약하자면, Erasure Code를 활용하여 데이터를 인코딩 하고, 데이터 손실시 디코딩 과정을 거쳐 원본 데이터를 복구하는 데이터 복구 기법중 하나

{{&lt; figure src=&#34;/images/minio/1-1.png&#34; title=&#34;Decode / Encode&#34; &gt;}}

자세한 설명은 링크를 걸어 두도록 하겠다. [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Minio Erasure Coding](https://docs.min.io/minio/baremetal/concepts/erasure-coding.html)

참고링크#1 [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; 참고링크#1](https://stonefly.com/blog/understanding-erasure-coding)

### 1.2. Erasure Coding vs RAID?
RAID로 구성시 데이터를 다른 위치에 저장할 수 있으며 드라이브 오류로부터 보호, Erasure Coding은 데이터가 부분적으로 분할된 다음 확장되고 인코딩이 된다. 그 후 세그먼트는 여러 위치에 보관하도록 구성이 된다. 
RAID는 무결성 위협으로 부터 데이터 보호를 용이 하게 할 수 있으며, Erasure Coding은 스토리지 소모를 덜 할 수 있게 해준다. 
상황에 따라 RAID 및 Erasure Coding 모두 적합 할 수 있다.

Erasure Coding의 현재 사용 사례 중 하나는 객체 기반 클라우드 스토리지입니다. Erasure Coding은 높은 CPU 사용률을 요구하고 대기 시간이 발생하므로 애플리케이션 보관에 적합합니다. 또한 Erasure Coding은 데이터 무결성 위협으로부터 보호할 수 없기 때문에 기본 워크로드에 적합하지 않습니다.

### 1.3. Erasure Coding의 이점
Erasure Coding은 고급 데이터 보호 및 재해 복구 방법을 제공합니다 . 

* 저장 공간 활용도: Erasure Coding은 소비되는 공간을 줄이고 동일한 수준의 중복성을 제공하여 더 나은 저장 활용률을 제공(복사본 3개). Erasure Coding을 활용하면 최대 50% 더 많은 공간을 절약할 수 있습니다.
* 신뢰성 향상:  데이터 조각은 독립적인 오류 더미 로 조각화됩니다 . 이렇게 하면 종속되거나 상관된 오류가 발생하지 않습니다.
* 적합성: Erasure Coding은 모든 파일 크기에 사용할 수 있습니다. KiloBytes의 작은 블록 크기에서 PetaBytes의 큰 블록 크기에 이르기까지 다양합니다.
* Suitability: 데이터를 복구하는 데 데이터의 Suitability만 필요합니다. 원본 데이터가 필요하지 않습니다.
* 유연성: 시스템을 오프라인으로 전환하지 않고도 편리할 때 고장난 구성 요소를 교체할 수 있습니다.

{{&lt; admonition tip &#34;Suitablility?&#34; &gt;}}
Suitablility란 더 큰 집합에서의 부분적인 집합.
{{&lt; /admonition &gt;}}

### 1.4. MiniO Erasure Code 계산기
&gt; [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; 계산기 LINK](https://min.io/product/erasure-code-calculator?utm_term=erasure%20coding&amp;utm_campaign=Erasure&#43;Coding&#43;1.4&amp;utm_source=adwords&amp;utm_medium=ppc&amp;hsa_acc=8976569894&amp;hsa_cam=13884673572&amp;hsa_grp=127699937027&amp;hsa_ad=533469681242&amp;hsa_src=g&amp;hsa_tgt=kwd-314402742856&amp;hsa_kw=erasure%20coding&amp;hsa_mt=p&amp;hsa_net=adwords&amp;hsa_ver=3&amp;gclid=Cj0KCQiAip-PBhDVARIsAPP2xc2nLMVBzYtNdDYlETP-3UjGr3ZqD7sA-IPzfhNnxWhzes03cq62ViUaAtprEALw_wcB)


## 2. Immutability
MiniO 서버는 특정 개체에 대해 WORM을 허용하거나 모든 객체에 기본 보존 모드 및 보존기간을 적용하는 객체 잠금 구성으로 버킷을 구성하여 WORM을 허용합니다. 이렇게 하면 버킷의 객체를 변경 할 수 없습니다. 즉, 버킷의 객체 잠금 구성 또는 객체 보존에 지정된 만료일 까지 버전 삭제가 허용 되지 않습니다.

객체 잠금을 사용하려면 버킷 생성시 잠금을 활성화해야 하며, 객체 잠금도 버킷의 버전 관리를 자동으로 활성화 합니다. 또는 버킷에서 생성된 객체에 적용할 기본 보존 기간 및 보존 모드를 버킷에 구성 할 수 있습니다.

{{&lt; admonition tip &#34;WORM?&#34; &gt;}}
Read Many(WORM)
{{&lt; /admonition &gt;}}


### 2.1. 개념
{{&lt; admonition note &#34;Immutability 개념&#34; &gt;}}
* 객체가 법적 보존 상태에 있는 경우 해당 버전ID에 대한 법적 보존이 명시적으로 제거되지 않는 한 삭제 할 수 없다. 그렇지 않으면 DeleteObjectVersio()이 실패 한다.
* Compliance모드 에서는 해당 버전 ID의 보존기간이 만료될 때때가지 누구도 객체를 삭제 할 수 없다. 사용자에게 필요한 거버넌스 우회 권한이 있는 경우 Compliance모드 에서 개체의 보존 날짜를 연장 할 수 있다.
* 객체 잠금 구성이 버킷으로 설정되면
&gt; * 새 객체는 버킷 객체 잠금 구성의 보존 설정을 자동으로 상속한다. 
&gt; * 개체를 업로드할 때 보존 헤더를 선택적으로 설정 할 수 있다.
&gt; * 개체에서 명시적으로 PutObjectRetention API 호출을 할 수 있다.
* MINIO_NTP_SERVER환경 변수는 보존하는 날짜를 시스템시간으로 설정이 필요하지 않는 경우 원격 NTP 서버를 구성 할 수 있다.
* 객체잠금 기능은 삭제 코드 및 분산 삭제 코드 설정에서만 사용 할 수 있다.
{{&lt; /admonition &gt;}}

자세한 설명은 링크를 걸어 두도록 하겠다. [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Minio Immutability](https://docs.min.io/docs/minio-bucket-object-lock-guide.html)


### 카스텐 설정시 MiniO로 Backup Storage 구성 링크 참조. [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Kasten MiniO Install](https://huntedhappy.github.io/ko/k10/)

---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/ko/minio/  

