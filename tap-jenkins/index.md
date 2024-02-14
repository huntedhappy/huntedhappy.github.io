# The Documentation TAP &amp; JENKINS


## Out of the Box Supply Chain with testing on Jenkins for Supply Chain Choreographer

기본적으로 TAP에서는 TEKTON을 사용하여 Source Testing을 제공 하고 있다. 하지만 별도로 Jenkins를 연동 해서 Source Testing을 진행 해보고 싶어 할 수 도 있을 거 같다. 

그래서 TAP에서는 Jenkins와 연동을 제공 하고 있다.

[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; with jenkins](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/scc-ootb-supply-chain-testing-with-jenkins.html)

사전구성으로 Build Cluster에 Out of the Box Supply Chain With Testing or Out of the Box Supply Chain With Testing and Scanning로 supply_chain 구성이 필요 하다.

사전에 Jenkins의 정보를 넣기 위해 Secret을 생성 해 준다.
```shell
cat &lt;&lt; EOF | kubectl apply -f - -n tap-install
apiVersion: v1
kind: Secret
metadata:
  name: MY-SECRET # secret name that will be referenced by the workload
type: Opaque
stringData:
  url: JENKINS-URL # target jenkins instance url
  username: USERNAME # jenkins username
  password: PASSWORD # jenkins password
  ca-cert: (Optional) PEM-CA-CERT # PEM encoded certificate
EOF
```
그리고 Out of the Box Jenkins를 사용하기 위해 Jenkin pipeline을 설정이 필요 합니다.

```shell
cat &lt;&lt;EOF | kubectl apply -f -
---
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: developer-defined-jenkins-tekton-pipeline
  namespace: developer-namespace
  labels:
    #! This label should be provided to the Workload so that
    #! the supply chain can find this pipeline
    apps.tanzu.vmware.com/pipeline: jenkins-pipeline
spec:
  results:
  - name: jenkins-job-url   #! To show the job URL on the
    #! Tanzu Application Platform GUI
    value: $(tasks.jenkins-task.results.jenkins-job-url)
  params:
  - name: source-url        #! Required
  - name: source-revision   #! Required
  - name: secret-name       #! Required
  - name: job-name          #! Required
  - name: job-params        #! Required
  tasks:
  #! Required: Include the built-in task that triggers the
  #! given job in Jenkins
  - name: jenkins-task
    taskRef:
      name: jenkins-task
      kind: ClusterTask
    params:
      - name: source-url
        value: $(params.source-url)
      - name: source-revision
        value: $(params.source-revision)
      - name: secret-name
        value: $(params.secret-name)
      - name: job-name
        value: $(params.job-name)
      - name: job-params
        value: $(params.job-params)
EOF 
```

Tekton pipeline은 아래와 같이 이루어 져 있다.

개발자는 아래와 같이 매개변수를 사용하여 Tekton pipeline을 생성 해야 합니다.

- source-url, required: 테스트 중인 모든 소스 코드가 포함된 소스 형상관리의 주소를 작성
- source-revision, required: Branch명을 넣어 주면 된다.
- secret-name, required: Jenkins의 사용자 이름, 암호, 인증서(선택사항)가 포함된 Secret Name
- job-name, required: Jenkins에 설정한 Pipeline의 이름과 일치
- job-params, required: Workload에 작성 한 JSON 문자열로 인코딩된 키-값 쌍 목록 
   ** 여기에 작성 한 값이 JENKINS에 전달해야 되는거 같은대 안되는 거 같다. 개인적인 생각. 이렇게 동작하라고 사용 하는거 같은대.. 실제로 동작하지 않아 보임.
Tasks:
- jenkins-task, required: 설정된 ClusterTask중 Jenkins작업을 트리거 하기 위해 실행, kubeclt get clustertask로 이름을 확인 할 수 있다.

그리고 아래와 같이 Jenkinsfile을 생성 해준다.
```shell
cat &lt;&lt;EOF | kubectl apply -f -
#!/bin/env groovy

pipeline {
  agent {
    // Use an agent that is appropriate 
    // for your Jenkins installation. 
    // This is only an example
    kubernetes { 
      label &#39;maven&#39;
    }
  }

  stages {
    stage(&#39;Checkout code&#39;) {
      steps {
        script {
          sourceUrl = params.SOURCE_REVISION
          indexSlash = sourceUrl.indexOf(&#34;/&#34;)
          revision = sourceUrl.substring(indexSlash &#43; 1)
        }
        sh &#34;git clone ${params.GIT_URL} target&#34;
        dir(&#34;target&#34;) {
          sh &#34;git checkout ${revision}&#34;
        }
      }
    }

    stage(&#39;Maven test&#39;) {
      steps {
        container(&#39;maven&#39;) {
          dir(&#34;target&#34;) {
            // Example tests with maven
            sh &#34;mvn clean test --no-transfer-progress&#34;
          }
        }
      }
    }
  }
}
EOF 
```

