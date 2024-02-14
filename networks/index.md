# The Documentation Networks


## 0. OSI 7 Layer
{{&lt; figure src=&#34;/images/network/1-1.png&#34; title=&#34;OSI 7Layer&#34; &gt;}}

### 0.1. Ethernet Frame

{{&lt; figure src=&#34;/images/network/2-1.png&#34; title=&#34;EthernetFrame&#34; &gt;}}

### 0.2. Ethernet Header ( 2 Layer)

Destination Address 6 bytes = 48 bits
* 목적지 맥 주소 6 bytes(48bits), 주소의 첫 번째 비트가 1이면 멀티캐스트 이며, 모든 비트가 1이면 브로드캐스트이다.
FF:FF:FF:FF:FF = Broadcast

Source Address 6 bytes = 48 bits
* 출발지 맥 주소 6 bytes(48bits)

802.1q tag 4 bytes = 32 bits
* L2에서 VLAN 설정

Ethernet Type 2 bytes = 16 bits

* Ethernet 및 802.3 와의 호환성을 위한 구분 방법 (Len/Type : 길이 또는 타입)
  * 0x 600 이하이면 =&gt; Length (IEEE 802.3) 로 해석
    * Length : 수납되는 LLC 프레임 길이(3~1500 바이트)를 나타냄   ☞  MTU

  * 0x 600 이상이면 =&gt; Type (DIX 2.0) 로 해석
    * Type   : Data에 담겨있는 상위 프로토콜 종류

|  Type Field | Description | 
| ------- | -------------- | 
| 0x0600h | Xerox XNS IDP |
| 0x0800h | IPv4 |
| 0x0805h | X.25 |
| 0x0806h | ARP |
| 0x0835h | RARP |
| 0x6003h | DEC DECnet Phase IV |
| 0x8100h | VLAN ID |
| 0x8137h | Novell Netware IPX |
| 0x8191h | NetBIOS |
| 0x86DDh | IPv6 |
| 0x8847h | MPLS }
| 0x8863h | PPPoE Discovery Stage |
| 0x8864h | PPPoE PPP Session Stage |
| 0x888Eh | IEEE 802.1X |
| 0x88CCh | LLDP (Link Layer Discovery Protocol) |

### 0.3. IP Header (3 Layer)

{{&lt; figure src=&#34;/images/network/2-2.png&#34; title=&#34;IP Header&#34; &gt;}}

windows에서 MTU 사이즈 확인 하는 방법

ping Option 설정 -l size , -f 조각화 하지 않음, IP 20 bytes, ICMP 8 bytes

1500 - (IP &#43; ICMP) = 1472

ping -l -f 1472

{{&lt; figure src=&#34;/images/network/2-3.png&#34; title=&#34;ICMP로 확인&#34; &gt;}}

명령어로 MTU 확인
netsh interface ipv4 show interfaces

{{&lt; figure src=&#34;/images/network/2-4.png&#34; title=&#34;netsh로 확인&#34; &gt;}}

변경은 아래 명령어로 가능하다. (변경시 상단 스위치에서도 변경 필요, 변경 하지 않으면 단편화가 된다.)
netsh interface ipv4 set subinterface &#34;색인 번호&#34; 또는 &#34;이름&#34; 으로 변경이 가능하다.

netsh interface ipv4 set subinterface &#34;10&#34; mtu=9000 store=persistent

netsh interface ipv4 set subinterface &#34;이더넷 2&#34; mtu=9000 store=persistent


### 0.4. TCP Header (4 Layer)

{{&lt; figure src=&#34;/images/network/2-5.png&#34; title=&#34;TCP Header&#34; &gt;}}

Source port (16 bits)
* 출발지 port

Destination port (16 bits)
* 목적지 port

Sequence number (32 bits)
* 패킷의 순서

Acknowledgment number (32 bits)

Data offset (4 bits)
* TCP 헤더의 크기를 32 bits로 지정

Reserved (3 bits)
* 향후 사용을 위해 0으로 설정 (현재는 사용하지 않음)

Flags (9 bits)
* 다음과 같은 9개의 1비트 플래그(제어 비트)를 포함합니다.
* NS(1비트): ECN-nonce - 은폐 보호 [a]
* CWR(1비트): CWR(Congestion Window Reduced) 플래그는 송신 호스트가 ECE 플래그가 설정된 TCP 세그먼트를 수신하고 혼잡 제어 메커니즘에서 응답했음을 나타내기 위해 설정됩니다. [비]
* ECE(1비트): ECN-Echo는 SYN 플래그 값에 따라 이중 역할을 합니다. 다음을 나타냅니다.
  * SYN 플래그가 설정되면(1), TCP 피어는 ECN 을 사용할 수 있습니다.
  * SYN 플래그가 클리어(0)이면 IP 헤더에 Congestion Experienced 플래그(ECN=11)가 설정된 패킷이 정상 전송 중에 수신되었음을 나타냅니다. [b] 이것은 TCP 발신자에게 네트워크 정체(또는 임박한 정체)를 나타내는 역할을 합니다.
* URG(1비트): 긴급 포인터 필드가 중요함을 나타냅니다.
* ACK(1비트): Acknowledgement 필드가 중요함을 나타냅니다. 클라이언트가 보낸 초기 SYN 패킷 이후의 모든 패킷에는 이 플래그가 설정되어 있어야 합니다.
* PSH(1비트): 푸시 기능. 버퍼링된 데이터를 수신 애플리케이션에 푸시하도록 요청합니다.
* RST(1비트): 연결 재설정
* SYN(1비트): 시퀀스 번호를 동기화합니다. 각 끝에서 보낸 첫 번째 패킷에만 이 플래그가 설정되어야 합니다. 일부 다른 플래그 및 필드는 이 플래그를 기반으로 의미를 변경하며 일부는 설정된 경우에만 유효하고 다른 일부는 해제된 경우에만 유효합니다.
* FIN(1비트): 보낸 사람의 마지막 패킷

Windows size (16 bits)
한번에 받을 수 있는 데이터의 양이며 최대 64Kbytes 까지 가능하다.PC에서 Windows Size만큼 한번에 전송 후에 ACK를 기다린다.
Windows Szie는 가변적이므로 통신에 문제가 없으면 Size를 늘리고, 문제가 발생 한다면 Size를 줄인다. 이렇게 늘렸다 줄였다 하는 것을 Sliding Window라고 하며 이렇게 전송속도를 제어 하는 것을 Flow-Control이라고 부른다.

Checksum (16 bits)
* 16비트 체크섬 필드는 TCP 헤더, 페이로드 및 IP 의사 헤더의 오류 검사에 사용됩니다. 의사 헤더는 소스 IP 주소 , 대상 IP 주소 , TCP 프로토콜의 프로토콜 번호 (6), TCP 헤더 및 페이로드의 길이(바이트)로 구성됩니다.

[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Sliding Window 참고 블로그 ](https://4network.tistory.com/entry/Sliding-Window-%EA%B0%9C%EB%85%90-%EC%9D%B4%ED%95%B4%ED%95%98%EA%B8%B0?category=286056)

[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Ethernet frame wiki ](https://en.wikipedia.org/wiki/Ethernet_frame)

[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; IP Header wiki  ](https://en.wikipedia.org/wiki/IPv4)

[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; TCP Header wiki  ](https://en.wikipedia.org/wiki/Transmission_Control_Protocol)

[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Ethernet Type 참고 ](http://www.ktword.co.kr/test/view/view.php?m_temp1=2039)

#### 0.4.1. (FIN, FIN-WAIT)관련

{{&lt; figure src=&#34;/images/network/3-1.png&#34; title=&#34;FIN&#34; &gt;}}

FIN_WAIT1 상태
* A가 B에게 Connection을 Close하면서, 종료 신호인 FIN segment를 A에서 B에게 보내고, A는 FIN_WAIT_1 상태가 된다.
(이때 A System의 User는 더이상의 SEND는 사용 할 수 없고, RECIEVE는 계속 가능)

CLOSE_WAIT 상태
* B가 신호를 받으면 B는 CLOSE_WAIT에 들어가면서 그에 대한 ACK을 보낸다.

FIN_WAIT2 상태
* A는 FIN_WAIT2상태가 되고, B는 Connection Close하면서 FIN을 보낸다.

TIME_WAIT 상태
* A는 TIME_WAIT상태가 되어 최종적으로 B와의 Connection이 닫히는지 확인 한다.

즉 서버가 클라이언트로 부터 FIN에 대한 ACK을 받고나서 클라이언트의 FIN을 기다리는 상태가 FIN_WAIT2 상태이다.

### 0.5. Overlay

#### 0.5.1. VXLAN
Outer IP Header 20 Bytes &#43; UDP Header 8 bytes &#43; VXLAN 8 bytes &#43; Inner Ethernet 18 bytes

VLAN 포함

20 &#43; 8 &#43; 8 &#43; 18 = 54

만약 VLAN이 포함 되어 있지 않다면

20 &#43; 8 &#43; 8 &#43; 14 = 50

그래서 1500 &#43; 54 = 1554 가 필요 하지만 계산하기 편하게 1600 이상으로 설정 하는 것을 권고 한다.
또한 요새는 SDN 제품들이 jumbo frame(9000) 으로 기본 셋팅 되어서 나오기 때문에 9000으로 설정을 해도 된다.

{{&lt; figure src=&#34;/images/network/4-1.png&#34; title=&#34;VXLAN&#34; &gt;}}

#### 0.5.2. GENEVE
{{&lt; figure src=&#34;/images/network/4-2.png&#34; title=&#34;GENEVE#1&#34; &gt;}}

{{&lt; figure src=&#34;/images/network/4-3.png&#34; title=&#34;GENEVE#2&#34; &gt;}}

|  PARAMETER  | VXLAN | GENEVE | 
| ------------------------------------------------------- | -------------- | ------------ | 
| Abbreviation for         | VXLAN (Virtual Extensible LAN) | GENEVE (Generic Network Virtualization Encapsulation) |
| Developed by             | VMware, Arista Networks and Cisco | VMware, Microsoft, Red Hat and Intel |
| Protocol                                                | UDP | UDP |
| Port No                                                 | 4789 | 6081 |
| Header Length                                           | 8 bytes | 16 bytes |
| Transport security, service chaining, in-band telemetry | Not Supported | Supported |
| RFC                       | VXLAN is officially documented by the IETF in RFC 7348 | RFC 8926 |
| Protocol Identifier                                     | No | Yes |
| Non-Client Payload Indication                           | No | Yes |
| Extensibility           | No. Infact all fields in VXLAN header have predefined value | Yes |
| Hardware friendly vendor extensibility mechanism        | Limited | Yes |
| Term used for Tunnel Endpoints                          | VTEP | TEP |




[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; VXLAN - GENEVE 참고  ](https://ipwithease.com/vxlan-vs-geneve-understand-the-difference/)

## 1. L2
### 1.1. MAC주소
MAC은 일반적으로 OSI 7 Layer중에서 2 Layer에 속한다. 확인하는 방법은 윈두우에서 CMD창을 연 후 ipconfig /all명령어를 사용하면 확인할 수 있다. 나오는 부분중에 물리적 주소라고 나오는 것을 확인 할 수 있다. 리눅스의 경우는 ifconfig라고 치면 바로 확인을 할 수 있을 것이다.
* 물론 H/W 주소이지만 변경은 가능하다. 그러므르 보안적으로 이슈가 될 수 있다.

{{&lt; figure src=&#34;/images/network/1-2.png&#34; title=&#34;MAC 주소 확인&#34; &gt;}}

확인을 하게 되면
E0-3F-49-AB-C8-AD
위와 같이 표시가 되며 절반으로 나누어 앞의 세부분은 생산자를 나타내고, 뒤의 세 부분은 장치의 일련번호(Host Identifier)을 나타낸다.

[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; MAC 제조회사 찾는 곳 ](https://regauth.standards.ieee.org/standards-ra-web/pub/view.html#registries)
{{&lt; figure src=&#34;/images/network/1-3.png&#34; title=&#34;제조회사 찾는 방법&#34; &gt;}}

### 1.2. ARP &amp; RARP &amp; GARP

ARP(Address Resolution Protofcol)는 IP주소를 MAC주소와 대응(Bind)시키기 위해 사용되는 프로토콜이다.
IP주소는 알지만 MAC주소를 모르는 경우 사용 할 수 있다.

윈도우에서 arp -a {IP} 로 확인 할 수 있다.
{{&lt; figure src=&#34;/images/network/1-4.png&#34; title=&#34;ARP 확인&#34; &gt;}}

RARP(Reverse Address Resolution Protocol)는 그 반대로 MAC주소로 IP를 대응(Bind)시키기 위해 사용되는 프로토콜이다.
MAC주소는 알지만 IP주소를 모르는 경우 사용 할 수 있다.

GARP(Gratuitous ARP)는 PC를 스위치에 연결을 하게 되면 나의 IP와 MAC은 이거라고 알리는대 사용한다. 3번정도 GARP를 보낸다. 그래서 IP 주소 충돌을 감지 할 수 있으며, GARP를 수신한 모든 호스트/라우터는 ARP Table을 갱신할 수 있다. 또 다른 목적은 VRRP/HSRP프로토콜에서 사용된다(VRRP/HSRP의 설명은 패스한다). 

ARP probe
ARP probe는 sender의 IP주소를 0으로 해서 ARP요청을 하며 IPv4 주소의 충돌을 감지 할 수 있다.

{{&lt; figure src=&#34;/images/network/1-6.png&#34; title=&#34;Probe 확인&#34; &gt;}}

ARP announcements
다른 호스트의 ARP 테이블을 갱신 할 수 있다.
{{&lt; figure src=&#34;/images/network/1-7.png&#34; title=&#34;Announcement 확인&#34; &gt;}}


### 1.3. L2 통신

| 기능 | 설명 | 기술 |
| ---- | ---- | ------------ | 
| learning  | 출발지 주소가 MAC 테이블에 주소가 없으면 MAC 주소를 저장 | MAC table |
| flooding  | 목적지 주소가 MAC 테이블에 없으면 전체 포트로 전달 | Broadcast |
| filtering | 출발지/목적지가 동일 네트워크에 있으면 다른 네트워크로 전파 차단 | Collision Domain |
| aging     | MAC 테이블 캐쉬 | Aging Time |

1. PC를 연결 하면 PC에서 PROBE를 3번 정도 보내고 Announcement 후 스위치 및 PC에서는 ARP를 Learning한다.
2. 만약 스위치 및 PC에서 arp table이 없으면 aging Time이 끝났거나 또는 GARP를 받지 못했을 경우 또는 ARP테이블이 갱신이 안될 경우, PC 1에서 PC 2로 통신을 할 때 Broadcast(flooding)를 보낸다. 이 때 스위치에서는 동일한 VLAN(Filtering)의 모든 포트로 (목적지 IP:ff:ff:ff:ff:ff) 브로드캐스트를 보낸다. 
3. PC2는 해당 브로드캐스트를 받고 반대로 PC1에게 전달을 하게 된다.
4. 스위치 및 PC는 해당 MAC Table에 저장한다. 그리고 스위치에서 연결된 PC에서 트래픽을 전달 한다.(Forwarding) 

{{&lt; figure src=&#34;/images/network/1-5.png&#34; title=&#34;L2 통신&#34; &gt;}}

## 2. L3

라우터에 Dynamic(RIP, EIGRP, OSPF, BGP) 또는 STATIC의 대한 설명은 하지 않는다.

Gateway를 적용 하면 아래와 같이 Gateway의 ARP를 얻기 위핸 Broadcast를 요청 하는 것을 확인 할 수 있다.

{{&lt; figure src=&#34;/images/network/1-8.png&#34; title=&#34;GATEWAY&#34; &gt;}}

동일한 대역의 경우 ARP가 각각의 Host에 등록이 되어 있거나 L2 스위치에 등록이 되어 있기 때문에 G/W가 필요 없다. G/W의 역할은 동일한 대역이 아닌 다른 대역과 통신 하기 위해 동일한 대역이 아닌 대역을 G/W에 물어보기 위해 존재 한다.

PC에서 라우팅 테이블을 확인 해 볼 수 있다.

route print 명령어를 통해 확인 해보자. 만약 피시에 Network Interface가 두개이고 목적지가 각각 다른 NIC으로 향해야 한다면. 
모든 목적지는 G/W로 지정을 하고 STATIC하게 라우팅을 2번 Interface로 테이블을 지정 할 수 있을 것이다. 그리고 만약 동일한 목적지로 라우팅이 잡혀 있다면 METRIC이 더 빠른쪽으로 라우팅을 한다는 것을 확인 할 수 있을 것이다.

{{&lt; figure src=&#34;/images/network/1-11.png&#34; title=&#34;route print&#34; &gt;}}

그리고 MAC주소는 라우터를 거치면서 바뀌게 된다. 아래에서 보듯이
실제 10.253.107.2의 MAC주소는 00:50:56:b0:f8:47 이지만 목적지 Host 10.253.126.25에서 확인하였을 때는 G/W인 10.253.126.1의 MAC주소로 바뀌어서 들어오는 것을 확인 할 수 있다. 

{{&lt; figure src=&#34;/images/network/1-12.png&#34; title=&#34;route print&#34; &gt;}}


## 3. L4

L3라우터의 경우 IP N/W을 통해 라우팅 경로(라우팅 경로라고 하면 G/W를 통해 봤듯이 자기가 모르는 대역을 다른 라우터에 물어보기 위한 것이라고 보면 된다. 이에 활용되는 것이 STATIC, RIP, EIGRP, OSPF. BGP가 있으며 하나 하나의 대한 기술적 내용은 기술 하지 않는다.)를 확보하는 반면. L4의 경우 Port까지 확인 한다. 이때부터 세션 베이스라고 보면 된다. 한마디로 라우터의 경우 2개의 물리적인 라우터가 있을 경우 A라는 라우터를 통해 들어온 트래픽이 B라는 트래픽을 통해 나가더라도 통신에 이슈가 발생 하지 않는다.

{{&lt; figure src=&#34;/images/network/1-9.png&#34; title=&#34;L3의 경우 Asymmetirc구조라도 상관 없음&#34; &gt;}}

하지만 L4 Layer이상의 경우 세션 베이스이기 때문에 자기가 가지고 있지 않은 정보가 들어오면 Drop을 한다. 그래서 동일한 경로로 통신을 해야 한다.

{{&lt; figure src=&#34;/images/network/1-10.png&#34; title=&#34;L4의 경우 Asymmetirc구조일 경우 Drop&#34; &gt;}}

또한 기술적으로 LoadBalancer의 경우 One-Arm구성 일 경우 어떻게 구성해야되는지의 대한 여러가지 방안들이 있지만 단순하게 어떻게 통신을 한다는지의 대한 내용만 적었다.. 마찬가지로 LoadBalancer의 경우 다양한 기술이 포함되어 있기 때문에 이렇게 되면 안됩니다. 라는 정도만 작성했다.


## 4. HTTPS 이야기
HTTPS는 공개키와 비공개키를 사용한다. 이유는 공개키는 비공개키보다 암/복호화 하는대 더 많은 트래픽이 필요 하기 때문에 공개키로 비공개키를 암호화하여 비공개키를 안전하게 전달 후 비공개키를 통해 데이터를 전달한다. 

{{&lt; figure src=&#34;/images/network/5-1.png&#34; title=&#34;HTTPS 이야기&#34; &gt;}}
{{&lt; figure src=&#34;/images/network/5-2.png&#34; title=&#34;HTTPS 이야기&#34; &gt;}}
{{&lt; figure src=&#34;/images/network/5-3.png&#34; title=&#34;HTTPS 이야기&#34; &gt;}}

1. 클라이언 헬로우 : &lt; sslversion, random number, cipersuites, session id 포함&gt;
   * ciphersuites 복수인 이유는 클라이언트에서 어떤 암호화 프로토콜이 있는지 서버에게 알려주게 된다.

2. 서버 헬로우 : &lt; sslversion, random number, ciphersuit, session id 포함 &gt;
   * 사이트의 ciphersuite 단수인데요. 이유는 클라이언트가 보내준 암호화중에 제일 암호화가 높은것으로 선택

3. 사용자의 웹브라우저에는 인증기관의 공개키가 이미 내장되어 있기 때문에 내장된 공개키로 인증서가 제대로된 인증서인지 판단   
   * 가끔 브라우저 버전이 낮으면 최신 인증기관의 정보가 없을 수 있다. 
   * 만약에 사설 인증서일 경우 인증된 인증서가 아닐 뿐 사아트에서는 공개키를 전달 했기 때문에 전달 받은 공개키로 대칭키를 암호화(Pre-Master-Secret) 한다.

4. 사용자는 사이트에서 얻은 공개키를 이용하여, PMS(Pre-Master-Secret)를 암호화
   * (Pre-Master-Secret)는 사용자가 Hello 보낼때 들어가있는 randomKey, 서버가 hello 할때 random key를 조합하여 만듦

5. 사이트는 자기의 개인키로 사용자가 공개키로 암호화한것을 복호화 하여 안에 들어있는 Pre-Master-Secret를 이용하여 사용자와 메시지를 주고 받음

6. Pre-Master-Secret는 master Secret을 만들고 master-Secret 은 세션키를 생성 이후 세션키 값을 이용하여 아까 했던 일련의 상황들을 모두 reuse를 하여 복잡한 방식을 모두 하지 않고 대칭키 방식으로 메시지를 주고 받습니다.



* 공인된 인증기관에서 발급 받은 인증서의 경우 기본적으로 인증서에는 공개키와 개인키가 포함되어 있기 때문에 이미 브라우저에 내장되어 있는 인증기관의 공개키로 복호화 하여 사이트가 인증기관에서 인증을 받은 사이트라는것을 검증 한다. 만약 사설 인증서인 경우 웹브라우저에서 검증되지 않는 사이트라고 나오며 * 이는 인증기관에서 인증되지 않는 사이트라는 것만 검사 할뿐 이를 무시를 하게 되면 서버에서는 이미 공개키를 전달 했기 때문에 해당 공개키를 가지고 대칭키를 암호화 하여 사이트에 전달을 하게 된다 그리고 사이트에는 개인키로 복호화 하여 대칭키를 획득 한 후 대칭키로 암/복호화를 하여 데이터를 주고 받게 된다.

## 5. 유저에서 웹서핑 까지
{{&lt; figure src=&#34;/images/network/6-1.png&#34; title=&#34;웹서핑&#34; &gt;}}

1. 사용자가 웹서핑을 하기 위해 브라우저에서 해당하는 DOMAIN을 입력한다. 예를 들어 www.naver.com을 입력하게 되면 최초로 LDNS에게 요청하게 된다. LDNS는 자기가 잡은 DNS를 LDSN라고 한다.

2. LDSN에서는 해당 도메인의 ROOT DNS에 쿼리를 날린다. 

3. ROOT DNS는 하위 DNS인 .COM의 IP를 응답해준다.

4. .COM의 DNS는 하위 DNS인 naver.com의 DNS의 IP를 응답해준다.

5. naver.com은 실제적으로 www.naver.com의 A 레코드를 가지고 있으면 LDNS에게 응답을 해주고 LDNS는 최종적으로 사용자에게 www.naver.com의 IP를 알려주게 된다. 

---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/networks/  

