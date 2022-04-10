# The Documentation Networks


{{< figure src="/images/network/1-1.png" title="OSI 7Layer" >}}

## 1. L2
### 1.1. MAC주소
MAC은 일반적으로 OSI 7 Layer중에서 2 Layer에 속한다. 확인하는 방법은 윈두우에서 CMD창을 연 후 ipconfig /all명령어를 사용하면 확인할 수 있다. 나오는 부분중에 물리적 주소라고 나오는 것을 확인 할 수 있다. 리눅스의 경우는 ifconfig라고 치면 바로 확인을 할 수 있을 것이다.
* 물론 H/W 주소이지만 변경은 가능하다. 그러므르 보안적으로 이슈가 될 수 있다.

{{< figure src="/images/network/1-2.png" title="MAC 주소 확인" >}}

확인을 하게 되면
E0-3F-49-AB-C8-AD
위와 같이 표시가 되며 절반으로 나누어 앞의 세부분은 생산자를 나타내고, 뒤의 세 부분은 장치의 일련번호(Host Identifier)을 나타낸다.

[<i class="fas fa-link"></i> MAC 제조회사 찾는 곳 ](https://regauth.standards.ieee.org/standards-ra-web/pub/view.html#registries)
{{< figure src="/images/network/1-3.png" title="제조회사 찾는 방법" >}}

### 1.2. ARP & RARP & GARP

ARP(Address Resolution Protofcol)는 IP주소를 MAC주소와 대응(Bind)시키기 위해 사용되는 프로토콜이다.
IP주소는 알지만 MAC주소를 모르는 경우 사용 할 수 있다.

윈도우에서 arp -a {IP} 로 확인 할 수 있다.
{{< figure src="/images/network/1-4.png" title="ARP 확인" >}}

RARP(Reverse Address Resolution Protocol)는 그 반대로 MAC주소로 IP를 대응(Bind)시키기 위해 사용되는 프로토콜이다.
MAC주소는 알지만 IP주소를 모르는 경우 사용 할 수 있다.

GARP(Gratuitous ARP)는 PC를 스위치에 연결을 하게 되면 나의 IP와 MAC은 이거라고 알리는대 사용한다. 3번정도 GARP를 보낸다. 그래서 IP 주소 충돌을 감지 할 수 있으며, GARP를 수신한 모든 호스트/라우터는 ARP Table을 갱신할 수 있다. 또 다른 목적은 VRRP/HSRP프로토콜에서 사용된다(VRRP/HSRP의 설명은 패스한다). 

### 1.3. L2 통신

| 기능 | 설명 | 기술 |
| ---- | ---- | ------------ | 
| learning  | 출발지 주소가 MAC 테이블에 주소가 없으면 MAC 주소를 저장 | MAC table |
| flooding  | 목적지 주소가 MAC 테이블에 없으면 전체 포트로 전달 | Broadcast |
| filtering | 출발지/목적지가 동일 네트워크에 있으면 다른 네트워크로 전파 차단 | Collision Domain |
| aging     | MAC 테이블 캐쉬 | Aging Time |

1. PC를 연결 하면 PC에서 GARP를 3번 정도 보내면서 스위치 및 PC에서는 ARP를 Learning한다.
2. 만약 스위치 및 PC에서 arp table이 없으면 aging Time이 끝났거나 또는 GARP를 받지 못했을 경우 또는 ARP테이블이 갱신이 안될 경우, PC 1에서 PC 2로 통신을 할 때 Broadcast(flooding)를 보낸다. 이 때 스위치에서는 동일한 VLAN의 모든 포트로 (목적지 IP:ff:ff:ff:ff:ff) 브로드캐스트를 보낸다. 
3. PC2는 해당 브로드캐스트를 받고 반대로 PC1에게 전달을 하게 된다.
4. 스위치 및 PC는 해당 MAC Table에 저장한다. 그리고 스위치에서 연결된 PC에서 트래픽을 전달 한다.(Forwarding) 

{{< figure src="/images/network/1-5.png" title="L2 통신" >}}


