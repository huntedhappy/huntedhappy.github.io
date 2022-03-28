# The Documentation VxRail


VxRail은 전체 스택 무결성 및 포괄적인 수명주기 관리로 비즈니스 변화에 신속하게 대응하는 인프라스트럭처를 제공하여 운영 효율성을 높이고, 위험을 줄이며, 팀이 비즈니스에 집중할 수 있도록 지원합니다.

## PreConfig
### DNS 구성
| Component Name  | BaseDomain | A Record |
| --------------- | ---------- | -------- |
| vcsa01 | vxrail.local | 192.168.215.10 |
| vxmgr  | vxrail.local | 192.168.215.9 |
| esxi01 | vxrail.local | 192.168.215.11 |
| esxi02 | vxrail.local | 192.168.215.12 |
| esxi03 | vxrail.local | 192.168.215.13 |
| esxi04 | vxrail.local | 192.168.215.14 |

### Default Passwqord
| Component Name  | Networking Configuration | Username | Default Password |
| --------------- | ---------- | -------- |  -------- |
| BIOS  | N/A | 192.168.215.10 | | |
| iDRAC | DHCP | 192.168.215.9 | root | calvin |
| ESXi  | DHCP | 192.168.215.11 | root | Passw0rd! |
| vCenter Server Applicance | root | vmware |
| VxRail Manager | 192.168.10.200 | root |Passw0rd! |
| VxRail Manager | 192.168.10.200 | mystic | VxRailManager@201602! |

## 1. RASR을 통해 초기화

기본적으로 VxRail장비가 입고가 되면 기본 이미지로 부팅이 되며 라이센스가 있을 경우 업그레이드를 할 수 있다. 
1. 초기화를 하는 이유는 테스트 위해 60일 EVALUATION을 재사용하려면 RASR을 통해 공장 초기화를 해야 한다. 
2. 기존의 VxRail을 구성한 상태에서 증설을 위해 추가로 구성을 하게 될경우 기본 들어오는 버전이 낮거나 높을 수 있다. 이럴 경우 RASR을 통해 펌웨어, 이미지를 업그레이드 또는 다운그레이드를 통해 증설을 할 수 있다.
3. 기본 설치되어 있는 VxRail이 테스트 하고자 하는 버전 보다 낮거나 또는 높거나 할 경우 변경을 할 수 있다.

{{< admonition tip "초기화 방법" >}}

> 1. USB
> * 장비 모든 부분의 버전을 업그레이드 및 다운그레이가 필요 할 경우 USB 방법사용, 또한 설치가 제일 빠름

> 2. Virtual Media
> * iDRAC의 Virtual Media를 통해 설치 하는 방법 부분적 설치만 가능 (Firmware 등등 업그레이드 또는 다운그레이드 못함) 또한 설치가 느림
{{< /admonition >}}

USB를 연결 한 후 iDRAC에서 Local SD Card로 부팅
{{< figure src="/images/vxrail/1-1.png" title="USB 설치#1" >}}
{{< figure src="/images/vxrail/1-2.png" title="USB 설치#2" >}}

Advancde 항목으로 접근 
{{< figure src="/images/vxrail/1-3.png" title="Advanced" >}}

Install DUP(s)
펌웨어 등 업그레이드 및 다운그레이드할 내용이 있는지 확인이 필요
{{< figure src="/images/vxrail/1-4.png" title="Install DUP(s)#1" >}}

업그레이드 / 다운그레이드를 선택 후 업그레이드가 있는지 다운그레이드가 있는지 체크 후 있으면 설치
{{< figure src="/images/vxrail/1-5.png" title="Install DUP(s)#2" >}}

진행 시 재부팅이 여러번 발생 대략 30분 ~ 1시간 소요
{{< figure src="/images/vxrail/1-6.png" title="Install DUP(s)#3" >}}

DUP를 업그레이드 또는 다운그레이드 이후 [F]actory Reset 실행 (1시간 소요)

## 2. ESXI 초기 설정
{{< figure src="/images/vxrail/2-1.png" title="ESXI#1" >}}
ESXi Shell Enable을 통해 콘솔 접속
{{< figure src="/images/vxrail/2-2.png" title="ESXI#2" >}}
esxcli vm process list 명령어를 VxRail Manager가 보이는 호스트를 찾는다.
아무곳에서나 해도 되지만. 시간이 오래 걸린다.
{{< figure src="/images/vxrail/2-3.png" title="ESXI#3" >}}

기본 디폴트 IP는 192.168.10.200이므로 통신이 된다면 VxRail Manager VM을 켜고 접속 하면 된다. 
만약 VLAN 또는 ESXI에 접근을 하고 싶으면 명령어로 VLAN 또는 IP를 설정 할 수 있다 또는 VM을 킬 수도 있다.
여기에서는 여러가지 방법을 설명하지는 않겠다. 기본 디폴트 IP와 변경하고자 하는 IP 둘다 통신이 되면 된다.

여러가지 방법론이 있겠지만, 신경을 쓰고 싶지 않다면 DEFAULT IP와 변경하고자 하는 IP 둘다 통신이 되는 것으로 테스트를 하면 좋을 것이다.

VLAN 3939가 실제적으로 Discovery를 하는 부분으로 스위치에서 3939설정을 해주면 나중에 호스트 증설을 할때 별도로 신경을 쓰지 않아도 된다. 

{{< admonition tip "명령어" >}}
```shell
esxcli network vswitch standard portgroup list
esxcli network vswitch standard portgroup set -p "Private Management Network" -v 0
esxcli network ip interface list
esxcli network ip interface ipv4 set -i vmk2 -I 192.168.215.13 -N 255.255.255.0 -g 192.168.215.1 -t static
```
VxRail Manager IP 변경 방법
```shell
vxrail-primary --setup --vxrail-address 192.168.215.9 --vxrail-netmask 255.255.255.0 --vxrail-gateway 192.168.215.1 --no-roll-back --verbose
```
{{< /admonition >}}


