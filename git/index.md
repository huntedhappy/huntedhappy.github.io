# The Documentation GitLab


## 1. GitLab 접속 유저별 아키텍쳐
GitLab은 1000명 2000명 3000명 4000명 5000명 10,000명 25,000명 50,000명 구성을 제공하고 있다. 여기서는 2000명정도 유저가 있을 경우 GIT을 배포 하는 방법에 대해서 설명하고자 한다.


2000 유저 구조에서는 고가용성을 제공하고 있지 않기 때문에 모든 Components에 대해서 고가용성을 가져가고 싶다면 3000 유저 이상의 구조로 가져가면 좋을거 같다.
그래도 고가용성이 필요하고 3000 유저의 아키텍쳐가 부담이라면 [3K 아키텍처](https://docs.gitlab.com/ee/administration/reference_architectures/3k_users.html#supported-modifications-for-lower-user-counts-ha)를 축소된 고가용성으로 구성 할 수 있다. 

여기서는 2000 유저의 대한 GitLab Install을 설정 할 예정이다.

구성도는 GitLab에서 아래와 같이 제공 하고 있다. 

{{&lt; figure src=&#34;/images/GitLab/1-1.png&#34; title=&#34;구성도&#34; &gt;}}

&gt; * Target Load: API: 40 RPS, Web: 4 RPS, Git (Pull): 4 RPS, Git (Push): 1 RPS
&gt; * High Availability: No. For a highly-available environment, you can follow a modified 3K reference architecture.
&gt; * Estimated Costs: See cost table
&gt; * Cloud Native Hybrid: Yes
&gt; * Unsure which Reference Architecture to use? Go to this guide for more info.

|     Service     | Nodes   | Configuration          | GCP            | AWS        | AZURE  |
| --------------- | :-----: | -------------          | ---            | ---        | -----  |
| Load balancer3  |	  1     | 2 vCPU, 1.8 GB memory  |	n1-highcpu-2  |	c5.large   | F2s v2 |
| PostgreSQL1 	  |   1     | 2 vCPU, 7.5 GB memory  | 	n1-standard-2 | m5.large   | D2s v3 |
| Redis2 	      |   1     | 1 vCPU, 3.75 GB memory | 	n1-standard-1 | m5.large   | D2s v3 |
| Gitaly5 	      |   1     | 4 vCPU, 15 GB memory5  |	n1-standard-4 | m5.xlarge  | D4s v3 |
| Sidekiq6 	      |   1     | 4 vCPU, 15 GB memory   |	n1-standard-4 | m5.xlarge  | D4s v3 |
| GitLab Rails6   |   2     | 8 vCPU, 7.2 GB memory  | 	n1-highcpu-8  |	c5.2xlarge | F8s v2 |
| Monitoring node |   1	    | 2 vCPU, 1.8 GB memory  | 	n1-highcpu-2  |	c5.large   | F2s v2 |
| Object storage4 |   -     | - 	                 |-               |	-          |	-   |


{{&lt; figure src=&#34;/images/GitLab/1-2.png&#34; title=&#34;FLOW&#34; &gt;}}

|     Service     | Platform   | IP                             |
| --------------- | :-----:    | -------------                  |
| Load balancer3  |	  AVI      | AVI Clustering                 |
| PostgreSQL1 	  |   UBUNTU   | 10.253.126.123                 |
| Redis2 	      |   UBUNTU   | 10.253.126.120                 |
| Gitaly5 	      |   UBUNTU   | 10.253.126.129                 |
| Sidekiq6 	      |   UBUNTU   | 10.253.126.132,10.253.126.133  |
| GitLab Rails6   |   UBUNTU   | 10.253.126.132,10.253.126.133  |
| Object storage4 |   MINIO(UBUNTU)    | MINIO Clustring                |

위와 같이 설정.

* #### POSTGRESQL을 아래와 같이 설정 한다.
```shell
## postgresql에 사용할 패스워드를 hsah로 생성 한다.
sudo gitlab-ctl pg-password-md5 gitlab

Enter password:
Confirm password:

## 생성된 HASH값
b7a289c0600988fe8e709dd2887e4d37

* 아래 파일을 수정한다.
vim /etc/gitlab/gitlab.rb

# Disable all components except PostgreSQL related ones
roles([&#39;postgres_role&#39;])

# Set the network addresses that the exporters used for monitoring will listen on
node_exporter[&#39;listen_address&#39;] = &#39;0.0.0.0:9100&#39;
postgres_exporter[&#39;listen_address&#39;] = &#39;0.0.0.0:9187&#39;
postgres_exporter[&#39;dbname&#39;] = &#39;gitlabhq_production&#39;
postgres_exporter[&#39;password&#39;] = &#39;b7a289c0600988fe8e709dd2887e4d37&#39; ## &lt;&lt; ADD

# Set the PostgreSQL address and port
postgresql[&#39;listen_address&#39;] = &#39;0.0.0.0&#39;
postgresql[&#39;port&#39;] = 5432

# Replace POSTGRESQL_PASSWORD_HASH with a generated md5 value
postgresql[&#39;sql_user_password&#39;] = &#39;Pb7a289c0600988fe8e709dd2887e4d37&#39; ## &lt;&lt; ADD

# Replace APPLICATION_SERVER_IP_BLOCK with the CIDR address of the application node
postgresql[&#39;trust_auth_cidr_addresses&#39;] = %w(127.0.0.1/32 10.253.126.0/24)

# Prevent database migrations from running on upgrade automatically
gitlab_rails[&#39;auto_migrate&#39;] = false

## 저장 완료 후 아래 명령어를 통해 GitLab을 재 설정 해준다.
gitlab-ctl reconfigure

## 완료 후 DB 테이블을 확인 할 수 있다.
## 또는 아래 명령어를 입력 하면
sudo gitlab-rake gitlab:db:decomposition:connection_status

## 아래와 같이 나오는 것을 확인 할 수 있다.
GitLab database already running on two connections
```

* #### REDIS을 아래와 같이 설정 한다.
```shell

* 아래 파일을 수정한다.
vim /etc/gitlab/gitlab.rb

## Enable Redis
roles([&#34;redis_master_role&#34;])

redis[&#39;bind&#39;] = &#39;0.0.0.0&#39;
redis[&#39;port&#39;] = 6379
redis[&#39;password&#39;] = &#39;SECRET_PASSWORD_HERE&#39;

gitlab_rails[&#39;enable&#39;] = false

# Set the network addresses that the exporters used for monitoring will listen on
node_exporter[&#39;listen_address&#39;] = &#39;0.0.0.0:9100&#39;
redis_exporter[&#39;listen_address&#39;] = &#39;0.0.0.0:9121&#39;
redis_exporter[&#39;flags&#39;] = {
      &#39;redis.addr&#39; =&gt; &#39;redis://0.0.0.0:6379&#39;,
      &#39;redis.password&#39; =&gt; &#39;SECRET_PASSWORD_HERE&#39;,
}

```

{{&lt; figure src=&#34;/images/GitLab/1-3.png&#34; title=&#34;REDIS 상태 확인&#34; &gt;}}

#### Gitaly는 레파지토리에 RPC기반의 빠른 읽기/쓰기를 가능하게 해준다.
* #### Gitaly을 아래와 같이 설정 한다.


```shell
# Avoid running unnecessary services on the Gitaly server
postgresql[&#39;enable&#39;] = false
redis[&#39;enable&#39;] = false
nginx[&#39;enable&#39;] = false
puma[&#39;enable&#39;] = false
sidekiq[&#39;enable&#39;] = false
gitlab_workhorse[&#39;enable&#39;] = false
prometheus[&#39;enable&#39;] = false
alertmanager[&#39;enable&#39;] = false
gitlab_exporter[&#39;enable&#39;] = false
gitlab_kas[&#39;enable&#39;] = false

# Prevent database migrations from running on upgrade automatically
gitlab_rails[&#39;auto_migrate&#39;] = false

# Configure the gitlab-shell API callback URL. Without this, `git push` will
# fail. This can be your &#39;front door&#39; GitLab URL or an internal load
# balancer.
gitlab_rails[&#39;internal_api_url&#39;] = &#39;https://gitlab.huntedhappy.kro.kr&#39;

# Gitaly
gitaly[&#39;enable&#39;] = true

# The secret token is used for authentication callbacks from Gitaly to the GitLab internal API.
# This must match the respective value in GitLab Rails application setup.
gitlab_shell[&#39;secret_token&#39;] = &#39;shellsecret&#39;

# Set the network addresses that the exporters used for monitoring will listen on
node_exporter[&#39;listen_address&#39;] = &#39;0.0.0.0:9100&#39;

gitaly[&#39;configuration&#39;] = {
   # ...
   #
   # Make Gitaly accept connections on all network interfaces. You must use
   # firewalls to restrict access to this address/port.
   # Comment out following line if you only want to support TLS connections
   listen_addr: &#39;0.0.0.0:8075&#39;,
   prometheus_listen_addr: &#39;0.0.0.0:9236&#39;,
   # Gitaly Auth Token
   # Should be the same as praefect_internal_token
   auth: {
      # ...
      #
      # Gitaly&#39;s authentication token is used to authenticate gRPC requests to Gitaly. This must match
      # the respective value in GitLab Rails application setup.
      token: &#39;gitalysecret&#39;,
   },
   # Gitaly Pack-objects cache
   # Recommended to be enabled for improved performance but can notably increase disk I/O
   # Refer to https://docs.gitlab.com/ee/administration/gitaly/configure_gitaly.html#pack-objects-cache for more info
   pack_objects_cache: {
      # ...
      enabled: true,
   },
   storage: [
      {
         name: &#39;default&#39;,
         path: &#39;/var/opt/gitlab/git-data&#39;,
      },
   ],
}

```

* #### Rails &amp; Sidekiq 을 아래와 같이 설정 한다.

```shell
vi /etc/gitlab/gitlab.rb

external_url &#39;https://gitlab.huntedhappy.kro.kr&#39;

# Gitaly and GitLab use two shared secrets for authentication, one to authenticate gRPC requests
# to Gitaly, and a second for authentication callbacks from GitLab-Shell to the GitLab internal API.
# The following two values must be the same as their respective values
# of the Gitaly setup
gitlab_rails[&#39;gitaly_token&#39;] = &#39;gitalysecret&#39;
gitlab_shell[&#39;secret_token&#39;] = &#39;shellsecret&#39;

git_data_dirs({
  &#39;default&#39; =&gt; { &#39;gitaly_address&#39; =&gt; &#39;tcp://10.253.126.129:8075&#39; },
})

## Disable components that will not be on the GitLab application server
roles([&#39;application_role&#39;, &#39;sidekiq_role&#39;])
gitaly[&#39;enable&#39;] = false

## PostgreSQL connection details
gitlab_rails[&#39;db_adapter&#39;] = &#39;postgresql&#39;
gitlab_rails[&#39;db_encoding&#39;] = &#39;unicode&#39;
gitlab_rails[&#39;db_host&#39;] = &#39;10.253.126.123&#39; # IP/hostname of database server
gitlab_rails[&#39;db_password&#39;] = &#39;Password&#39;

## Redis connection details
gitlab_rails[&#39;redis_port&#39;] = &#39;6379&#39;
gitlab_rails[&#39;redis_host&#39;] = &#39;10.253.126.120&#39; # IP/hostname of Redis server
gitlab_rails[&#39;redis_password&#39;] = &#39;Password&#39;

## Prevent database migrations from running on upgrade automatically
gitlab_rails[&#39;auto_migrate&#39;] = false

# Set the network addresses that the exporters used for monitoring will listen on
node_exporter[&#39;listen_address&#39;] = &#39;0.0.0.0:9100&#39;
gitlab_workhorse[&#39;prometheus_listen_addr&#39;] = &#39;0.0.0.0:9229&#39;
puma[&#39;listen&#39;] = &#39;0.0.0.0&#39;

# Sidekiq
sidekiq[&#39;enable&#39;] = true
sidekiq[&#39;listen_address&#39;] = &#34;0.0.0.0&#34;

# Configure Sidekiq with 2 workers and 20 max concurrency
sidekiq[&#39;max_concurrency&#39;] = 20
sidekiq[&#39;queue_groups&#39;] = [&#39;*&#39;] * 4

# Add the monitoring node&#39;s IP address to the monitoring whitelist and allow it to
# scrape the NGINX metrics. Replace placeholder `monitoring.gitlab.example.com` with
# the address and/or subnets gathered from the monitoring node
gitlab_rails[&#39;monitoring_whitelist&#39;] = [&#39;10.253.0.0/16&#39;, &#39;127.0.0.0/8&#39;]
nginx[&#39;status&#39;][&#39;options&#39;][&#39;allow&#39;] = [&#39;10.253.0.0/16&#39;, &#39;127.0.0.0/8&#39;]

# Object Storage
## This is an example for configuring Object Storage on GCP
## Replace this config with your chosen Object Storage provider as desired
gitlab_rails[&#39;object_store&#39;][&#39;enabled&#39;] = true
gitlab_rails[&#39;object_store&#39;][&#39;connection&#39;] = {
  &#39;provider&#39; =&gt; &#39;AWS&#39;,
  &#39;endpoint&#39; =&gt; &#39;https://minio-volumes.huntedhappy.kro.kr&#39;,
  &#39;path_style&#39; =&gt; true,
  &#39;aws_access_key_id&#39; =&gt; &#39;minioadmin&#39;,
  &#39;aws_secret_access_key&#39; =&gt; &#39;&#39;,
  &#39;region&#39; =&gt; &#39;us-west&#39;
}

gitlab_rails[&#39;object_store&#39;][&#39;objects&#39;][&#39;artifacts&#39;][&#39;bucket&#39;] = &#34;artifacts&#34;
gitlab_rails[&#39;object_store&#39;][&#39;objects&#39;][&#39;external_diffs&#39;][&#39;bucket&#39;] = &#34;external-diffs&#34;
gitlab_rails[&#39;object_store&#39;][&#39;objects&#39;][&#39;lfs&#39;][&#39;bucket&#39;] = &#34;lfs&#34;
gitlab_rails[&#39;object_store&#39;][&#39;objects&#39;][&#39;uploads&#39;][&#39;bucket&#39;] = &#34;uploads&#34;
gitlab_rails[&#39;object_store&#39;][&#39;objects&#39;][&#39;packages&#39;][&#39;bucket&#39;] = &#34;packages&#34;
gitlab_rails[&#39;object_store&#39;][&#39;objects&#39;][&#39;dependency_proxy&#39;][&#39;bucket&#39;] = &#34;dependency-proxy&#34;
gitlab_rails[&#39;object_store&#39;][&#39;objects&#39;][&#39;terraform_state&#39;][&#39;bucket&#39;] = &#34;terraform-state&#34;


#### END 
######################################################################
sudo touch /etc/gitlab/skip-auto-reconfigure

gitlab-ctl reconfigure
gitlab-ctl restart
gitlab-ctl status

## DB 마이그레이션 
sudo gitlab-rake gitlab:db:configure

## 첫 번 째가 완료 되면 두번째는 아래와 같이 재 설정만 해주면 된다.
gitlab-ctl reconfigure
```

###### 설정이 완료 되면 Gitaly Host에서 아래 명령어를 통해 정상 여부를 확인 할 수 있다.
```shell
sudo /opt/gitlab/embedded/bin/gitaly check /var/opt/gitlab/gitaly/config.toml
```

{{&lt; figure src=&#34;/images/GitLab/1-4.png&#34; title=&#34;상태 확인&#34; &gt;}}

##### * 처음 접속 하면 root 패스워드를 변경하라고 나온 후 패스워드를 변경하면 접속 할 수 있다.

{{&lt; figure src=&#34;/images/GitLab/1-5.png&#34; title=&#34;접속&#34; &gt;}}


## 2. MINIO에 저장 확인

&gt; * 아래와 같이 MINIO 오프젝트 스토리지에 저장 된 것을 확인 할 수 있다.

##### 프로젝트 생성
{{&lt; figure src=&#34;/images/GitLab/2-1.png&#34; title=&#34;프로젝트 생성&#34; &gt;}}

##### 이슈 생성
{{&lt; figure src=&#34;/images/GitLab/2-2.png&#34; title=&#34;이슈 생성&#34; &gt;}}
{{&lt; figure src=&#34;/images/GitLab/2-3.png&#34; title=&#34;이슈 생성&#34; &gt;}}
{{&lt; figure src=&#34;/images/GitLab/2-4.png&#34; title=&#34;MINIO 업로드 확인&#34; &gt;}}


---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/git/  

