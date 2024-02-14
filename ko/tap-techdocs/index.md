# The Documentation TechDocs in Tap


## 1. 간단한 설명
### 1.1. Backstage?
Backstage는 개발자 포털 구축을 위한 오픈 플랫폼입니다. 2년 전 Spotify의 소규모 팀이 내부에서 Backstage를 오픈소스로 출시 후 CNCF SANDBOX에서 현재는 INCUBATING 단계가 되었습니다. CNCF는 프로젝트 성숙도에 따라서 SANDBOX, INCUBATING, GRADUATED 단계로  구성 되어 있습니다.

프로젝트의 성숙도는 CNCF 위원회 멤버들에 의해서 결정되며, GRADUATED 단계의 프로젝트가 되기 위해서는 GRADUATED 요건이 필요 하며 위원회 멤버 과반수 이상의 찬성표를 받아야 합니다.

{{&lt; figure src=&#34;/images/tap-techdocs/1-1.png&#34; title=&#34;https://www.cncf.io/projects/&#34; &gt;}}

Backstage WebPage를 가게 되면 엄청 많은 기능들을 확인 할 수 있습니다. 

[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Backstage LINK](https://backstage.io/docs/overview/what-is-backstage)
### 1.2. TechDocs?

Backstage에 내장되어 있으며 MarkDown 파일을 작성 함으로 Backstage에 문서형 사이트를 얻을 수 있습니다.
[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Backstage TechDocs 참고링크](https://backstage.io/docs/features/techdocs/)

TANZU의 TAP의 경우 Backstage의 기능으로 구성이 되어 있습니다.

## 2. TechDocs 설정
&gt; 사전 구성
&gt; 1. Object Storage : &#39;awsS3&#39; or &#39;googleGcs&#39; or &#39;azureBlobStorage&#39; or &#39;openStackSwift&#39; 
&gt; 2. TANZU TAP
&gt; 3. npm, node, npx (9.5.0, 18.14.2, 9.5.0)의 버전으로 테스트 진행

&gt; 앞서 설명에서 MarkDown를 통해 Tanzu의 TAP에 문서형태를 구성 할 수 있습니다. 사전에 Tanzu Net에서 sample을 다운로드 받을 수 있습니다.

{{&lt; figure src=&#34;/images/tap-techdocs/1-2.png&#34; title=&#34;Sample Download&#34; &gt;}}

```shell
## 압축 해제
tar zxvf tap-gui-yelb-catalog.tgz

## markdown 
cd tap-gui-yelb-catalog

```


&gt; 위의 Sample 파일을 다운로드 받은 후 TAP에서 Catalog를 등록 한 후 DOCS를 보면 아래와 같이 오류가 나는 것을 확인 할 수 있습니다.

{{&lt; figure src=&#34;/images/tap-techdocs/1-3.webp&#34; title=&#34;Error&#34; &gt;}}

TANZU에서 TechDocs 관련 LINK는 아래에서 참고 할 수 있지만, 문서를 보면 어떻게 해야 되는지 잘 알지 못할 수도 있습니다.
[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; TechDocs In TAP 참고링크](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.4/tap/tap-gui-techdocs-usage.html)

&gt; 그리고 SAMPLE에서 mkdocs.yml 의 내용을 보면 docs에 index.md, add-docs.md를 읽을 수 있게 구성이 되어져 있는 것을 확인 해 볼 수 있습니다.
```shell
site_name: &#39;Yelb demo catalog&#39;

nav:
  - Home: index.md
  - Adding Documentation: add-docs.md

plugins:
  - techdocs-core
```

&gt; spotify에서 제공하는 techdocs docker를 다운로드 합니다.

```shell
docker pull spotify/techdocs:v1.1.0
```
&gt; 테스트 환경에서는 AWS의 S3를 구성 하지 않고, MINIO를 사용하여 구성하였습니다. S3의 계정 정보를 환경변수로 저장합니다. MINIO에 저장 할 수 있는 버킷을 생성 합니다.


```shell
export AWS_ACCESS_KEY_ID=&#39;&#39;
export AWS_SECRET_ACCESS_KEY=&#39;&#39;
export AWS_REGION=ap-northeast-2
```

&gt; 페이지를 작성 하기 위해 MarkDown을 npx로 웹 관련 파일을 생성 합니다.
```shell
npx @techdocs/cli generate --source-dir /var/tmp/tkgm/workload/catalog/yelb-catalog --output-dir ./site

## 아래와 같이 ./site 폴더에 파일들이 생성 된 것을 확인 할 수 있습니다.
ls site/
404.html  README.md  add-docs  assets  images  index.html  search  sitemap.xml  sitemap.xml.gz  techdocs_metadata.json
```
&gt; 사전에 Catalog를 등록 하면 DOCS에서 아래처럼 확인이 가능 합니다.

{{&lt; figure src=&#34;/images/tap-techdocs/1-3.png&#34; title=&#34;yelb-catalog-info&#34; &gt;}}


&gt; 확인 및 site 파일이 생성이 되면 오브젝트 스토리지에 파일들을 업로드 해줍니다.
```shell
npx @techdocs/cli publish --publisher-type awsS3 --storage-name techdocs --entity default/location/yelb-catalog-info --directory ./site --awsEndpoint https://minio-volumes.huntedhappy.kro.kr --awsS3ForcePathStyle true
```

{{&lt; figure src=&#34;/images/tap-techdocs/1-4.png&#34; title=&#34;MINIO BUCKET&#34; &gt;}}

&gt; 여기까지 완료가 되면 tap values yaml 파일을 업데이트 합니다.

```shell
    techdocs:
      builder: &#39;external&#39; # Alternatives - &#39;external&#39;
      publisher:
        type: &#39;awsS3&#39; # Alternatives - &#39;googleGcs&#39; or &#39;awsS3&#39; or &#39;azureBlobStorage&#39; or &#39;openStackSwift&#39;. Read documentation for using alternatives.
        awsS3:
          bucketName: &#39;techdocs&#39;
          credentials:
            accessKeyId: &#39;&#39;
            secretAccessKey: &#39;&#39;
          region: ap-northeast-2
          s3ForcePathStyle: true
          endpoint: https://minio-volumes.huntedhappy.kro.kr

## 수정 후 
tanzu package installed update tap -n tap-install --values-file {file.yaml}          
```
&gt; 이 후 완료가 되면 아래 처럼 DOCS를 확인 할 수 있습니다. MARKDOWN을 작성 함으로 인해서 TAP에 개발을 한 Application의 대한 설명을 작성 할 수 있습니다.

{{&lt; figure src=&#34;/images/tap-techdocs/1-5.png&#34; title=&#34;DOCS1&#34; &gt;}}
{{&lt; figure src=&#34;/images/tap-techdocs/1-6.png&#34; title=&#34;DOCS2&#34; &gt;}}
{{&lt; figure src=&#34;/images/tap-techdocs/1-7.png&#34; title=&#34;DOCS3&#34; &gt;}}
{{&lt; figure src=&#34;/images/tap-techdocs/1-8.png&#34; title=&#34;DOCS4&#34; &gt;}}

---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/ko/tap-techdocs/  

