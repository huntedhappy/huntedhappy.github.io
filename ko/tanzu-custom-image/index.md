# The Documentation TANZU CUSTOM IMAGE


## 1. Tanzu Custom Image

VMware에서 기본적으로 제공하는 이미지외에 별도로 Custom Image를 구성 할 수 있다. 

호환되는 OS버전은 아래와 같다.
{{&lt; figure src=&#34;/images/tanzu-custom-image/1-1.png&#34; title=&#34;지원 하는 OS Version&#34; &gt;}}

1.6 버전 Custom Image 생성 [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; 1.6 Custom-Image ](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.6/vmware-tanzu-kubernetes-grid-16/GUID-build-images-linux.html)

2.1 버전 Custom Image 생성 [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; 2.1 Custom-Image ](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/2.1/tkg-deploy-mc-21/mgmt-byoi-linux.html#linux-tkr)

TANZU 버전별 Sample Download [&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; Sample Downloads ](https://developer.vmware.com/samples)

&gt; 사전에 도커가 설치 되어 있어야 함

&gt; RHEL의 경우 Subscription이 되어 있어야 함
## 2. 공통 작업

{{&lt; admonition tip &#34;Docker Server 실행&#34; &gt;}}
```shell
docker pull projects.registry.vmware.com/tkg/linux-resource-bundle:v1.23.10_vmware.1-tkg.1
docker run -d -p 3000:3000 projects.registry.vmware.com/tkg/linux-resource-bundle:v1.23.10_vmware.1-tkg.1
```
{{&lt; /admonition &gt;}}

{{&lt; admonition tip &#34;Sample 다운로드&#34; &gt;}}
```shell
## 1.6 Sample Download
curl -L https://apigw.vmware.com/sampleExchange/v1/downloads/8031 -o TKG-Image-Builder-for-Kubernetes-v1.23.10-master.zip
unzip TKG-Image-Builder-for-Kubernetes-v1.23.10-master.zip
cd TKG-Image-Builder-for-Kubernetes-v1.23.10-on-TKG-v1.6.1-master/TKG-Image-Builder-for-Kubernetes-v1_23_10---vmware_1-tkg_v1_6_1/

## 2.1 Sample Download
curl -L https://apigw.vmware.com/sampleExchange/v1/downloads/8061 -o TKG-Image-Builder-for-Kubernetes-v1.24.9-master.zip
unzip TKG-Image-Builder-for-Kubernetes-v1.24.9-master.zip
cd /TKG-Image-Builder-for-Kubernetes-v1.24.9-on-TKG-v2.1.0-master/TKG-Image-Builder-for-Kubernetes-v1_24_9---vmware_1-tkg_v2_1_0/
```
{{&lt; /admonition &gt;}}

{{&lt; admonition tip &#34;tkg.json 설정 변경&#34; &gt;}}
```shell
## 아래 &lt;IP&gt;:&lt;PORT&gt; 설정
cat &lt;&lt; &#39;EOF&#39; &gt; tkg.json
{
  &#34;build_version&#34;: &#34;{{user `build_name`}}-kube-v1.23.10_vmware.1&#34;,
  &#34;pause_image&#34;: &#34;projects.registry.vmware.com/tkg/pause:3.6&#34;,
  &#34;containerd_sha256&#34;: &#34;48f4327570dd7543464a28893160ab3bc9719ed2553f0a529a884b40f6dafd29&#34;,
  &#34;containerd_url&#34;: &#34;http://&lt;IP&gt;:&lt;PORT&gt;/files/containerd/cri-containerd-v1.6.6&#43;vmware.2.linux-amd64.tar&#34;,
  &#34;containerd_version&#34;: &#34;v1.6.6&#43;vmware.2&#34;,
  &#34;crictl_sha256&#34;: &#34;&#34;,
  &#34;crictl_url&#34;: &#34;&#34;,
  &#34;custom_role&#34;: &#34;true&#34;,
  &#34;custom_role_names&#34;: &#34;/home/imagebuilder/tkg&#34;,
  &#34;extra_debs&#34;: &#34;nfs-common unzip apparmor apparmor-utils sysstat&#34;,
  &#34;extra_rpms&#34;: &#34;sysstat&#34;,
  &#34;goss_vars_file&#34;: &#34;&#34;,
  &#34;goss_tests_dir&#34;: &#34;/home/imagebuilder/goss&#34;,
  &#34;goss_entry_file&#34;: &#34;goss/goss.yaml&#34;,
  &#34;goss_download_path&#34;: &#34;/tkg-tmp/goss-linux-amd64&#34;,
  &#34;goss_remote_folder&#34;: &#34;/tkg-tmp&#34;,
  &#34;goss_remote_path&#34;: &#34;/tkg-tmp/goss&#34;,
  &#34;kubernetes_series&#34;: &#34;v1.23&#34;,
  &#34;kubernetes_semver&#34;: &#34;v1.23.10&#43;vmware.1&#34;,
  &#34;kubernetes_source_type&#34;: &#34;http&#34;,
  &#34;kubernetes_http_source&#34;: &#34;http://&lt;IP&gt;:&lt;PORT&gt;/files/kubernetes&#34;,
  &#34;kubernetes_container_registry&#34;: &#34;projects.registry.vmware.com/tkg&#34;,
  &#34;kubernetes_cni_semver&#34;: &#34;v1.1.1&#43;vmware.7&#34;,
  &#34;kubernetes_cni_source_type&#34;: &#34;http&#34;,
  &#34;kubernetes_cni_http_source&#34;: &#34;http://&lt;IP&gt;:&lt;PORT&gt;/files/cni_plugins&#34;,
  &#34;kubernetes_cni_http_checksum&#34;: &#34;&#34;,
  &#34;kubernetes_load_additional_imgs&#34;: &#34;true&#34;
}
EOF
```
{{&lt; /admonition &gt;}}

{{&lt; admonition tip &#34;vCenter 및 Tanzu Kubernetes 버전 설정&#34; &gt;}}
```shell
## vCenter의 정보를 넣어 준다.
cat &lt;&lt; EOF &gt; vsphere.json
{
  &#34;vcenter_server&#34;: &#34;&#34;,
  &#34;username&#34;: &#34;&#34;,
  &#34;password&#34;: &#34;&#34;,
  &#34;insecure_connection&#34;: &#34;true&#34;,
  &#34;datacenter&#34;: &#34;Datacenter&#34;,
  &#34;cluster&#34;: &#34;Cluster&#34;,
  &#34;resource_pool&#34;: &#34;&#34;,
  &#34;folder&#34;: &#34;tanzu&#34;,
  &#34;datastore&#34;: &#34;vsanDatastore&#34;,
  &#34;network&#34;: &#34;VM Network&#34;,
  &#34;convert_to_template&#34;: &#34;false&#34;,
  &#34;create_snapshot&#34;: &#34;false&#34;,
  &#34;linked_clone&#34;: &#34;false&#34;,
  &#34;template&#34;: &#34;false&#34;
}
EOF

## 설치할 버전 설정 

## 1.6
cat &lt;&lt; EOF &gt; metadata.json
{
  &#34;VERSION&#34;: &#34;v1.23.10&#43;vmware.1-dokyung.0&#34;
}
EOF

## 2.1
{
  &#34;VERSION&#34;: &#34;v1.24.9&#43;vmware.1-dokyung.0&#34;
}
```
{{&lt; /admonition &gt;}}

## 3. Ubuntu Custom Image 생성

{{&lt; admonition tip &#34;이미지 생성 실행&#34; &gt;}}
```shell
mkdir output

## 1.6 설정
docker run --net=host -it --rm \
  -v $(pwd)/vsphere.json:/home/imagebuilder/vsphere.json \
  -v $(pwd)/tkg.json:/home/imagebuilder/tkg.json \
  -v $(pwd)/tkg:/home/imagebuilder/tkg \
  -v $(pwd)/stig_ubuntu_2004:/home/imagebuilder/stig_ubuntu_2004 \
  -v $(pwd)/goss/vsphere-ubuntu-1.23.10&#43;vmware.2-goss-spec.yaml:/home/imagebuilder/goss/goss.yaml \
  -v $(pwd)/metadata.json:/home/imagebuilder/metadata.json \
  -v $(pwd)/output:/home/imagebuilder/output \
  --env PACKER_VAR_FILES=&#34;tkg.json vsphere.json&#34; \
  --env OVF_CUSTOM_PROPERTIES=/home/imagebuilder/metadata.json \
  --env IB_OVFTOOL=1 \
  projects.registry.vmware.com/tkg/image-builder:v0.1.13_vmware.2 \
  build-node-ova-vsphere-ubuntu-2004

## 2.1 설정
docker run -it --rm \
  -v $(pwd)/vsphere.json:/home/imagebuilder/vsphere.json \
  -v $(pwd)/tkg.json:/home/imagebuilder/tkg.json \
  -v $(pwd)/tkg:/home/imagebuilder/tkg \
  -v $(pwd)/goss/vsphere-ubuntu-1.24.9&#43;vmware.1-goss-spec.yaml:/home/imagebuilder/goss/goss.yaml \
  -v $(pwd)/metadata.json:/home/imagebuilder/metadata.json \
  -v $(pwd)/output:/home/imagebuilder/output \
  --env PACKER_VAR_FILES=&#34;tkg.json vsphere.json&#34; \
  --env OVF_CUSTOM_PROPERTIES=/home/imagebuilder/metadata.json \
  --env IB_OVFTOOL=1 \
  --network host \
  projects.registry.vmware.com/tkg/image-builder:v0.1.13_vmware.2 \
  build-node-ova-vsphere-ubuntu-2004
```
{{&lt; /admonition &gt;}}

{{&lt; admonition tip &#34;LOG&#34; &gt;}}
```shell
## Ubuntu Custom Image 생성시 아래와 같은 Log를 볼 수 있다, vCenter에서는 Template으로 생성이 되는 것을 확인 할 수 있다.
hack/ensure-ansible.sh
Starting galaxy collection install process
Nothing to do. All requested collections are already installed. If you want to reinstall them, consider using `--force`.
hack/ensure-ansible-windows.sh
hack/ensure-packer.sh
hack/ensure-goss.sh
Right version of binary present
hack/ensure-ovftool.sh
packer build -var-file=&#34;/home/imagebuilder/packer/config/kubernetes.json&#34;  -var-file=&#34;/home/imagebuilder/packer/config/cni.json&#34;  -var-file=&#34;/home/imagebuilder/packer/config/containerd.json&#34;  -var-file=&#34;/home/imagebuilder/packer/config/ansible-args.json&#34;  -var-file=&#34;/home/imagebuilder/packer/config/goss-args.json&#34;  -var-file=&#34;/home/imagebuilder/packer/config/common.json&#34;  -var-file=&#34;/home/imagebuilder/packer/config/additional_components.json&#34;  -color=true  -var-file=&#34;packer/ova/packer-common.json&#34; -var-file=&#34;/home/imagebuilder/packer/ova/ubuntu-2004.json&#34; -var-file=&#34;packer/ova/vsphere.json&#34;  -except=local -only=vsphere-iso -var-file=&#34;/home/imagebuilder/tkg.json&#34;  -var-file=&#34;/home/imagebuilder/vsphere.json&#34;  -only=vsphere packer/ova/packer-node.json
vsphere: output will be in this color.

==&gt; vsphere: File /home/imagebuilder/.cache/packer/48e4ec4daa32571605576c5566f486133ecc271f.iso already uploaded; continuing
==&gt; vsphere: File [vsanDatastore] packer_cache//48e4ec4daa32571605576c5566f486133ecc271f.iso already exists; skipping upload.
==&gt; vsphere: Creating VM...
==&gt; vsphere: Customizing hardware...
==&gt; vsphere: Mounting ISO images...
==&gt; vsphere: Adding configuration parameters...
==&gt; vsphere: Creating floppy disk...
    vsphere: Copying files flatly from floppy_files
    vsphere: Done copying files from floppy_files
    vsphere: Collecting paths from floppy_dirs
    vsphere: Resulting paths from floppy_dirs : [./packer/ova/linux/ubuntu/http/]
    vsphere: Recursively copying : ./packer/ova/linux/ubuntu/http/
    vsphere: Done copying paths from floppy_dirs
    vsphere: Copying files from floppy_content
    vsphere: Done copying files from floppy_content
==&gt; vsphere: Uploading created floppy image
==&gt; vsphere: Adding generated Floppy...
==&gt; vsphere: Starting HTTP server on port 8033
==&gt; vsphere: Set boot order temporary...
==&gt; vsphere: Power on VM...
==&gt; vsphere: Waiting 10s for boot...
==&gt; vsphere: HTTP server is working at http://10.253.126.163:8033/
==&gt; vsphere: Typing boot command...
==&gt; vsphere: Waiting for IP...
==&gt; vsphere: IP address: 10.253.126.102
==&gt; vsphere: Using SSH communicator to connect: 10.253.126.102
==&gt; vsphere: Waiting for SSH to become available...
==&gt; vsphere: Connected to SSH!
==&gt; vsphere: Provisioning with shell script: ./packer/files/flatcar/scripts/bootstrap-flatcar.sh
==&gt; vsphere: Provisioning with Ansible...
    vsphere: Setting up proxy adapter for Ansible....
==&gt; vsphere: Executing Ansible: ansible-playbook -e packer_build_name=&#34;vsphere&#34; -e packer_*****_type=vsphere-iso -e packer_http_addr=10.253.126.163:8033 --ssh-extra-args &#39;-o IdentitiesOnly=yes&#39; --extra-vars containerd_url=http://10.253.126.163:3000/files/containerd/cri-containerd-v1.6.6&#43;vmware.2.linux-amd64.tar containerd_sha256=48f4327570dd7543464a28893160ab3bc9719ed2553f0a529a884b40f6dafd29 pause_image=projects.registry.vmware.com/tkg/pause:3.6 containerd_additional_settings= containerd_cri_socket=/var/run/containerd/containerd.sock containerd_version=v1.6.6&#43;vmware.2 crictl_url= crictl_sha256= crictl_source_type=pkg custom_role_names=&#34;/home/image*****/tkg&#34; firstboot_custom_roles_pre=&#34;&#34; firstboot_custom_roles_post=&#34;&#34; node_custom_roles_pre=&#34;&#34; node_custom_roles_post=&#34;&#34; disable_public_repos=false extra_debs=&#34;nfs-common unzip apparmor apparmor-utils sysstat&#34; extra_repos=&#34;&#34; extra_rpms=&#34;sysstat&#34; http_proxy= https_proxy= kubeadm_template=etc/kubeadm.yml kubernetes_cni_http_source=http://10.253.126.163:3000/files/cni_plugins kubernetes_cni_http_checksum= kubernetes_http_source=http://10.253.126.163:3000/files/kubernetes kubernetes_container_registry=projects.registry.vmware.com/tkg kubernetes_rpm_repo=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64 kubernetes_rpm_gpg_key=&#34;https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg&#34; kubernetes_rpm_gpg_check=True kubernetes_deb_repo=&#34;https://apt.kubernetes.io/ kubernetes-xenial&#34; kubernetes_deb_gpg_key=https://packages.cloud.google.com/apt/doc/apt-key.gpg kubernetes_cni_deb_version=1.1.1-00 kubernetes_cni_rpm_version=1.1.1-0 kubernetes_cni_semver=v1.1.1&#43;vmware.7 kubernetes_cni_source_type=http kubernetes_semver=v1.23.10&#43;vmware.1 kubernetes_source_type=http kubernetes_load_additional_imgs=true kubernetes_deb_version=1.23.10-00 kubernetes_rpm_version=1.23.10-0 no_proxy= pip_conf_file= python_path= redhat_epel_rpm=https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm epel_rpm_gpg_key= reenable_public_repos=true remove_extra_repos=false systemd_prefix=/usr/lib/systemd sysusr_prefix=/usr sysusrlocal_prefix=/usr/local load_additional_components=false additional_registry_images=false additional_registry_images_list= additional_url_images=false additional_url_images_list= additional_executables=false additional_executables_list= additional_executables_destination_path= build_target=virt amazon_ssm_agent_rpm= --extra-vars guestinfo_datasource_slug=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo guestinfo_datasource_ref=v1.4.1 guestinfo_datasource_script=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/v1.4.1/install.sh --extra-vars  -e ansible_ssh_private_key_file=/tmp/ansible-key1308883835 -i /tmp/packer-provisioner-ansible2622378892 /home/image*****/ansible/firstboot.yml
    vsphere:
    vsphere: PLAY [all] *********************************************************************
    vsphere:
    vsphere: TASK [Gathering Facts] *********************************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [include_role : firstboot] ************************************************
    vsphere:
    vsphere: PLAY RECAP *********************************************************************
    vsphere: default                    : ok=1    changed=0    unreachable=0    failed=0    skipped=80   rescued=0    ignored=0
    vsphere:
==&gt; vsphere: Provisioning with shell script: /tmp/packer-shell4104450257
==&gt; vsphere: Provisioning with Ansible...
    vsphere: Setting up proxy adapter for Ansible....
==&gt; vsphere: Executing Ansible: ansible-playbook -e packer_build_name=&#34;vsphere&#34; -e packer_*****_type=vsphere-iso -e packer_http_addr=10.253.126.163:8033 --ssh-extra-args &#39;-o IdentitiesOnly=yes&#39; --extra-vars containerd_url=http://10.253.126.163:3000/files/containerd/cri-containerd-v1.6.6&#43;vmware.2.linux-amd64.tar containerd_sha256=48f4327570dd7543464a28893160ab3bc9719ed2553f0a529a884b40f6dafd29 pause_image=projects.registry.vmware.com/tkg/pause:3.6 containerd_additional_settings= containerd_cri_socket=/var/run/containerd/containerd.sock containerd_version=v1.6.6&#43;vmware.2 crictl_url= crictl_sha256= crictl_source_type=pkg custom_role_names=&#34;/home/image*****/tkg&#34; firstboot_custom_roles_pre=&#34;&#34; firstboot_custom_roles_post=&#34;&#34; node_custom_roles_pre=&#34;&#34; node_custom_roles_post=&#34;&#34; disable_public_repos=false extra_debs=&#34;nfs-common unzip apparmor apparmor-utils sysstat&#34; extra_repos=&#34;&#34; extra_rpms=&#34;sysstat&#34; http_proxy= https_proxy= kubeadm_template=etc/kubeadm.yml kubernetes_cni_http_source=http://10.253.126.163:3000/files/cni_plugins kubernetes_cni_http_checksum= kubernetes_http_source=http://10.253.126.163:3000/files/kubernetes kubernetes_container_registry=projects.registry.vmware.com/tkg kubernetes_rpm_repo=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64 kubernetes_rpm_gpg_key=&#34;https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg&#34; kubernetes_rpm_gpg_check=True kubernetes_deb_repo=&#34;https://apt.kubernetes.io/ kubernetes-xenial&#34; kubernetes_deb_gpg_key=https://packages.cloud.google.com/apt/doc/apt-key.gpg kubernetes_cni_deb_version=1.1.1-00 kubernetes_cni_rpm_version=1.1.1-0 kubernetes_cni_semver=v1.1.1&#43;vmware.7 kubernetes_cni_source_type=http kubernetes_semver=v1.23.10&#43;vmware.1 kubernetes_source_type=http kubernetes_load_additional_imgs=true kubernetes_deb_version=1.23.10-00 kubernetes_rpm_version=1.23.10-0 no_proxy= pip_conf_file= python_path= redhat_epel_rpm=https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm epel_rpm_gpg_key= reenable_public_repos=true remove_extra_repos=false systemd_prefix=/usr/lib/systemd sysusr_prefix=/usr sysusrlocal_prefix=/usr/local load_additional_components=false additional_registry_images=false additional_registry_images_list= additional_url_images=false additional_url_images_list= additional_executables=false additional_executables_list= additional_executables_destination_path= build_target=virt amazon_ssm_agent_rpm= --extra-vars guestinfo_datasource_slug=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo guestinfo_datasource_ref=v1.4.1 guestinfo_datasource_script=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/v1.4.1/install.sh --extra-vars  -e ansible_ssh_private_key_file=/tmp/ansible-key2329815423 -i /tmp/packer-provisioner-ansible3700347837 /home/image*****/ansible/node.yml
    vsphere:
    vsphere: PLAY [all] *********************************************************************
    vsphere:
    vsphere: TASK [Gathering Facts] *********************************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [include_role : node] *****************************************************
    vsphere:
    vsphere: TASK [setup : Put templated sources.list in place] *****************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [setup : Put templated apt.conf.d/90proxy in place when defined] **********
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [setup : perform a dist-upgrade] ******************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [setup : install baseline dependencies] ***********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [setup : install extra debs] **********************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [setup : install pinned debs] *********************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [node : Ensure overlay module is present] *********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Ensure br_netfilter module is present] ****************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Persist required kernel modules] **********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Set and persist kernel params] ************************************
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.bridge.bridge-nf-call-iptables&#39;, &#39;val&#39;: 1})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.bridge.bridge-nf-call-ip6tables&#39;, &#39;val&#39;: 1})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv4.ip_forward&#39;, &#39;val&#39;: 1})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv6.conf.all.forwarding&#39;, &#39;val&#39;: 1})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv6.conf.all.disable_ipv6&#39;, &#39;val&#39;: 0})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv4.tcp_congestion_control&#39;, &#39;val&#39;: &#39;bbr&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;vm.overcommit_memory&#39;, &#39;val&#39;: 1})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;kernel.panic&#39;, &#39;val&#39;: 10})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;kernel.panic_on_oops&#39;, &#39;val&#39;: 1})
    vsphere:
    vsphere: TASK [node : Ensure auditd is running and comes on at reboot] ******************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [node : configure auditd rules for containerd] ****************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Ensure reverse packet filtering is set as strict] *****************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Copy udev etcd network tuning rules] ******************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Copy etcd network tuning script] **********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [include_role : providers] ************************************************
    vsphere:
    vsphere: TASK [providers : include_tasks] ***********************************************
    vsphere: included: /home/imagebuilder/ansible/roles/providers/tasks/vmware.yml for default
    vsphere:
    vsphere: TASK [providers : include_tasks] ***********************************************
    vsphere: included: /home/imagebuilder/ansible/roles/providers/tasks/vmware-ubuntu.yml for default
    vsphere:
    vsphere: TASK [providers : Install cloud-init packages] *********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Disable Hyper-V KVP protocol daemon on Ubuntu] ***************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Copy networkd-dispatcher scripts to add DHCP provided NTP servers] ***
    vsphere: changed: [default] =&gt; (item={&#39;src&#39;: &#39;files/etc/networkd-dispatcher/routable.d/20-chrony.j2&#39;, &#39;dest&#39;: &#39;/etc/networkd-dispatcher/routable.d/20-chrony&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;src&#39;: &#39;files/etc/networkd-dispatcher/off.d/20-chrony.j2&#39;, &#39;dest&#39;: &#39;/etc/networkd-dispatcher/off.d/20-chrony&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;src&#39;: &#39;files/etc/networkd-dispatcher/no-carrier.d/20-chrony.j2&#39;, &#39;dest&#39;: &#39;/etc/networkd-dispatcher/no-carrier.d/20-chrony&#39;})
    vsphere:
    vsphere: TASK [providers : Create provider vmtools config drop-in file] *****************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Create service to modify cloud-init config] ******************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Copy cloud-init modification script] *************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Enable modify-cloud-init-cfg.service] ************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Creates unit file directory for cloud-final] *****************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Create cloud-final boot order drop in file] ******************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Creates unit file directory for cloud-config] ****************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Create cloud-final boot order drop in file] ******************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Make sure all cloud init services are enabled] ***************
    vsphere: ok: [default] =&gt; (item=cloud-final)
    vsphere: ok: [default] =&gt; (item=cloud-config)
    vsphere: ok: [default] =&gt; (item=cloud-init)
    vsphere: ok: [default] =&gt; (item=cloud-init-local)
    vsphere:
    vsphere: TASK [providers : Create cloud-init config file] *******************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : set cloudinit feature flags] *********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Ensure chrony is running] ************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [include_role : containerd] ***********************************************
    vsphere:
    vsphere: TASK [containerd : Install libseccomp2 package] ********************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [containerd : download containerd] ****************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Create a directory if it does not exist] ********************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [containerd : unpack containerd] ******************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : delete /opt/cni directory] **********************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [containerd : delete /etc/cni directory] **********************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [containerd : Creates unit file directory] ********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Create containerd memory pressure drop in file] *************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Create containerd max tasks drop in file] *******************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Create containerd http proxy conf file if needed] ***********
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Creates containerd config directory] ************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Copy in containerd config file etc/containerd/config.toml] ***
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Copy in crictl config] **************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : start containerd service] ***********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : delete tarball] *********************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [include_role : kubernetes] ***********************************************
    vsphere:
    vsphere: TASK [kubernetes : Symlink cri-tools] ******************************************
    vsphere: changed: [default] =&gt; (item=ctr)
    vsphere: changed: [default] =&gt; (item=crictl)
    vsphere: changed: [default] =&gt; (item=critest)
    vsphere:
    vsphere: TASK [kubernetes : Create CNI directory] ***************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Download CNI tarball] ***************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Install CNI] ************************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Remove CNI tarball] *****************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Download Kubernetes binaries] *******************************
    vsphere: changed: [default] =&gt; (item=kubeadm)
    vsphere: changed: [default] =&gt; (item=kubectl)
    vsphere: changed: [default] =&gt; (item=kubelet)
    vsphere:
    vsphere: TASK [kubernetes : Download Kubernetes images] *********************************
    vsphere: changed: [default] =&gt; (item=kube-apiserver.tar)
    vsphere: changed: [default] =&gt; (item=kube-controller-manager.tar)
    vsphere: changed: [default] =&gt; (item=kube-scheduler.tar)
    vsphere: changed: [default] =&gt; (item=kube-proxy.tar)
    vsphere: changed: [default] =&gt; (item=pause.tar)
    vsphere: changed: [default] =&gt; (item=coredns.tar)
    vsphere: changed: [default] =&gt; (item=etcd.tar)
    vsphere:
    vsphere: TASK [kubernetes : Load Kubernetes images] *************************************
    vsphere: changed: [default] =&gt; (item=kube-apiserver.tar)
    vsphere: changed: [default] =&gt; (item=kube-controller-manager.tar)
    vsphere: changed: [default] =&gt; (item=kube-scheduler.tar)
    vsphere: changed: [default] =&gt; (item=kube-proxy.tar)
    vsphere: changed: [default] =&gt; (item=pause.tar)
    vsphere: changed: [default] =&gt; (item=coredns.tar)
    vsphere: changed: [default] =&gt; (item=etcd.tar)
    vsphere:
    vsphere: TASK [kubernetes : Remove Kubernetes images] ***********************************
    vsphere: changed: [default] =&gt; (item=kube-apiserver.tar)
    vsphere: changed: [default] =&gt; (item=kube-controller-manager.tar)
    vsphere: changed: [default] =&gt; (item=kube-scheduler.tar)
    vsphere: changed: [default] =&gt; (item=kube-proxy.tar)
    vsphere: changed: [default] =&gt; (item=pause.tar)
    vsphere: changed: [default] =&gt; (item=coredns.tar)
    vsphere: changed: [default] =&gt; (item=etcd.tar)
    vsphere:
    vsphere: TASK [kubernetes : Create Kubernetes manifests directory] **********************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Create kubelet sysconfig directory] *************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Create kubelet drop-in directory] ***************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Create kubelet kubeadm drop-in file] ************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Create kubelet systemd file] ********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Create kubelet default config file] *************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Enable kubelet service] *************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Create the Kubernetes version file] *************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Check if Kubernetes container registry is using Amazon ECR] ***
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [include_role : {{ role }}] ***********************************************
    vsphere:
    vsphere: TASK [/home/imagebuilder/tkg : Create /tkg-tmp space] **************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [/home/imagebuilder/tkg : Ensure reverse path filtering is set as strict] ***
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [/home/imagebuilder/tkg : Modify /bin/sh to point to bash instead of dash] ***
    vsphere: changed: [default] =&gt; (item=echo &#34;dash dash/sh boolean false&#34; |  debconf-set-selections)
    vsphere: changed: [default] =&gt; (item=DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash)
    vsphere:
    vsphere: TASK [/home/imagebuilder/tkg : remove unwanted packages] ***********************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [/home/imagebuilder/tkg : include_tasks] **********************************
    vsphere: included: /home/imagebuilder/tkg/tasks/vsphere.yml for default
    vsphere:
    vsphere: TASK [/home/imagebuilder/tkg : Set extra kernel params for GC threshhold] ******
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv4.neigh.default.gc_thresh1&#39;, &#39;val&#39;: 4096})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv6.neigh.default.gc_thresh1&#39;, &#39;val&#39;: 4096})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv4.neigh.default.gc_thresh2&#39;, &#39;val&#39;: 8192})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv6.neigh.default.gc_thresh2&#39;, &#39;val&#39;: 8192})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv4.neigh.default.gc_thresh3&#39;, &#39;val&#39;: 16384})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv6.neigh.default.gc_thresh3&#39;, &#39;val&#39;: 16384})
    vsphere:
    vsphere: TASK [/home/imagebuilder/tkg : Ensure fs.file-max is set] **********************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [include_role : sysprep] **************************************************
    vsphere:
    vsphere: TASK [sysprep : Define file modes] *********************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : apt-mark all installed packages] *******************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove templated apt.conf.d/90proxy used for http(s)_proxy support] ***
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Stop auditing] *************************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove apt package caches] *************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove apt package lists] **************************************
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/lib/apt/lists&#39;, &#39;state&#39;: &#39;absent&#39;, &#39;mode&#39;: &#39;0755&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/lib/apt/lists&#39;, &#39;state&#39;: &#39;directory&#39;, &#39;mode&#39;: &#39;0755&#39;})
    vsphere:
    vsphere: TASK [sysprep : Disable apt-daily services] ************************************
    vsphere: changed: [default] =&gt; (item=apt-daily.timer)
    vsphere: changed: [default] =&gt; (item=apt-daily-upgrade.timer)
    vsphere:
    vsphere: TASK [sysprep : Get installed packages] ****************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Disable unattended upgrades if installed] **********************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Reset network interface IDs] ***********************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove containerd http proxy conf file if needed] **************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Truncate machine id] *******************************************
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/machine-id&#39;, &#39;state&#39;: &#39;absent&#39;, &#39;mode&#39;: &#39;0644&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/machine-id&#39;, &#39;state&#39;: &#39;touch&#39;, &#39;mode&#39;: &#39;0644&#39;})
    vsphere:
    vsphere: TASK [sysprep : Truncate hostname file] ****************************************
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/hostname&#39;, &#39;state&#39;: &#39;absent&#39;, &#39;mode&#39;: &#39;0644&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/hostname&#39;, &#39;state&#39;: &#39;touch&#39;, &#39;mode&#39;: &#39;0644&#39;})
    vsphere:
    vsphere: TASK [sysprep : Set hostname] **************************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Reset hosts file] **********************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Truncate audit logs] *******************************************
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/log/wtmp&#39;, &#39;state&#39;: &#39;absent&#39;, &#39;mode&#39;: &#39;0664&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/log/lastlog&#39;, &#39;state&#39;: &#39;absent&#39;, &#39;mode&#39;: &#39;0664&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/log/wtmp&#39;, &#39;state&#39;: &#39;touch&#39;, &#39;mode&#39;: &#39;0664&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/log/lastlog&#39;, &#39;state&#39;: &#39;touch&#39;, &#39;mode&#39;: &#39;0664&#39;})
    vsphere:
    vsphere: TASK [sysprep : Remove cloud-init lib dir and logs] ****************************
    vsphere: ok: [default] =&gt; (item=/var/lib/cloud)
    vsphere: ok: [default] =&gt; (item=/var/log/cloud-init.log)
    vsphere: ok: [default] =&gt; (item=/var/log/cloud-init-output.log)
    vsphere: changed: [default] =&gt; (item=/var/run/cloud-init)
    vsphere:
    vsphere: TASK [sysprep : Find temp files] ***********************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Reset temp space] **********************************************
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/tmp.fstab&#39;, &#39;mode&#39;: &#39;0644&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 34, &#39;inode&#39;: 402670, &#39;dev&#39;: 2049, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677597184.857451, &#39;mtime&#39;: 1677597184.853451, &#39;ctime&#39;: 1677597184.853451, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: True, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: True, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: ok: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/ansible_find_payload_f0kvk8b5&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 402677, &#39;dev&#39;: 2049, &#39;nlink&#39;: 2, &#39;atime&#39;: 1677597223.1412058, &#39;mtime&#39;: 1677597223.1412058, &#39;ctime&#39;: 1677597223.1412058, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/vmware-root_11794-701728372&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 402667, &#39;dev&#39;: 2049, &#39;nlink&#39;: 2, &#39;atime&#39;: 1677596834.564557, &#39;mtime&#39;: 1677596834.564557, &#39;ctime&#39;: 1677596834.564557, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/systemd-private-63552066ae0f41f8b3f40451498e4ff1-systemd-resolved.service-ODYbtj&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 402665, &#39;dev&#39;: 2049, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677596833.9565601, &#39;mtime&#39;: 1677596833.9565601, &#39;ctime&#39;: 1677596833.9565601, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/systemd-private-63552066ae0f41f8b3f40451498e4ff1-systemd-logind.service-3e3WGf&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 788745, &#39;dev&#39;: 2049, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677596646.7835886, &#39;mtime&#39;: 1677596646.7835886, &#39;ctime&#39;: 1677596646.7835886, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/systemd-private-63552066ae0f41f8b3f40451498e4ff1-chrony.service-KU8mhf&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 402669, &#39;dev&#39;: 2049, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677596913.092651, &#39;mtime&#39;: 1677596913.092651, &#39;ctime&#39;: 1677596913.092651, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/vmware-root_11732-2832205138&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 400095, &#39;dev&#39;: 2049, &#39;nlink&#39;: 2, &#39;atime&#39;: 1677596832.1765683, &#39;mtime&#39;: 1677596832.1765683, &#39;ctime&#39;: 1677596832.1765683, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/vmware-root_435-1848905162&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 788741, &#39;dev&#39;: 2049, &#39;nlink&#39;: 2, &#39;atime&#39;: 1677596647.2115886, &#39;mtime&#39;: 1677596647.2115886, &#39;ctime&#39;: 1677596647.2115886, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/systemd-private-63552066ae0f41f8b3f40451498e4ff1-systemd-hostnamed.service-09uISe&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 402716, &#39;dev&#39;: 2049, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677597214.7612596, &#39;mtime&#39;: 1677597214.7612596, &#39;ctime&#39;: 1677597214.7612596, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/tmp/systemd-private-63552066ae0f41f8b3f40451498e4ff1-systemd-resolved.service-3M3Qwh&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 787951, &#39;dev&#39;: 2049, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677596833.9565601, &#39;mtime&#39;: 1677596833.9565601, &#39;ctime&#39;: 1677596833.9565601, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/tmp/systemd-private-63552066ae0f41f8b3f40451498e4ff1-chrony.service-qhrzGi&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 276520, &#39;dev&#39;: 2049, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677596913.092651, &#39;mtime&#39;: 1677596913.092651, &#39;ctime&#39;: 1677596913.092651, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/tmp/systemd-private-63552066ae0f41f8b3f40451498e4ff1-systemd-logind.service-5Ee1Zh&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 788747, &#39;dev&#39;: 2049, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677596646.7835886, &#39;mtime&#39;: 1677596646.7835886, &#39;ctime&#39;: 1677596646.7835886, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/tmp/systemd-private-63552066ae0f41f8b3f40451498e4ff1-systemd-hostnamed.service-SbNfXe&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 262171, &#39;dev&#39;: 2049, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677597214.7612596, &#39;mtime&#39;: 1677597214.7612596, &#39;ctime&#39;: 1677597214.7612596, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere:
    vsphere: [WARNING]: Skipped &#39;/run/netplan&#39; path due to this access issue: &#39;/run/netplan&#39;
    vsphere: TASK [sysprep : Find netplan files] ********************************************
    vsphere: is not a directory
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Delete netplan files] ******************************************
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/netplan/01-netcfg.yaml&#39;, &#39;mode&#39;: &#39;0644&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 195, &#39;inode&#39;: 1048713, &#39;dev&#39;: 2049, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677596772.6521707, &#39;mtime&#39;: 1677596518.2793102, &#39;ctime&#39;: 1677596518.2793102, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: True, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: True, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere:
    vsphere: TASK [sysprep : Find SSH host keys] ********************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove SSH host keys] ******************************************
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_rsa_key&#39;, &#39;mode&#39;: &#39;0600&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 2602, &#39;inode&#39;: 1049683, &#39;dev&#39;: 2049, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677596646.8235886, &#39;mtime&#39;: 1677596605.0113115, &#39;ctime&#39;: 1677596605.0113115, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_ecdsa_key.pub&#39;, &#39;mode&#39;: &#39;0644&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 176, &#39;inode&#39;: 1049686, &#39;dev&#39;: 2049, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677596605.0233116, &#39;mtime&#39;: 1677596605.0193117, &#39;ctime&#39;: 1677596605.0193117, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: True, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: True, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_ecdsa_key&#39;, &#39;mode&#39;: &#39;0600&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 505, &#39;inode&#39;: 1049685, &#39;dev&#39;: 2049, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677596646.8275886, &#39;mtime&#39;: 1677596605.0193117, &#39;ctime&#39;: 1677596605.0193117, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_ed25519_key&#39;, &#39;mode&#39;: &#39;0600&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 411, &#39;inode&#39;: 1049687, &#39;dev&#39;: 2049, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677596646.8315885, &#39;mtime&#39;: 1677596605.0273116, &#39;ctime&#39;: 1677596605.0273116, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_ed25519_key.pub&#39;, &#39;mode&#39;: &#39;0644&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 96, &#39;inode&#39;: 1049688, &#39;dev&#39;: 2049, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677596605.0313115, &#39;mtime&#39;: 1677596605.0273116, &#39;ctime&#39;: 1677596605.0273116, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: True, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: True, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_rsa_key.pub&#39;, &#39;mode&#39;: &#39;0644&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 568, &#39;inode&#39;: 1049684, &#39;dev&#39;: 2049, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677596605.0153117, &#39;mtime&#39;: 1677596605.0113115, &#39;ctime&#39;: 1677596605.0113115, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: True, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: True, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere:
    vsphere: TASK [sysprep : Remove SSH authorized users] ***********************************
    vsphere: ok: [default] =&gt; (item={&#39;path&#39;: &#39;/root/.ssh/authorized_keys&#39;})
    vsphere: ok: [default] =&gt; (item={&#39;path&#39;: &#39;/home/builder/.ssh/authorized_keys&#39;})
    vsphere:
    vsphere: TASK [sysprep : Truncate all remaining log files in /var/log] ******************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Delete all logrotated log zips] ********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Truncate shell history] ****************************************
    vsphere: ok: [default] =&gt; (item={&#39;path&#39;: &#39;/root/.bash_history&#39;})
    vsphere: ok: [default] =&gt; (item={&#39;path&#39;: &#39;/home/builder/.bash_history&#39;})
    vsphere:
    vsphere: TASK [sysprep : Rotate journalctl to archive logs] *****************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove archived journalctl logs] *******************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : start ssh] *****************************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: PLAY RECAP *********************************************************************
    vsphere: default                    : ok=103  changed=77   unreachable=0    failed=0    skipped=203  rescued=0    ignored=0
    vsphere:
==&gt; vsphere: Provisioning with Goss
==&gt; vsphere: Configured to run on Linux
    vsphere: Creating directory: /tkg-tmp/goss
    vsphere: Installing Goss from, https://github.com/aelsabbahy/goss/releases/download/v0.3.16/goss-linux-amd64
    vsphere: Downloading Goss to /tkg-tmp/goss-linux-amd64
==&gt; vsphere:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
==&gt; vsphere:                                  Dload  Upload   Total   Spent    Left  Speed
==&gt; vsphere:   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
==&gt; vsphere:   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
==&gt; vsphere: 100 11.8M  100 11.8M    0     0  3271k      0  0:00:03  0:00:03 --:--:-- 5114k
    vsphere: goss version v0.3.16
==&gt; vsphere: Uploading goss tests...
    vsphere: Inline variables are --vars-inline &#39;{&#34;ARCH&#34;:&#34;amd64&#34;,&#34;OS&#34;:&#34;ubuntu&#34;,&#34;OS_VERSION&#34;:&#34;20.04&#34;,&#34;PROVIDER&#34;:&#34;ova&#34;,&#34;containerd_version&#34;:&#34;v1.6.6&#43;vmware.2&#34;,&#34;kubernetes_cni_deb_version&#34;:&#34;1.1.1-00&#34;,&#34;kubernetes_cni_rpm_version&#34;:&#34;1.1.1&#34;,&#34;kubernetes_cni_source_type&#34;:&#34;http&#34;,&#34;kubernetes_cni_version&#34;:&#34;1.1.1&#43;vmware.7&#34;,&#34;kubernetes_deb_version&#34;:&#34;1.23.10-00&#34;,&#34;kubernetes_rpm_version&#34;:&#34;1.23.10&#34;,&#34;kubernetes_source_type&#34;:&#34;http&#34;,&#34;kubernetes_version&#34;:&#34;1.23.10&#43;vmware.1&#34;}&#39;
    vsphere: Uploading Dir /home/imagebuilder/goss
    vsphere: Creating directory: /tkg-tmp/goss/goss
==&gt; vsphere:
==&gt; vsphere:
==&gt; vsphere:
==&gt; vsphere: Running goss tests...
==&gt; vsphere: Running GOSS validate command: cd /tkg-tmp/goss &amp;&amp; sudo  /tkg-tmp/goss-linux-amd64 --gossfile goss/goss.yaml  --vars-inline &#39;{&#34;ARCH&#34;:&#34;amd64&#34;,&#34;OS&#34;:&#34;ubuntu&#34;,&#34;OS_VERSION&#34;:&#34;20.04&#34;,&#34;PROVIDER&#34;:&#34;ova&#34;,&#34;containerd_version&#34;:&#34;v1.6.6&#43;vmware.2&#34;,&#34;kubernetes_cni_deb_version&#34;:&#34;1.1.1-00&#34;,&#34;kubernetes_cni_rpm_version&#34;:&#34;1.1.1&#34;,&#34;kubernetes_cni_source_type&#34;:&#34;http&#34;,&#34;kubernetes_cni_version&#34;:&#34;1.1.1&#43;vmware.7&#34;,&#34;kubernetes_deb_version&#34;:&#34;1.23.10-00&#34;,&#34;kubernetes_rpm_version&#34;:&#34;1.23.10&#34;,&#34;kubernetes_source_type&#34;:&#34;http&#34;,&#34;kubernetes_version&#34;:&#34;1.23.10&#43;vmware.1&#34;}&#39; validate --retry-timeout 0s --sleep 1s -f json -o pretty
    vsphere: Error: file error: read goss/goss.yaml: is a directory
==&gt; vsphere: Goss validate failed
==&gt; vsphere: Inspect mode on : proceeding without failing Packer
==&gt; vsphere: Running GOSS render command: cd /tkg-tmp/goss &amp;&amp;  /tkg-tmp/goss-linux-amd64 --gossfile goss/goss.yaml  --vars-inline &#39;{&#34;ARCH&#34;:&#34;amd64&#34;,&#34;OS&#34;:&#34;ubuntu&#34;,&#34;OS_VERSION&#34;:&#34;20.04&#34;,&#34;PROVIDER&#34;:&#34;ova&#34;,&#34;containerd_version&#34;:&#34;v1.6.6&#43;vmware.2&#34;,&#34;kubernetes_cni_deb_version&#34;:&#34;1.1.1-00&#34;,&#34;kubernetes_cni_rpm_version&#34;:&#34;1.1.1&#34;,&#34;kubernetes_cni_source_type&#34;:&#34;http&#34;,&#34;kubernetes_cni_version&#34;:&#34;1.1.1&#43;vmware.7&#34;,&#34;kubernetes_deb_version&#34;:&#34;1.23.10-00&#34;,&#34;kubernetes_rpm_version&#34;:&#34;1.23.10&#34;,&#34;kubernetes_source_type&#34;:&#34;http&#34;,&#34;kubernetes_version&#34;:&#34;1.23.10&#43;vmware.1&#34;}&#39; render &gt; /tmp/goss-spec.yaml
==&gt; vsphere: file error: read goss/goss.yaml: is a directory
==&gt; vsphere: Goss render failed
==&gt; vsphere: Inspect mode on : proceeding without failing Packer
==&gt; vsphere: Running GOSS render debug command: cd /tkg-tmp/goss &amp;&amp;  /tkg-tmp/goss-linux-amd64 --gossfile goss/goss.yaml  --vars-inline &#39;{&#34;ARCH&#34;:&#34;amd64&#34;,&#34;OS&#34;:&#34;ubuntu&#34;,&#34;OS_VERSION&#34;:&#34;20.04&#34;,&#34;PROVIDER&#34;:&#34;ova&#34;,&#34;containerd_version&#34;:&#34;v1.6.6&#43;vmware.2&#34;,&#34;kubernetes_cni_deb_version&#34;:&#34;1.1.1-00&#34;,&#34;kubernetes_cni_rpm_version&#34;:&#34;1.1.1&#34;,&#34;kubernetes_cni_source_type&#34;:&#34;http&#34;,&#34;kubernetes_cni_version&#34;:&#34;1.1.1&#43;vmware.7&#34;,&#34;kubernetes_deb_version&#34;:&#34;1.23.10-00&#34;,&#34;kubernetes_rpm_version&#34;:&#34;1.23.10&#34;,&#34;kubernetes_source_type&#34;:&#34;http&#34;,&#34;kubernetes_version&#34;:&#34;1.23.10&#43;vmware.1&#34;}&#39; render -d &gt; /tmp/debug-goss-spec.yaml
==&gt; vsphere: file error: read goss/goss.yaml: is a directory
==&gt; vsphere: Goss render debug failed
==&gt; vsphere: Inspect mode on : proceeding without failing Packer
==&gt; vsphere:
==&gt; vsphere:
==&gt; vsphere:
==&gt; vsphere: Downloading spec file and debug info
    vsphere: Downloading Goss specs from, /tmp/goss-spec.yaml and /tmp/debug-goss-spec.yaml to current dir
==&gt; vsphere: Executing shutdown command...
==&gt; vsphere: Deleting Floppy drives...
==&gt; vsphere: Deleting Floppy image...
==&gt; vsphere: Eject CD-ROM drives...
==&gt; vsphere: Convert VM into template...
    vsphere: Starting export...
    vsphere: Downloading: ubuntu-2004-kube-v1.23.10_vmware.1-disk-0.vmdk
    vsphere: Exporting file: ubuntu-2004-kube-v1.23.10_vmware.1-disk-0.vmdk
    vsphere: Writing ovf...
==&gt; vsphere: Clear boot order...
==&gt; vsphere: Running post-processor: packer-manifest (type manifest)
==&gt; vsphere: Running post-processor: vsphere (type shell-local)
==&gt; vsphere (shell-local): Running local shell script: /tmp/packer-shell750060967
    vsphere (shell-local): Opening OVF source: ubuntu-2004-kube-v1.23.10&#43;vmware.1.ovf
    vsphere (shell-local): Opening OVA target: ubuntu-2004-kube-v1.23.10&#43;vmware.1.ova
    vsphere (shell-local): Writing OVA package: ubuntu-2004-kube-v1.23.10&#43;vmware.1.ova
    vsphere (shell-local): Transfer Completed
    vsphere (shell-local): Warning:
    vsphere (shell-local):  - No manifest file found.
    vsphere (shell-local):  - No supported manifest(sha1, sha256, sha512) entry found for: &#39;ubuntu-2004-kube-v1.23.10_vmware.1-disk-0.vmdk&#39;.
    vsphere (shell-local): Completed successfully
    vsphere (shell-local): image-build-ova: cd .
    vsphere (shell-local): image-build-ova: loaded ubuntu-2004-kube-v1.23.10&#43;vmware.1
    vsphere (shell-local): image-build-ova: create ovf ubuntu-2004-kube-v1.23.10&#43;vmware.1.ovf
    vsphere (shell-local): image-build-ova: creating OVA from ubuntu-2004-kube-v1.23.10&#43;vmware.1.ovf using ovftool
    vsphere (shell-local): image-build-ova: create ova checksum ubuntu-2004-kube-v1.23.10&#43;vmware.1.ova.sha256
==&gt; vsphere: Running post-processor: custom-post-processor (type shell-local)
==&gt; vsphere (shell-local): Running local shell script: /tmp/packer-shell508306614
Build &#39;vsphere&#39; finished after 17 minutes 24 seconds.

==&gt; Wait completed after 17 minutes 24 seconds

==&gt; Builds finished. The artifacts of successful builds are:
--&gt; vsphere: ubuntu-2004-kube-v1.23.10_vmware.1
--&gt; vsphere: ubuntu-2004-kube-v1.23.10_vmware.1
--&gt; vsphere: ubuntu-2004-kube-v1.23.10_vmware.1
--&gt; vsphere: ubuntu-2004-kube-v1.23.10_vmware.1
```
```shell
## output 폴더 OVA 생성
## 1.6 
ls output/ubuntu-2004-kube-v1.23.10_vmware.1/
packer-manifest.json  ubuntu-2004-kube-v1.23.10&#43;vmware.1.ova  ubuntu-2004-kube-v1.23.10&#43;vmware.1.ova.sha256  ubuntu-2004-kube-v1.23.10&#43;vmware.1.ovf  ubuntu-2004-kube-v1.23.10_vmware.1-disk-0.vmdk  ubuntu-2004-kube-v1.23.10_vmware.1.ovf

## 2.1
ls output/ubuntu-2004-kube-v1.24.9_vmware.1/
packer-manifest.json  ubuntu-2004-kube-v1.24.9_vmware.1-disk-0.vmdk  ubuntu-2004-kube-v1.24.9&#43;vmware.1.ova  ubuntu-2004-kube-v1.24.9&#43;vmware.1.ova.sha256  ubuntu-2004-kube-v1.24.9&#43;vmware.1.ovf  ubuntu-2004-kube-v1.24.9_vmware.1.ovf
```
{{&lt; /admonition &gt;}}

## 4. RHEL Custom Image 생성

{{&lt; admonition tip &#34;rhel-8.json 생성&#34; &gt;}}
```shell
cat &lt;&lt; &#39;EOF&#39; &gt; rhel-8.json
{
  &#34;boot_command_prefix&#34;: &#34;&lt;up&gt;&lt;tab&gt; text inst.ks=&#34;,
  &#34;boot_command_suffix&#34;: &#34;/8/ks.cfg&lt;enter&gt;&lt;wait&gt;&#34;,
  &#34;boot_media_path&#34;: &#34;http://{{ .HTTPIP }}:{{ .HTTPPort }}&#34;,
  &#34;build_name&#34;: &#34;rhel-8&#34;,
  &#34;distro_arch&#34;: &#34;amd64&#34;,
  &#34;distro_name&#34;: &#34;rhel&#34;,
  &#34;distro_version&#34;: &#34;8&#34;,
  &#34;epel_rpm_gpg_key&#34;: &#34;https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8&#34;,
  &#34;guest_os_type&#34;: &#34;rhel8-64&#34;,
  &#34;http_directory&#34;: &#34;./packer/ova/linux/{{user `distro_name`}}/http/&#34;,
  &#34;iso_checksum&#34;: &#34;a6a7418a75d721cc696d3cbdd648b5248808e7fef0f8742f518e43b46fa08139&#34;,
  &#34;iso_checksum_type&#34;: &#34;sha256&#34;,
  &#34;iso_url&#34;: &#34;./rhel-8.7-x86_64-dvd.iso&#34;,
  &#34;os_display_name&#34;: &#34;RHEL 8&#34;,
  &#34;redhat_epel_rpm&#34;: &#34;https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm&#34;,
  &#34;shutdown_command&#34;: &#34;shutdown -P now&#34;,
  &#34;vsphere_guest_os_type&#34;: &#34;rhel8_64Guest&#34;
}
EOF
```
{{&lt; /admonition &gt;}}
{{&lt; admonition tip &#34;rhel-8 생성&#34; &gt;}}
```shell
## RHSM_USER= --env RHSM_PASS= \ -- subscription user/pw 설정

## 1.6 설정
docker run -it --rm \
  -v $(pwd)/vsphere.json:/home/imagebuilder/vsphere.json \
  -v $(pwd)/tkg.json:/home/imagebuilder/tkg.json \
  -v $(pwd)/tkg:/home/imagebuilder/tkg \
  -v $(pwd)/goss/vsphere-ubuntu-1.23.10&#43;vmware.2-goss-spec.yaml:/home/imagebuilder/goss/goss.yaml \
  -v $(pwd)/metadata.json:/home/imagebuilder/metadata.json \
  -v $(pwd)/output:/home/imagebuilder/output \
  -v $(pwd)/rhel-8.json:/home/imagebuilder/packer/ova/rhel-8.json \
  -v $(pwd)/ks.cfg:/home/imagebuilder/packer/ova/linux/photon/http/3/ks.cfg \
  -v $(pwd)/rhel-8.7-x86_64-dvd.iso:/home/imagebuilder/rhel-8.7-x86_64-dvd.iso \
  --network host \
  --env RHSM_USER={ID} --env RHSM_PASS={PW} \
  --env PACKER_VAR_FILES=&#34;tkg.json vsphere.json&#34; \
  --env OVF_CUSTOM_PROPERTIES=/home/imagebuilder/metadata.json \
  --env IB_OVFTOOL=1 \
  --env IB_OVFTOOL_ARGS=&#34;--allowExtraConfig&#34; \
  projects.registry.vmware.com/tkg/image-builder:v0.1.13_vmware.2 \
  build-node-ova-vsphere-rhel-8

## 2.1 설정
docker run -it --rm \
  -v $(pwd)/vsphere.json:/home/imagebuilder/vsphere.json \
  -v $(pwd)/tkg.json:/home/imagebuilder/tkg.json \
  -v $(pwd)/tkg:/home/imagebuilder/tkg \
  -v $(pwd)/goss/vsphere-rhel-8-v1.24.9&#43;vmware.1-tkg_v2_1_0-goss-spec.yaml:/home/imagebuilder/goss/goss.yaml \
  -v $(pwd)/metadata.json:/home/imagebuilder/metadata.json \
  -v $(pwd)/output:/home/imagebuilder/output \
  -v $(pwd)/rhel-8.json:/home/imagebuilder/packer/ova/rhel-8.json \
  -v $(pwd)/ks.cfg:/home/imagebuilder/packer/ova/linux/photon/http/3/ks.cfg \
  -v $(pwd)/rhel-8.7-x86_64-dvd.iso:/home/imagebuilder/rhel-8.7-x86_64-dvd.iso \
  --network host \
  --env RHSM_USER={ID} --env RHSM_PASS={PW} \
  --env PACKER_VAR_FILES=&#34;tkg.json vsphere.json&#34; \
  --env OVF_CUSTOM_PROPERTIES=/home/imagebuilder/metadata.json \
  --env IB_OVFTOOL=1 \
  --env IB_OVFTOOL_ARGS=&#34;--allowExtraConfig&#34; \
  projects.registry.vmware.com/tkg/image-builder:v0.1.13_vmware.2 \
  build-node-ova-vsphere-rhel-8
```
{{&lt; /admonition &gt;}}

{{&lt; admonition tip &#34;LOG&#34; &gt;}}

## rhel 8 이미지 로그

```shell
hack/ensure-ansible.sh
Starting galaxy collection install process
Nothing to do. All requested collections are already installed. If you want to reinstall them, consider using `--force`.
hack/ensure-ansible-windows.sh
hack/ensure-packer.sh
hack/ensure-goss.sh
Right version of binary present
hack/ensure-ovftool.sh
packer build -var-file=&#34;/home/imagebuilder/packer/config/kubernetes.json&#34;  -var-file=&#34;/home/imagebuilder/packer/config/cni.json&#34;  -var-file=&#34;/home/imagebuilder/packer/config/containerd.json&#34;  -var-file=&#34;/home/imagebuilder/packer/config/ansible-args.json&#34;  -var-file=&#34;/home/imagebuilder/packer/config/goss-args.json&#34;  -var-file=&#34;/home/imagebuilder/packer/config/common.json&#34;  -var-file=&#34;/home/imagebuilder/packer/config/additional_components.json&#34;  -color=true  -var-file=&#34;packer/ova/packer-common.json&#34; -var-file=&#34;/home/imagebuilder/packer/ova/rhel-8.json&#34; -var-file=&#34;packer/ova/vsphere.json&#34;  -except=local -only=vsphere-iso -var-file=&#34;/home/imagebuilder/tkg.json&#34;  -var-file=&#34;/home/imagebuilder/vsphere.json&#34;  -only=vsphere packer/ova/packer-node.json
vsphere: output will be in this color.

==&gt; vsphere: Retrieving ISO
==&gt; vsphere: Trying ./rhel-8.7-x86_64-dvd.iso
==&gt; vsphere: Trying ./rhel-8.7-x86_64-dvd.iso?checksum=sha256%3Aa6a7418a75d721cc696d3cbdd648b5248808e7fef0f8742f518e43b46fa08139
==&gt; vsphere: ./rhel-8.7-x86_64-dvd.iso?checksum=sha256%3Aa6a7418a75d721cc696d3cbdd648b5248808e7fef0f8742f518e43b46fa08139 =&gt; /home/imagebuilder/rhel-8.7-x86_64-dvd.iso
==&gt; vsphere: Uploading rhel-8.7-x86_64-dvd.iso to packer_cache/rhel-8.7-x86_64-dvd.iso
==&gt; vsphere: Creating VM...
==&gt; vsphere: Customizing hardware...
==&gt; vsphere: Mounting ISO images...
==&gt; vsphere: Adding configuration parameters...
==&gt; vsphere: Starting HTTP server on port 8709
==&gt; vsphere: Set boot order temporary...
==&gt; vsphere: Power on VM...
==&gt; vsphere: Waiting 10s for boot...
==&gt; vsphere: HTTP server is working at http://10.253.126.163:8709/
==&gt; vsphere: Typing boot command...
==&gt; vsphere: Waiting for IP...
==&gt; vsphere: IP address: 10.253.126.195
==&gt; vsphere: Using SSH communicator to connect: 10.253.126.195
==&gt; vsphere: Waiting for SSH to become available...
==&gt; vsphere: Connected to SSH!
==&gt; vsphere: Provisioning with shell script: ./packer/files/flatcar/scripts/bootstrap-flatcar.sh
==&gt; vsphere: Provisioning with Ansible...
    vsphere: Setting up proxy adapter for Ansible....
==&gt; vsphere: Executing Ansible: ansible-playbook -e packer_build_name=&#34;vsphere&#34; -e packer_*****_type=vsphere-iso -e packer_http_addr=10.253.126.163:8709 --ssh-extra-args &#39;-o IdentitiesOnly=yes&#39; --extra-vars containerd_url=http://10.253.126.163:3000/files/containerd/cri-containerd-v1.6.6&#43;vmware.2.linux-amd64.tar containerd_sha256=48f4327570dd7543464a28893160ab3bc9719ed2553f0a529a884b40f6dafd29 pause_image=projects.registry.vmware.com/tkg/pause:3.6 containerd_additional_settings= containerd_cri_socket=/var/run/containerd/containerd.sock containerd_version=v1.6.6&#43;vmware.2 crictl_url= crictl_sha256= crictl_source_type=pkg custom_role_names=&#34;/home/image*****/tkg&#34; firstboot_custom_roles_pre=&#34;&#34; firstboot_custom_roles_post=&#34;&#34; node_custom_roles_pre=&#34;&#34; node_custom_roles_post=&#34;&#34; disable_public_repos=false extra_debs=&#34;nfs-common unzip apparmor apparmor-utils sysstat&#34; extra_repos=&#34;&#34; extra_rpms=&#34;sysstat&#34; http_proxy= https_proxy= kubeadm_template=etc/kubeadm.yml kubernetes_cni_http_source=http://10.253.126.163:3000/files/cni_plugins kubernetes_cni_http_checksum= kubernetes_http_source=http://10.253.126.163:3000/files/kubernetes kubernetes_container_registry=projects.registry.vmware.com/tkg kubernetes_rpm_repo=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64 kubernetes_rpm_gpg_key=&#34;https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg&#34; kubernetes_rpm_gpg_check=True kubernetes_deb_repo=&#34;https://apt.kubernetes.io/ kubernetes-xenial&#34; kubernetes_deb_gpg_key=https://packages.cloud.google.com/apt/doc/apt-key.gpg kubernetes_cni_deb_version=1.1.1-00 kubernetes_cni_rpm_version=1.1.1-0 kubernetes_cni_semver=v1.1.1&#43;vmware.7 kubernetes_cni_source_type=http kubernetes_semver=v1.23.10&#43;vmware.1 kubernetes_source_type=http kubernetes_load_additional_imgs=true kubernetes_deb_version=1.23.10-00 kubernetes_rpm_version=1.23.10-0 no_proxy= pip_conf_file= python_path= redhat_epel_rpm=https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm epel_rpm_gpg_key=https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8 reenable_public_repos=true remove_extra_repos=false systemd_prefix=/usr/lib/systemd sysusr_prefix=/usr sysusrlocal_prefix=/usr/local load_additional_components=false additional_registry_images=false additional_registry_images_list= additional_url_images=false additional_url_images_list= additional_executables=false additional_executables_list= additional_executables_destination_path= build_target=virt amazon_ssm_agent_rpm= --extra-vars guestinfo_datasource_slug=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo guestinfo_datasource_ref=v1.4.1 guestinfo_datasource_script=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/v1.4.1/install.sh --extra-vars  -e ansible_ssh_private_key_file=/tmp/ansible-key1071931383 -i /tmp/packer-provisioner-ansible1131624432 /home/image*****/ansible/firstboot.yml
    vsphere:
    vsphere: PLAY [all] *********************************************************************
    vsphere:
    vsphere: TASK [Gathering Facts] *********************************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [include_role : firstboot] ************************************************
    vsphere:
    vsphere: PLAY RECAP *********************************************************************
    vsphere: default                    : ok=1    changed=0    unreachable=0    failed=0    skipped=80   rescued=0    ignored=0
    vsphere:
==&gt; vsphere: Provisioning with shell script: /tmp/packer-shell2138983735
==&gt; vsphere: Provisioning with Ansible...
    vsphere: Setting up proxy adapter for Ansible....
==&gt; vsphere: Executing Ansible: ansible-playbook -e packer_build_name=&#34;vsphere&#34; -e packer_*****_type=vsphere-iso -e packer_http_addr=10.253.126.163:8709 --ssh-extra-args &#39;-o IdentitiesOnly=yes&#39; --extra-vars containerd_url=http://10.253.126.163:3000/files/containerd/cri-containerd-v1.6.6&#43;vmware.2.linux-amd64.tar containerd_sha256=48f4327570dd7543464a28893160ab3bc9719ed2553f0a529a884b40f6dafd29 pause_image=projects.registry.vmware.com/tkg/pause:3.6 containerd_additional_settings= containerd_cri_socket=/var/run/containerd/containerd.sock containerd_version=v1.6.6&#43;vmware.2 crictl_url= crictl_sha256= crictl_source_type=pkg custom_role_names=&#34;/home/image*****/tkg&#34; firstboot_custom_roles_pre=&#34;&#34; firstboot_custom_roles_post=&#34;&#34; node_custom_roles_pre=&#34;&#34; node_custom_roles_post=&#34;&#34; disable_public_repos=false extra_debs=&#34;nfs-common unzip apparmor apparmor-utils sysstat&#34; extra_repos=&#34;&#34; extra_rpms=&#34;sysstat&#34; http_proxy= https_proxy= kubeadm_template=etc/kubeadm.yml kubernetes_cni_http_source=http://10.253.126.163:3000/files/cni_plugins kubernetes_cni_http_checksum= kubernetes_http_source=http://10.253.126.163:3000/files/kubernetes kubernetes_container_registry=projects.registry.vmware.com/tkg kubernetes_rpm_repo=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64 kubernetes_rpm_gpg_key=&#34;https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg&#34; kubernetes_rpm_gpg_check=True kubernetes_deb_repo=&#34;https://apt.kubernetes.io/ kubernetes-xenial&#34; kubernetes_deb_gpg_key=https://packages.cloud.google.com/apt/doc/apt-key.gpg kubernetes_cni_deb_version=1.1.1-00 kubernetes_cni_rpm_version=1.1.1-0 kubernetes_cni_semver=v1.1.1&#43;vmware.7 kubernetes_cni_source_type=http kubernetes_semver=v1.23.10&#43;vmware.1 kubernetes_source_type=http kubernetes_load_additional_imgs=true kubernetes_deb_version=1.23.10-00 kubernetes_rpm_version=1.23.10-0 no_proxy= pip_conf_file= python_path= redhat_epel_rpm=https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm epel_rpm_gpg_key=https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8 reenable_public_repos=true remove_extra_repos=false systemd_prefix=/usr/lib/systemd sysusr_prefix=/usr sysusrlocal_prefix=/usr/local load_additional_components=false additional_registry_images=false additional_registry_images_list= additional_url_images=false additional_url_images_list= additional_executables=false additional_executables_list= additional_executables_destination_path= build_target=virt amazon_ssm_agent_rpm= --extra-vars guestinfo_datasource_slug=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo guestinfo_datasource_ref=v1.4.1 guestinfo_datasource_script=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/v1.4.1/install.sh --extra-vars  -e ansible_ssh_private_key_file=/tmp/ansible-key652222647 -i /tmp/packer-provisioner-ansible1252180858 /home/image*****/ansible/node.yml
    vsphere:
    vsphere: PLAY [all] *********************************************************************
    vsphere:
    vsphere: TASK [Gathering Facts] *********************************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [include_role : node] *****************************************************
    vsphere:
    vsphere: TASK [setup : RHEL subscription] ***********************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [setup : import epel gpg key] *********************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [setup : add epel repo] ***************************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [setup : perform a yum update] ********************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [setup : install baseline dependencies] ***********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [setup : install extra rpms] **********************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [node : Ensure overlay module is present] *********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Ensure br_netfilter module is present] ****************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Persist required kernel modules] **********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Set and persist kernel params] ************************************
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.bridge.bridge-nf-call-iptables&#39;, &#39;val&#39;: 1})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.bridge.bridge-nf-call-ip6tables&#39;, &#39;val&#39;: 1})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv4.ip_forward&#39;, &#39;val&#39;: 1})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv6.conf.all.forwarding&#39;, &#39;val&#39;: 1})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv6.conf.all.disable_ipv6&#39;, &#39;val&#39;: 0})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv4.tcp_congestion_control&#39;, &#39;val&#39;: &#39;bbr&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;vm.overcommit_memory&#39;, &#39;val&#39;: 1})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;kernel.panic&#39;, &#39;val&#39;: 10})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;kernel.panic_on_oops&#39;, &#39;val&#39;: 1})
    vsphere:
    vsphere: TASK [node : Disable conntrackd service] ***************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [node : Ensure auditd is running and comes on at reboot] ******************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [node : configure auditd rules for containerd] ****************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Set transparent huge pages to madvise] ****************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Copy udev etcd network tuning rules] ******************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Copy etcd network tuning script] **********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [include_role : providers] ************************************************
    vsphere:
    vsphere: TASK [providers : include_tasks] ***********************************************
    vsphere: included: /home/imagebuilder/ansible/roles/providers/tasks/vmware.yml for default
    vsphere:
    vsphere: TASK [providers : include_tasks] ***********************************************
    vsphere: included: /home/imagebuilder/ansible/roles/providers/tasks/vmware-redhat.yml for default
    vsphere:
    vsphere: TASK [providers : Install cloud-init packages] *********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Download cloud-init datasource for VMware Guestinfo] *********
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Execute cloud-init-vmware.sh] ********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Remove cloud-init-vmware.sh] *********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Create provider vmtools config drop-in file] *****************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Create service to modify cloud-init config] ******************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Copy cloud-init modification script] *************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Enable modify-cloud-init-cfg.service] ************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Creates unit file directory for cloud-final] *****************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Create cloud-final boot order drop in file] ******************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Creates unit file directory for cloud-config] ****************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Create cloud-final boot order drop in file] ******************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Make sure all cloud init services are enabled] ***************
    vsphere: ok: [default] =&gt; (item=cloud-final)
    vsphere: ok: [default] =&gt; (item=cloud-config)
    vsphere: ok: [default] =&gt; (item=cloud-init)
    vsphere: ok: [default] =&gt; (item=cloud-init-local)
    vsphere:
    vsphere: TASK [providers : Create cloud-init config file] *******************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Ensure chrony is running] ************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [include_role : containerd] ***********************************************
    vsphere:
    vsphere: TASK [containerd : Install libseccomp package] *********************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [containerd : download containerd] ****************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Create a directory if it does not exist] ********************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : unpack containerd] ******************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : delete /opt/cni directory] **********************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [containerd : delete /etc/cni directory] **********************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [containerd : Creates unit file directory] ********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Create containerd memory pressure drop in file] *************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Create containerd max tasks drop in file] *******************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Create containerd http proxy conf file if needed] ***********
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Creates containerd config directory] ************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Copy in containerd config file etc/containerd/config.toml] ***
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Copy in crictl config] **************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : start containerd service] ***********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : delete tarball] *********************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [include_role : kubernetes] ***********************************************
    vsphere:
    vsphere: TASK [kubernetes : Symlink cri-tools] ******************************************
    vsphere: changed: [default] =&gt; (item=ctr)
    vsphere: changed: [default] =&gt; (item=crictl)
    vsphere: changed: [default] =&gt; (item=critest)
    vsphere:
    vsphere: TASK [kubernetes : Create CNI directory] ***************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Download CNI tarball] ***************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Install CNI] ************************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Remove CNI tarball] *****************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Download Kubernetes binaries] *******************************
    vsphere: changed: [default] =&gt; (item=kubeadm)
    vsphere: changed: [default] =&gt; (item=kubectl)
    vsphere: changed: [default] =&gt; (item=kubelet)
    vsphere:
    vsphere: TASK [kubernetes : Download Kubernetes images] *********************************
    vsphere: changed: [default] =&gt; (item=kube-apiserver.tar)
    vsphere: changed: [default] =&gt; (item=kube-controller-manager.tar)
    vsphere: changed: [default] =&gt; (item=kube-scheduler.tar)
    vsphere: changed: [default] =&gt; (item=kube-proxy.tar)
    vsphere: changed: [default] =&gt; (item=pause.tar)
    vsphere: changed: [default] =&gt; (item=coredns.tar)
    vsphere: changed: [default] =&gt; (item=etcd.tar)
    vsphere:
    vsphere: TASK [kubernetes : Load Kubernetes images] *************************************
    vsphere: changed: [default] =&gt; (item=kube-apiserver.tar)
    vsphere: changed: [default] =&gt; (item=kube-controller-manager.tar)
    vsphere: changed: [default] =&gt; (item=kube-scheduler.tar)
    vsphere: changed: [default] =&gt; (item=kube-proxy.tar)
    vsphere: changed: [default] =&gt; (item=pause.tar)
    vsphere: changed: [default] =&gt; (item=coredns.tar)
    vsphere: changed: [default] =&gt; (item=etcd.tar)
    vsphere:
    vsphere: TASK [kubernetes : Remove Kubernetes images] ***********************************
    vsphere: changed: [default] =&gt; (item=kube-apiserver.tar)
    vsphere: changed: [default] =&gt; (item=kube-controller-manager.tar)
    vsphere: changed: [default] =&gt; (item=kube-scheduler.tar)
    vsphere: changed: [default] =&gt; (item=kube-proxy.tar)
    vsphere: changed: [default] =&gt; (item=pause.tar)
    vsphere: changed: [default] =&gt; (item=coredns.tar)
    vsphere: changed: [default] =&gt; (item=etcd.tar)
    vsphere:
    vsphere: TASK [kubernetes : Create Kubernetes manifests directory] **********************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Create kubelet sysconfig directory] *************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [kubernetes : Create kubelet drop-in directory] ***************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Create kubelet kubeadm drop-in file] ************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Create kubelet systemd file] ********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Create kubelet default config file] *************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Enable kubelet service] *************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Create the Kubernetes version file] *************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Check if Kubernetes container registry is using Amazon ECR] ***
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [include_role : {{ role }}] ***********************************************
    vsphere:
    vsphere: TASK [/home/imagebuilder/tkg : Create /tkg-tmp space] **************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [/home/imagebuilder/tkg : include_tasks] **********************************
    vsphere: included: /home/imagebuilder/tkg/tasks/vsphere.yml for default
    vsphere:
    vsphere: TASK [/home/imagebuilder/tkg : Set extra kernel params for GC threshhold] ******
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv4.neigh.default.gc_thresh1&#39;, &#39;val&#39;: 4096})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv6.neigh.default.gc_thresh1&#39;, &#39;val&#39;: 4096})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv4.neigh.default.gc_thresh2&#39;, &#39;val&#39;: 8192})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv6.neigh.default.gc_thresh2&#39;, &#39;val&#39;: 8192})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv4.neigh.default.gc_thresh3&#39;, &#39;val&#39;: 16384})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv6.neigh.default.gc_thresh3&#39;, &#39;val&#39;: 16384})
    vsphere:
    vsphere: TASK [/home/imagebuilder/tkg : Ensure fs.file-max is set] **********************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [include_role : sysprep] **************************************************
    vsphere:
    vsphere: TASK [sysprep : Define file modes] *********************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Get installed packages] ****************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : create the package list] ***************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : exclude the packages from upgrades] ****************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove subscriptions] ******************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Unregister system] *********************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : clean local subscription data] *********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove yum package caches] *************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove yum package lists] **************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Reset network interface IDs] ***********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove the kickstart log] **************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove containerd http proxy conf file if needed] **************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Truncate machine id] *******************************************
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/machine-id&#39;, &#39;state&#39;: &#39;absent&#39;, &#39;mode&#39;: &#39;0444&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/machine-id&#39;, &#39;state&#39;: &#39;touch&#39;, &#39;mode&#39;: &#39;0444&#39;})
    vsphere:
    vsphere: TASK [sysprep : Truncate hostname file] ****************************************
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/hostname&#39;, &#39;state&#39;: &#39;absent&#39;, &#39;mode&#39;: &#39;0644&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/hostname&#39;, &#39;state&#39;: &#39;touch&#39;, &#39;mode&#39;: &#39;0644&#39;})
    vsphere:
    vsphere: TASK [sysprep : Set hostname] **************************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Reset hosts file] **********************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Truncate audit logs] *******************************************
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/log/wtmp&#39;, &#39;state&#39;: &#39;absent&#39;, &#39;mode&#39;: &#39;0664&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/log/lastlog&#39;, &#39;state&#39;: &#39;absent&#39;, &#39;mode&#39;: &#39;0644&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/log/wtmp&#39;, &#39;state&#39;: &#39;touch&#39;, &#39;mode&#39;: &#39;0664&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/log/lastlog&#39;, &#39;state&#39;: &#39;touch&#39;, &#39;mode&#39;: &#39;0644&#39;})
    vsphere:
    vsphere: TASK [sysprep : Remove cloud-init lib dir and logs] ****************************
    vsphere: changed: [default] =&gt; (item=/var/lib/cloud)
    vsphere: ok: [default] =&gt; (item=/var/log/cloud-init.log)
    vsphere: ok: [default] =&gt; (item=/var/log/cloud-init-output.log)
    vsphere: changed: [default] =&gt; (item=/var/run/cloud-init)
    vsphere:
    vsphere: TASK [sysprep : Find temp files] ***********************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Reset temp space] **********************************************
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/tmp.fstab&#39;, &#39;mode&#39;: &#39;0644&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 34, &#39;inode&#39;: 917558, &#39;dev&#39;: 2049, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677598881.515565, &#39;mtime&#39;: 1677598881.511565, &#39;ctime&#39;: 1677598881.511565, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: True, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: True, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/ks-script-womie7ev&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 701, &#39;inode&#39;: 917515, &#39;dev&#39;: 2049, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677598324.1556787, &#39;mtime&#39;: 1677598324.1486788, &#39;ctime&#39;: 1677598324.1486788, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/ks-script-8szmx8f8&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 291, &#39;inode&#39;: 917517, &#39;dev&#39;: 2049, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677598326.7056713, &#39;mtime&#39;: 1677598326.6976714, &#39;ctime&#39;: 1677598326.6976714, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/systemd-private-b8ce99c5a00043e28de4419f4592fc36-systemd-hostnamed.service-a3ZTtU&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 917547, &#39;dev&#39;: 2049, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677598962.1890013, &#39;mtime&#39;: 1677598962.1890013, &#39;ctime&#39;: 1677598962.1890013, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/systemd-private-b8ce99c5a00043e28de4419f4592fc36-chronyd.service-1qPo5I&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 917523, &#39;dev&#39;: 2049, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677598344.4472764, &#39;mtime&#39;: 1677598344.4472764, &#39;ctime&#39;: 1677598344.4472764, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/vmware-root_756-2965382642&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 917527, &#39;dev&#39;: 2049, &#39;nlink&#39;: 2, &#39;atime&#39;: 1677598344.8446836, &#39;mtime&#39;: 1677598344.8446836, &#39;ctime&#39;: 1677598344.8446836, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: ok: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/ansible_find_payload_zej9mp7r&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 917531, &#39;dev&#39;: 2049, &#39;nlink&#39;: 2, &#39;atime&#39;: 1677598971.9629292, &#39;mtime&#39;: 1677598971.9639292, &#39;ctime&#39;: 1677598971.9639292, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/tmp/systemd-private-b8ce99c5a00043e28de4419f4592fc36-systemd-hostnamed.service-xvJeOq&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 1050059, &#39;dev&#39;: 2049, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677598962.1890013, &#39;mtime&#39;: 1677598962.1900015, &#39;ctime&#39;: 1677598962.1900015, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/tmp/systemd-private-b8ce99c5a00043e28de4419f4592fc36-chronyd.service-CiirL0&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 1050453, &#39;dev&#39;: 2049, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677598344.4472764, &#39;mtime&#39;: 1677598344.4472764, &#39;ctime&#39;: 1677598344.4472764, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere:
    vsphere: [WARNING]: Skipped &#39;/lib/netplan&#39; path due to this access issue: &#39;/lib/netplan&#39;
    vsphere: TASK [sysprep : Find netplan files] ********************************************
    vsphere: is not a directory
    vsphere: ok: [default]
    vsphere: [WARNING]: Skipped &#39;/etc/netplan&#39; path due to this access issue: &#39;/etc/netplan&#39;
    vsphere: is not a directory
    vsphere: [WARNING]: Skipped &#39;/run/netplan&#39; path due to this access issue: &#39;/run/netplan&#39;
    vsphere: is not a directory
    vsphere:
    vsphere: TASK [sysprep : Find SSH host keys] ********************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove SSH host keys] ******************************************
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_ecdsa_key.pub&#39;, &#39;mode&#39;: &#39;0644&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 162, &#39;inode&#39;: 787156, &#39;dev&#39;: 2049, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677598344.7996838, &#39;mtime&#39;: 1677598344.4712763, &#39;ctime&#39;: 1677598344.4872763, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: True, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: True, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_ecdsa_key&#39;, &#39;mode&#39;: &#39;0640&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 995, &#39;size&#39;: 480, &#39;inode&#39;: 787155, &#39;dev&#39;: 2049, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677598344.7996838, &#39;mtime&#39;: 1677598344.4712763, &#39;ctime&#39;: 1677598344.4812763, &#39;gr_name&#39;: &#39;ssh_keys&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: True, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_ed25519_key&#39;, &#39;mode&#39;: &#39;0640&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 995, &#39;size&#39;: 387, &#39;inode&#39;: 787153, &#39;dev&#39;: 2049, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677598344.7996838, &#39;mtime&#39;: 1677598344.4712763, &#39;ctime&#39;: 1677598344.4852762, &#39;gr_name&#39;: &#39;ssh_keys&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: True, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_rsa_key.pub&#39;, &#39;mode&#39;: &#39;0644&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 554, &#39;inode&#39;: 787158, &#39;dev&#39;: 2049, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677598344.7996838, &#39;mtime&#39;: 1677598344.7286837, &#39;ctime&#39;: 1677598344.7676837, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: True, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: True, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_rsa_key&#39;, &#39;mode&#39;: &#39;0640&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 995, &#39;size&#39;: 2578, &#39;inode&#39;: 787157, &#39;dev&#39;: 2049, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677598344.7986836, &#39;mtime&#39;: 1677598344.7286837, &#39;ctime&#39;: 1677598344.7676837, &#39;gr_name&#39;: &#39;ssh_keys&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: True, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_ed25519_key.pub&#39;, &#39;mode&#39;: &#39;0644&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 82, &#39;inode&#39;: 787154, &#39;dev&#39;: 2049, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677598344.7996838, &#39;mtime&#39;: 1677598344.4712763, &#39;ctime&#39;: 1677598344.4872763, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: True, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: True, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere:
    vsphere: TASK [sysprep : Remove SSH authorized users] ***********************************
    vsphere: ok: [default] =&gt; (item={&#39;path&#39;: &#39;/root/.ssh/authorized_keys&#39;})
    vsphere: ok: [default] =&gt; (item={&#39;path&#39;: &#39;/home/builder/.ssh/authorized_keys&#39;})
    vsphere:
    vsphere: TASK [sysprep : Truncate all remaining log files in /var/log] ******************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Delete all logrotated log zips] ********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Truncate shell history] ****************************************
    vsphere: ok: [default] =&gt; (item={&#39;path&#39;: &#39;/root/.bash_history&#39;})
    vsphere: ok: [default] =&gt; (item={&#39;path&#39;: &#39;/home/builder/.bash_history&#39;})
    vsphere:
    vsphere: TASK [sysprep : Rotate journalctl to archive logs] *****************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove archived journalctl logs] *******************************
    vsphere: changed: [default]
    vsphere:
    vsphere: PLAY RECAP *********************************************************************
    vsphere: default                    : ok=100  changed=77   unreachable=0    failed=0    skipped=208  rescued=0    ignored=0
    vsphere:
==&gt; vsphere: Provisioning with Goss
==&gt; vsphere: Configured to run on Linux
    vsphere: Creating directory: /tkg-tmp/goss
    vsphere: Installing Goss from, https://github.com/aelsabbahy/goss/releases/download/v0.3.16/goss-linux-amd64
    vsphere: Downloading Goss to /tkg-tmp/goss-linux-amd64
==&gt; vsphere:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
==&gt; vsphere:                                  Dload  Upload   Total   Spent    Left  Speed
==&gt; vsphere:   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
==&gt; vsphere:   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
==&gt; vsphere: 100 11.8M  100 11.8M    0     0  2901k      0  0:00:04  0:00:04 --:--:-- 4025k
    vsphere: goss version v0.3.16
==&gt; vsphere: Uploading goss tests...
    vsphere: Inline variables are --vars-inline &#39;{&#34;ARCH&#34;:&#34;amd64&#34;,&#34;OS&#34;:&#34;rhel&#34;,&#34;OS_VERSION&#34;:&#34;8&#34;,&#34;PROVIDER&#34;:&#34;ova&#34;,&#34;containerd_version&#34;:&#34;v1.6.6&#43;vmware.2&#34;,&#34;kubernetes_cni_deb_version&#34;:&#34;1.1.1-00&#34;,&#34;kubernetes_cni_rpm_version&#34;:&#34;1.1.1&#34;,&#34;kubernetes_cni_source_type&#34;:&#34;http&#34;,&#34;kubernetes_cni_version&#34;:&#34;1.1.1&#43;vmware.7&#34;,&#34;kubernetes_deb_version&#34;:&#34;1.23.10-00&#34;,&#34;kubernetes_rpm_version&#34;:&#34;1.23.10&#34;,&#34;kubernetes_source_type&#34;:&#34;http&#34;,&#34;kubernetes_version&#34;:&#34;1.23.10&#43;vmware.1&#34;}&#39;
    vsphere: Uploading Dir /home/imagebuilder/goss
    vsphere: Creating directory: /tkg-tmp/goss/goss
==&gt; vsphere:
==&gt; vsphere:
==&gt; vsphere:
==&gt; vsphere: Running goss tests...
==&gt; vsphere: Running GOSS render command: cd /tkg-tmp/goss &amp;&amp;  /tkg-tmp/goss-linux-amd64 --gossfile goss/goss.yaml  --vars-inline &#39;{&#34;ARCH&#34;:&#34;amd64&#34;,&#34;OS&#34;:&#34;rhel&#34;,&#34;OS_VERSION&#34;:&#34;8&#34;,&#34;PROVIDER&#34;:&#34;ova&#34;,&#34;containerd_version&#34;:&#34;v1.6.6&#43;vmware.2&#34;,&#34;kubernetes_cni_deb_version&#34;:&#34;1.1.1-00&#34;,&#34;kubernetes_cni_rpm_version&#34;:&#34;1.1.1&#34;,&#34;kubernetes_cni_source_type&#34;:&#34;http&#34;,&#34;kubernetes_cni_version&#34;:&#34;1.1.1&#43;vmware.7&#34;,&#34;kubernetes_deb_version&#34;:&#34;1.23.10-00&#34;,&#34;kubernetes_rpm_version&#34;:&#34;1.23.10&#34;,&#34;kubernetes_source_type&#34;:&#34;http&#34;,&#34;kubernetes_version&#34;:&#34;1.23.10&#43;vmware.1&#34;}&#39; render &gt; /tmp/goss-spec.yaml
==&gt; vsphere: file error: read goss/goss.yaml: is a directory
==&gt; vsphere: Goss render failed
==&gt; vsphere: Inspect mode on : proceeding without failing Packer
==&gt; vsphere: Running GOSS render debug command: cd /tkg-tmp/goss &amp;&amp;  /tkg-tmp/goss-linux-amd64 --gossfile goss/goss.yaml  --vars-inline &#39;{&#34;ARCH&#34;:&#34;amd64&#34;,&#34;OS&#34;:&#34;rhel&#34;,&#34;OS_VERSION&#34;:&#34;8&#34;,&#34;PROVIDER&#34;:&#34;ova&#34;,&#34;containerd_version&#34;:&#34;v1.6.6&#43;vmware.2&#34;,&#34;kubernetes_cni_deb_version&#34;:&#34;1.1.1-00&#34;,&#34;kubernetes_cni_rpm_version&#34;:&#34;1.1.1&#34;,&#34;kubernetes_cni_source_type&#34;:&#34;http&#34;,&#34;kubernetes_cni_version&#34;:&#34;1.1.1&#43;vmware.7&#34;,&#34;kubernetes_deb_version&#34;:&#34;1.23.10-00&#34;,&#34;kubernetes_rpm_version&#34;:&#34;1.23.10&#34;,&#34;kubernetes_source_type&#34;:&#34;http&#34;,&#34;kubernetes_version&#34;:&#34;1.23.10&#43;vmware.1&#34;}&#39; render -d &gt; /tmp/debug-goss-spec.yaml
==&gt; vsphere: file error: read goss/goss.yaml: is a directory
==&gt; vsphere: Goss render debug failed
==&gt; vsphere: Inspect mode on : proceeding without failing Packer
==&gt; vsphere: Running GOSS validate command: cd /tkg-tmp/goss &amp;&amp; sudo  /tkg-tmp/goss-linux-amd64 --gossfile goss/goss.yaml  --vars-inline &#39;{&#34;ARCH&#34;:&#34;amd64&#34;,&#34;OS&#34;:&#34;rhel&#34;,&#34;OS_VERSION&#34;:&#34;8&#34;,&#34;PROVIDER&#34;:&#34;ova&#34;,&#34;containerd_version&#34;:&#34;v1.6.6&#43;vmware.2&#34;,&#34;kubernetes_cni_deb_version&#34;:&#34;1.1.1-00&#34;,&#34;kubernetes_cni_rpm_version&#34;:&#34;1.1.1&#34;,&#34;kubernetes_cni_source_type&#34;:&#34;http&#34;,&#34;kubernetes_cni_version&#34;:&#34;1.1.1&#43;vmware.7&#34;,&#34;kubernetes_deb_version&#34;:&#34;1.23.10-00&#34;,&#34;kubernetes_rpm_version&#34;:&#34;1.23.10&#34;,&#34;kubernetes_source_type&#34;:&#34;http&#34;,&#34;kubernetes_version&#34;:&#34;1.23.10&#43;vmware.1&#34;}&#39; validate --retry-timeout 0s --sleep 1s -f json -o pretty
    vsphere: Error: file error: read goss/goss.yaml: is a directory
==&gt; vsphere: Goss validate failed
==&gt; vsphere: Inspect mode on : proceeding without failing Packer
==&gt; vsphere:
==&gt; vsphere:
==&gt; vsphere:
==&gt; vsphere: Downloading spec file and debug info
    vsphere: Downloading Goss specs from, /tmp/goss-spec.yaml and /tmp/debug-goss-spec.yaml to current dir
==&gt; vsphere: Executing shutdown command...
==&gt; vsphere: Deleting Floppy drives...
==&gt; vsphere: Eject CD-ROM drives...
==&gt; vsphere: Convert VM into template...
    vsphere: Starting export...
    vsphere: Downloading: rhel-8-kube-v1.23.10_vmware.1-disk-0.vmdk
    vsphere: Exporting file: rhel-8-kube-v1.23.10_vmware.1-disk-0.vmdk
    vsphere: Writing ovf...
==&gt; vsphere: Clear boot order...
==&gt; vsphere: Running post-processor: packer-manifest (type manifest)
==&gt; vsphere: Running post-processor: vsphere (type shell-local)
==&gt; vsphere (shell-local): Running local shell script: /tmp/packer-shell4251240128
    vsphere (shell-local): Opening OVF source: rhel-8-kube-v1.23.10&#43;vmware.1.ovf
    vsphere (shell-local): Opening OVA target: rhel-8-kube-v1.23.10&#43;vmware.1.ova
    vsphere (shell-local): Writing OVA package: rhel-8-kube-v1.23.10&#43;vmware.1.ova
    vsphere (shell-local): Transfer Completed
    vsphere (shell-local): Warning:
    vsphere (shell-local):  - No manifest file found.
    vsphere (shell-local):  - No supported manifest(sha1, sha256, sha512) entry found for: &#39;rhel-8-kube-v1.23.10_vmware.1-disk-0.vmdk&#39;.
    vsphere (shell-local): Completed successfully
    vsphere (shell-local): image-build-ova: cd .
    vsphere (shell-local): image-build-ova: loaded rhel-8-kube-v1.23.10&#43;vmware.1
    vsphere (shell-local): image-build-ova: create ovf rhel-8-kube-v1.23.10&#43;vmware.1.ovf
    vsphere (shell-local): image-build-ova: creating OVA from rhel-8-kube-v1.23.10&#43;vmware.1.ovf using ovftool
    vsphere (shell-local): image-build-ova: create ova checksum rhel-8-kube-v1.23.10&#43;vmware.1.ova.sha256
==&gt; vsphere: Running post-processor: custom-post-processor (type shell-local)
==&gt; vsphere (shell-local): Running local shell script: /tmp/packer-shell2087900433
Build &#39;vsphere&#39; finished after 25 minutes 32 seconds.

==&gt; Wait completed after 25 minutes 32 seconds

==&gt; Builds finished. The artifacts of successful builds are:
--&gt; vsphere: rhel-8-kube-v1.23.10_vmware.1
--&gt; vsphere: rhel-8-kube-v1.23.10_vmware.1
--&gt; vsphere: rhel-8-kube-v1.23.10_vmware.1
--&gt; vsphere: rhel-8-kube-v1.23.10_vmware.1

```

```shell
## output 폴더 OVA 생성

## 1.6 
ls output/rhel-8-kube-v1.23.10_vmware.1/
packer-manifest.json  rhel-8-kube-v1.23.10&#43;vmware.1.ova  rhel-8-kube-v1.23.10&#43;vmware.1.ova.sha256  rhel-8-kube-v1.23.10&#43;vmware.1.ovf  rhel-8-kube-v1.23.10_vmware.1-disk-0.vmdk  rhel-8-kube-v1.23.10_vmware.1.ovf

## 2.1
ls output/rhel-8-kube-v1.24.9_vmware.1/
packer-manifest.json  rhel-8-kube-v1.24.9_vmware.1-disk-0.vmdk  rhel-8-kube-v1.24.9&#43;vmware.1.ova  rhel-8-kube-v1.24.9&#43;vmware.1.ova.sha256  rhel-8-kube-v1.24.9&#43;vmware.1.ovf  rhel-8-kube-v1.24.9_vmware.1.ovf
```
{{&lt; /admonition &gt;}}

## 5. Photon Custom Image 생성

{{&lt; admonition tip &#34;LOG&#34; &gt;}}
```shell
## Photon Custom Image 생성시 아래와 같은 Log를 볼 수 있다, vCenter에서는 Template으로 생성이 되는 것을 확인 할 수 있다.
hack/ensure-ansible.sh
Starting galaxy collection install process
Nothing to do. All requested collections are already installed. If you want to reinstall them, consider using `--force`.
hack/ensure-ansible-windows.sh
hack/ensure-packer.sh
hack/ensure-goss.sh
Right version of binary present
hack/ensure-ovftool.sh
packer build -var-file=&#34;/home/imagebuilder/packer/config/kubernetes.json&#34;  -var-file=&#34;/home/imagebuilder/packer/config/cni.json&#34;  -var-file=&#34;/home/imagebuilder/packer/config/containerd.json&#34;  -var-file=&#34;/home/imagebuilder/packer/config/ansible-args.json&#34;  -var-file=&#34;/home/imagebuilder/packer/config/goss-args.json&#34;  -var-file=&#34;/home/imagebuilder/packer/config/common.json&#34;  -var-file=&#34;/home/imagebuilder/packer/config/additional_components.json&#34;  -color=true  -var-file=&#34;packer/ova/packer-common.json&#34; -var-file=&#34;/home/imagebuilder/packer/ova/photon-3.json&#34; -var-file=&#34;packer/ova/vsphere.json&#34;  -except=local -only=vsphere-iso -var-file=&#34;/home/imagebuilder/tkg.json&#34;  -var-file=&#34;/home/imagebuilder/vsphere.json&#34;  -only=vsphere packer/ova/packer-node.json
vsphere: output will be in this color.

==&gt; vsphere: File /home/imagebuilder/.cache/packer/2d88648c04e690990b2940ca3710b0baadf15256.iso already uploaded; continuing
==&gt; vsphere: File [vsanDatastore] packer_cache//2d88648c04e690990b2940ca3710b0baadf15256.iso already exists; skipping upload.
==&gt; vsphere: Creating VM...
==&gt; vsphere: Customizing hardware...
==&gt; vsphere: Mounting ISO images...
==&gt; vsphere: Adding configuration parameters...
==&gt; vsphere: Starting HTTP server on port 8897
==&gt; vsphere: Set boot order temporary...
==&gt; vsphere: Power on VM...
==&gt; vsphere: Waiting 10s for boot...
==&gt; vsphere: HTTP server is working at http://10.253.126.163:8897/
==&gt; vsphere: Typing boot command...
==&gt; vsphere: Waiting for IP...
==&gt; vsphere: IP address: 10.253.126.198
==&gt; vsphere: Using SSH communicator to connect: 10.253.126.198
==&gt; vsphere: Waiting for SSH to become available...
==&gt; vsphere: Connected to SSH!
==&gt; vsphere: Provisioning with shell script: ./packer/files/flatcar/scripts/bootstrap-flatcar.sh
==&gt; vsphere: Provisioning with Ansible...
    vsphere: Setting up proxy adapter for Ansible....
==&gt; vsphere: Executing Ansible: ansible-playbook -e packer_build_name=&#34;vsphere&#34; -e packer_*****_type=vsphere-iso -e packer_http_addr=10.253.126.163:8897 --ssh-extra-args &#39;-o IdentitiesOnly=yes&#39; --extra-vars containerd_url=http://10.253.126.163:3000/files/containerd/cri-containerd-v1.6.6&#43;vmware.2.linux-amd64.tar containerd_sha256=48f4327570dd7543464a28893160ab3bc9719ed2553f0a529a884b40f6dafd29 pause_image=projects.registry.vmware.com/tkg/pause:3.6 containerd_additional_settings= containerd_cri_socket=/var/run/containerd/containerd.sock containerd_version=v1.6.6&#43;vmware.2 crictl_url= crictl_sha256= crictl_source_type=pkg custom_role_names=&#34;/home/image*****/tkg&#34; firstboot_custom_roles_pre=&#34;&#34; firstboot_custom_roles_post=&#34;&#34; node_custom_roles_pre=&#34;&#34; node_custom_roles_post=&#34;&#34; disable_public_repos=false extra_debs=&#34;nfs-common unzip apparmor apparmor-utils sysstat&#34; extra_repos=&#34;&#34; extra_rpms=&#34;sysstat&#34; http_proxy= https_proxy= kubeadm_template=etc/kubeadm.yml kubernetes_cni_http_source=http://10.253.126.163:3000/files/cni_plugins kubernetes_cni_http_checksum= kubernetes_http_source=http://10.253.126.163:3000/files/kubernetes kubernetes_container_registry=projects.registry.vmware.com/tkg kubernetes_rpm_repo=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64 kubernetes_rpm_gpg_key=&#34;https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg&#34; kubernetes_rpm_gpg_check=True kubernetes_deb_repo=&#34;https://apt.kubernetes.io/ kubernetes-xenial&#34; kubernetes_deb_gpg_key=https://packages.cloud.google.com/apt/doc/apt-key.gpg kubernetes_cni_deb_version=1.1.1-00 kubernetes_cni_rpm_version=1.1.1-0 kubernetes_cni_semver=v1.1.1&#43;vmware.7 kubernetes_cni_source_type=http kubernetes_semver=v1.23.10&#43;vmware.1 kubernetes_source_type=http kubernetes_load_additional_imgs=true kubernetes_deb_version=1.23.10-00 kubernetes_rpm_version=1.23.10-0 no_proxy= pip_conf_file= python_path= redhat_epel_rpm=https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm epel_rpm_gpg_key= reenable_public_repos=true remove_extra_repos=false systemd_prefix=/usr/lib/systemd sysusr_prefix=/usr sysusrlocal_prefix=/usr/local load_additional_components=false additional_registry_images=false additional_registry_images_list= additional_url_images=false additional_url_images_list= additional_executables=false additional_executables_list= additional_executables_destination_path= build_target=virt amazon_ssm_agent_rpm= --extra-vars guestinfo_datasource_slug=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo guestinfo_datasource_ref=v1.4.1 guestinfo_datasource_script=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/v1.4.1/install.sh --extra-vars  -e ansible_ssh_private_key_file=/tmp/ansible-key167164286 -i /tmp/packer-provisioner-ansible3699664147 /home/image*****/ansible/firstboot.yml
    vsphere:
    vsphere: PLAY [all] *********************************************************************
    vsphere:
    vsphere: [WARNING]: Platform linux on host default is using the discovered Python
    vsphere: TASK [Gathering Facts] *********************************************************
    vsphere: interpreter at /usr/bin/python, but future installation of another Python
    vsphere: ok: [default]
    vsphere: interpreter could change the meaning of that path. See
    vsphere: https://docs.ansible.com/ansible-
    vsphere: core/2.11/reference_appendices/interpreter_discovery.html for more information.
    vsphere:
    vsphere: TASK [include_role : firstboot] ************************************************
    vsphere:
    vsphere: TASK [setup : add bash_profile] ************************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [setup : Perform a tdnf distro-sync] **************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [setup : Concatenate the Photon RPMs] *************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [setup : install extra RPMs] **********************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [setup : Increase tmpfs size] *********************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [setup : reset iptables rules input] **************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [setup : reset ip6tables rules input] *************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [firstboot : include_tasks] ***********************************************
    vsphere: included: /home/imagebuilder/ansible/roles/firstboot/tasks/photon.yml for default
    vsphere:
    vsphere: TASK [firstboot : Set transparent huge pages to madvise] ***********************
    vsphere: changed: [default]
    vsphere:
    vsphere: PLAY RECAP *********************************************************************
    vsphere: default                    : ok=10   changed=7    unreachable=0    failed=0    skipped=72   rescued=0    ignored=0
    vsphere:
==&gt; vsphere: Provisioning with shell script: /tmp/packer-shell2422633172
==&gt; vsphere: Provisioning with Ansible...
    vsphere: Setting up proxy adapter for Ansible....
==&gt; vsphere: Executing Ansible: ansible-playbook -e packer_build_name=&#34;vsphere&#34; -e packer_*****_type=vsphere-iso -e packer_http_addr=10.253.126.163:8897 --ssh-extra-args &#39;-o IdentitiesOnly=yes&#39; --extra-vars containerd_url=http://10.253.126.163:3000/files/containerd/cri-containerd-v1.6.6&#43;vmware.2.linux-amd64.tar containerd_sha256=48f4327570dd7543464a28893160ab3bc9719ed2553f0a529a884b40f6dafd29 pause_image=projects.registry.vmware.com/tkg/pause:3.6 containerd_additional_settings= containerd_cri_socket=/var/run/containerd/containerd.sock containerd_version=v1.6.6&#43;vmware.2 crictl_url= crictl_sha256= crictl_source_type=pkg custom_role_names=&#34;/home/image*****/tkg&#34; firstboot_custom_roles_pre=&#34;&#34; firstboot_custom_roles_post=&#34;&#34; node_custom_roles_pre=&#34;&#34; node_custom_roles_post=&#34;&#34; disable_public_repos=false extra_debs=&#34;nfs-common unzip apparmor apparmor-utils sysstat&#34; extra_repos=&#34;&#34; extra_rpms=&#34;sysstat&#34; http_proxy= https_proxy= kubeadm_template=etc/kubeadm.yml kubernetes_cni_http_source=http://10.253.126.163:3000/files/cni_plugins kubernetes_cni_http_checksum= kubernetes_http_source=http://10.253.126.163:3000/files/kubernetes kubernetes_container_registry=projects.registry.vmware.com/tkg kubernetes_rpm_repo=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64 kubernetes_rpm_gpg_key=&#34;https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg&#34; kubernetes_rpm_gpg_check=True kubernetes_deb_repo=&#34;https://apt.kubernetes.io/ kubernetes-xenial&#34; kubernetes_deb_gpg_key=https://packages.cloud.google.com/apt/doc/apt-key.gpg kubernetes_cni_deb_version=1.1.1-00 kubernetes_cni_rpm_version=1.1.1-0 kubernetes_cni_semver=v1.1.1&#43;vmware.7 kubernetes_cni_source_type=http kubernetes_semver=v1.23.10&#43;vmware.1 kubernetes_source_type=http kubernetes_load_additional_imgs=true kubernetes_deb_version=1.23.10-00 kubernetes_rpm_version=1.23.10-0 no_proxy= pip_conf_file= python_path= redhat_epel_rpm=https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm epel_rpm_gpg_key= reenable_public_repos=true remove_extra_repos=false systemd_prefix=/usr/lib/systemd sysusr_prefix=/usr sysusrlocal_prefix=/usr/local load_additional_components=false additional_registry_images=false additional_registry_images_list= additional_url_images=false additional_url_images_list= additional_executables=false additional_executables_list= additional_executables_destination_path= build_target=virt amazon_ssm_agent_rpm= --extra-vars guestinfo_datasource_slug=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo guestinfo_datasource_ref=v1.4.1 guestinfo_datasource_script=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/v1.4.1/install.sh --extra-vars  -e ansible_ssh_private_key_file=/tmp/ansible-key3066177402 -i /tmp/packer-provisioner-ansible1843978590 /home/image*****/ansible/node.yml
    vsphere:
    vsphere: PLAY [all] *********************************************************************
    vsphere:
    vsphere: [WARNING]: Platform linux on host default is using the discovered Python
    vsphere: TASK [Gathering Facts] *********************************************************
    vsphere: interpreter at /usr/bin/python, but future installation of another Python
    vsphere: interpreter could change the meaning of that path. See
    vsphere: ok: [default]
    vsphere: https://docs.ansible.com/ansible-
    vsphere: core/2.11/reference_appendices/interpreter_discovery.html for more information.
    vsphere:
    vsphere: TASK [include_role : node] *****************************************************
    vsphere:
    vsphere: TASK [setup : add bash_profile] ************************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [setup : Perform a tdnf distro-sync] **************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [setup : Concatenate the Photon RPMs] *************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [setup : install baseline dependencies] ***********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [setup : install extra RPMs] **********************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [setup : Increase tmpfs size] *********************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [setup : reset iptables rules input] **************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [setup : reset ip6tables rules input] *************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [node : Double TCP small queue limit to be the same as Ubuntu] ************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Disable Apparmor service] *****************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Disable Apparmor in kernel] ***************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Ensure overlay module is present] *********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Ensure br_netfilter module is present] ****************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Persist required kernel modules] **********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Set and persist kernel params] ************************************
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.bridge.bridge-nf-call-iptables&#39;, &#39;val&#39;: 1})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.bridge.bridge-nf-call-ip6tables&#39;, &#39;val&#39;: 1})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv4.ip_forward&#39;, &#39;val&#39;: 1})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv6.conf.all.forwarding&#39;, &#39;val&#39;: 1})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv6.conf.all.disable_ipv6&#39;, &#39;val&#39;: 0})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv4.tcp_congestion_control&#39;, &#39;val&#39;: &#39;bbr&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;vm.overcommit_memory&#39;, &#39;val&#39;: 1})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;kernel.panic&#39;, &#39;val&#39;: 10})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;kernel.panic_on_oops&#39;, &#39;val&#39;: 1})
    vsphere:
    vsphere: TASK [node : Disable conntrackd service] ***************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Ensure auditd is running and comes on at reboot] ******************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : configure auditd rules for containerd] ****************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Copy udev etcd network tuning rules] ******************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [node : Copy etcd network tuning script] **********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [include_role : providers] ************************************************
    vsphere:
    vsphere: TASK [providers : include_tasks] ***********************************************
    vsphere: included: /home/imagebuilder/ansible/roles/providers/tasks/vmware.yml for default
    vsphere:
    vsphere: TASK [providers : include_tasks] ***********************************************
    vsphere: included: /home/imagebuilder/ansible/roles/providers/tasks/vmware-photon.yml for default
    vsphere:
    vsphere: TASK [providers : Install cloud-init and tools for VMware Photon OS] ***********
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Remove cloud-init /etc/cloud/cloud.cfg.d/99-disable-networking-config.cfg] ***
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [providers : Install networkd-dispatcher service (Download from source)] ***
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Create needed directories] ***********************************
    vsphere: changed: [default] =&gt; (item={&#39;dir&#39;: &#39;/etc/conf.d&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;dir&#39;: &#39;/etc/networkd-dispatcher/carrier.d&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;dir&#39;: &#39;/etc/networkd-dispatcher/configured.d&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;dir&#39;: &#39;/etc/networkd-dispatcher/configuring.d&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;dir&#39;: &#39;/etc/networkd-dispatcher/degraded.d&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;dir&#39;: &#39;/etc/networkd-dispatcher/dormant.d&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;dir&#39;: &#39;/etc/networkd-dispatcher/no-carrier.d&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;dir&#39;: &#39;/etc/networkd-dispatcher/off.d&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;dir&#39;: &#39;/etc/networkd-dispatcher/routable.d&#39;})
    vsphere:
    vsphere: TASK [providers : Install networkd-dispatcher service (Move files)] ************
    vsphere: changed: [default] =&gt; (item={&#39;src&#39;: &#39;/tmp/networkd-dispatcher-2.1/networkd-dispatcher&#39;, &#39;dest&#39;: &#39;/usr/bin&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;src&#39;: &#39;/tmp/networkd-dispatcher-2.1/networkd-dispatcher.service&#39;, &#39;dest&#39;: &#39;/etc/systemd/system&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;src&#39;: &#39;/tmp/networkd-dispatcher-2.1/networkd-dispatcher.conf&#39;, &#39;dest&#39;: &#39;/etc/conf.d&#39;})
    vsphere:
    vsphere: TASK [providers : Install networkd-dispatcher service (Run networkd-dispatcher)] ***
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Copy networkd-dispatcher scripts to add DHCP provided NTP servers] ***
    vsphere: changed: [default] =&gt; (item={&#39;src&#39;: &#39;files/etc/networkd-dispatcher/routable.d/20-chrony.j2&#39;, &#39;dest&#39;: &#39;/etc/networkd-dispatcher/routable.d/20-chrony&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;src&#39;: &#39;files/etc/networkd-dispatcher/off.d/20-chrony.j2&#39;, &#39;dest&#39;: &#39;/etc/networkd-dispatcher/off.d/20-chrony&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;src&#39;: &#39;files/etc/networkd-dispatcher/no-carrier.d/20-chrony.j2&#39;, &#39;dest&#39;: &#39;/etc/networkd-dispatcher/no-carrier.d/20-chrony&#39;})
    vsphere:
    vsphere: TASK [providers : Copy chrony-helper script] ***********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Create provider vmtools config drop-in file] *****************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Create service to modify cloud-init config] ******************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Copy cloud-init modification script] *************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Enable modify-cloud-init-cfg.service] ************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Creates unit file directory for cloud-final] *****************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Create cloud-final boot order drop in file] ******************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Creates unit file directory for cloud-config] ****************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Create cloud-final boot order drop in file] ******************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Make sure all cloud init services are enabled] ***************
    vsphere: ok: [default] =&gt; (item=cloud-final)
    vsphere: ok: [default] =&gt; (item=cloud-config)
    vsphere: ok: [default] =&gt; (item=cloud-init)
    vsphere: ok: [default] =&gt; (item=cloud-init-local)
    vsphere:
    vsphere: TASK [providers : Create cloud-init config file] *******************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Ensure chrony is running] ************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [include_role : containerd] ***********************************************
    vsphere:
    vsphere: TASK [containerd : Install libseccomp package] *********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : download containerd] ****************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Create a directory if it does not exist] ********************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [containerd : unpack containerd] ******************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : delete /opt/cni directory] **********************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [containerd : delete /etc/cni directory] **********************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [containerd : Creates unit file directory] ********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Create containerd memory pressure drop in file] *************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Create containerd max tasks drop in file] *******************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Create containerd http proxy conf file if needed] ***********
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Creates containerd config directory] ************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Copy in containerd config file etc/containerd/config.toml] ***
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : Copy in crictl config] **************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : start containerd service] ***********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [containerd : delete tarball] *********************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [include_role : kubernetes] ***********************************************
    vsphere:
    vsphere: TASK [kubernetes : Symlink cri-tools] ******************************************
    vsphere: changed: [default] =&gt; (item=ctr)
    vsphere: changed: [default] =&gt; (item=crictl)
    vsphere: changed: [default] =&gt; (item=critest)
    vsphere:
    vsphere: TASK [kubernetes : Create CNI directory] ***************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Download CNI tarball] ***************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Install CNI] ************************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Remove CNI tarball] *****************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Download Kubernetes binaries] *******************************
    vsphere: changed: [default] =&gt; (item=kubeadm)
    vsphere: changed: [default] =&gt; (item=kubectl)
    vsphere: changed: [default] =&gt; (item=kubelet)
    vsphere:
    vsphere: TASK [kubernetes : Download Kubernetes images] *********************************
    vsphere: changed: [default] =&gt; (item=kube-apiserver.tar)
    vsphere: changed: [default] =&gt; (item=kube-controller-manager.tar)
    vsphere: changed: [default] =&gt; (item=kube-scheduler.tar)
    vsphere: changed: [default] =&gt; (item=kube-proxy.tar)
    vsphere: changed: [default] =&gt; (item=pause.tar)
    vsphere: changed: [default] =&gt; (item=coredns.tar)
    vsphere: changed: [default] =&gt; (item=etcd.tar)
    vsphere:
    vsphere: TASK [kubernetes : Load Kubernetes images] *************************************
    vsphere: changed: [default] =&gt; (item=kube-apiserver.tar)
    vsphere: changed: [default] =&gt; (item=kube-controller-manager.tar)
    vsphere: changed: [default] =&gt; (item=kube-scheduler.tar)
    vsphere: changed: [default] =&gt; (item=kube-proxy.tar)
    vsphere: changed: [default] =&gt; (item=pause.tar)
    vsphere: changed: [default] =&gt; (item=coredns.tar)
    vsphere: changed: [default] =&gt; (item=etcd.tar)
    vsphere:
    vsphere: TASK [kubernetes : Remove Kubernetes images] ***********************************
    vsphere: changed: [default] =&gt; (item=kube-apiserver.tar)
    vsphere: changed: [default] =&gt; (item=kube-controller-manager.tar)
    vsphere: changed: [default] =&gt; (item=kube-scheduler.tar)
    vsphere: changed: [default] =&gt; (item=kube-proxy.tar)
    vsphere: changed: [default] =&gt; (item=pause.tar)
    vsphere: changed: [default] =&gt; (item=coredns.tar)
    vsphere: changed: [default] =&gt; (item=etcd.tar)
    vsphere:
    vsphere: TASK [kubernetes : Create Kubernetes manifests directory] **********************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Create kubelet sysconfig directory] *************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [kubernetes : Create kubelet drop-in directory] ***************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Create kubelet kubeadm drop-in file] ************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Create kubelet systemd file] ********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Create kubelet default config file] *************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Enable kubelet service] *************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Create the Kubernetes version file] *************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [kubernetes : Check if Kubernetes container registry is using Amazon ECR] ***
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [include_role : {{ role }}] ***********************************************
    vsphere:
    vsphere: TASK [/home/imagebuilder/tkg : Create /tkg-tmp space] **************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [/home/imagebuilder/tkg : include_tasks] **********************************
    vsphere: included: /home/imagebuilder/tkg/tasks/vsphere.yml for default
    vsphere:
    vsphere: TASK [/home/imagebuilder/tkg : Set extra kernel params for GC threshhold] ******
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv4.neigh.default.gc_thresh1&#39;, &#39;val&#39;: 4096})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv6.neigh.default.gc_thresh1&#39;, &#39;val&#39;: 4096})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv4.neigh.default.gc_thresh2&#39;, &#39;val&#39;: 8192})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv6.neigh.default.gc_thresh2&#39;, &#39;val&#39;: 8192})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv4.neigh.default.gc_thresh3&#39;, &#39;val&#39;: 16384})
    vsphere: changed: [default] =&gt; (item={&#39;param&#39;: &#39;net.ipv6.neigh.default.gc_thresh3&#39;, &#39;val&#39;: 16384})
    vsphere:
    vsphere: TASK [/home/imagebuilder/tkg : Ensure fs.file-max is set] **********************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [include_role : sysprep] **************************************************
    vsphere:
    vsphere: TASK [sysprep : Define file modes] *********************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : set hostname] **************************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove the kickstart log] **************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Get installed packages] ****************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : create a package list] *****************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : exclude packages from upgrade] *********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove tdnf package caches] ************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Lock root account] *********************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove containerd http proxy conf file if needed] **************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Truncate machine id] *******************************************
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/machine-id&#39;, &#39;state&#39;: &#39;absent&#39;, &#39;mode&#39;: &#39;0444&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/machine-id&#39;, &#39;state&#39;: &#39;touch&#39;, &#39;mode&#39;: &#39;0444&#39;})
    vsphere:
    vsphere: TASK [sysprep : Truncate hostname file] ****************************************
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/hostname&#39;, &#39;state&#39;: &#39;absent&#39;, &#39;mode&#39;: &#39;0644&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/hostname&#39;, &#39;state&#39;: &#39;touch&#39;, &#39;mode&#39;: &#39;0644&#39;})
    vsphere:
    vsphere: TASK [sysprep : Reset hosts file] **********************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Truncate audit logs] *******************************************
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/log/wtmp&#39;, &#39;state&#39;: &#39;absent&#39;, &#39;mode&#39;: &#39;0664&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/log/lastlog&#39;, &#39;state&#39;: &#39;absent&#39;, &#39;mode&#39;: &#39;0644&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/log/wtmp&#39;, &#39;state&#39;: &#39;touch&#39;, &#39;mode&#39;: &#39;0664&#39;})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/log/lastlog&#39;, &#39;state&#39;: &#39;touch&#39;, &#39;mode&#39;: &#39;0644&#39;})
    vsphere:
    vsphere: TASK [sysprep : Remove cloud-init lib dir and logs] ****************************
    vsphere: changed: [default] =&gt; (item=/var/lib/cloud)
    vsphere: changed: [default] =&gt; (item=/var/log/cloud-init.log)
    vsphere: changed: [default] =&gt; (item=/var/log/cloud-init-output.log)
    vsphere: changed: [default] =&gt; (item=/var/run/cloud-init)
    vsphere:
    vsphere: TASK [sysprep : Find temp files] ***********************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Reset temp space] **********************************************
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/tmp.fstab&#39;, &#39;mode&#39;: &#39;0640&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 34, &#39;inode&#39;: 57450, &#39;dev&#39;: 40, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677665217.6763215, &#39;mtime&#39;: 1677665217.6723216, &#39;ctime&#39;: 1677665217.6723216, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: True, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: ok: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/ansible_find_payload_3hbfsyyc&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 60, &#39;inode&#39;: 63432, &#39;dev&#39;: 40, &#39;nlink&#39;: 2, &#39;atime&#39;: 1677665254.2719367, &#39;mtime&#39;: 1677665254.2719367, &#39;ctime&#39;: 1677665254.2719367, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/systemd-private-3a2fc663b4fc47f4ba32428a1da69c77-systemd-hostnamed.service-xJnZMS&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 60, &#39;inode&#39;: 57839, &#39;dev&#39;: 40, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677665228.8361993, &#39;mtime&#39;: 1677665228.8361993, &#39;ctime&#39;: 1677665228.8361993, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/systemd-private-3a2fc663b4fc47f4ba32428a1da69c77-chronyd.service-fJ6BYJ&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 60, &#39;inode&#39;: 38557, &#39;dev&#39;: 40, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677665108.6314168, &#39;mtime&#39;: 1677665108.6314168, &#39;ctime&#39;: 1677665108.6314168, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/networkd-dispatcher-2.1&#39;, &#39;mode&#39;: &#39;0775&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 240, &#39;inode&#39;: 31992, &#39;dev&#39;: 40, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677665059.744108, &#39;mtime&#39;: 1677665074.139975, &#39;ctime&#39;: 1677665074.139975, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: True, &#39;rgrp&#39;: True, &#39;xgrp&#39;: True, &#39;woth&#39;: False, &#39;roth&#39;: True, &#39;xoth&#39;: True, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/systemd-private-3a2fc663b4fc47f4ba32428a1da69c77-systemd-resolved.service-xp4jFP&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 60, &#39;inode&#39;: 17549, &#39;dev&#39;: 40, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677664816.3119998, &#39;mtime&#39;: 1677664816.3119998, &#39;ctime&#39;: 1677664816.3119998, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/systemd-private-3a2fc663b4fc47f4ba32428a1da69c77-systemd-networkd.service-t6w0pJ&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 60, &#39;inode&#39;: 17540, &#39;dev&#39;: 40, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677664816.1039999, &#39;mtime&#39;: 1677664816.1039999, &#39;ctime&#39;: 1677664816.1039999, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/tmp/vmware-root_477-2084322203&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 40, &#39;inode&#39;: 19486, &#39;dev&#39;: 40, &#39;nlink&#39;: 2, &#39;atime&#39;: 1677664812.5279999, &#39;mtime&#39;: 1677664812.5279999, &#39;ctime&#39;: 1677664812.5279999, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/tmp/systemd-private-3a2fc663b4fc47f4ba32428a1da69c77-systemd-networkd.service-aPq1ih&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 1048662, &#39;dev&#39;: 2051, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677664816.1039999, &#39;mtime&#39;: 1677664816.1039999, &#39;ctime&#39;: 1677664816.1039999, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/tmp/systemd-private-3a2fc663b4fc47f4ba32428a1da69c77-systemd-resolved.service-kXLC1n&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 1048689, &#39;dev&#39;: 2051, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677664816.3119998, &#39;mtime&#39;: 1677664816.3119998, &#39;ctime&#39;: 1677664816.3119998, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: ok: [default] =&gt; (item={&#39;path&#39;: &#39;/var/tmp/systemd-private-3a2fc663b4fc47f4ba32428a1da69c77-systemd-hostnamed.service-cCjnEF&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 1055760, &#39;dev&#39;: 2051, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677665228.8361993, &#39;mtime&#39;: 1677665228.8361993, &#39;ctime&#39;: 1677665228.8361993, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/var/tmp/systemd-private-3a2fc663b4fc47f4ba32428a1da69c77-chronyd.service-KHvBV5&#39;, &#39;mode&#39;: &#39;0700&#39;, &#39;isdir&#39;: True, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: False, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 4096, &#39;inode&#39;: 1048771, &#39;dev&#39;: 2051, &#39;nlink&#39;: 3, &#39;atime&#39;: 1677665108.6314168, &#39;mtime&#39;: 1677665108.6314168, &#39;ctime&#39;: 1677665108.6314168, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: True, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere:
    vsphere: [WARNING]: Skipped &#39;/lib/netplan&#39; path due to this access issue: &#39;/lib/netplan&#39;
    vsphere: TASK [sysprep : Find netplan files] ********************************************
    vsphere: is not a directory
    vsphere: [WARNING]: Skipped &#39;/etc/netplan&#39; path due to this access issue: &#39;/etc/netplan&#39;
    vsphere: ok: [default]
    vsphere: is not a directory
    vsphere: [WARNING]: Skipped &#39;/run/netplan&#39; path due to this access issue: &#39;/run/netplan&#39;
    vsphere: is not a directory
    vsphere:
    vsphere: TASK [sysprep : Find SSH host keys] ********************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove SSH host keys] ******************************************
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_ed25519_key&#39;, &#39;mode&#39;: &#39;0600&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 411, &#39;inode&#39;: 655964, &#39;dev&#39;: 2051, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677664650.3719997, &#39;mtime&#39;: 1677664650.3719997, &#39;ctime&#39;: 1677664650.3719997, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_ecdsa_key&#39;, &#39;mode&#39;: &#39;0600&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 505, &#39;inode&#39;: 655962, &#39;dev&#39;: 2051, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677664650.3559997, &#39;mtime&#39;: 1677664650.3559997, &#39;ctime&#39;: 1677664650.3559997, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_dsa_key&#39;, &#39;mode&#39;: &#39;0600&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 1381, &#39;inode&#39;: 655960, &#39;dev&#39;: 2051, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677664650.3439996, &#39;mtime&#39;: 1677664650.3439996, &#39;ctime&#39;: 1677664650.3439996, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_dsa_key.pub&#39;, &#39;mode&#39;: &#39;0644&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 604, &#39;inode&#39;: 655961, &#39;dev&#39;: 2051, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677664650.3439996, &#39;mtime&#39;: 1677664650.3439996, &#39;ctime&#39;: 1677664650.3439996, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: True, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: True, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_rsa_key.pub&#39;, &#39;mode&#39;: &#39;0644&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 396, &#39;inode&#39;: 655959, &#39;dev&#39;: 2051, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677664650.2879996, &#39;mtime&#39;: 1677664650.2879996, &#39;ctime&#39;: 1677664650.2879996, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: True, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: True, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_rsa_key&#39;, &#39;mode&#39;: &#39;0600&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 1823, &#39;inode&#39;: 655957, &#39;dev&#39;: 2051, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677664650.2879996, &#39;mtime&#39;: 1677664650.2879996, &#39;ctime&#39;: 1677664650.2879996, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: False, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: False, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_ed25519_key.pub&#39;, &#39;mode&#39;: &#39;0644&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 96, &#39;inode&#39;: 655965, &#39;dev&#39;: 2051, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677664650.3719997, &#39;mtime&#39;: 1677664650.3719997, &#39;ctime&#39;: 1677664650.3719997, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: True, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: True, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/etc/ssh/ssh_host_ecdsa_key.pub&#39;, &#39;mode&#39;: &#39;0644&#39;, &#39;isdir&#39;: False, &#39;ischr&#39;: False, &#39;isblk&#39;: False, &#39;isreg&#39;: True, &#39;isfifo&#39;: False, &#39;islnk&#39;: False, &#39;issock&#39;: False, &#39;uid&#39;: 0, &#39;gid&#39;: 0, &#39;size&#39;: 176, &#39;inode&#39;: 655963, &#39;dev&#39;: 2051, &#39;nlink&#39;: 1, &#39;atime&#39;: 1677664650.3559997, &#39;mtime&#39;: 1677664650.3559997, &#39;ctime&#39;: 1677664650.3559997, &#39;gr_name&#39;: &#39;root&#39;, &#39;pw_name&#39;: &#39;root&#39;, &#39;wusr&#39;: True, &#39;rusr&#39;: True, &#39;xusr&#39;: False, &#39;wgrp&#39;: False, &#39;rgrp&#39;: True, &#39;xgrp&#39;: False, &#39;woth&#39;: False, &#39;roth&#39;: True, &#39;xoth&#39;: False, &#39;isuid&#39;: False, &#39;isgid&#39;: False})
    vsphere:
    vsphere: TASK [sysprep : Remove SSH authorized users] ***********************************
    vsphere: changed: [default] =&gt; (item={&#39;path&#39;: &#39;/root/.ssh/authorized_keys&#39;})
    vsphere: ok: [default] =&gt; (item={&#39;path&#39;: &#39;/home/builder/.ssh/authorized_keys&#39;})
    vsphere:
    vsphere: TASK [sysprep : Truncate all remaining log files in /var/log] ******************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Delete all logrotated log zips] ********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Truncate shell history] ****************************************
    vsphere: ok: [default] =&gt; (item={&#39;path&#39;: &#39;/root/.bash_history&#39;})
    vsphere: ok: [default] =&gt; (item={&#39;path&#39;: &#39;/home/builder/.bash_history&#39;})
    vsphere:
    vsphere: TASK [sysprep : Rotate journalctl to archive logs] *****************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove archived journalctl logs] *******************************
    vsphere: changed: [default]
    vsphere:
    vsphere: PLAY RECAP *********************************************************************
    vsphere: default                    : ok=104  changed=81   unreachable=0    failed=0    skipped=207  rescued=0    ignored=0
    vsphere:
==&gt; vsphere: Provisioning with Goss
==&gt; vsphere: Configured to run on Linux
    vsphere: Creating directory: /tkg-tmp/goss
    vsphere: Installing Goss from, https://github.com/aelsabbahy/goss/releases/download/v0.3.16/goss-linux-amd64
    vsphere: Downloading Goss to /tkg-tmp/goss-linux-amd64
==&gt; vsphere:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
==&gt; vsphere:                                  Dload  Upload   Total   Spent    Left  Speed
==&gt; vsphere:   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
==&gt; vsphere:   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
==&gt; vsphere: 100 11.8M  100 11.8M    0     0  2067k      0  0:00:05  0:00:05 --:--:-- 3162k
    vsphere: goss version v0.3.16
==&gt; vsphere: Uploading goss tests...
    vsphere: Inline variables are --vars-inline &#39;{&#34;ARCH&#34;:&#34;amd64&#34;,&#34;OS&#34;:&#34;photon&#34;,&#34;OS_VERSION&#34;:&#34;3&#34;,&#34;PROVIDER&#34;:&#34;ova&#34;,&#34;containerd_version&#34;:&#34;v1.6.6&#43;vmware.2&#34;,&#34;kubernetes_cni_deb_version&#34;:&#34;1.1.1-00&#34;,&#34;kubernetes_cni_rpm_version&#34;:&#34;1.1.1&#34;,&#34;kubernetes_cni_source_type&#34;:&#34;http&#34;,&#34;kubernetes_cni_version&#34;:&#34;1.1.1&#43;vmware.7&#34;,&#34;kubernetes_deb_version&#34;:&#34;1.23.10-00&#34;,&#34;kubernetes_rpm_version&#34;:&#34;1.23.10&#34;,&#34;kubernetes_source_type&#34;:&#34;http&#34;,&#34;kubernetes_version&#34;:&#34;1.23.10&#43;vmware.1&#34;}&#39;
    vsphere: Uploading Dir /home/imagebuilder/goss
    vsphere: Creating directory: /tkg-tmp/goss/goss
==&gt; vsphere:
==&gt; vsphere:
==&gt; vsphere:
==&gt; vsphere: Running goss tests...
==&gt; vsphere: Running GOSS render command: cd /tkg-tmp/goss &amp;&amp;  /tkg-tmp/goss-linux-amd64 --gossfile goss/goss.yaml  --vars-inline &#39;{&#34;ARCH&#34;:&#34;amd64&#34;,&#34;OS&#34;:&#34;photon&#34;,&#34;OS_VERSION&#34;:&#34;3&#34;,&#34;PROVIDER&#34;:&#34;ova&#34;,&#34;containerd_version&#34;:&#34;v1.6.6&#43;vmware.2&#34;,&#34;kubernetes_cni_deb_version&#34;:&#34;1.1.1-00&#34;,&#34;kubernetes_cni_rpm_version&#34;:&#34;1.1.1&#34;,&#34;kubernetes_cni_source_type&#34;:&#34;http&#34;,&#34;kubernetes_cni_version&#34;:&#34;1.1.1&#43;vmware.7&#34;,&#34;kubernetes_deb_version&#34;:&#34;1.23.10-00&#34;,&#34;kubernetes_rpm_version&#34;:&#34;1.23.10&#34;,&#34;kubernetes_source_type&#34;:&#34;http&#34;,&#34;kubernetes_version&#34;:&#34;1.23.10&#43;vmware.1&#34;}&#39; render &gt; /tmp/goss-spec.yaml
==&gt; vsphere: Goss render ran successfully
==&gt; vsphere: Running GOSS render debug command: cd /tkg-tmp/goss &amp;&amp;  /tkg-tmp/goss-linux-amd64 --gossfile goss/goss.yaml  --vars-inline &#39;{&#34;ARCH&#34;:&#34;amd64&#34;,&#34;OS&#34;:&#34;photon&#34;,&#34;OS_VERSION&#34;:&#34;3&#34;,&#34;PROVIDER&#34;:&#34;ova&#34;,&#34;containerd_version&#34;:&#34;v1.6.6&#43;vmware.2&#34;,&#34;kubernetes_cni_deb_version&#34;:&#34;1.1.1-00&#34;,&#34;kubernetes_cni_rpm_version&#34;:&#34;1.1.1&#34;,&#34;kubernetes_cni_source_type&#34;:&#34;http&#34;,&#34;kubernetes_cni_version&#34;:&#34;1.1.1&#43;vmware.7&#34;,&#34;kubernetes_deb_version&#34;:&#34;1.23.10-00&#34;,&#34;kubernetes_rpm_version&#34;:&#34;1.23.10&#34;,&#34;kubernetes_source_type&#34;:&#34;http&#34;,&#34;kubernetes_version&#34;:&#34;1.23.10&#43;vmware.1&#34;}&#39; render -d &gt; /tmp/debug-goss-spec.yaml
==&gt; vsphere: Goss render debug ran successfully
==&gt; vsphere: Running GOSS validate command: cd /tkg-tmp/goss &amp;&amp; sudo  /tkg-tmp/goss-linux-amd64 --gossfile goss/goss.yaml  --vars-inline &#39;{&#34;ARCH&#34;:&#34;amd64&#34;,&#34;OS&#34;:&#34;photon&#34;,&#34;OS_VERSION&#34;:&#34;3&#34;,&#34;PROVIDER&#34;:&#34;ova&#34;,&#34;containerd_version&#34;:&#34;v1.6.6&#43;vmware.2&#34;,&#34;kubernetes_cni_deb_version&#34;:&#34;1.1.1-00&#34;,&#34;kubernetes_cni_rpm_version&#34;:&#34;1.1.1&#34;,&#34;kubernetes_cni_source_type&#34;:&#34;http&#34;,&#34;kubernetes_cni_version&#34;:&#34;1.1.1&#43;vmware.7&#34;,&#34;kubernetes_deb_version&#34;:&#34;1.23.10-00&#34;,&#34;kubernetes_rpm_version&#34;:&#34;1.23.10&#34;,&#34;kubernetes_source_type&#34;:&#34;http&#34;,&#34;kubernetes_version&#34;:&#34;1.23.10&#43;vmware.1&#34;}&#39; validate --retry-timeout 0s --sleep 1s -f json -o pretty
    vsphere: {
    vsphere:     &#34;results&#34;: [
    vsphere:         {
    vsphere:             &#34;duration&#34;: 10299109,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;rng-tools&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: rng-tools: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 25116058,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;jq&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: jq: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 25439183,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;chrony&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: chrony: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 26234385,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;cloud-init&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: cloud-init: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 32738183,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;false&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;Expected\n    \u003cbool\u003e: false\nto equal\n    \u003cbool\u003e: true&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;ethtool&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 1,
    vsphere:             &#34;successful&#34;: false,
    vsphere:             &#34;summary-line&#34;: &#34;Package: ethtool: installed:\nExpected\n    \u003cbool\u003e: false\nto equal\n    \u003cbool\u003e: true&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 35497290,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;python-netifaces&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: python-netifaces: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 36019503,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;python3-netifaces&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: python3-netifaces: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 40315463,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;apparmor-parser&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: apparmor-parser: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 43431807,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;distrib-compat&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: distrib-compat: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 48933998,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;tar&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: tar: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 45595040,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;openssl-c_rehash&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: openssl-c_rehash: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 59955212,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;0&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;0&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;exit-status&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;containerd --version | awk -F&#39; &#39; &#39;{print substr($3,2); }&#39;&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Command&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Command: containerd --version | awk -F&#39; &#39; &#39;{print substr($3,2); }&#39;: exit-status: matches expectation: [0]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 76769725,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;unzip&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: unzip: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 72268162,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;socat&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: socat: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 78789939,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;0&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;0&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;exit-status&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;crictl images | grep -v &#39;IMAGE ID&#39; | awk -F&#39;[ /]&#39; &#39;{print $3}&#39; | sed &#39;s/-amd64//g&#39; | sort&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Command&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Command: crictl images | grep -v &#39;IMAGE ID&#39; | awk -F&#39;[ /]&#39; &#39;{print $3}&#39; | sed &#39;s/-amd64//g&#39; | sort: exit-status: matches expectation: [0]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 13332,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;coredns&#34;,
    vsphere:                 &#34;etcd&#34;,
    vsphere:                 &#34;kube-apiserver&#34;,
    vsphere:                 &#34;kube-controller-manager&#34;,
    vsphere:                 &#34;kube-proxy&#34;,
    vsphere:                 &#34;kube-scheduler&#34;,
    vsphere:                 &#34;pause&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;coredns&#34;,
    vsphere:                 &#34;etcd&#34;,
    vsphere:                 &#34;kube-apiserver&#34;,
    vsphere:                 &#34;kube-controller-manager&#34;,
    vsphere:                 &#34;kube-proxy&#34;,
    vsphere:                 &#34;kube-scheduler&#34;,
    vsphere:                 &#34;pause&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;stdout&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;crictl images | grep -v &#39;IMAGE ID&#39; | awk -F&#39;[ /]&#39; &#39;{print $3}&#39; | sed &#39;s/-amd64//g&#39; | sort&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Command&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Command: crictl images | grep -v &#39;IMAGE ID&#39; | awk -F&#39;[ /]&#39; &#39;{print $3}&#39; | sed &#39;s/-amd64//g&#39; | sort: stdout: matches expectation: [coredns etcd kube-apiserver kube-controller-manager kube-proxy kube-scheduler pause]&#34;,
    vsphere:             &#34;test-type&#34;: 2,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 87058361,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;0&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;0&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;exit-status&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;/opt/cni/bin/host-device 2\u003e\u00261 | awk -F&#39; &#39; &#39;{print substr($4,2); }&#39;&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Command&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Command: /opt/cni/bin/host-device 2\u003e\u00261 | awk -F&#39; &#39; &#39;{print substr($4,2); }&#39;: exit-status: matches expectation: [0]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 11728,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;1.1.1&#43;vmware.7&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;1.1.1&#43;vmware.7&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;stdout&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;/opt/cni/bin/host-device 2\u003e\u00261 | awk -F&#39; &#39; &#39;{print substr($4,2); }&#39;&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Command&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Command: /opt/cni/bin/host-device 2\u003e\u00261 | awk -F&#39; &#39; &#39;{print substr($4,2); }&#39;: stdout: matches expectation: [1.1.1&#43;vmware.7]&#34;,
    vsphere:             &#34;test-type&#34;: 2,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 86595708,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;false&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;false&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;ntp&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: ntp: installed: matches expectation: [false]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 64736050,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;sysstat&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: sysstat: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 67731573,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;conntrack-tools&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: conntrack-tools: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 98041982,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;0&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;0&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;exit-status&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;kubeadm version -o json | jq .clientVersion.gitVersion | tr -d &#39;\&#34;&#39; | awk &#39;{print substr($1,2); }&#39;&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Command&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Command: kubeadm version -o json | jq .clientVersion.gitVersion | tr -d &#39;\&#34;&#39; | awk &#39;{print substr($1,2); }&#39;: exit-status: matches expectation: [0]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 15067,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;1.23.10&#43;vmware.1&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;1.23.10&#43;vmware.1&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;stdout&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;kubeadm version -o json | jq .clientVersion.gitVersion | tr -d &#39;\&#34;&#39; | awk &#39;{print substr($1,2); }&#39;&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Command&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Command: kubeadm version -o json | jq .clientVersion.gitVersion | tr -d &#39;\&#34;&#39; | awk &#39;{print substr($1,2); }&#39;: stdout: matches expectation: [1.23.10&#43;vmware.1]&#34;,
    vsphere:             &#34;test-type&#34;: 2,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 43288,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;\&#34;8192\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;\&#34;8192\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;value&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;net.ipv4.neigh.default.gc_thresh2&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;KernelParam&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;KernelParam: net.ipv4.neigh.default.gc_thresh2: value: matches expectation: [\&#34;8192\&#34;]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 37179,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;\&#34;524288\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;\&#34;524288\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;value&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;net.ipv4.tcp_limit_output_bytes&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;KernelParam&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;KernelParam: net.ipv4.tcp_limit_output_bytes: value: matches expectation: [\&#34;524288\&#34;]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 40709,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;\&#34;16384\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;\&#34;16384\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;value&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;net.ipv4.neigh.default.gc_thresh3&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;KernelParam&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;KernelParam: net.ipv4.neigh.default.gc_thresh3: value: matches expectation: [\&#34;16384\&#34;]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 19243,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;\&#34;4096\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;\&#34;4096\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;value&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;net.ipv6.neigh.default.gc_thresh1&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;KernelParam&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;KernelParam: net.ipv6.neigh.default.gc_thresh1: value: matches expectation: [\&#34;4096\&#34;]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 28023,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;\&#34;1\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;\&#34;1\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;value&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;net.bridge.bridge-nf-call-ip6tables&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;KernelParam&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;KernelParam: net.bridge.bridge-nf-call-ip6tables: value: matches expectation: [\&#34;1\&#34;]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 28141,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;\&#34;1\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;\&#34;1\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;value&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;net.ipv4.ip_forward&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;KernelParam&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;KernelParam: net.ipv4.ip_forward: value: matches expectation: [\&#34;1\&#34;]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 28205,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;\&#34;1\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;\&#34;1\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;value&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;net.ipv6.conf.all.forwarding&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;KernelParam&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;KernelParam: net.ipv6.conf.all.forwarding: value: matches expectation: [\&#34;1\&#34;]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 28518,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;\&#34;1\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;\&#34;1\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;value&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;net.bridge.bridge-nf-call-iptables&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;KernelParam&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;KernelParam: net.bridge.bridge-nf-call-iptables: value: matches expectation: [\&#34;1\&#34;]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 22812,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;\&#34;16384\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;\&#34;16384\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;value&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;net.ipv6.neigh.default.gc_thresh3&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;KernelParam&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;KernelParam: net.ipv6.neigh.default.gc_thresh3: value: matches expectation: [\&#34;16384\&#34;]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 30924,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;\&#34;4096\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;\&#34;4096\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;value&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;net.ipv4.neigh.default.gc_thresh1&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;KernelParam&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;KernelParam: net.ipv4.neigh.default.gc_thresh1: value: matches expectation: [\&#34;4096\&#34;]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 27686,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;\&#34;8192\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;\&#34;8192\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;value&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;net.ipv6.neigh.default.gc_thresh2&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;KernelParam&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;KernelParam: net.ipv6.neigh.default.gc_thresh2: value: matches expectation: [\&#34;8192\&#34;]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 19066,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;\&#34;9223372036854775807\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;\&#34;9223372036854775807\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;value&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;fs.file-max&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;KernelParam&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;KernelParam: fs.file-max: value: matches expectation: [\&#34;9223372036854775807\&#34;]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 29099,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;\&#34;0\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;\&#34;0\&#34;&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;value&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;net.ipv6.conf.all.disable_ipv6&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;KernelParam&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;KernelParam: net.ipv6.conf.all.disable_ipv6: value: matches expectation: [\&#34;0\&#34;]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 73090032,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;false&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;Expected\n    \u003cbool\u003e: false\nto equal\n    \u003cbool\u003e: true&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;nfs-utils&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 1,
    vsphere:             &#34;successful&#34;: false,
    vsphere:             &#34;summary-line&#34;: &#34;Package: nfs-utils: installed:\nExpected\n    \u003cbool\u003e: false\nto equal\n    \u003cbool\u003e: true&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 72355410,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;open-vm-tools&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: open-vm-tools: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 112430963,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;0&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;0&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;exit-status&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;crictl ps&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Command&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Command: crictl ps: exit-status: matches expectation: [0]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 80632261,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;python3-pip&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: python3-pip: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 82198514,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;audit&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: audit: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 74345777,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;cloud-utils&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: cloud-utils: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 78364183,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;python-requests&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: python-requests: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 77396663,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;net-tools&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: net-tools: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 73944805,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;installed&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;ebtables&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Package&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Package: ebtables: installed: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 145517664,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;0&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;0&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;exit-status&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;kubectl version --short --client=true -o json | jq .clientVersion.gitVersion | tr -d &#39;\&#34;&#39; | awk &#39;{print substr($1,2); }&#39;&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Command&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Command: kubectl version --short --client=true -o json | jq .clientVersion.gitVersion | tr -d &#39;\&#34;&#39; | awk &#39;{print substr($1,2); }&#39;: exit-status: matches expectation: [0]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 10058,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;1.23.10&#43;vmware.1&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;1.23.10&#43;vmware.1&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;stdout&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;kubectl version --short --client=true -o json | jq .clientVersion.gitVersion | tr -d &#39;\&#34;&#39; | awk &#39;{print substr($1,2); }&#39;&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Command&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Command: kubectl version --short --client=true -o json | jq .clientVersion.gitVersion | tr -d &#39;\&#34;&#39; | awk &#39;{print substr($1,2); }&#39;: stdout: matches expectation: [1.23.10&#43;vmware.1]&#34;,
    vsphere:             &#34;test-type&#34;: 2,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 149739398,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;0&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;0&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;exit-status&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;kubelet --version | awk -F&#39; &#39; &#39;{print $2}&#39;  | tr -d &#39;\&#34;&#39; | awk &#39;{print substr($1,2); }&#39;&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Command&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Command: kubelet --version | awk -F&#39; &#39; &#39;{print $2}&#39;  | tr -d &#39;\&#34;&#39; | awk &#39;{print substr($1,2); }&#39;: exit-status: matches expectation: [0]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 7485,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;1.23.10&#43;vmware.1&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;1.23.10&#43;vmware.1&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;stdout&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;kubelet --version | awk -F&#39; &#39; &#39;{print $2}&#39;  | tr -d &#39;\&#34;&#39; | awk &#39;{print substr($1,2); }&#39;&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Command&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Command: kubelet --version | awk -F&#39; &#39; &#39;{print $2}&#39;  | tr -d &#39;\&#34;&#39; | awk &#39;{print substr($1,2); }&#39;: stdout: matches expectation: [1.23.10&#43;vmware.1]&#34;,
    vsphere:             &#34;test-type&#34;: 2,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 62272042,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;false&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;false&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;enabled&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;dockerd&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Service&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Service: dockerd: enabled: matches expectation: [false]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 20644198,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;false&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;false&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;running&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;dockerd&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Service&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Service: dockerd: running: matches expectation: [false]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 65773735,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;enabled&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;containerd&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Service&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Service: containerd: enabled: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 18159690,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;running&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;containerd&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Service&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Service: containerd: running: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 58361772,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;enabled&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;kubelet&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Service&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Service: kubelet: enabled: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 18462803,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;false&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;false&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;running&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;kubelet&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Service&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Service: kubelet: running: matches expectation: [false]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 77957073,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;false&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;false&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;enabled&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;conntrackd&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Service&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Service: conntrackd: enabled: matches expectation: [false]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 22462736,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;false&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;false&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;running&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;conntrackd&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Service&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Service: conntrackd: running: matches expectation: [false]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 66898103,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;enabled&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;networkd-dispatcher&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Service&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Service: networkd-dispatcher: enabled: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 11014421,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;running&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;networkd-dispatcher&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Service&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Service: networkd-dispatcher: running: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 58245320,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;enabled&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;chronyd&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Service&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Service: chronyd: enabled: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 14300317,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;running&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;chronyd&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Service&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Service: chronyd: running: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 66981034,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;false&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;false&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;enabled&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;apparmor&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Service&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Service: apparmor: enabled: matches expectation: [false]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 10594373,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;false&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;false&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;running&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;apparmor&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Service&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Service: apparmor: running: matches expectation: [false]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 67507859,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;enabled&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;auditd&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Service&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Service: auditd: enabled: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         },
    vsphere:         {
    vsphere:             &#34;duration&#34;: 10329547,
    vsphere:             &#34;err&#34;: null,
    vsphere:             &#34;expected&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;found&#34;: [
    vsphere:                 &#34;true&#34;
    vsphere:             ],
    vsphere:             &#34;human&#34;: &#34;&#34;,
    vsphere:             &#34;meta&#34;: null,
    vsphere:             &#34;property&#34;: &#34;running&#34;,
    vsphere:             &#34;resource-id&#34;: &#34;auditd&#34;,
    vsphere:             &#34;resource-type&#34;: &#34;Service&#34;,
    vsphere:             &#34;result&#34;: 0,
    vsphere:             &#34;successful&#34;: true,
    vsphere:             &#34;summary-line&#34;: &#34;Service: auditd: running: matches expectation: [true]&#34;,
    vsphere:             &#34;test-type&#34;: 0,
    vsphere:             &#34;title&#34;: &#34;&#34;
    vsphere:         }
    vsphere:     ],
    vsphere:     &#34;summary&#34;: {
    vsphere:         &#34;failed-count&#34;: 2,
    vsphere:         &#34;summary-line&#34;: &#34;Count: 65, Failed: 2, Duration: 0.168s&#34;,
    vsphere:         &#34;test-count&#34;: 65,
    vsphere:         &#34;total-duration&#34;: 168422616
    vsphere:     }
    vsphere: }
==&gt; vsphere: Goss validate failed
==&gt; vsphere: Inspect mode on : proceeding without failing Packer
==&gt; vsphere:
==&gt; vsphere:
==&gt; vsphere:
==&gt; vsphere: Downloading spec file and debug info
    vsphere: Downloading Goss specs from, /tmp/goss-spec.yaml and /tmp/debug-goss-spec.yaml to current dir
==&gt; vsphere: Executing shutdown command...
==&gt; vsphere: Deleting Floppy drives...
==&gt; vsphere: Eject CD-ROM drives...
    vsphere: Starting export...
    vsphere: Downloading: photon-3-kube-v1.23.10_vmware.1-disk-0.vmdk
    vsphere: Exporting file: photon-3-kube-v1.23.10_vmware.1-disk-0.vmdk
    vsphere: Writing ovf...
==&gt; vsphere: Clear boot order...
==&gt; vsphere: Running post-processor: packer-manifest (type manifest)
==&gt; vsphere: Running post-processor: vsphere (type shell-local)
==&gt; vsphere (shell-local): Running local shell script: /tmp/packer-shell2767289316
    vsphere (shell-local): Opening OVF source: photon-3-kube-v1.23.10&#43;vmware.1.ovf
    vsphere (shell-local): Opening OVA target: photon-3-kube-v1.23.10&#43;vmware.1.ova
    vsphere (shell-local): Writing OVA package: photon-3-kube-v1.23.10&#43;vmware.1.ova
    vsphere (shell-local): Transfer Completed
    vsphere (shell-local): Warning:
    vsphere (shell-local):  - No manifest file found.
    vsphere (shell-local):  - No supported manifest(sha1, sha256, sha512) entry found for: &#39;photon-3-kube-v1.23.10_vmware.1-disk-0.vmdk&#39;.
    vsphere (shell-local): Completed successfully
    vsphere (shell-local): image-build-ova: cd .
    vsphere (shell-local): image-build-ova: loaded photon-3-kube-v1.23.10&#43;vmware.1
    vsphere (shell-local): image-build-ova: create ovf photon-3-kube-v1.23.10&#43;vmware.1.ovf
    vsphere (shell-local): image-build-ova: creating OVA from photon-3-kube-v1.23.10&#43;vmware.1.ovf using ovftool
    vsphere (shell-local): image-build-ova: create ova checksum photon-3-kube-v1.23.10&#43;vmware.1.ova.sha256
==&gt; vsphere: Running post-processor: custom-post-processor (type shell-local)
==&gt; vsphere (shell-local): Running local shell script: /tmp/packer-shell4018393751
Build &#39;vsphere&#39; finished after 13 minutes 36 seconds.

==&gt; Wait completed after 13 minutes 36 seconds

==&gt; Builds finished. The artifacts of successful builds are:
--&gt; vsphere: photon-3-kube-v1.23.10_vmware.1
--&gt; vsphere: photon-3-kube-v1.23.10_vmware.1
--&gt; vsphere: photon-3-kube-v1.23.10_vmware.1
--&gt; vsphere: photon-3-kube-v1.23.10_vmware.1
```
```shell
## output 폴더 OVA 생성

## 1.6 
ls output/photon-3-kube-v1.23.10_vmware.1/
packer-manifest.json  photon-3-kube-v1.23.10&#43;vmware.1.ova  photon-3-kube-v1.23.10&#43;vmware.1.ova.sha256  photon-3-kube-v1.23.10&#43;vmware.1.ovf  photon-3-kube-v1.23.10_vmware.1-disk-0.vmdk  photon-3-kube-v1.23.10_vmware.1.ovf

## 2.1
ls output/photon-3-kube-v1.24.9_vmware.1/
packer-manifest.json  photon-3-kube-v1.24.9_vmware.1-disk-0.vmdk  photon-3-kube-v1.24.9&#43;vmware.1.ova  photon-3-kube-v1.24.9&#43;vmware.1.ova.sha256  photon-3-kube-v1.24.9&#43;vmware.1.ovf  photon-3-kube-v1.24.9_vmware.1.ovf
```
{{&lt; /admonition &gt;}}

## 6. TKR 등록
{{&lt; admonition tip &#34;TKR 등록&#34; &gt;}}
```shell
## 1.6
vi ~/.config/tanzu/tkg/bom/tkr-bom-v1.23.10&#43;vmware.1-tkg.1.yaml

## 아래 ova를 찾아서 추가 해준다. 
ova:
- name: ova-photon-3-rt
  osinfo:
    name: photon
    version: &#34;3&#34;
    arch: amd64
  version: v1.23.10&#43;vmware.1-dokyung.0
- name: ova-ubuntu-2004-rt
  osinfo:
    name: ubuntu
    version: &#34;20.04&#34;
    arch: amd64
  version: v1.23.10&#43;vmware.1-dokyung.0
- name: ova-rhel-8-rt
  osinfo:
    name: rhel
    version: &#34;8&#34;
    arch: amd64
  version: v1.23.10&#43;vmware.1-dokyung.0

## 2.1
vi ~/.config/tanzu/tkg/bom/tkr-bom-v1.24.9&#43;vmware.1-tkg.1.yaml

## 아래 ova를 찾아서 추가 해준다. 
ova:
- name: ova-photon-3-rt
  osinfo:
    name: photon
    version: &#34;3&#34;
    arch: amd64
  version: v1.24.9&#43;vmware.1-dokyung.0
- name: ova-ubuntu-2004-rt
  osinfo:
    name: ubuntu
    version: &#34;20.04&#34;
    arch: amd64
  version: v1.24.9&#43;vmware.1-dokyung.0
- name: ova-rhel-8-rt
  osinfo:
    name: rhel
    version: &#34;8&#34;
    arch: amd64
  version: v1.24.9&#43;vmware.1-dokyung.0
```
{{&lt; /admonition &gt;}}

## 7. OVA 업로드
{{&lt; admonition tip &#34;업로드&#34; &gt;}}
```shell
## 1.6
### photon
ovftool --acceptAllEulas --net:nic0={NIC}--datastore={STORE} --vmFolder={FOLDER} --importAsTemplate output/photon-3-kube-v1.23.10_vmware.1/photon-3-kube-v1.23.10&#43;vmware.1.ova &#39;vi://{ID}:{PW}}@{vCenter FQDN or IP}/{DATACENTER}/host/{CLUSTER}/&#39;
### ubuntu
ovftool --acceptAllEulas --net:nic0={NIC}--datastore={STORE} --vmFolder={FOLDER} --importAsTemplate output/ubuntu-2004-kube-v1.23.10_vmware.1/ubuntu-2004-kube-v1.23.10&#43;vmware.1.ova &#39;vi://{ID}:{PW}}@{vCenter FQDN or IP}/{DATACENTER}/host/{CLUSTER}/&#39;
### rhel
ovftool --acceptAllEulas --net:nic0={NIC}--datastore={STORE} --vmFolder={FOLDER} --importAsTemplate output/rhel-8-kube-v1.23.10_vmware.1/rhel-8-kube-v1.23.10&#43;vmware.1.ova &#39;vi://{ID}:{PW}}@{vCenter FQDN or IP}/{DATACENTER}/host/{CLUSTER}/&#39;

## 2.1
### photon
ovftool --acceptAllEulas --net:nic0={NIC}--datastore={STORE} --vmFolder={FOLDER} --importAsTemplate output/photon-3-kube-v1.24.9_vmware.1/photon-3-kube-v1.24.9&#43;vmware.1.ova &#39;vi://{ID}:{PW}}@{vCenter FQDN or IP}/{DATACENTER}/host/{CLUSTER}/&#39;
### ubuntu
ovftool --acceptAllEulas --net:nic0={NIC}--datastore={STORE} --vmFolder={FOLDER} --importAsTemplate output/ubuntu-2004-kube-v1.24.9_vmware.1/ubuntu-2004-kube-v1.24.9&#43;vmware.1.ova &#39;vi://{ID}:{PW}}@{vCenter FQDN or IP}/{DATACENTER}/host/{CLUSTER}/&#39;
### rhel
ovftool --acceptAllEulas --net:nic0={NIC}--datastore={STORE} --vmFolder={FOLDER} --importAsTemplate output/rhel-8-kube-v1.24.9_vmware.1/rhel-8-kube-v1.24.9&#43;vmware.1.ova &#39;vi://{ID}:{PW}}@{vCenter FQDN or IP}/{DATACENTER}/host/{CLUSTER}/&#39;

```
{{&lt; /admonition &gt;}}
## 6. 배포
{{&lt; admonition tip &#34;클러스터 배포&#34; &gt;}}

```shell
tanzu cluster create -f {FILE} -v 9 -y
```
{{&lt; /admonition &gt;}}

## 7. 확인

&gt; 1.6
{{&lt; figure src=&#34;/images/tanzu-custom-image/1-3.png&#34; title=&#34;rhel node&#34; &gt;}}
{{&lt; figure src=&#34;/images/tanzu-custom-image/1-2.png&#34; title=&#34;photon node&#34; &gt;}}

&gt; 2.1
{{&lt; figure src=&#34;/images/tanzu-custom-image/1-4.png&#34; title=&#34;All node&#34; &gt;}}

---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/ko/tanzu-custom-image/  