## 3. INIT
원하는 언어를 선택 할 수 있다.
{{< figure src="/images/vxrail/3-1.png" title="INIT#1" >}}
{{< figure src="/images/vxrail/3-2.png" title="INIT#2" >}}

Standrad Cluster (3 or more hosts)는 3개이상의 VSAN 구성
VSAN 2-Node Cluster (2 hosts only) witness host 필요
Dynamic Node Cluster (2 or more hosts) VSAN 구성이 아닌 외부 스토리지로 구성 할 경우
{{< figure src="/images/vxrail/3-3.png" title="INIT#3" >}}
설치가 잘 되었다면 아래와 같이 자동으로 Discovery가 됨
{{< figure src="/images/vxrail/3-4.png" title="INIT#4" >}}
{{< figure src="/images/vxrail/3-5.png" title="INIT#5" >}}

JSON파일로 구성이 다 되어 있다면 JSON을 삽입 해도 되지만 없으면 Step-by-step으로 진행
{{< figure src="/images/vxrail/3-6.png" title="INIT#6" >}}

{{< figure src="/images/vxrail/3-7.png" title="INIT#7" >}}
{{< figure src="/images/vxrail/3-8.png" title="INIT#8" >}}
{{< figure src="/images/vxrail/3-9.png" title="INIT#9" >}}
{{< figure src="/images/vxrail/3-10.png" title="INIT#10" >}}
{{< figure src="/images/vxrail/3-11.png" title="INIT#11" >}}
{{< figure src="/images/vxrail/3-12.png" title="INIT#12" >}}

나중을 위해서 JSON파일을 다운로드 받을 수 있다.
{{< figure src="/images/vxrail/3-13.png" title="INIT#13" >}}
{{< figure src="/images/vxrail/3-14.png" title="INIT#14" >}}
{{< figure src="/images/vxrail/3-15.png" title="INIT#15" >}}
{{< figure src="/images/vxrail/3-16.png" title="INIT#16" >}}

## 4. HOST ADD
만약 기존 구성된 클러스터와 다른 버전이 설치되어 있는 호스트라면 RSAR 초기화 필요

호스트를 추가 할 때 Host DISCOVERY가 되지 않으면 loudmouth restart를 해준다.

{{< figure src="/images/vxrail/4-1.png" title="HOST ADD#1" >}}
{{< figure src="/images/vxrail/4-2.png" title="HOST ADD#2" >}}
{{< figure src="/images/vxrail/4-3.png" title="HOST ADD#3" >}}
{{< figure src="/images/vxrail/4-4.png" title="HOST ADD#4" >}}
{{< figure src="/images/vxrail/4-5.png" title="HOST ADD#5" >}}
{{< figure src="/images/vxrail/4-6.png" title="HOST ADD#6" >}}
{{< figure src="/images/vxrail/4-7.png" title="HOST ADD#7" >}}
{{< figure src="/images/vxrail/4-8.png" title="HOST ADD#8" >}}
{{< figure src="/images/vxrail/4-9.png" title="HOST ADD#9" >}}
{{< figure src="/images/vxrail/4-10.png" title="HOST ADD#10" >}}

HOST ADD 시 HOST가 DISCOVERY되지 않는다면 loudmouth를 리스타트 해준다.
{{< figure src="/images/vxrail/4-11.png" title="HOST ADD#11" >}}

## 5. UPGRADE

{{< figure src="/images/vxrail/5-1.png" title="UPGRADE#1" >}}
{{< figure src="/images/vxrail/5-2.png" title="UPGRADE#2" >}}
{{< figure src="/images/vxrail/5-3.png" title="UPGRADE#3" >}}
{{< figure src="/images/vxrail/5-4.png" title="UPGRADE#4" >}}
{{< figure src="/images/vxrail/5-5.png" title="UPGRADE#5" >}}
{{< figure src="/images/vxrail/5-6.png" title="UPGRADE#6" >}}
{{< figure src="/images/vxrail/5-7.png" title="UPGRADE#7" >}}
{{< figure src="/images/vxrail/5-8.png" title="UPGRADE#8" >}}
{{< figure src="/images/vxrail/5-9.png" title="UPGRADE#9" >}}
{{< figure src="/images/vxrail/5-10.png" title="UPGRADE#10" >}}

## 6. VxRail BackUP

백업 스케줄 설정 가능

VxRail 접속
```shell
## 백업 리스트 확인
cd /mystic/vxm_backup_restore
python vxm_backup_restore.py -l

## 메뉴얼 백업
python vxm_backup_restore.py -b
```

{{< figure src="/images/vxrail/6-1.png" title="스케쥴 백업" >}}
{{< figure src="/images/vxrail/6-2.png" title="메뉴얼 백업" >}}
{{< figure src="/images/vxrail/6-3.png" title="백업 리스트 확인" >}}

## 6. VxRail Recovery
VxRail Manager가 망가졌을 경우 사용 가능

백업이 없으면 의미 없음

VxRail OVA 이미지 필요

```shell
## 신규 설치한 vxrail manager 접속 후 IP 변경
/opt/vmware/share/vami/vami_set_network eth0 STATICV4 192.168.215.9 255.255.255.0 192.168.215.1

## Backup 확인
cd /mystic/vxm_backup_restore
python vxm_backup_restore.py -l

## Recovery 실행
python vxm_backup_restore.py -r –-vcenter 192.168.215.10
```

