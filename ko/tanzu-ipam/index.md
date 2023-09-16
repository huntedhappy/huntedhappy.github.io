# The Documentation IPAM on TANZU


# 1.  IPAM ON TANZU 
탄주는 기본적으로 DHCP 서버가 필요 하다. K8S 환경을 유지 하기 위해 VM의 라이프 사이클을 제공 하고 있기 때문이다. 그렇기 때문에 VM에 HANG이 걸리거나, 삭제가 되면 자동적으로 복구를 하게 된다. K8S에서 POD를 관리 하는 것처럼 탄주는 Master, Worker Node를 하나의 POD로 인식을 하게 설계를 한게 아닌가 싶다. 하지만 이런 자동화 시스템으로 인하여 STATIC하게 IP를 넣을 수도 없으며(DHCP서버를 통해 배포 후 IP를 변경 할 수 있겠지만 권장 하지 않는다.) 무조건적으로 DHCP 서버가 필요 하기 때문에 설치시 많은 어려움이 있을 수 있다. 또한 DHCP 서버를 운영 함으로 인해서 불필요한 자원을 사용하게 될 수도 있다. 

지금 작성 하는 부분은 DHCP서버를 완전히 배제 할 수는 없다. 다만 메니저 클러스터를 배포 한 후 CLUSTER의 IP는 관리 클러스터에서 관리를 할 수 있게 설정을 할 수 있다. 두가지 방법이 있을 수 있는대 처음은 YTT를 구성함으로 인해서 처음부터 클러스터가 배포 될 경우 IP를 할당 받을 수 있게 할 수 도 있으며, 두번째로는 클러스터를 DHCP서버를 배포 후 IPAM을 사용하게 구성 할 수 있다. 

당연히 YTT로 구성을 하여서 처음부터 배포를 하는 것이 권장을 할 것이다. 하지만 한편으로는 걱정도 된다. 이렇게 구성 함으로 인해서 업그레이드가 잘 될지.. (추후에 업그레이드도 진행을 해봐야 할 것이다...)

현재 작성하는 방법은 2번째 방법으로 진행 할 예정이다. 
방법은 간단하다. 우선 metal3-io가 무엇을 하는지는 알지 못하지만 해당 github에서 제공을 받아 설치를 해볼 수 있을 것이다.

아래와 같이 GIT을 다운로드 받은 후 간단하게 실행을 해준다.

```shell
git clone https://github.com/arbhoj/vsphere-ipam.git
kubectl apply -f vsphere-ipam/metal3ipam/provider-components/infrastructure-components.yaml
kubectl apply -f vsphere-ipam/spectro-ipam-adapter/install.yaml
```

그리고 아래와 같이 환경 변수를 적용해도 되고, 그냥 입력을 해도 된다. 편한대로 설정을 해보자
```shell
export CLUSTER_NAME=run2
export NETWORK_NAME=LS-TKGM01-WORKLOAD-10.253.127.x #This is the name of the network to be used in vSphere
export START_IP=10.253.127.120
export END_IP=10.253.127.130
export CIDR=24
export GATEWAY=10.253.127.1
export DNS_SERVER=10.253.107.2
```

위와 같이 환경변수를 적용 후 ippol을 실행 해주자.

```shell
cat << EOF | kubectl apply -f -
apiVersion: ipam.metal3.io/v1alpha1
kind: IPPool
metadata:
  name: ${CLUSTER_NAME}-pool
  labels:
    cluster.x-k8s.io/network-name: ${NETWORK_NAME}
spec:
  clusterName: ${CLUSTER_NAME}
  namePrefix: ${CLUSTER_NAME}-prov
  pools:
    - start: ${START_IP}
      end: ${END_IP}
      prefix: ${CIDR}
      gateway: ${GATEWAY}
  prefix: 24
  gateway: ${GATEWAY}
  dnsServers: [${DNS_SERVER}]
EOF
```

그리고 machine에다가 lables을 붙여주어야 한다. 지금 해도 되고 새로 생성 할 때 해도 된다.
```shell
kubectl label vspheremachinetemplates run2-control-plane cluster.x-k8s.io/ip-pool-name=run2-pool
kubectl label vspheremachinetemplates run2-worker cluster.x-k8s.io/ip-pool-name=run2-pool
```