다음 필드는 Jenkins 작업 정의에도 필요합니다.

- SOURCE_REVISION string
- GIT_URL string

Jenkins에 파라미터를 제공하기 위해 GIT_URL을 작성 해준다. 

** 현재 1.5.2 까지 GIT_URL 및 GIT_REVISION이 JENKINS로 전달 되지 않는 것으로 보인다. 하여 Jenkins파일에 파라미터를 추가를 해주어야 한다.

이렇게 설정 한 후에 Workload를 실행을 하게 되면 실제적으로 Jenkins를 통해 소스테스트가 이루어지는 것을 확인 할 수 있다.
```shell
cat &lt;&lt; &#39;EOF&#39; | kubectl -n tap-install apply -f - --context $b
kind: Workload
metadata:
  labels:
    app.kubernetes.io/part-of: jenkins-tanzu-java-web-app
    apps.tanzu.vmware.com/has-tests: &#34;true&#34;
    apps.tanzu.vmware.com/workload-type: web
    tanzu.app.live.view: &#34;true&#34;
    tanzu.app.live.view.application.name: jenkins-tanzu-java-web-app
  name: jenkins-tanzu-java-web-app
spec:
  build:
    env:
    - name: BP_JVM_VERSION
      value: 17.*
  env:
  - name: JAVA_TOOL_OPTIONS
    value: &gt;-
      -Dserver.port=8080
      -XX:MaxMetaspaceSize=589794K
      -XX:MaxDirectMemorySize=400M
      -XX:ReservedCodeCacheSize=240M
      -Dmanagement.endpoints.web.exposure.include=*
      -Dmanagement.endpoint.health.show-details=always
  params:
  - name: testing_pipeline_matching_labels
    value:
      apps.tanzu.vmware.com/pipeline: jenkins-pipeline
  - name: testing_pipeline_params
    value:
      job-name: tap-jenkins
#      job-params: &#34;[{\&#34;name\&#34;:\&#34;GIT_URL\&#34;, \&#34;value\&#34;:\&#34;https://gitlab.huntedhappy.kro.kr/tanzu/jenkins-tanzu-java-web-app/\&#34;}, {\&#34;name\&#34;:\&#34;GIT_BRANCH\&#34;, \&#34;value\&#34;:\&#34;main\&#34;}]&#34;
      job-params:
      - name: GIT_URL
        value: https://gitlab.huntedhappy.kro.kr/tanzu/jenkins-tanzu-java-web-app
        name: GIT_BRANCH
        value: main
      secret-name: jenkins
  - name: scanning_source_policy
    value: sample-scan-policy
  - name: scanning_image_policy
    value: sample-scan-policy
  - name: gitops_server_address
    value: https://gitlab.huntedhappy.kro.kr
  - name: gitops_repository_name
    value: jenkins-tanzu-java-web-app-gitops
  - name: gitops_repository_owner
    value: tanzu
  - name: gitops_branch
    value: main
  - name: gitops_user_name
    value: tanzu
  - name: gitops_user_email
    value: my1208@openbase.co.kr
  - name: gitops_commit_message
    value: test_giops
  - name: gitops_ssh_secret
    value: git-https
  - name: gitops_server_kind
    value: gitlab
  - name: gitops_commit_branch
    value: &#34;staging&#34;
  - name: gitops_pull_request_title
    value: &#34;ready for review&#34;
  - name: gitops_pull_request_body
    value: &#34;generated by supply chain&#34;
  - name: debug
    value: &#34;true&#34;
  resources:
    requests:
      cpu: 300m
      memory: 500Mi
  source:
    git:
      ref:
       branch: main
      url: https://gitlab.huntedhappy.kro.kr/tanzu/jenkins-tanzu-java-web-app
EOF
```
## RESULT
{{&lt; figure src=&#34;/images/tap-jenkins/1-1.png&#34; title=&#34;Jenkins에서 확인&#34; &gt;}}
{{&lt; figure src=&#34;/images/tap-jenkins/1-2.png&#34; title=&#34;TAP에서 Jenkins를 통해 배포 확인&#34; &gt;}}

---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/tap-jenkins/  

