# The Documentation K8s


아래 내용을 작성 하는 이유
같이 일했던 동료가 다른 곳으로 회사를 이직 하고 나서 컨테이너를 해야 되는거 같았다. 같이 일을 했기 때문에 L4 / L7을 잘 했던 친구 였다. 그런대 뜬금없이 L4를 연동 하면 어떻게 컨테이너로 트래픽을 전달하냐라고 물어본적이 있었다. 
그래서 혹시 모르는 사람을 위해서 간략하게 적어 내려 간다.

## 1. Service Type
컨테이너를 하기 위해서는 우선 Deploy , STS등으로 Pod를 생성한다. 그럼 일반적으로 테스트를 하기 위해서 아래와 같이 명령어를 칠 것이다.

* kubectl create deploy nginx --image=nginx -n nginx

그러면 deploy를 통해 pod가 생성 된 것을 확인 할 수 있다. 그리고 나서 서비스를 연동 할 것이다. 그럼 아래와 같은 명령어를 칠 것이다.

*  kubectl expose deploy nginx --port=80 --target-port=80 --type=ClusterIP -n nginx

ClusterIP는 그럼 아래와 같은 정보를 보게 될 것이다.

{{&lt; figure src=&#34;/images/k8s/1-1.png&#34; title=&#34;svc ClusterIP상태&#34; &gt;}}

NodePort는 아래처럼 정보를 보게 된다.

* kubectl expose deploy nginx --port=80 --target-port=80 --type=NodePort -n nginx

{{&lt; figure src=&#34;/images/k8s/1-2.png&#34; title=&#34;svc NodePort상태&#34; &gt;}}


그럼 보는바와 같이 차이가 좀 있는 것을 알 수 있다.
NodePort를 하게 될 경우 아래와 같이 30000대의 Port를 확인 할 수 있을 것이다. 

## L4연동 후 NodePort
그럼 만약에 L4장비와 연결을 하게 되면 어떻게 보이게 될까? 아래 그림으로 한번 확인을 해보자

* kubectl expose deploy nginx --port=80 --target-port=80 --type=LoadBalancer -n nginx

{{&lt; figure src=&#34;/images/k8s/1-3.png&#34; title=&#34;svc LoadBalancer상태#1&#34; &gt;}}

{{&lt; figure src=&#34;/images/k8s/1-4.png&#34; title=&#34;svc LoadBalancer상태#2&#34; &gt;}}

위에 AVI에 설정된 서버가 실제적인 K8S의 Node인것을 확인 할 수 있다.

{{&lt; figure src=&#34;/images/k8s/1-5.png&#34; title=&#34;svc LoadBalancer상태#3&#34; &gt;}}

보는 것과 같이 실제 노드IP에 32676번 (30000번대의 포트를 할당 받음) 포트가 연동 되어 있는것을 확인 할 수 있다.

그럼 실제적으로 클라이언트가 접속을 하게 되면 Node:Port(32767)의 연결된 노드로 트래픽이 가게 되고 노드는 트래픽이 들어오면 해당하는 EndPoint로 접속 하게 되는 것이다.

* Source &gt; L4 &gt; Node:Port &gt; Container

그럼 아래와 같이 SVC와 그의 대한 Endpoint가 어떻게 연결되어 있는지 알 수 있다.
{{&lt; figure src=&#34;/images/k8s/1-6.png&#34; title=&#34;svc LoadBalancer상태#4&#34; &gt;}}

아래와 같이 접속이 되는 것을 확인 할 수 있다.
{{&lt; figure src=&#34;/images/k8s/1-7.png&#34; title=&#34;svc LoadBalancer상태#5&#34; &gt;}}

## L4연동 후 ClusterIP
그런대 여기서 의문점이 들 것이다. 그럼 ClusterIP는 지원이 안되는건가? 그건 연동하는 L4에서 지원을 하면 가능 하다. 그럼 어떻게 나오는지 한번 확인 해보자.

특별하게 설정 할 것은 없고, AVI를 NodePort를 지원하는 것에서 ClusterIP로 변경 후 상태를 확인 해보면 실제 Pod의 IP로 맵핑이 된 것을 확인 할 수 있다.
{{&lt; figure src=&#34;/images/k8s/1-8.png&#34; title=&#34;svc LoadBalancer상태#6&#34; &gt;}}

## 결과
위에서 보듯이 NodePort와 ClusterIP의 차이점을 확인해 볼 수 있을 거 같다.

---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/ko/k8s/  