이렇게 구성을 하였다고 하더라도 실제적으로 vspheremachinetemplates 여기에 수정을 할 수가 없기 때문에 별도로 새로 생성을 해야 한다. 아마 이 부분은 vmsizing을 변경 할 때 많이 봤을 수도 있다. vmsizing은 이렇게 변경도 가능하지만 왠만하면 nodepool을 사용하여서 변경하는게 좋지 않을가 하는 생각을 잠시 한다.

아래와 같이 주석 처리 한부분을 추가 및 변경을 해준다.
```shell
kubectl get VSphereMachineTemplate run2-control-plane -o yaml | kubectl neat > run2-control-plane.yaml

vi run2-control-plan.yaml
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: VSphereMachineTemplate
metadata:
  annotations:
    vmTemplateMoid: vm-134165
  labels:
    cluster.x-k8s.io/ip-pool-name: run2-pool   ## ippool이랑 name 일치 하는지 확인
  name: run2-control-plane01
  namespace: default
spec:
  template:
    spec:
      cloneMode: fullClone
      datacenter: /OBDC
      datastore: /OBDC/datastore/vsanDatastore
      diskGiB: 300
      folder: /OBDC/vm/tanzu
      memoryMiB: 8192
      network:
        devices:
        - dhcp4: false   #### 변경
          networkName: /OBDC/network/LS-TKGM01-WORKLOAD-10.253.127.x
      numCPUs: 4
      resourcePool: /OBDC/host/OBCLUSTER/Resources/dk-tanzu
      server: vcsa01.vcf.local
      storagePolicyName: k8s
      template: /OBDC/vm/temp/photon-3-kube-v1.24.10+vmware.1

kubectl apply -f run2-control-plan.yaml
```

마찬가지로 worker노드도 템플릿을 생성 해준다.
```shell

kubectl get VSphereMachineTemplate run2-worker -o yaml | kubectl neat > run2-worker.yaml
vi run2-worker.yaml
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: VSphereMachineTemplate
metadata:
  annotations:
    vmTemplateMoid: vm-134165
  labels:
    cluster.x-k8s.io/ip-pool-name: run2-pool    ## ippool이랑 name 일치 하는지 확인
  name: run2-worker01
  namespace: default
spec:
  template:
    spec:
      cloneMode: fullClone
      datacenter: /OBDC
      datastore: /OBDC/datastore/vsanDatastore
      diskGiB: 300
      folder: /OBDC/vm/tanzu
      memoryMiB: 16384
      network:
        devices:
        - dhcp4: false    #### 변경
          networkName: /OBDC/network/LS-TKGM01-WORKLOAD-10.253.127.x
      numCPUs: 4
      resourcePool: /OBDC/host/OBCLUSTER/Resources/dk-tanzu
      server: vcsa01.vcf.local
      storagePolicyName: k8s
      template: /OBDC/vm/temp/photon-3-kube-v1.24.10+vmware.1

kubectl apply -f run2-worker.yaml
```

이렇게 구성을 하게 되면 준비는 다 된것이다. 이제 master, worker node의 template만 변경 하게 되면 된다.
```sheel
kubectl patch md run2-md-0 --type 'json' -p '[{"op":"replace","path":"/spec/template/spec/infrastructureRef/name","value":"run2-worker01"}]' --dry-run=client -o yaml | kubectl apply -f -
kubectl patch kcp run2-control-plane --type 'json' -p '[{"op":"replace","path":"/spec/machineTemplate/infrastructureRef/name","value":"run2-control-plane01"}]' --dry-run=client -o yaml | kubectl apply - f-
```

이렇게 변경을 하게 되면 자동적으로 VM이 삭제 하고 재 생성 되는 것을 확인 할 수 있다.

그러면 IPPOOL에서 제대로 받아 오는지 확인을 해볼 수 있을 것이다.

```shell
kubectl describe ippools.ipam.metal3.io run2-pool

Status:
  Indexes:
    run2:                        10.253.127.121
    run2-control-plane-wnng6-0:  10.253.127.124
    run2-worker-hcmw8-0:         10.253.127.120
    run2-worker-sgbmb-0:         10.253.127.122
    run2-worker-sjf5m-0:         10.253.127.123

```

DHCP서버를 완전히 안사용하게 할 수는 없겠지만 이 방법으로 어느정도 DHCP서버를 대체 할 수 있지 않을까라는 조심스러운 생각을 해본다.

