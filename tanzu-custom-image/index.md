# The Documentation TANZU CUSTOM IMAGE


## 1. Tanzu Custom Image

VMware에서 기본적으로 제공하는 이미지외에 별도로 Custom Image를 구성 할 수 있다. 

호환되는 OS버전은 아래와 같다.
{{< figure src="/images/tanzu-custom-image/1-1.png" title="지원 하는 OS Version" >}}

1.6 버전 Custom Image 생성 [<i class="fas fa-link"></i> 1.6 Custom-Image ](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.6/vmware-tanzu-kubernetes-grid-16/GUID-build-images-linux.html)

2.1 버전 Custom Image 생성 [<i class="fas fa-link"></i> 2.1 Custom-Image ](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/2.1/tkg-deploy-mc-21/mgmt-byoi-linux.html#linux-tkr)

TANZU 버전별 Sample Download [<i class="fas fa-link"></i> Sample Downloads ](https://developer.vmware.com/samples)

> 사전에 도커가 설치 되어 있어야 함

> RHEL의 경우 Subscription이 되어 있어야 함

## 2. 공통 작업

{{< admonition tip "Docker Server 실행" >}}
```shell
docker pull projects.registry.vmware.com/tkg/linux-resource-bundle:v1.23.10_vmware.1-tkg.1
docker run -d -p 3000:3000 projects.registry.vmware.com/tkg/linux-resource-bundle:v1.23.10_vmware.1-tkg.1
```
{{< /admonition >}}

{{< admonition tip "Sample 다운로드" >}}
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
{{< /admonition >}}

{{< admonition tip "tkg.json 설정 변경" >}}
```shell
## 아래 <IP>:<PORT> 설정
cat << 'EOF' > tkg.json
{
  "build_version": "{{user `build_name`}}-kube-v1.23.10_vmware.1",
  "pause_image": "projects.registry.vmware.com/tkg/pause:3.6",
  "containerd_sha256": "48f4327570dd7543464a28893160ab3bc9719ed2553f0a529a884b40f6dafd29",
  "containerd_url": "http://<IP>:<PORT>/files/containerd/cri-containerd-v1.6.6+vmware.2.linux-amd64.tar",
  "containerd_version": "v1.6.6+vmware.2",
  "crictl_sha256": "",
  "crictl_url": "",
  "custom_role": "true",
  "custom_role_names": "/home/imagebuilder/tkg",
  "extra_debs": "nfs-common unzip apparmor apparmor-utils sysstat",
  "extra_rpms": "sysstat",
  "goss_vars_file": "",
  "goss_tests_dir": "/home/imagebuilder/goss",
  "goss_entry_file": "goss/goss.yaml",
  "goss_download_path": "/tkg-tmp/goss-linux-amd64",
  "goss_remote_folder": "/tkg-tmp",
  "goss_remote_path": "/tkg-tmp/goss",
  "kubernetes_series": "v1.23",
  "kubernetes_semver": "v1.23.10+vmware.1",
  "kubernetes_source_type": "http",
  "kubernetes_http_source": "http://<IP>:<PORT>/files/kubernetes",
  "kubernetes_container_registry": "projects.registry.vmware.com/tkg",
  "kubernetes_cni_semver": "v1.1.1+vmware.7",
  "kubernetes_cni_source_type": "http",
  "kubernetes_cni_http_source": "http://<IP>:<PORT>/files/cni_plugins",
  "kubernetes_cni_http_checksum": "",
  "kubernetes_load_additional_imgs": "true"
}
EOF
```
{{< /admonition >}}

{{< admonition tip "vCenter 및 Tanzu Kubernetes 버전 설정" >}}
```shell
## vCenter의 정보를 넣어 준다.
cat << EOF > vsphere.json
{
  "vcenter_server": "",
  "username": "",
  "password": "",
  "insecure_connection": "true",
  "datacenter": "Datacenter",
  "cluster": "Cluster",
  "resource_pool": "",
  "folder": "tanzu",
  "datastore": "vsanDatastore",
  "network": "VM Network",
  "convert_to_template": "false",
  "create_snapshot": "false",
  "linked_clone": "false",
  "template": "false"
}
EOF

## 설치할 버전 설정 

## 1.6
cat << EOF > metadata.json
{
  "VERSION": "v1.23.10+vmware.1-dokyung.0"
}
EOF

## 2.1
{
  "VERSION": "v1.24.9+vmware.1-dokyung.0"
}
```
{{< /admonition >}}

## 3. Ubuntu Custom Image 생성

{{< admonition tip "이미지 생성 실행" >}}
```shell
mkdir output

## 1.6 설정
docker run --net=host -it --rm \
  -v $(pwd)/vsphere.json:/home/imagebuilder/vsphere.json \
  -v $(pwd)/tkg.json:/home/imagebuilder/tkg.json \
  -v $(pwd)/tkg:/home/imagebuilder/tkg \
  -v $(pwd)/stig_ubuntu_2004:/home/imagebuilder/stig_ubuntu_2004 \
  -v $(pwd)/goss/vsphere-ubuntu-1.23.10+vmware.2-goss-spec.yaml:/home/imagebuilder/goss/goss.yaml \
  -v $(pwd)/metadata.json:/home/imagebuilder/metadata.json \
  -v $(pwd)/output:/home/imagebuilder/output \
  --env PACKER_VAR_FILES="tkg.json vsphere.json" \
  --env OVF_CUSTOM_PROPERTIES=/home/imagebuilder/metadata.json \
  --env IB_OVFTOOL=1 \
  projects.registry.vmware.com/tkg/image-builder:v0.1.13_vmware.2 \
  build-node-ova-vsphere-ubuntu-2004

## 2.1 설정
docker run -it --rm \
  -v $(pwd)/vsphere.json:/home/imagebuilder/vsphere.json \
  -v $(pwd)/tkg.json:/home/imagebuilder/tkg.json \
  -v $(pwd)/tkg:/home/imagebuilder/tkg \
  -v $(pwd)/goss/vsphere-ubuntu-1.24.9+vmware.1-goss-spec.yaml:/home/imagebuilder/goss/goss.yaml \
  -v $(pwd)/metadata.json:/home/imagebuilder/metadata.json \
  -v $(pwd)/output:/home/imagebuilder/output \
  --env PACKER_VAR_FILES="tkg.json vsphere.json" \
  --env OVF_CUSTOM_PROPERTIES=/home/imagebuilder/metadata.json \
  --env IB_OVFTOOL=1 \
  --network host \
  projects.registry.vmware.com/tkg/image-builder:v0.1.13_vmware.2 \
  build-node-ova-vsphere-ubuntu-2004
```
{{< /admonition >}}

{{< admonition tip "LOG" >}}
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
packer build -var-file="/home/imagebuilder/packer/config/kubernetes.json"  -var-file="/home/imagebuilder/packer/config/cni.json"  -var-file="/home/imagebuilder/packer/config/containerd.json"  -var-file="/home/imagebuilder/packer/config/ansible-args.json"  -var-file="/home/imagebuilder/packer/config/goss-args.json"  -var-file="/home/imagebuilder/packer/config/common.json"  -var-file="/home/imagebuilder/packer/config/additional_components.json"  -color=true  -var-file="packer/ova/packer-common.json" -var-file="/home/imagebuilder/packer/ova/ubuntu-2004.json" -var-file="packer/ova/vsphere.json"  -except=local -only=vsphere-iso -var-file="/home/imagebuilder/tkg.json"  -var-file="/home/imagebuilder/vsphere.json"  -only=vsphere packer/ova/packer-node.json
vsphere: output will be in this color.

==> vsphere: File /home/imagebuilder/.cache/packer/48e4ec4daa32571605576c5566f486133ecc271f.iso already uploaded; continuing
==> vsphere: File [vsanDatastore] packer_cache//48e4ec4daa32571605576c5566f486133ecc271f.iso already exists; skipping upload.
==> vsphere: Creating VM...
==> vsphere: Customizing hardware...
==> vsphere: Mounting ISO images...
==> vsphere: Adding configuration parameters...
==> vsphere: Creating floppy disk...
    vsphere: Copying files flatly from floppy_files
    vsphere: Done copying files from floppy_files
    vsphere: Collecting paths from floppy_dirs
    vsphere: Resulting paths from floppy_dirs : [./packer/ova/linux/ubuntu/http/]
    vsphere: Recursively copying : ./packer/ova/linux/ubuntu/http/
    vsphere: Done copying paths from floppy_dirs
    vsphere: Copying files from floppy_content
    vsphere: Done copying files from floppy_content
==> vsphere: Uploading created floppy image
==> vsphere: Adding generated Floppy...
==> vsphere: Starting HTTP server on port 8033
==> vsphere: Set boot order temporary...
==> vsphere: Power on VM...
==> vsphere: Waiting 10s for boot...
==> vsphere: HTTP server is working at http://10.253.126.163:8033/
==> vsphere: Typing boot command...
==> vsphere: Waiting for IP...
==> vsphere: IP address: 10.253.126.102
==> vsphere: Using SSH communicator to connect: 10.253.126.102
==> vsphere: Waiting for SSH to become available...
==> vsphere: Connected to SSH!
==> vsphere: Provisioning with shell script: ./packer/files/flatcar/scripts/bootstrap-flatcar.sh
==> vsphere: Provisioning with Ansible...
    vsphere: Setting up proxy adapter for Ansible....
==> vsphere: Executing Ansible: ansible-playbook -e packer_build_name="vsphere" -e packer_*****_type=vsphere-iso -e packer_http_addr=10.253.126.163:8033 --ssh-extra-args '-o IdentitiesOnly=yes' --extra-vars containerd_url=http://10.253.126.163:3000/files/containerd/cri-containerd-v1.6.6+vmware.2.linux-amd64.tar containerd_sha256=48f4327570dd7543464a28893160ab3bc9719ed2553f0a529a884b40f6dafd29 pause_image=projects.registry.vmware.com/tkg/pause:3.6 containerd_additional_settings= containerd_cri_socket=/var/run/containerd/containerd.sock containerd_version=v1.6.6+vmware.2 crictl_url= crictl_sha256= crictl_source_type=pkg custom_role_names="/home/image*****/tkg" firstboot_custom_roles_pre="" firstboot_custom_roles_post="" node_custom_roles_pre="" node_custom_roles_post="" disable_public_repos=false extra_debs="nfs-common unzip apparmor apparmor-utils sysstat" extra_repos="" extra_rpms="sysstat" http_proxy= https_proxy= kubeadm_template=etc/kubeadm.yml kubernetes_cni_http_source=http://10.253.126.163:3000/files/cni_plugins kubernetes_cni_http_checksum= kubernetes_http_source=http://10.253.126.163:3000/files/kubernetes kubernetes_container_registry=projects.registry.vmware.com/tkg kubernetes_rpm_repo=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64 kubernetes_rpm_gpg_key="https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" kubernetes_rpm_gpg_check=True kubernetes_deb_repo="https://apt.kubernetes.io/ kubernetes-xenial" kubernetes_deb_gpg_key=https://packages.cloud.google.com/apt/doc/apt-key.gpg kubernetes_cni_deb_version=1.1.1-00 kubernetes_cni_rpm_version=1.1.1-0 kubernetes_cni_semver=v1.1.1+vmware.7 kubernetes_cni_source_type=http kubernetes_semver=v1.23.10+vmware.1 kubernetes_source_type=http kubernetes_load_additional_imgs=true kubernetes_deb_version=1.23.10-00 kubernetes_rpm_version=1.23.10-0 no_proxy= pip_conf_file= python_path= redhat_epel_rpm=https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm epel_rpm_gpg_key= reenable_public_repos=true remove_extra_repos=false systemd_prefix=/usr/lib/systemd sysusr_prefix=/usr sysusrlocal_prefix=/usr/local load_additional_components=false additional_registry_images=false additional_registry_images_list= additional_url_images=false additional_url_images_list= additional_executables=false additional_executables_list= additional_executables_destination_path= build_target=virt amazon_ssm_agent_rpm= --extra-vars guestinfo_datasource_slug=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo guestinfo_datasource_ref=v1.4.1 guestinfo_datasource_script=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/v1.4.1/install.sh --extra-vars  -e ansible_ssh_private_key_file=/tmp/ansible-key1308883835 -i /tmp/packer-provisioner-ansible2622378892 /home/image*****/ansible/firstboot.yml
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
==> vsphere: Provisioning with shell script: /tmp/packer-shell4104450257
==> vsphere: Provisioning with Ansible...
    vsphere: Setting up proxy adapter for Ansible....
==> vsphere: Executing Ansible: ansible-playbook -e packer_build_name="vsphere" -e packer_*****_type=vsphere-iso -e packer_http_addr=10.253.126.163:8033 --ssh-extra-args '-o IdentitiesOnly=yes' --extra-vars containerd_url=http://10.253.126.163:3000/files/containerd/cri-containerd-v1.6.6+vmware.2.linux-amd64.tar containerd_sha256=48f4327570dd7543464a28893160ab3bc9719ed2553f0a529a884b40f6dafd29 pause_image=projects.registry.vmware.com/tkg/pause:3.6 containerd_additional_settings= containerd_cri_socket=/var/run/containerd/containerd.sock containerd_version=v1.6.6+vmware.2 crictl_url= crictl_sha256= crictl_source_type=pkg custom_role_names="/home/image*****/tkg" firstboot_custom_roles_pre="" firstboot_custom_roles_post="" node_custom_roles_pre="" node_custom_roles_post="" disable_public_repos=false extra_debs="nfs-common unzip apparmor apparmor-utils sysstat" extra_repos="" extra_rpms="sysstat" http_proxy= https_proxy= kubeadm_template=etc/kubeadm.yml kubernetes_cni_http_source=http://10.253.126.163:3000/files/cni_plugins kubernetes_cni_http_checksum= kubernetes_http_source=http://10.253.126.163:3000/files/kubernetes kubernetes_container_registry=projects.registry.vmware.com/tkg kubernetes_rpm_repo=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64 kubernetes_rpm_gpg_key="https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" kubernetes_rpm_gpg_check=True kubernetes_deb_repo="https://apt.kubernetes.io/ kubernetes-xenial" kubernetes_deb_gpg_key=https://packages.cloud.google.com/apt/doc/apt-key.gpg kubernetes_cni_deb_version=1.1.1-00 kubernetes_cni_rpm_version=1.1.1-0 kubernetes_cni_semver=v1.1.1+vmware.7 kubernetes_cni_source_type=http kubernetes_semver=v1.23.10+vmware.1 kubernetes_source_type=http kubernetes_load_additional_imgs=true kubernetes_deb_version=1.23.10-00 kubernetes_rpm_version=1.23.10-0 no_proxy= pip_conf_file= python_path= redhat_epel_rpm=https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm epel_rpm_gpg_key= reenable_public_repos=true remove_extra_repos=false systemd_prefix=/usr/lib/systemd sysusr_prefix=/usr sysusrlocal_prefix=/usr/local load_additional_components=false additional_registry_images=false additional_registry_images_list= additional_url_images=false additional_url_images_list= additional_executables=false additional_executables_list= additional_executables_destination_path= build_target=virt amazon_ssm_agent_rpm= --extra-vars guestinfo_datasource_slug=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo guestinfo_datasource_ref=v1.4.1 guestinfo_datasource_script=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/v1.4.1/install.sh --extra-vars  -e ansible_ssh_private_key_file=/tmp/ansible-key2329815423 -i /tmp/packer-provisioner-ansible3700347837 /home/image*****/ansible/node.yml
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
    vsphere: changed: [default] => (item={'param': 'net.bridge.bridge-nf-call-iptables', 'val': 1})
    vsphere: changed: [default] => (item={'param': 'net.bridge.bridge-nf-call-ip6tables', 'val': 1})
    vsphere: changed: [default] => (item={'param': 'net.ipv4.ip_forward', 'val': 1})
    vsphere: changed: [default] => (item={'param': 'net.ipv6.conf.all.forwarding', 'val': 1})
    vsphere: changed: [default] => (item={'param': 'net.ipv6.conf.all.disable_ipv6', 'val': 0})
    vsphere: changed: [default] => (item={'param': 'net.ipv4.tcp_congestion_control', 'val': 'bbr'})
    vsphere: changed: [default] => (item={'param': 'vm.overcommit_memory', 'val': 1})
    vsphere: changed: [default] => (item={'param': 'kernel.panic', 'val': 10})
    vsphere: changed: [default] => (item={'param': 'kernel.panic_on_oops', 'val': 1})
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
    vsphere: changed: [default] => (item={'src': 'files/etc/networkd-dispatcher/routable.d/20-chrony.j2', 'dest': '/etc/networkd-dispatcher/routable.d/20-chrony'})
    vsphere: changed: [default] => (item={'src': 'files/etc/networkd-dispatcher/off.d/20-chrony.j2', 'dest': '/etc/networkd-dispatcher/off.d/20-chrony'})
    vsphere: changed: [default] => (item={'src': 'files/etc/networkd-dispatcher/no-carrier.d/20-chrony.j2', 'dest': '/etc/networkd-dispatcher/no-carrier.d/20-chrony'})
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
    vsphere: ok: [default] => (item=cloud-final)
    vsphere: ok: [default] => (item=cloud-config)
    vsphere: ok: [default] => (item=cloud-init)
    vsphere: ok: [default] => (item=cloud-init-local)
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
    vsphere: changed: [default] => (item=ctr)
    vsphere: changed: [default] => (item=crictl)
    vsphere: changed: [default] => (item=critest)
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
    vsphere: changed: [default] => (item=kubeadm)
    vsphere: changed: [default] => (item=kubectl)
    vsphere: changed: [default] => (item=kubelet)
    vsphere:
    vsphere: TASK [kubernetes : Download Kubernetes images] *********************************
    vsphere: changed: [default] => (item=kube-apiserver.tar)
    vsphere: changed: [default] => (item=kube-controller-manager.tar)
    vsphere: changed: [default] => (item=kube-scheduler.tar)
    vsphere: changed: [default] => (item=kube-proxy.tar)
    vsphere: changed: [default] => (item=pause.tar)
    vsphere: changed: [default] => (item=coredns.tar)
    vsphere: changed: [default] => (item=etcd.tar)
    vsphere:
    vsphere: TASK [kubernetes : Load Kubernetes images] *************************************
    vsphere: changed: [default] => (item=kube-apiserver.tar)
    vsphere: changed: [default] => (item=kube-controller-manager.tar)
    vsphere: changed: [default] => (item=kube-scheduler.tar)
    vsphere: changed: [default] => (item=kube-proxy.tar)
    vsphere: changed: [default] => (item=pause.tar)
    vsphere: changed: [default] => (item=coredns.tar)
    vsphere: changed: [default] => (item=etcd.tar)
    vsphere:
    vsphere: TASK [kubernetes : Remove Kubernetes images] ***********************************
    vsphere: changed: [default] => (item=kube-apiserver.tar)
    vsphere: changed: [default] => (item=kube-controller-manager.tar)
    vsphere: changed: [default] => (item=kube-scheduler.tar)
    vsphere: changed: [default] => (item=kube-proxy.tar)
    vsphere: changed: [default] => (item=pause.tar)
    vsphere: changed: [default] => (item=coredns.tar)
    vsphere: changed: [default] => (item=etcd.tar)
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
    vsphere: changed: [default] => (item=echo "dash dash/sh boolean false" |  debconf-set-selections)
    vsphere: changed: [default] => (item=DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash)
    vsphere:
    vsphere: TASK [/home/imagebuilder/tkg : remove unwanted packages] ***********************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [/home/imagebuilder/tkg : include_tasks] **********************************
    vsphere: included: /home/imagebuilder/tkg/tasks/vsphere.yml for default
    vsphere:
    vsphere: TASK [/home/imagebuilder/tkg : Set extra kernel params for GC threshhold] ******
    vsphere: changed: [default] => (item={'param': 'net.ipv4.neigh.default.gc_thresh1', 'val': 4096})
    vsphere: changed: [default] => (item={'param': 'net.ipv6.neigh.default.gc_thresh1', 'val': 4096})
    vsphere: changed: [default] => (item={'param': 'net.ipv4.neigh.default.gc_thresh2', 'val': 8192})
    vsphere: changed: [default] => (item={'param': 'net.ipv6.neigh.default.gc_thresh2', 'val': 8192})
    vsphere: changed: [default] => (item={'param': 'net.ipv4.neigh.default.gc_thresh3', 'val': 16384})
    vsphere: changed: [default] => (item={'param': 'net.ipv6.neigh.default.gc_thresh3', 'val': 16384})
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
    vsphere: changed: [default] => (item={'path': '/var/lib/apt/lists', 'state': 'absent', 'mode': '0755'})
    vsphere: changed: [default] => (item={'path': '/var/lib/apt/lists', 'state': 'directory', 'mode': '0755'})
    vsphere:
    vsphere: TASK [sysprep : Disable apt-daily services] ************************************
    vsphere: changed: [default] => (item=apt-daily.timer)
    vsphere: changed: [default] => (item=apt-daily-upgrade.timer)
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
    vsphere: changed: [default] => (item={'path': '/etc/machine-id', 'state': 'absent', 'mode': '0644'})
    vsphere: changed: [default] => (item={'path': '/etc/machine-id', 'state': 'touch', 'mode': '0644'})
    vsphere:
    vsphere: TASK [sysprep : Truncate hostname file] ****************************************
    vsphere: changed: [default] => (item={'path': '/etc/hostname', 'state': 'absent', 'mode': '0644'})
    vsphere: changed: [default] => (item={'path': '/etc/hostname', 'state': 'touch', 'mode': '0644'})
    vsphere:
    vsphere: TASK [sysprep : Set hostname] **************************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Reset hosts file] **********************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Truncate audit logs] *******************************************
    vsphere: changed: [default] => (item={'path': '/var/log/wtmp', 'state': 'absent', 'mode': '0664'})
    vsphere: changed: [default] => (item={'path': '/var/log/lastlog', 'state': 'absent', 'mode': '0664'})
    vsphere: changed: [default] => (item={'path': '/var/log/wtmp', 'state': 'touch', 'mode': '0664'})
    vsphere: changed: [default] => (item={'path': '/var/log/lastlog', 'state': 'touch', 'mode': '0664'})
    vsphere:
    vsphere: TASK [sysprep : Remove cloud-init lib dir and logs] ****************************
    vsphere: ok: [default] => (item=/var/lib/cloud)
    vsphere: ok: [default] => (item=/var/log/cloud-init.log)
    vsphere: ok: [default] => (item=/var/log/cloud-init-output.log)
    vsphere: changed: [default] => (item=/var/run/cloud-init)
    vsphere:
    vsphere: TASK [sysprep : Find temp files] ***********************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Reset temp space] **********************************************
    vsphere: changed: [default] => (item={'path': '/tmp/tmp.fstab', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 34, 'inode': 402670, 'dev': 2049, 'nlink': 1, 'atime': 1677597184.857451, 'mtime': 1677597184.853451, 'ctime': 1677597184.853451, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: ok: [default] => (item={'path': '/tmp/ansible_find_payload_f0kvk8b5', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 402677, 'dev': 2049, 'nlink': 2, 'atime': 1677597223.1412058, 'mtime': 1677597223.1412058, 'ctime': 1677597223.1412058, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/tmp/vmware-root_11794-701728372', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 402667, 'dev': 2049, 'nlink': 2, 'atime': 1677596834.564557, 'mtime': 1677596834.564557, 'ctime': 1677596834.564557, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/tmp/systemd-private-63552066ae0f41f8b3f40451498e4ff1-systemd-resolved.service-ODYbtj', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 402665, 'dev': 2049, 'nlink': 3, 'atime': 1677596833.9565601, 'mtime': 1677596833.9565601, 'ctime': 1677596833.9565601, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/tmp/systemd-private-63552066ae0f41f8b3f40451498e4ff1-systemd-logind.service-3e3WGf', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 788745, 'dev': 2049, 'nlink': 3, 'atime': 1677596646.7835886, 'mtime': 1677596646.7835886, 'ctime': 1677596646.7835886, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/tmp/systemd-private-63552066ae0f41f8b3f40451498e4ff1-chrony.service-KU8mhf', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 402669, 'dev': 2049, 'nlink': 3, 'atime': 1677596913.092651, 'mtime': 1677596913.092651, 'ctime': 1677596913.092651, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/tmp/vmware-root_11732-2832205138', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 400095, 'dev': 2049, 'nlink': 2, 'atime': 1677596832.1765683, 'mtime': 1677596832.1765683, 'ctime': 1677596832.1765683, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/tmp/vmware-root_435-1848905162', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 788741, 'dev': 2049, 'nlink': 2, 'atime': 1677596647.2115886, 'mtime': 1677596647.2115886, 'ctime': 1677596647.2115886, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/tmp/systemd-private-63552066ae0f41f8b3f40451498e4ff1-systemd-hostnamed.service-09uISe', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 402716, 'dev': 2049, 'nlink': 3, 'atime': 1677597214.7612596, 'mtime': 1677597214.7612596, 'ctime': 1677597214.7612596, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/var/tmp/systemd-private-63552066ae0f41f8b3f40451498e4ff1-systemd-resolved.service-3M3Qwh', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 787951, 'dev': 2049, 'nlink': 3, 'atime': 1677596833.9565601, 'mtime': 1677596833.9565601, 'ctime': 1677596833.9565601, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/var/tmp/systemd-private-63552066ae0f41f8b3f40451498e4ff1-chrony.service-qhrzGi', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 276520, 'dev': 2049, 'nlink': 3, 'atime': 1677596913.092651, 'mtime': 1677596913.092651, 'ctime': 1677596913.092651, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/var/tmp/systemd-private-63552066ae0f41f8b3f40451498e4ff1-systemd-logind.service-5Ee1Zh', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 788747, 'dev': 2049, 'nlink': 3, 'atime': 1677596646.7835886, 'mtime': 1677596646.7835886, 'ctime': 1677596646.7835886, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/var/tmp/systemd-private-63552066ae0f41f8b3f40451498e4ff1-systemd-hostnamed.service-SbNfXe', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 262171, 'dev': 2049, 'nlink': 3, 'atime': 1677597214.7612596, 'mtime': 1677597214.7612596, 'ctime': 1677597214.7612596, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere:
    vsphere: [WARNING]: Skipped '/run/netplan' path due to this access issue: '/run/netplan'
    vsphere: TASK [sysprep : Find netplan files] ********************************************
    vsphere: is not a directory
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Delete netplan files] ******************************************
    vsphere: changed: [default] => (item={'path': '/etc/netplan/01-netcfg.yaml', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 195, 'inode': 1048713, 'dev': 2049, 'nlink': 1, 'atime': 1677596772.6521707, 'mtime': 1677596518.2793102, 'ctime': 1677596518.2793102, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere:
    vsphere: TASK [sysprep : Find SSH host keys] ********************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove SSH host keys] ******************************************
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_rsa_key', 'mode': '0600', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 2602, 'inode': 1049683, 'dev': 2049, 'nlink': 1, 'atime': 1677596646.8235886, 'mtime': 1677596605.0113115, 'ctime': 1677596605.0113115, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_ecdsa_key.pub', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 176, 'inode': 1049686, 'dev': 2049, 'nlink': 1, 'atime': 1677596605.0233116, 'mtime': 1677596605.0193117, 'ctime': 1677596605.0193117, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_ecdsa_key', 'mode': '0600', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 505, 'inode': 1049685, 'dev': 2049, 'nlink': 1, 'atime': 1677596646.8275886, 'mtime': 1677596605.0193117, 'ctime': 1677596605.0193117, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_ed25519_key', 'mode': '0600', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 411, 'inode': 1049687, 'dev': 2049, 'nlink': 1, 'atime': 1677596646.8315885, 'mtime': 1677596605.0273116, 'ctime': 1677596605.0273116, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_ed25519_key.pub', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 96, 'inode': 1049688, 'dev': 2049, 'nlink': 1, 'atime': 1677596605.0313115, 'mtime': 1677596605.0273116, 'ctime': 1677596605.0273116, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_rsa_key.pub', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 568, 'inode': 1049684, 'dev': 2049, 'nlink': 1, 'atime': 1677596605.0153117, 'mtime': 1677596605.0113115, 'ctime': 1677596605.0113115, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere:
    vsphere: TASK [sysprep : Remove SSH authorized users] ***********************************
    vsphere: ok: [default] => (item={'path': '/root/.ssh/authorized_keys'})
    vsphere: ok: [default] => (item={'path': '/home/builder/.ssh/authorized_keys'})
    vsphere:
    vsphere: TASK [sysprep : Truncate all remaining log files in /var/log] ******************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Delete all logrotated log zips] ********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Truncate shell history] ****************************************
    vsphere: ok: [default] => (item={'path': '/root/.bash_history'})
    vsphere: ok: [default] => (item={'path': '/home/builder/.bash_history'})
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
==> vsphere: Provisioning with Goss
==> vsphere: Configured to run on Linux
    vsphere: Creating directory: /tkg-tmp/goss
    vsphere: Installing Goss from, https://github.com/aelsabbahy/goss/releases/download/v0.3.16/goss-linux-amd64
    vsphere: Downloading Goss to /tkg-tmp/goss-linux-amd64
==> vsphere:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
==> vsphere:                                  Dload  Upload   Total   Spent    Left  Speed
==> vsphere:   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
==> vsphere:   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
==> vsphere: 100 11.8M  100 11.8M    0     0  3271k      0  0:00:03  0:00:03 --:--:-- 5114k
    vsphere: goss version v0.3.16
==> vsphere: Uploading goss tests...
    vsphere: Inline variables are --vars-inline '{"ARCH":"amd64","OS":"ubuntu","OS_VERSION":"20.04","PROVIDER":"ova","containerd_version":"v1.6.6+vmware.2","kubernetes_cni_deb_version":"1.1.1-00","kubernetes_cni_rpm_version":"1.1.1","kubernetes_cni_source_type":"http","kubernetes_cni_version":"1.1.1+vmware.7","kubernetes_deb_version":"1.23.10-00","kubernetes_rpm_version":"1.23.10","kubernetes_source_type":"http","kubernetes_version":"1.23.10+vmware.1"}'
    vsphere: Uploading Dir /home/imagebuilder/goss
    vsphere: Creating directory: /tkg-tmp/goss/goss
==> vsphere:
==> vsphere:
==> vsphere:
==> vsphere: Running goss tests...
==> vsphere: Running GOSS validate command: cd /tkg-tmp/goss && sudo  /tkg-tmp/goss-linux-amd64 --gossfile goss/goss.yaml  --vars-inline '{"ARCH":"amd64","OS":"ubuntu","OS_VERSION":"20.04","PROVIDER":"ova","containerd_version":"v1.6.6+vmware.2","kubernetes_cni_deb_version":"1.1.1-00","kubernetes_cni_rpm_version":"1.1.1","kubernetes_cni_source_type":"http","kubernetes_cni_version":"1.1.1+vmware.7","kubernetes_deb_version":"1.23.10-00","kubernetes_rpm_version":"1.23.10","kubernetes_source_type":"http","kubernetes_version":"1.23.10+vmware.1"}' validate --retry-timeout 0s --sleep 1s -f json -o pretty
    vsphere: Error: file error: read goss/goss.yaml: is a directory
==> vsphere: Goss validate failed
==> vsphere: Inspect mode on : proceeding without failing Packer
==> vsphere: Running GOSS render command: cd /tkg-tmp/goss &&  /tkg-tmp/goss-linux-amd64 --gossfile goss/goss.yaml  --vars-inline '{"ARCH":"amd64","OS":"ubuntu","OS_VERSION":"20.04","PROVIDER":"ova","containerd_version":"v1.6.6+vmware.2","kubernetes_cni_deb_version":"1.1.1-00","kubernetes_cni_rpm_version":"1.1.1","kubernetes_cni_source_type":"http","kubernetes_cni_version":"1.1.1+vmware.7","kubernetes_deb_version":"1.23.10-00","kubernetes_rpm_version":"1.23.10","kubernetes_source_type":"http","kubernetes_version":"1.23.10+vmware.1"}' render > /tmp/goss-spec.yaml
==> vsphere: file error: read goss/goss.yaml: is a directory
==> vsphere: Goss render failed
==> vsphere: Inspect mode on : proceeding without failing Packer
==> vsphere: Running GOSS render debug command: cd /tkg-tmp/goss &&  /tkg-tmp/goss-linux-amd64 --gossfile goss/goss.yaml  --vars-inline '{"ARCH":"amd64","OS":"ubuntu","OS_VERSION":"20.04","PROVIDER":"ova","containerd_version":"v1.6.6+vmware.2","kubernetes_cni_deb_version":"1.1.1-00","kubernetes_cni_rpm_version":"1.1.1","kubernetes_cni_source_type":"http","kubernetes_cni_version":"1.1.1+vmware.7","kubernetes_deb_version":"1.23.10-00","kubernetes_rpm_version":"1.23.10","kubernetes_source_type":"http","kubernetes_version":"1.23.10+vmware.1"}' render -d > /tmp/debug-goss-spec.yaml
==> vsphere: file error: read goss/goss.yaml: is a directory
==> vsphere: Goss render debug failed
==> vsphere: Inspect mode on : proceeding without failing Packer
==> vsphere:
==> vsphere:
==> vsphere:
==> vsphere: Downloading spec file and debug info
    vsphere: Downloading Goss specs from, /tmp/goss-spec.yaml and /tmp/debug-goss-spec.yaml to current dir
==> vsphere: Executing shutdown command...
==> vsphere: Deleting Floppy drives...
==> vsphere: Deleting Floppy image...
==> vsphere: Eject CD-ROM drives...
==> vsphere: Convert VM into template...
    vsphere: Starting export...
    vsphere: Downloading: ubuntu-2004-kube-v1.23.10_vmware.1-disk-0.vmdk
    vsphere: Exporting file: ubuntu-2004-kube-v1.23.10_vmware.1-disk-0.vmdk
    vsphere: Writing ovf...
==> vsphere: Clear boot order...
==> vsphere: Running post-processor: packer-manifest (type manifest)
==> vsphere: Running post-processor: vsphere (type shell-local)
==> vsphere (shell-local): Running local shell script: /tmp/packer-shell750060967
    vsphere (shell-local): Opening OVF source: ubuntu-2004-kube-v1.23.10+vmware.1.ovf
    vsphere (shell-local): Opening OVA target: ubuntu-2004-kube-v1.23.10+vmware.1.ova
    vsphere (shell-local): Writing OVA package: ubuntu-2004-kube-v1.23.10+vmware.1.ova
    vsphere (shell-local): Transfer Completed
    vsphere (shell-local): Warning:
    vsphere (shell-local):  - No manifest file found.
    vsphere (shell-local):  - No supported manifest(sha1, sha256, sha512) entry found for: 'ubuntu-2004-kube-v1.23.10_vmware.1-disk-0.vmdk'.
    vsphere (shell-local): Completed successfully
    vsphere (shell-local): image-build-ova: cd .
    vsphere (shell-local): image-build-ova: loaded ubuntu-2004-kube-v1.23.10+vmware.1
    vsphere (shell-local): image-build-ova: create ovf ubuntu-2004-kube-v1.23.10+vmware.1.ovf
    vsphere (shell-local): image-build-ova: creating OVA from ubuntu-2004-kube-v1.23.10+vmware.1.ovf using ovftool
    vsphere (shell-local): image-build-ova: create ova checksum ubuntu-2004-kube-v1.23.10+vmware.1.ova.sha256
==> vsphere: Running post-processor: custom-post-processor (type shell-local)
==> vsphere (shell-local): Running local shell script: /tmp/packer-shell508306614
Build 'vsphere' finished after 17 minutes 24 seconds.

==> Wait completed after 17 minutes 24 seconds

==> Builds finished. The artifacts of successful builds are:
--> vsphere: ubuntu-2004-kube-v1.23.10_vmware.1
--> vsphere: ubuntu-2004-kube-v1.23.10_vmware.1
--> vsphere: ubuntu-2004-kube-v1.23.10_vmware.1
--> vsphere: ubuntu-2004-kube-v1.23.10_vmware.1
```
```shell
## output 폴더 OVA 생성
## 1.6 
ls output/ubuntu-2004-kube-v1.23.10_vmware.1/
packer-manifest.json  ubuntu-2004-kube-v1.23.10+vmware.1.ova  ubuntu-2004-kube-v1.23.10+vmware.1.ova.sha256  ubuntu-2004-kube-v1.23.10+vmware.1.ovf  ubuntu-2004-kube-v1.23.10_vmware.1-disk-0.vmdk  ubuntu-2004-kube-v1.23.10_vmware.1.ovf

## 2.1
ls output/ubuntu-2004-kube-v1.24.9_vmware.1/
packer-manifest.json  ubuntu-2004-kube-v1.24.9_vmware.1-disk-0.vmdk  ubuntu-2004-kube-v1.24.9+vmware.1.ova  ubuntu-2004-kube-v1.24.9+vmware.1.ova.sha256  ubuntu-2004-kube-v1.24.9+vmware.1.ovf  ubuntu-2004-kube-v1.24.9_vmware.1.ovf
```
{{< /admonition >}}

## 4. RHEL Custom Image 생성

{{< admonition tip "rhel-8.json 생성" >}}
```shell
cat << 'EOF' > rhel-8.json
{
  "boot_command_prefix": "<up><tab> text inst.ks=",
  "boot_command_suffix": "/8/ks.cfg<enter><wait>",
  "boot_media_path": "http://{{ .HTTPIP }}:{{ .HTTPPort }}",
  "build_name": "rhel-8",
  "distro_arch": "amd64",
  "distro_name": "rhel",
  "distro_version": "8",
  "epel_rpm_gpg_key": "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8",
  "guest_os_type": "rhel8-64",
  "http_directory": "./packer/ova/linux/{{user `distro_name`}}/http/",
  "iso_checksum": "a6a7418a75d721cc696d3cbdd648b5248808e7fef0f8742f518e43b46fa08139",
  "iso_checksum_type": "sha256",
  "iso_url": "./rhel-8.7-x86_64-dvd.iso",
  "os_display_name": "RHEL 8",
  "redhat_epel_rpm": "https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm",
  "shutdown_command": "shutdown -P now",
  "vsphere_guest_os_type": "rhel8_64Guest"
}
EOF
```
{{< /admonition >}}
{{< admonition tip "rhel-8 생성" >}}
```shell
## RHSM_USER= --env RHSM_PASS= \ -- subscription user/pw 설정

## 1.6 설정
docker run -it --rm \
  -v $(pwd)/vsphere.json:/home/imagebuilder/vsphere.json \
  -v $(pwd)/tkg.json:/home/imagebuilder/tkg.json \
  -v $(pwd)/tkg:/home/imagebuilder/tkg \
  -v $(pwd)/goss/vsphere-ubuntu-1.23.10+vmware.2-goss-spec.yaml:/home/imagebuilder/goss/goss.yaml \
  -v $(pwd)/metadata.json:/home/imagebuilder/metadata.json \
  -v $(pwd)/output:/home/imagebuilder/output \
  -v $(pwd)/rhel-8.json:/home/imagebuilder/packer/ova/rhel-8.json \
  -v $(pwd)/ks.cfg:/home/imagebuilder/packer/ova/linux/photon/http/3/ks.cfg \
  -v $(pwd)/rhel-8.7-x86_64-dvd.iso:/home/imagebuilder/rhel-8.7-x86_64-dvd.iso \
  --network host \
  --env RHSM_USER={ID} --env RHSM_PASS={PW} \
  --env PACKER_VAR_FILES="tkg.json vsphere.json" \
  --env OVF_CUSTOM_PROPERTIES=/home/imagebuilder/metadata.json \
  --env IB_OVFTOOL=1 \
  --env IB_OVFTOOL_ARGS="--allowExtraConfig" \
  projects.registry.vmware.com/tkg/image-builder:v0.1.13_vmware.2 \
  build-node-ova-vsphere-rhel-8

## 2.1 설정
docker run -it --rm \
  -v $(pwd)/vsphere.json:/home/imagebuilder/vsphere.json \
  -v $(pwd)/tkg.json:/home/imagebuilder/tkg.json \
  -v $(pwd)/tkg:/home/imagebuilder/tkg \
  -v $(pwd)/goss/vsphere-rhel-8-v1.24.9+vmware.1-tkg_v2_1_0-goss-spec.yaml:/home/imagebuilder/goss/goss.yaml \
  -v $(pwd)/metadata.json:/home/imagebuilder/metadata.json \
  -v $(pwd)/output:/home/imagebuilder/output \
  -v $(pwd)/rhel-8.json:/home/imagebuilder/packer/ova/rhel-8.json \
  -v $(pwd)/ks.cfg:/home/imagebuilder/packer/ova/linux/photon/http/3/ks.cfg \
  -v $(pwd)/rhel-8.7-x86_64-dvd.iso:/home/imagebuilder/rhel-8.7-x86_64-dvd.iso \
  --network host \
  --env RHSM_USER={ID} --env RHSM_PASS={PW} \
  --env PACKER_VAR_FILES="tkg.json vsphere.json" \
  --env OVF_CUSTOM_PROPERTIES=/home/imagebuilder/metadata.json \
  --env IB_OVFTOOL=1 \
  --env IB_OVFTOOL_ARGS="--allowExtraConfig" \
  projects.registry.vmware.com/tkg/image-builder:v0.1.13_vmware.2 \
  build-node-ova-vsphere-rhel-8
```
{{< /admonition >}}

{{< admonition tip "LOG" >}}

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
packer build -var-file="/home/imagebuilder/packer/config/kubernetes.json"  -var-file="/home/imagebuilder/packer/config/cni.json"  -var-file="/home/imagebuilder/packer/config/containerd.json"  -var-file="/home/imagebuilder/packer/config/ansible-args.json"  -var-file="/home/imagebuilder/packer/config/goss-args.json"  -var-file="/home/imagebuilder/packer/config/common.json"  -var-file="/home/imagebuilder/packer/config/additional_components.json"  -color=true  -var-file="packer/ova/packer-common.json" -var-file="/home/imagebuilder/packer/ova/rhel-8.json" -var-file="packer/ova/vsphere.json"  -except=local -only=vsphere-iso -var-file="/home/imagebuilder/tkg.json"  -var-file="/home/imagebuilder/vsphere.json"  -only=vsphere packer/ova/packer-node.json
vsphere: output will be in this color.

==> vsphere: Retrieving ISO
==> vsphere: Trying ./rhel-8.7-x86_64-dvd.iso
==> vsphere: Trying ./rhel-8.7-x86_64-dvd.iso?checksum=sha256%3Aa6a7418a75d721cc696d3cbdd648b5248808e7fef0f8742f518e43b46fa08139
==> vsphere: ./rhel-8.7-x86_64-dvd.iso?checksum=sha256%3Aa6a7418a75d721cc696d3cbdd648b5248808e7fef0f8742f518e43b46fa08139 => /home/imagebuilder/rhel-8.7-x86_64-dvd.iso
==> vsphere: Uploading rhel-8.7-x86_64-dvd.iso to packer_cache/rhel-8.7-x86_64-dvd.iso
==> vsphere: Creating VM...
==> vsphere: Customizing hardware...
==> vsphere: Mounting ISO images...
==> vsphere: Adding configuration parameters...
==> vsphere: Starting HTTP server on port 8709
==> vsphere: Set boot order temporary...
==> vsphere: Power on VM...
==> vsphere: Waiting 10s for boot...
==> vsphere: HTTP server is working at http://10.253.126.163:8709/
==> vsphere: Typing boot command...
==> vsphere: Waiting for IP...
==> vsphere: IP address: 10.253.126.195
==> vsphere: Using SSH communicator to connect: 10.253.126.195
==> vsphere: Waiting for SSH to become available...
==> vsphere: Connected to SSH!
==> vsphere: Provisioning with shell script: ./packer/files/flatcar/scripts/bootstrap-flatcar.sh
==> vsphere: Provisioning with Ansible...
    vsphere: Setting up proxy adapter for Ansible....
==> vsphere: Executing Ansible: ansible-playbook -e packer_build_name="vsphere" -e packer_*****_type=vsphere-iso -e packer_http_addr=10.253.126.163:8709 --ssh-extra-args '-o IdentitiesOnly=yes' --extra-vars containerd_url=http://10.253.126.163:3000/files/containerd/cri-containerd-v1.6.6+vmware.2.linux-amd64.tar containerd_sha256=48f4327570dd7543464a28893160ab3bc9719ed2553f0a529a884b40f6dafd29 pause_image=projects.registry.vmware.com/tkg/pause:3.6 containerd_additional_settings= containerd_cri_socket=/var/run/containerd/containerd.sock containerd_version=v1.6.6+vmware.2 crictl_url= crictl_sha256= crictl_source_type=pkg custom_role_names="/home/image*****/tkg" firstboot_custom_roles_pre="" firstboot_custom_roles_post="" node_custom_roles_pre="" node_custom_roles_post="" disable_public_repos=false extra_debs="nfs-common unzip apparmor apparmor-utils sysstat" extra_repos="" extra_rpms="sysstat" http_proxy= https_proxy= kubeadm_template=etc/kubeadm.yml kubernetes_cni_http_source=http://10.253.126.163:3000/files/cni_plugins kubernetes_cni_http_checksum= kubernetes_http_source=http://10.253.126.163:3000/files/kubernetes kubernetes_container_registry=projects.registry.vmware.com/tkg kubernetes_rpm_repo=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64 kubernetes_rpm_gpg_key="https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" kubernetes_rpm_gpg_check=True kubernetes_deb_repo="https://apt.kubernetes.io/ kubernetes-xenial" kubernetes_deb_gpg_key=https://packages.cloud.google.com/apt/doc/apt-key.gpg kubernetes_cni_deb_version=1.1.1-00 kubernetes_cni_rpm_version=1.1.1-0 kubernetes_cni_semver=v1.1.1+vmware.7 kubernetes_cni_source_type=http kubernetes_semver=v1.23.10+vmware.1 kubernetes_source_type=http kubernetes_load_additional_imgs=true kubernetes_deb_version=1.23.10-00 kubernetes_rpm_version=1.23.10-0 no_proxy= pip_conf_file= python_path= redhat_epel_rpm=https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm epel_rpm_gpg_key=https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8 reenable_public_repos=true remove_extra_repos=false systemd_prefix=/usr/lib/systemd sysusr_prefix=/usr sysusrlocal_prefix=/usr/local load_additional_components=false additional_registry_images=false additional_registry_images_list= additional_url_images=false additional_url_images_list= additional_executables=false additional_executables_list= additional_executables_destination_path= build_target=virt amazon_ssm_agent_rpm= --extra-vars guestinfo_datasource_slug=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo guestinfo_datasource_ref=v1.4.1 guestinfo_datasource_script=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/v1.4.1/install.sh --extra-vars  -e ansible_ssh_private_key_file=/tmp/ansible-key1071931383 -i /tmp/packer-provisioner-ansible1131624432 /home/image*****/ansible/firstboot.yml
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
==> vsphere: Provisioning with shell script: /tmp/packer-shell2138983735
==> vsphere: Provisioning with Ansible...
    vsphere: Setting up proxy adapter for Ansible....
==> vsphere: Executing Ansible: ansible-playbook -e packer_build_name="vsphere" -e packer_*****_type=vsphere-iso -e packer_http_addr=10.253.126.163:8709 --ssh-extra-args '-o IdentitiesOnly=yes' --extra-vars containerd_url=http://10.253.126.163:3000/files/containerd/cri-containerd-v1.6.6+vmware.2.linux-amd64.tar containerd_sha256=48f4327570dd7543464a28893160ab3bc9719ed2553f0a529a884b40f6dafd29 pause_image=projects.registry.vmware.com/tkg/pause:3.6 containerd_additional_settings= containerd_cri_socket=/var/run/containerd/containerd.sock containerd_version=v1.6.6+vmware.2 crictl_url= crictl_sha256= crictl_source_type=pkg custom_role_names="/home/image*****/tkg" firstboot_custom_roles_pre="" firstboot_custom_roles_post="" node_custom_roles_pre="" node_custom_roles_post="" disable_public_repos=false extra_debs="nfs-common unzip apparmor apparmor-utils sysstat" extra_repos="" extra_rpms="sysstat" http_proxy= https_proxy= kubeadm_template=etc/kubeadm.yml kubernetes_cni_http_source=http://10.253.126.163:3000/files/cni_plugins kubernetes_cni_http_checksum= kubernetes_http_source=http://10.253.126.163:3000/files/kubernetes kubernetes_container_registry=projects.registry.vmware.com/tkg kubernetes_rpm_repo=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64 kubernetes_rpm_gpg_key="https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" kubernetes_rpm_gpg_check=True kubernetes_deb_repo="https://apt.kubernetes.io/ kubernetes-xenial" kubernetes_deb_gpg_key=https://packages.cloud.google.com/apt/doc/apt-key.gpg kubernetes_cni_deb_version=1.1.1-00 kubernetes_cni_rpm_version=1.1.1-0 kubernetes_cni_semver=v1.1.1+vmware.7 kubernetes_cni_source_type=http kubernetes_semver=v1.23.10+vmware.1 kubernetes_source_type=http kubernetes_load_additional_imgs=true kubernetes_deb_version=1.23.10-00 kubernetes_rpm_version=1.23.10-0 no_proxy= pip_conf_file= python_path= redhat_epel_rpm=https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm epel_rpm_gpg_key=https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8 reenable_public_repos=true remove_extra_repos=false systemd_prefix=/usr/lib/systemd sysusr_prefix=/usr sysusrlocal_prefix=/usr/local load_additional_components=false additional_registry_images=false additional_registry_images_list= additional_url_images=false additional_url_images_list= additional_executables=false additional_executables_list= additional_executables_destination_path= build_target=virt amazon_ssm_agent_rpm= --extra-vars guestinfo_datasource_slug=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo guestinfo_datasource_ref=v1.4.1 guestinfo_datasource_script=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/v1.4.1/install.sh --extra-vars  -e ansible_ssh_private_key_file=/tmp/ansible-key652222647 -i /tmp/packer-provisioner-ansible1252180858 /home/image*****/ansible/node.yml
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
    vsphere: changed: [default] => (item={'param': 'net.bridge.bridge-nf-call-iptables', 'val': 1})
    vsphere: changed: [default] => (item={'param': 'net.bridge.bridge-nf-call-ip6tables', 'val': 1})
    vsphere: changed: [default] => (item={'param': 'net.ipv4.ip_forward', 'val': 1})
    vsphere: changed: [default] => (item={'param': 'net.ipv6.conf.all.forwarding', 'val': 1})
    vsphere: changed: [default] => (item={'param': 'net.ipv6.conf.all.disable_ipv6', 'val': 0})
    vsphere: changed: [default] => (item={'param': 'net.ipv4.tcp_congestion_control', 'val': 'bbr'})
    vsphere: changed: [default] => (item={'param': 'vm.overcommit_memory', 'val': 1})
    vsphere: changed: [default] => (item={'param': 'kernel.panic', 'val': 10})
    vsphere: changed: [default] => (item={'param': 'kernel.panic_on_oops', 'val': 1})
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
    vsphere: ok: [default] => (item=cloud-final)
    vsphere: ok: [default] => (item=cloud-config)
    vsphere: ok: [default] => (item=cloud-init)
    vsphere: ok: [default] => (item=cloud-init-local)
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
    vsphere: changed: [default] => (item=ctr)
    vsphere: changed: [default] => (item=crictl)
    vsphere: changed: [default] => (item=critest)
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
    vsphere: changed: [default] => (item=kubeadm)
    vsphere: changed: [default] => (item=kubectl)
    vsphere: changed: [default] => (item=kubelet)
    vsphere:
    vsphere: TASK [kubernetes : Download Kubernetes images] *********************************
    vsphere: changed: [default] => (item=kube-apiserver.tar)
    vsphere: changed: [default] => (item=kube-controller-manager.tar)
    vsphere: changed: [default] => (item=kube-scheduler.tar)
    vsphere: changed: [default] => (item=kube-proxy.tar)
    vsphere: changed: [default] => (item=pause.tar)
    vsphere: changed: [default] => (item=coredns.tar)
    vsphere: changed: [default] => (item=etcd.tar)
    vsphere:
    vsphere: TASK [kubernetes : Load Kubernetes images] *************************************
    vsphere: changed: [default] => (item=kube-apiserver.tar)
    vsphere: changed: [default] => (item=kube-controller-manager.tar)
    vsphere: changed: [default] => (item=kube-scheduler.tar)
    vsphere: changed: [default] => (item=kube-proxy.tar)
    vsphere: changed: [default] => (item=pause.tar)
    vsphere: changed: [default] => (item=coredns.tar)
    vsphere: changed: [default] => (item=etcd.tar)
    vsphere:
    vsphere: TASK [kubernetes : Remove Kubernetes images] ***********************************
    vsphere: changed: [default] => (item=kube-apiserver.tar)
    vsphere: changed: [default] => (item=kube-controller-manager.tar)
    vsphere: changed: [default] => (item=kube-scheduler.tar)
    vsphere: changed: [default] => (item=kube-proxy.tar)
    vsphere: changed: [default] => (item=pause.tar)
    vsphere: changed: [default] => (item=coredns.tar)
    vsphere: changed: [default] => (item=etcd.tar)
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
    vsphere: changed: [default] => (item={'param': 'net.ipv4.neigh.default.gc_thresh1', 'val': 4096})
    vsphere: changed: [default] => (item={'param': 'net.ipv6.neigh.default.gc_thresh1', 'val': 4096})
    vsphere: changed: [default] => (item={'param': 'net.ipv4.neigh.default.gc_thresh2', 'val': 8192})
    vsphere: changed: [default] => (item={'param': 'net.ipv6.neigh.default.gc_thresh2', 'val': 8192})
    vsphere: changed: [default] => (item={'param': 'net.ipv4.neigh.default.gc_thresh3', 'val': 16384})
    vsphere: changed: [default] => (item={'param': 'net.ipv6.neigh.default.gc_thresh3', 'val': 16384})
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
    vsphere: changed: [default] => (item={'path': '/etc/machine-id', 'state': 'absent', 'mode': '0444'})
    vsphere: changed: [default] => (item={'path': '/etc/machine-id', 'state': 'touch', 'mode': '0444'})
    vsphere:
    vsphere: TASK [sysprep : Truncate hostname file] ****************************************
    vsphere: changed: [default] => (item={'path': '/etc/hostname', 'state': 'absent', 'mode': '0644'})
    vsphere: changed: [default] => (item={'path': '/etc/hostname', 'state': 'touch', 'mode': '0644'})
    vsphere:
    vsphere: TASK [sysprep : Set hostname] **************************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Reset hosts file] **********************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Truncate audit logs] *******************************************
    vsphere: changed: [default] => (item={'path': '/var/log/wtmp', 'state': 'absent', 'mode': '0664'})
    vsphere: changed: [default] => (item={'path': '/var/log/lastlog', 'state': 'absent', 'mode': '0644'})
    vsphere: changed: [default] => (item={'path': '/var/log/wtmp', 'state': 'touch', 'mode': '0664'})
    vsphere: changed: [default] => (item={'path': '/var/log/lastlog', 'state': 'touch', 'mode': '0644'})
    vsphere:
    vsphere: TASK [sysprep : Remove cloud-init lib dir and logs] ****************************
    vsphere: changed: [default] => (item=/var/lib/cloud)
    vsphere: ok: [default] => (item=/var/log/cloud-init.log)
    vsphere: ok: [default] => (item=/var/log/cloud-init-output.log)
    vsphere: changed: [default] => (item=/var/run/cloud-init)
    vsphere:
    vsphere: TASK [sysprep : Find temp files] ***********************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Reset temp space] **********************************************
    vsphere: changed: [default] => (item={'path': '/tmp/tmp.fstab', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 34, 'inode': 917558, 'dev': 2049, 'nlink': 1, 'atime': 1677598881.515565, 'mtime': 1677598881.511565, 'ctime': 1677598881.511565, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/tmp/ks-script-womie7ev', 'mode': '0700', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 701, 'inode': 917515, 'dev': 2049, 'nlink': 1, 'atime': 1677598324.1556787, 'mtime': 1677598324.1486788, 'ctime': 1677598324.1486788, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/tmp/ks-script-8szmx8f8', 'mode': '0700', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 291, 'inode': 917517, 'dev': 2049, 'nlink': 1, 'atime': 1677598326.7056713, 'mtime': 1677598326.6976714, 'ctime': 1677598326.6976714, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/tmp/systemd-private-b8ce99c5a00043e28de4419f4592fc36-systemd-hostnamed.service-a3ZTtU', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 917547, 'dev': 2049, 'nlink': 3, 'atime': 1677598962.1890013, 'mtime': 1677598962.1890013, 'ctime': 1677598962.1890013, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/tmp/systemd-private-b8ce99c5a00043e28de4419f4592fc36-chronyd.service-1qPo5I', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 917523, 'dev': 2049, 'nlink': 3, 'atime': 1677598344.4472764, 'mtime': 1677598344.4472764, 'ctime': 1677598344.4472764, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/tmp/vmware-root_756-2965382642', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 917527, 'dev': 2049, 'nlink': 2, 'atime': 1677598344.8446836, 'mtime': 1677598344.8446836, 'ctime': 1677598344.8446836, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: ok: [default] => (item={'path': '/tmp/ansible_find_payload_zej9mp7r', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 917531, 'dev': 2049, 'nlink': 2, 'atime': 1677598971.9629292, 'mtime': 1677598971.9639292, 'ctime': 1677598971.9639292, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/var/tmp/systemd-private-b8ce99c5a00043e28de4419f4592fc36-systemd-hostnamed.service-xvJeOq', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 1050059, 'dev': 2049, 'nlink': 3, 'atime': 1677598962.1890013, 'mtime': 1677598962.1900015, 'ctime': 1677598962.1900015, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/var/tmp/systemd-private-b8ce99c5a00043e28de4419f4592fc36-chronyd.service-CiirL0', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 1050453, 'dev': 2049, 'nlink': 3, 'atime': 1677598344.4472764, 'mtime': 1677598344.4472764, 'ctime': 1677598344.4472764, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere:
    vsphere: [WARNING]: Skipped '/lib/netplan' path due to this access issue: '/lib/netplan'
    vsphere: TASK [sysprep : Find netplan files] ********************************************
    vsphere: is not a directory
    vsphere: ok: [default]
    vsphere: [WARNING]: Skipped '/etc/netplan' path due to this access issue: '/etc/netplan'
    vsphere: is not a directory
    vsphere: [WARNING]: Skipped '/run/netplan' path due to this access issue: '/run/netplan'
    vsphere: is not a directory
    vsphere:
    vsphere: TASK [sysprep : Find SSH host keys] ********************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove SSH host keys] ******************************************
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_ecdsa_key.pub', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 162, 'inode': 787156, 'dev': 2049, 'nlink': 1, 'atime': 1677598344.7996838, 'mtime': 1677598344.4712763, 'ctime': 1677598344.4872763, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_ecdsa_key', 'mode': '0640', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 995, 'size': 480, 'inode': 787155, 'dev': 2049, 'nlink': 1, 'atime': 1677598344.7996838, 'mtime': 1677598344.4712763, 'ctime': 1677598344.4812763, 'gr_name': 'ssh_keys', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_ed25519_key', 'mode': '0640', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 995, 'size': 387, 'inode': 787153, 'dev': 2049, 'nlink': 1, 'atime': 1677598344.7996838, 'mtime': 1677598344.4712763, 'ctime': 1677598344.4852762, 'gr_name': 'ssh_keys', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_rsa_key.pub', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 554, 'inode': 787158, 'dev': 2049, 'nlink': 1, 'atime': 1677598344.7996838, 'mtime': 1677598344.7286837, 'ctime': 1677598344.7676837, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_rsa_key', 'mode': '0640', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 995, 'size': 2578, 'inode': 787157, 'dev': 2049, 'nlink': 1, 'atime': 1677598344.7986836, 'mtime': 1677598344.7286837, 'ctime': 1677598344.7676837, 'gr_name': 'ssh_keys', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_ed25519_key.pub', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 82, 'inode': 787154, 'dev': 2049, 'nlink': 1, 'atime': 1677598344.7996838, 'mtime': 1677598344.4712763, 'ctime': 1677598344.4872763, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere:
    vsphere: TASK [sysprep : Remove SSH authorized users] ***********************************
    vsphere: ok: [default] => (item={'path': '/root/.ssh/authorized_keys'})
    vsphere: ok: [default] => (item={'path': '/home/builder/.ssh/authorized_keys'})
    vsphere:
    vsphere: TASK [sysprep : Truncate all remaining log files in /var/log] ******************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Delete all logrotated log zips] ********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Truncate shell history] ****************************************
    vsphere: ok: [default] => (item={'path': '/root/.bash_history'})
    vsphere: ok: [default] => (item={'path': '/home/builder/.bash_history'})
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
==> vsphere: Provisioning with Goss
==> vsphere: Configured to run on Linux
    vsphere: Creating directory: /tkg-tmp/goss
    vsphere: Installing Goss from, https://github.com/aelsabbahy/goss/releases/download/v0.3.16/goss-linux-amd64
    vsphere: Downloading Goss to /tkg-tmp/goss-linux-amd64
==> vsphere:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
==> vsphere:                                  Dload  Upload   Total   Spent    Left  Speed
==> vsphere:   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
==> vsphere:   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
==> vsphere: 100 11.8M  100 11.8M    0     0  2901k      0  0:00:04  0:00:04 --:--:-- 4025k
    vsphere: goss version v0.3.16
==> vsphere: Uploading goss tests...
    vsphere: Inline variables are --vars-inline '{"ARCH":"amd64","OS":"rhel","OS_VERSION":"8","PROVIDER":"ova","containerd_version":"v1.6.6+vmware.2","kubernetes_cni_deb_version":"1.1.1-00","kubernetes_cni_rpm_version":"1.1.1","kubernetes_cni_source_type":"http","kubernetes_cni_version":"1.1.1+vmware.7","kubernetes_deb_version":"1.23.10-00","kubernetes_rpm_version":"1.23.10","kubernetes_source_type":"http","kubernetes_version":"1.23.10+vmware.1"}'
    vsphere: Uploading Dir /home/imagebuilder/goss
    vsphere: Creating directory: /tkg-tmp/goss/goss
==> vsphere:
==> vsphere:
==> vsphere:
==> vsphere: Running goss tests...
==> vsphere: Running GOSS render command: cd /tkg-tmp/goss &&  /tkg-tmp/goss-linux-amd64 --gossfile goss/goss.yaml  --vars-inline '{"ARCH":"amd64","OS":"rhel","OS_VERSION":"8","PROVIDER":"ova","containerd_version":"v1.6.6+vmware.2","kubernetes_cni_deb_version":"1.1.1-00","kubernetes_cni_rpm_version":"1.1.1","kubernetes_cni_source_type":"http","kubernetes_cni_version":"1.1.1+vmware.7","kubernetes_deb_version":"1.23.10-00","kubernetes_rpm_version":"1.23.10","kubernetes_source_type":"http","kubernetes_version":"1.23.10+vmware.1"}' render > /tmp/goss-spec.yaml
==> vsphere: file error: read goss/goss.yaml: is a directory
==> vsphere: Goss render failed
==> vsphere: Inspect mode on : proceeding without failing Packer
==> vsphere: Running GOSS render debug command: cd /tkg-tmp/goss &&  /tkg-tmp/goss-linux-amd64 --gossfile goss/goss.yaml  --vars-inline '{"ARCH":"amd64","OS":"rhel","OS_VERSION":"8","PROVIDER":"ova","containerd_version":"v1.6.6+vmware.2","kubernetes_cni_deb_version":"1.1.1-00","kubernetes_cni_rpm_version":"1.1.1","kubernetes_cni_source_type":"http","kubernetes_cni_version":"1.1.1+vmware.7","kubernetes_deb_version":"1.23.10-00","kubernetes_rpm_version":"1.23.10","kubernetes_source_type":"http","kubernetes_version":"1.23.10+vmware.1"}' render -d > /tmp/debug-goss-spec.yaml
==> vsphere: file error: read goss/goss.yaml: is a directory
==> vsphere: Goss render debug failed
==> vsphere: Inspect mode on : proceeding without failing Packer
==> vsphere: Running GOSS validate command: cd /tkg-tmp/goss && sudo  /tkg-tmp/goss-linux-amd64 --gossfile goss/goss.yaml  --vars-inline '{"ARCH":"amd64","OS":"rhel","OS_VERSION":"8","PROVIDER":"ova","containerd_version":"v1.6.6+vmware.2","kubernetes_cni_deb_version":"1.1.1-00","kubernetes_cni_rpm_version":"1.1.1","kubernetes_cni_source_type":"http","kubernetes_cni_version":"1.1.1+vmware.7","kubernetes_deb_version":"1.23.10-00","kubernetes_rpm_version":"1.23.10","kubernetes_source_type":"http","kubernetes_version":"1.23.10+vmware.1"}' validate --retry-timeout 0s --sleep 1s -f json -o pretty
    vsphere: Error: file error: read goss/goss.yaml: is a directory
==> vsphere: Goss validate failed
==> vsphere: Inspect mode on : proceeding without failing Packer
==> vsphere:
==> vsphere:
==> vsphere:
==> vsphere: Downloading spec file and debug info
    vsphere: Downloading Goss specs from, /tmp/goss-spec.yaml and /tmp/debug-goss-spec.yaml to current dir
==> vsphere: Executing shutdown command...
==> vsphere: Deleting Floppy drives...
==> vsphere: Eject CD-ROM drives...
==> vsphere: Convert VM into template...
    vsphere: Starting export...
    vsphere: Downloading: rhel-8-kube-v1.23.10_vmware.1-disk-0.vmdk
    vsphere: Exporting file: rhel-8-kube-v1.23.10_vmware.1-disk-0.vmdk
    vsphere: Writing ovf...
==> vsphere: Clear boot order...
==> vsphere: Running post-processor: packer-manifest (type manifest)
==> vsphere: Running post-processor: vsphere (type shell-local)
==> vsphere (shell-local): Running local shell script: /tmp/packer-shell4251240128
    vsphere (shell-local): Opening OVF source: rhel-8-kube-v1.23.10+vmware.1.ovf
    vsphere (shell-local): Opening OVA target: rhel-8-kube-v1.23.10+vmware.1.ova
    vsphere (shell-local): Writing OVA package: rhel-8-kube-v1.23.10+vmware.1.ova
    vsphere (shell-local): Transfer Completed
    vsphere (shell-local): Warning:
    vsphere (shell-local):  - No manifest file found.
    vsphere (shell-local):  - No supported manifest(sha1, sha256, sha512) entry found for: 'rhel-8-kube-v1.23.10_vmware.1-disk-0.vmdk'.
    vsphere (shell-local): Completed successfully
    vsphere (shell-local): image-build-ova: cd .
    vsphere (shell-local): image-build-ova: loaded rhel-8-kube-v1.23.10+vmware.1
    vsphere (shell-local): image-build-ova: create ovf rhel-8-kube-v1.23.10+vmware.1.ovf
    vsphere (shell-local): image-build-ova: creating OVA from rhel-8-kube-v1.23.10+vmware.1.ovf using ovftool
    vsphere (shell-local): image-build-ova: create ova checksum rhel-8-kube-v1.23.10+vmware.1.ova.sha256
==> vsphere: Running post-processor: custom-post-processor (type shell-local)
==> vsphere (shell-local): Running local shell script: /tmp/packer-shell2087900433
Build 'vsphere' finished after 25 minutes 32 seconds.

==> Wait completed after 25 minutes 32 seconds

==> Builds finished. The artifacts of successful builds are:
--> vsphere: rhel-8-kube-v1.23.10_vmware.1
--> vsphere: rhel-8-kube-v1.23.10_vmware.1
--> vsphere: rhel-8-kube-v1.23.10_vmware.1
--> vsphere: rhel-8-kube-v1.23.10_vmware.1

```

```shell
## output 폴더 OVA 생성

## 1.6 
ls output/rhel-8-kube-v1.23.10_vmware.1/
packer-manifest.json  rhel-8-kube-v1.23.10+vmware.1.ova  rhel-8-kube-v1.23.10+vmware.1.ova.sha256  rhel-8-kube-v1.23.10+vmware.1.ovf  rhel-8-kube-v1.23.10_vmware.1-disk-0.vmdk  rhel-8-kube-v1.23.10_vmware.1.ovf

## 2.1
ls output/rhel-8-kube-v1.24.9_vmware.1/
packer-manifest.json  rhel-8-kube-v1.24.9_vmware.1-disk-0.vmdk  rhel-8-kube-v1.24.9+vmware.1.ova  rhel-8-kube-v1.24.9+vmware.1.ova.sha256  rhel-8-kube-v1.24.9+vmware.1.ovf  rhel-8-kube-v1.24.9_vmware.1.ovf
```
{{< /admonition >}}

## 5. Photon Custom Image 생성

{{< admonition tip "LOG" >}}
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
packer build -var-file="/home/imagebuilder/packer/config/kubernetes.json"  -var-file="/home/imagebuilder/packer/config/cni.json"  -var-file="/home/imagebuilder/packer/config/containerd.json"  -var-file="/home/imagebuilder/packer/config/ansible-args.json"  -var-file="/home/imagebuilder/packer/config/goss-args.json"  -var-file="/home/imagebuilder/packer/config/common.json"  -var-file="/home/imagebuilder/packer/config/additional_components.json"  -color=true  -var-file="packer/ova/packer-common.json" -var-file="/home/imagebuilder/packer/ova/photon-3.json" -var-file="packer/ova/vsphere.json"  -except=local -only=vsphere-iso -var-file="/home/imagebuilder/tkg.json"  -var-file="/home/imagebuilder/vsphere.json"  -only=vsphere packer/ova/packer-node.json
vsphere: output will be in this color.

==> vsphere: File /home/imagebuilder/.cache/packer/2d88648c04e690990b2940ca3710b0baadf15256.iso already uploaded; continuing
==> vsphere: File [vsanDatastore] packer_cache//2d88648c04e690990b2940ca3710b0baadf15256.iso already exists; skipping upload.
==> vsphere: Creating VM...
==> vsphere: Customizing hardware...
==> vsphere: Mounting ISO images...
==> vsphere: Adding configuration parameters...
==> vsphere: Starting HTTP server on port 8897
==> vsphere: Set boot order temporary...
==> vsphere: Power on VM...
==> vsphere: Waiting 10s for boot...
==> vsphere: HTTP server is working at http://10.253.126.163:8897/
==> vsphere: Typing boot command...
==> vsphere: Waiting for IP...
==> vsphere: IP address: 10.253.126.198
==> vsphere: Using SSH communicator to connect: 10.253.126.198
==> vsphere: Waiting for SSH to become available...
==> vsphere: Connected to SSH!
==> vsphere: Provisioning with shell script: ./packer/files/flatcar/scripts/bootstrap-flatcar.sh
==> vsphere: Provisioning with Ansible...
    vsphere: Setting up proxy adapter for Ansible....
==> vsphere: Executing Ansible: ansible-playbook -e packer_build_name="vsphere" -e packer_*****_type=vsphere-iso -e packer_http_addr=10.253.126.163:8897 --ssh-extra-args '-o IdentitiesOnly=yes' --extra-vars containerd_url=http://10.253.126.163:3000/files/containerd/cri-containerd-v1.6.6+vmware.2.linux-amd64.tar containerd_sha256=48f4327570dd7543464a28893160ab3bc9719ed2553f0a529a884b40f6dafd29 pause_image=projects.registry.vmware.com/tkg/pause:3.6 containerd_additional_settings= containerd_cri_socket=/var/run/containerd/containerd.sock containerd_version=v1.6.6+vmware.2 crictl_url= crictl_sha256= crictl_source_type=pkg custom_role_names="/home/image*****/tkg" firstboot_custom_roles_pre="" firstboot_custom_roles_post="" node_custom_roles_pre="" node_custom_roles_post="" disable_public_repos=false extra_debs="nfs-common unzip apparmor apparmor-utils sysstat" extra_repos="" extra_rpms="sysstat" http_proxy= https_proxy= kubeadm_template=etc/kubeadm.yml kubernetes_cni_http_source=http://10.253.126.163:3000/files/cni_plugins kubernetes_cni_http_checksum= kubernetes_http_source=http://10.253.126.163:3000/files/kubernetes kubernetes_container_registry=projects.registry.vmware.com/tkg kubernetes_rpm_repo=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64 kubernetes_rpm_gpg_key="https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" kubernetes_rpm_gpg_check=True kubernetes_deb_repo="https://apt.kubernetes.io/ kubernetes-xenial" kubernetes_deb_gpg_key=https://packages.cloud.google.com/apt/doc/apt-key.gpg kubernetes_cni_deb_version=1.1.1-00 kubernetes_cni_rpm_version=1.1.1-0 kubernetes_cni_semver=v1.1.1+vmware.7 kubernetes_cni_source_type=http kubernetes_semver=v1.23.10+vmware.1 kubernetes_source_type=http kubernetes_load_additional_imgs=true kubernetes_deb_version=1.23.10-00 kubernetes_rpm_version=1.23.10-0 no_proxy= pip_conf_file= python_path= redhat_epel_rpm=https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm epel_rpm_gpg_key= reenable_public_repos=true remove_extra_repos=false systemd_prefix=/usr/lib/systemd sysusr_prefix=/usr sysusrlocal_prefix=/usr/local load_additional_components=false additional_registry_images=false additional_registry_images_list= additional_url_images=false additional_url_images_list= additional_executables=false additional_executables_list= additional_executables_destination_path= build_target=virt amazon_ssm_agent_rpm= --extra-vars guestinfo_datasource_slug=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo guestinfo_datasource_ref=v1.4.1 guestinfo_datasource_script=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/v1.4.1/install.sh --extra-vars  -e ansible_ssh_private_key_file=/tmp/ansible-key167164286 -i /tmp/packer-provisioner-ansible3699664147 /home/image*****/ansible/firstboot.yml
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
==> vsphere: Provisioning with shell script: /tmp/packer-shell2422633172
==> vsphere: Provisioning with Ansible...
    vsphere: Setting up proxy adapter for Ansible....
==> vsphere: Executing Ansible: ansible-playbook -e packer_build_name="vsphere" -e packer_*****_type=vsphere-iso -e packer_http_addr=10.253.126.163:8897 --ssh-extra-args '-o IdentitiesOnly=yes' --extra-vars containerd_url=http://10.253.126.163:3000/files/containerd/cri-containerd-v1.6.6+vmware.2.linux-amd64.tar containerd_sha256=48f4327570dd7543464a28893160ab3bc9719ed2553f0a529a884b40f6dafd29 pause_image=projects.registry.vmware.com/tkg/pause:3.6 containerd_additional_settings= containerd_cri_socket=/var/run/containerd/containerd.sock containerd_version=v1.6.6+vmware.2 crictl_url= crictl_sha256= crictl_source_type=pkg custom_role_names="/home/image*****/tkg" firstboot_custom_roles_pre="" firstboot_custom_roles_post="" node_custom_roles_pre="" node_custom_roles_post="" disable_public_repos=false extra_debs="nfs-common unzip apparmor apparmor-utils sysstat" extra_repos="" extra_rpms="sysstat" http_proxy= https_proxy= kubeadm_template=etc/kubeadm.yml kubernetes_cni_http_source=http://10.253.126.163:3000/files/cni_plugins kubernetes_cni_http_checksum= kubernetes_http_source=http://10.253.126.163:3000/files/kubernetes kubernetes_container_registry=projects.registry.vmware.com/tkg kubernetes_rpm_repo=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64 kubernetes_rpm_gpg_key="https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" kubernetes_rpm_gpg_check=True kubernetes_deb_repo="https://apt.kubernetes.io/ kubernetes-xenial" kubernetes_deb_gpg_key=https://packages.cloud.google.com/apt/doc/apt-key.gpg kubernetes_cni_deb_version=1.1.1-00 kubernetes_cni_rpm_version=1.1.1-0 kubernetes_cni_semver=v1.1.1+vmware.7 kubernetes_cni_source_type=http kubernetes_semver=v1.23.10+vmware.1 kubernetes_source_type=http kubernetes_load_additional_imgs=true kubernetes_deb_version=1.23.10-00 kubernetes_rpm_version=1.23.10-0 no_proxy= pip_conf_file= python_path= redhat_epel_rpm=https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm epel_rpm_gpg_key= reenable_public_repos=true remove_extra_repos=false systemd_prefix=/usr/lib/systemd sysusr_prefix=/usr sysusrlocal_prefix=/usr/local load_additional_components=false additional_registry_images=false additional_registry_images_list= additional_url_images=false additional_url_images_list= additional_executables=false additional_executables_list= additional_executables_destination_path= build_target=virt amazon_ssm_agent_rpm= --extra-vars guestinfo_datasource_slug=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo guestinfo_datasource_ref=v1.4.1 guestinfo_datasource_script=https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/v1.4.1/install.sh --extra-vars  -e ansible_ssh_private_key_file=/tmp/ansible-key3066177402 -i /tmp/packer-provisioner-ansible1843978590 /home/image*****/ansible/node.yml
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
    vsphere: changed: [default] => (item={'param': 'net.bridge.bridge-nf-call-iptables', 'val': 1})
    vsphere: changed: [default] => (item={'param': 'net.bridge.bridge-nf-call-ip6tables', 'val': 1})
    vsphere: changed: [default] => (item={'param': 'net.ipv4.ip_forward', 'val': 1})
    vsphere: changed: [default] => (item={'param': 'net.ipv6.conf.all.forwarding', 'val': 1})
    vsphere: changed: [default] => (item={'param': 'net.ipv6.conf.all.disable_ipv6', 'val': 0})
    vsphere: changed: [default] => (item={'param': 'net.ipv4.tcp_congestion_control', 'val': 'bbr'})
    vsphere: changed: [default] => (item={'param': 'vm.overcommit_memory', 'val': 1})
    vsphere: changed: [default] => (item={'param': 'kernel.panic', 'val': 10})
    vsphere: changed: [default] => (item={'param': 'kernel.panic_on_oops', 'val': 1})
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
    vsphere: changed: [default] => (item={'dir': '/etc/conf.d'})
    vsphere: changed: [default] => (item={'dir': '/etc/networkd-dispatcher/carrier.d'})
    vsphere: changed: [default] => (item={'dir': '/etc/networkd-dispatcher/configured.d'})
    vsphere: changed: [default] => (item={'dir': '/etc/networkd-dispatcher/configuring.d'})
    vsphere: changed: [default] => (item={'dir': '/etc/networkd-dispatcher/degraded.d'})
    vsphere: changed: [default] => (item={'dir': '/etc/networkd-dispatcher/dormant.d'})
    vsphere: changed: [default] => (item={'dir': '/etc/networkd-dispatcher/no-carrier.d'})
    vsphere: changed: [default] => (item={'dir': '/etc/networkd-dispatcher/off.d'})
    vsphere: changed: [default] => (item={'dir': '/etc/networkd-dispatcher/routable.d'})
    vsphere:
    vsphere: TASK [providers : Install networkd-dispatcher service (Move files)] ************
    vsphere: changed: [default] => (item={'src': '/tmp/networkd-dispatcher-2.1/networkd-dispatcher', 'dest': '/usr/bin'})
    vsphere: changed: [default] => (item={'src': '/tmp/networkd-dispatcher-2.1/networkd-dispatcher.service', 'dest': '/etc/systemd/system'})
    vsphere: changed: [default] => (item={'src': '/tmp/networkd-dispatcher-2.1/networkd-dispatcher.conf', 'dest': '/etc/conf.d'})
    vsphere:
    vsphere: TASK [providers : Install networkd-dispatcher service (Run networkd-dispatcher)] ***
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [providers : Copy networkd-dispatcher scripts to add DHCP provided NTP servers] ***
    vsphere: changed: [default] => (item={'src': 'files/etc/networkd-dispatcher/routable.d/20-chrony.j2', 'dest': '/etc/networkd-dispatcher/routable.d/20-chrony'})
    vsphere: changed: [default] => (item={'src': 'files/etc/networkd-dispatcher/off.d/20-chrony.j2', 'dest': '/etc/networkd-dispatcher/off.d/20-chrony'})
    vsphere: changed: [default] => (item={'src': 'files/etc/networkd-dispatcher/no-carrier.d/20-chrony.j2', 'dest': '/etc/networkd-dispatcher/no-carrier.d/20-chrony'})
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
    vsphere: ok: [default] => (item=cloud-final)
    vsphere: ok: [default] => (item=cloud-config)
    vsphere: ok: [default] => (item=cloud-init)
    vsphere: ok: [default] => (item=cloud-init-local)
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
    vsphere: changed: [default] => (item=ctr)
    vsphere: changed: [default] => (item=crictl)
    vsphere: changed: [default] => (item=critest)
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
    vsphere: changed: [default] => (item=kubeadm)
    vsphere: changed: [default] => (item=kubectl)
    vsphere: changed: [default] => (item=kubelet)
    vsphere:
    vsphere: TASK [kubernetes : Download Kubernetes images] *********************************
    vsphere: changed: [default] => (item=kube-apiserver.tar)
    vsphere: changed: [default] => (item=kube-controller-manager.tar)
    vsphere: changed: [default] => (item=kube-scheduler.tar)
    vsphere: changed: [default] => (item=kube-proxy.tar)
    vsphere: changed: [default] => (item=pause.tar)
    vsphere: changed: [default] => (item=coredns.tar)
    vsphere: changed: [default] => (item=etcd.tar)
    vsphere:
    vsphere: TASK [kubernetes : Load Kubernetes images] *************************************
    vsphere: changed: [default] => (item=kube-apiserver.tar)
    vsphere: changed: [default] => (item=kube-controller-manager.tar)
    vsphere: changed: [default] => (item=kube-scheduler.tar)
    vsphere: changed: [default] => (item=kube-proxy.tar)
    vsphere: changed: [default] => (item=pause.tar)
    vsphere: changed: [default] => (item=coredns.tar)
    vsphere: changed: [default] => (item=etcd.tar)
    vsphere:
    vsphere: TASK [kubernetes : Remove Kubernetes images] ***********************************
    vsphere: changed: [default] => (item=kube-apiserver.tar)
    vsphere: changed: [default] => (item=kube-controller-manager.tar)
    vsphere: changed: [default] => (item=kube-scheduler.tar)
    vsphere: changed: [default] => (item=kube-proxy.tar)
    vsphere: changed: [default] => (item=pause.tar)
    vsphere: changed: [default] => (item=coredns.tar)
    vsphere: changed: [default] => (item=etcd.tar)
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
    vsphere: changed: [default] => (item={'param': 'net.ipv4.neigh.default.gc_thresh1', 'val': 4096})
    vsphere: changed: [default] => (item={'param': 'net.ipv6.neigh.default.gc_thresh1', 'val': 4096})
    vsphere: changed: [default] => (item={'param': 'net.ipv4.neigh.default.gc_thresh2', 'val': 8192})
    vsphere: changed: [default] => (item={'param': 'net.ipv6.neigh.default.gc_thresh2', 'val': 8192})
    vsphere: changed: [default] => (item={'param': 'net.ipv4.neigh.default.gc_thresh3', 'val': 16384})
    vsphere: changed: [default] => (item={'param': 'net.ipv6.neigh.default.gc_thresh3', 'val': 16384})
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
    vsphere: changed: [default] => (item={'path': '/etc/machine-id', 'state': 'absent', 'mode': '0444'})
    vsphere: changed: [default] => (item={'path': '/etc/machine-id', 'state': 'touch', 'mode': '0444'})
    vsphere:
    vsphere: TASK [sysprep : Truncate hostname file] ****************************************
    vsphere: changed: [default] => (item={'path': '/etc/hostname', 'state': 'absent', 'mode': '0644'})
    vsphere: changed: [default] => (item={'path': '/etc/hostname', 'state': 'touch', 'mode': '0644'})
    vsphere:
    vsphere: TASK [sysprep : Reset hosts file] **********************************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Truncate audit logs] *******************************************
    vsphere: changed: [default] => (item={'path': '/var/log/wtmp', 'state': 'absent', 'mode': '0664'})
    vsphere: changed: [default] => (item={'path': '/var/log/lastlog', 'state': 'absent', 'mode': '0644'})
    vsphere: changed: [default] => (item={'path': '/var/log/wtmp', 'state': 'touch', 'mode': '0664'})
    vsphere: changed: [default] => (item={'path': '/var/log/lastlog', 'state': 'touch', 'mode': '0644'})
    vsphere:
    vsphere: TASK [sysprep : Remove cloud-init lib dir and logs] ****************************
    vsphere: changed: [default] => (item=/var/lib/cloud)
    vsphere: changed: [default] => (item=/var/log/cloud-init.log)
    vsphere: changed: [default] => (item=/var/log/cloud-init-output.log)
    vsphere: changed: [default] => (item=/var/run/cloud-init)
    vsphere:
    vsphere: TASK [sysprep : Find temp files] ***********************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Reset temp space] **********************************************
    vsphere: changed: [default] => (item={'path': '/tmp/tmp.fstab', 'mode': '0640', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 34, 'inode': 57450, 'dev': 40, 'nlink': 1, 'atime': 1677665217.6763215, 'mtime': 1677665217.6723216, 'ctime': 1677665217.6723216, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: ok: [default] => (item={'path': '/tmp/ansible_find_payload_3hbfsyyc', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 60, 'inode': 63432, 'dev': 40, 'nlink': 2, 'atime': 1677665254.2719367, 'mtime': 1677665254.2719367, 'ctime': 1677665254.2719367, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/tmp/systemd-private-3a2fc663b4fc47f4ba32428a1da69c77-systemd-hostnamed.service-xJnZMS', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 60, 'inode': 57839, 'dev': 40, 'nlink': 3, 'atime': 1677665228.8361993, 'mtime': 1677665228.8361993, 'ctime': 1677665228.8361993, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/tmp/systemd-private-3a2fc663b4fc47f4ba32428a1da69c77-chronyd.service-fJ6BYJ', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 60, 'inode': 38557, 'dev': 40, 'nlink': 3, 'atime': 1677665108.6314168, 'mtime': 1677665108.6314168, 'ctime': 1677665108.6314168, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/tmp/networkd-dispatcher-2.1', 'mode': '0775', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 240, 'inode': 31992, 'dev': 40, 'nlink': 3, 'atime': 1677665059.744108, 'mtime': 1677665074.139975, 'ctime': 1677665074.139975, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': True, 'rgrp': True, 'xgrp': True, 'woth': False, 'roth': True, 'xoth': True, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/tmp/systemd-private-3a2fc663b4fc47f4ba32428a1da69c77-systemd-resolved.service-xp4jFP', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 60, 'inode': 17549, 'dev': 40, 'nlink': 3, 'atime': 1677664816.3119998, 'mtime': 1677664816.3119998, 'ctime': 1677664816.3119998, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/tmp/systemd-private-3a2fc663b4fc47f4ba32428a1da69c77-systemd-networkd.service-t6w0pJ', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 60, 'inode': 17540, 'dev': 40, 'nlink': 3, 'atime': 1677664816.1039999, 'mtime': 1677664816.1039999, 'ctime': 1677664816.1039999, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/tmp/vmware-root_477-2084322203', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 40, 'inode': 19486, 'dev': 40, 'nlink': 2, 'atime': 1677664812.5279999, 'mtime': 1677664812.5279999, 'ctime': 1677664812.5279999, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/var/tmp/systemd-private-3a2fc663b4fc47f4ba32428a1da69c77-systemd-networkd.service-aPq1ih', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 1048662, 'dev': 2051, 'nlink': 3, 'atime': 1677664816.1039999, 'mtime': 1677664816.1039999, 'ctime': 1677664816.1039999, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/var/tmp/systemd-private-3a2fc663b4fc47f4ba32428a1da69c77-systemd-resolved.service-kXLC1n', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 1048689, 'dev': 2051, 'nlink': 3, 'atime': 1677664816.3119998, 'mtime': 1677664816.3119998, 'ctime': 1677664816.3119998, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: ok: [default] => (item={'path': '/var/tmp/systemd-private-3a2fc663b4fc47f4ba32428a1da69c77-systemd-hostnamed.service-cCjnEF', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 1055760, 'dev': 2051, 'nlink': 3, 'atime': 1677665228.8361993, 'mtime': 1677665228.8361993, 'ctime': 1677665228.8361993, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/var/tmp/systemd-private-3a2fc663b4fc47f4ba32428a1da69c77-chronyd.service-KHvBV5', 'mode': '0700', 'isdir': True, 'ischr': False, 'isblk': False, 'isreg': False, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 4096, 'inode': 1048771, 'dev': 2051, 'nlink': 3, 'atime': 1677665108.6314168, 'mtime': 1677665108.6314168, 'ctime': 1677665108.6314168, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': True, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere:
    vsphere: [WARNING]: Skipped '/lib/netplan' path due to this access issue: '/lib/netplan'
    vsphere: TASK [sysprep : Find netplan files] ********************************************
    vsphere: is not a directory
    vsphere: [WARNING]: Skipped '/etc/netplan' path due to this access issue: '/etc/netplan'
    vsphere: ok: [default]
    vsphere: is not a directory
    vsphere: [WARNING]: Skipped '/run/netplan' path due to this access issue: '/run/netplan'
    vsphere: is not a directory
    vsphere:
    vsphere: TASK [sysprep : Find SSH host keys] ********************************************
    vsphere: ok: [default]
    vsphere:
    vsphere: TASK [sysprep : Remove SSH host keys] ******************************************
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_ed25519_key', 'mode': '0600', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 411, 'inode': 655964, 'dev': 2051, 'nlink': 1, 'atime': 1677664650.3719997, 'mtime': 1677664650.3719997, 'ctime': 1677664650.3719997, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_ecdsa_key', 'mode': '0600', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 505, 'inode': 655962, 'dev': 2051, 'nlink': 1, 'atime': 1677664650.3559997, 'mtime': 1677664650.3559997, 'ctime': 1677664650.3559997, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_dsa_key', 'mode': '0600', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 1381, 'inode': 655960, 'dev': 2051, 'nlink': 1, 'atime': 1677664650.3439996, 'mtime': 1677664650.3439996, 'ctime': 1677664650.3439996, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_dsa_key.pub', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 604, 'inode': 655961, 'dev': 2051, 'nlink': 1, 'atime': 1677664650.3439996, 'mtime': 1677664650.3439996, 'ctime': 1677664650.3439996, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_rsa_key.pub', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 396, 'inode': 655959, 'dev': 2051, 'nlink': 1, 'atime': 1677664650.2879996, 'mtime': 1677664650.2879996, 'ctime': 1677664650.2879996, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_rsa_key', 'mode': '0600', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 1823, 'inode': 655957, 'dev': 2051, 'nlink': 1, 'atime': 1677664650.2879996, 'mtime': 1677664650.2879996, 'ctime': 1677664650.2879996, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_ed25519_key.pub', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 96, 'inode': 655965, 'dev': 2051, 'nlink': 1, 'atime': 1677664650.3719997, 'mtime': 1677664650.3719997, 'ctime': 1677664650.3719997, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere: changed: [default] => (item={'path': '/etc/ssh/ssh_host_ecdsa_key.pub', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 176, 'inode': 655963, 'dev': 2051, 'nlink': 1, 'atime': 1677664650.3559997, 'mtime': 1677664650.3559997, 'ctime': 1677664650.3559997, 'gr_name': 'root', 'pw_name': 'root', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False})
    vsphere:
    vsphere: TASK [sysprep : Remove SSH authorized users] ***********************************
    vsphere: changed: [default] => (item={'path': '/root/.ssh/authorized_keys'})
    vsphere: ok: [default] => (item={'path': '/home/builder/.ssh/authorized_keys'})
    vsphere:
    vsphere: TASK [sysprep : Truncate all remaining log files in /var/log] ******************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Delete all logrotated log zips] ********************************
    vsphere: changed: [default]
    vsphere:
    vsphere: TASK [sysprep : Truncate shell history] ****************************************
    vsphere: ok: [default] => (item={'path': '/root/.bash_history'})
    vsphere: ok: [default] => (item={'path': '/home/builder/.bash_history'})
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
==> vsphere: Provisioning with Goss
==> vsphere: Configured to run on Linux
    vsphere: Creating directory: /tkg-tmp/goss
    vsphere: Installing Goss from, https://github.com/aelsabbahy/goss/releases/download/v0.3.16/goss-linux-amd64
    vsphere: Downloading Goss to /tkg-tmp/goss-linux-amd64
==> vsphere:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
==> vsphere:                                  Dload  Upload   Total   Spent    Left  Speed
==> vsphere:   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
==> vsphere:   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
==> vsphere: 100 11.8M  100 11.8M    0     0  2067k      0  0:00:05  0:00:05 --:--:-- 3162k
    vsphere: goss version v0.3.16
==> vsphere: Uploading goss tests...
    vsphere: Inline variables are --vars-inline '{"ARCH":"amd64","OS":"photon","OS_VERSION":"3","PROVIDER":"ova","containerd_version":"v1.6.6+vmware.2","kubernetes_cni_deb_version":"1.1.1-00","kubernetes_cni_rpm_version":"1.1.1","kubernetes_cni_source_type":"http","kubernetes_cni_version":"1.1.1+vmware.7","kubernetes_deb_version":"1.23.10-00","kubernetes_rpm_version":"1.23.10","kubernetes_source_type":"http","kubernetes_version":"1.23.10+vmware.1"}'
    vsphere: Uploading Dir /home/imagebuilder/goss
    vsphere: Creating directory: /tkg-tmp/goss/goss
==> vsphere:
==> vsphere:
==> vsphere:
==> vsphere: Running goss tests...
==> vsphere: Running GOSS render command: cd /tkg-tmp/goss &&  /tkg-tmp/goss-linux-amd64 --gossfile goss/goss.yaml  --vars-inline '{"ARCH":"amd64","OS":"photon","OS_VERSION":"3","PROVIDER":"ova","containerd_version":"v1.6.6+vmware.2","kubernetes_cni_deb_version":"1.1.1-00","kubernetes_cni_rpm_version":"1.1.1","kubernetes_cni_source_type":"http","kubernetes_cni_version":"1.1.1+vmware.7","kubernetes_deb_version":"1.23.10-00","kubernetes_rpm_version":"1.23.10","kubernetes_source_type":"http","kubernetes_version":"1.23.10+vmware.1"}' render > /tmp/goss-spec.yaml
==> vsphere: Goss render ran successfully
==> vsphere: Running GOSS render debug command: cd /tkg-tmp/goss &&  /tkg-tmp/goss-linux-amd64 --gossfile goss/goss.yaml  --vars-inline '{"ARCH":"amd64","OS":"photon","OS_VERSION":"3","PROVIDER":"ova","containerd_version":"v1.6.6+vmware.2","kubernetes_cni_deb_version":"1.1.1-00","kubernetes_cni_rpm_version":"1.1.1","kubernetes_cni_source_type":"http","kubernetes_cni_version":"1.1.1+vmware.7","kubernetes_deb_version":"1.23.10-00","kubernetes_rpm_version":"1.23.10","kubernetes_source_type":"http","kubernetes_version":"1.23.10+vmware.1"}' render -d > /tmp/debug-goss-spec.yaml
==> vsphere: Goss render debug ran successfully
==> vsphere: Running GOSS validate command: cd /tkg-tmp/goss && sudo  /tkg-tmp/goss-linux-amd64 --gossfile goss/goss.yaml  --vars-inline '{"ARCH":"amd64","OS":"photon","OS_VERSION":"3","PROVIDER":"ova","containerd_version":"v1.6.6+vmware.2","kubernetes_cni_deb_version":"1.1.1-00","kubernetes_cni_rpm_version":"1.1.1","kubernetes_cni_source_type":"http","kubernetes_cni_version":"1.1.1+vmware.7","kubernetes_deb_version":"1.23.10-00","kubernetes_rpm_version":"1.23.10","kubernetes_source_type":"http","kubernetes_version":"1.23.10+vmware.1"}' validate --retry-timeout 0s --sleep 1s -f json -o pretty
    vsphere: {
    vsphere:     "results": [
    vsphere:         {
    vsphere:             "duration": 10299109,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "rng-tools",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: rng-tools: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 25116058,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "jq",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: jq: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 25439183,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "chrony",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: chrony: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 26234385,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "cloud-init",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: cloud-init: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 32738183,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "false"
    vsphere:             ],
    vsphere:             "human": "Expected\n    \u003cbool\u003e: false\nto equal\n    \u003cbool\u003e: true",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "ethtool",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 1,
    vsphere:             "successful": false,
    vsphere:             "summary-line": "Package: ethtool: installed:\nExpected\n    \u003cbool\u003e: false\nto equal\n    \u003cbool\u003e: true",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 35497290,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "python-netifaces",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: python-netifaces: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 36019503,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "python3-netifaces",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: python3-netifaces: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 40315463,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "apparmor-parser",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: apparmor-parser: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 43431807,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "distrib-compat",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: distrib-compat: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 48933998,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "tar",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: tar: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 45595040,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "openssl-c_rehash",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: openssl-c_rehash: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 59955212,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "0"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "0"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "exit-status",
    vsphere:             "resource-id": "containerd --version | awk -F' ' '{print substr($3,2); }'",
    vsphere:             "resource-type": "Command",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Command: containerd --version | awk -F' ' '{print substr($3,2); }': exit-status: matches expectation: [0]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 76769725,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "unzip",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: unzip: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 72268162,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "socat",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: socat: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 78789939,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "0"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "0"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "exit-status",
    vsphere:             "resource-id": "crictl images | grep -v 'IMAGE ID' | awk -F'[ /]' '{print $3}' | sed 's/-amd64//g' | sort",
    vsphere:             "resource-type": "Command",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Command: crictl images | grep -v 'IMAGE ID' | awk -F'[ /]' '{print $3}' | sed 's/-amd64//g' | sort: exit-status: matches expectation: [0]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 13332,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "coredns",
    vsphere:                 "etcd",
    vsphere:                 "kube-apiserver",
    vsphere:                 "kube-controller-manager",
    vsphere:                 "kube-proxy",
    vsphere:                 "kube-scheduler",
    vsphere:                 "pause"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "coredns",
    vsphere:                 "etcd",
    vsphere:                 "kube-apiserver",
    vsphere:                 "kube-controller-manager",
    vsphere:                 "kube-proxy",
    vsphere:                 "kube-scheduler",
    vsphere:                 "pause"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "stdout",
    vsphere:             "resource-id": "crictl images | grep -v 'IMAGE ID' | awk -F'[ /]' '{print $3}' | sed 's/-amd64//g' | sort",
    vsphere:             "resource-type": "Command",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Command: crictl images | grep -v 'IMAGE ID' | awk -F'[ /]' '{print $3}' | sed 's/-amd64//g' | sort: stdout: matches expectation: [coredns etcd kube-apiserver kube-controller-manager kube-proxy kube-scheduler pause]",
    vsphere:             "test-type": 2,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 87058361,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "0"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "0"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "exit-status",
    vsphere:             "resource-id": "/opt/cni/bin/host-device 2\u003e\u00261 | awk -F' ' '{print substr($4,2); }'",
    vsphere:             "resource-type": "Command",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Command: /opt/cni/bin/host-device 2\u003e\u00261 | awk -F' ' '{print substr($4,2); }': exit-status: matches expectation: [0]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 11728,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "1.1.1+vmware.7"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "1.1.1+vmware.7"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "stdout",
    vsphere:             "resource-id": "/opt/cni/bin/host-device 2\u003e\u00261 | awk -F' ' '{print substr($4,2); }'",
    vsphere:             "resource-type": "Command",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Command: /opt/cni/bin/host-device 2\u003e\u00261 | awk -F' ' '{print substr($4,2); }': stdout: matches expectation: [1.1.1+vmware.7]",
    vsphere:             "test-type": 2,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 86595708,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "false"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "false"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "ntp",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: ntp: installed: matches expectation: [false]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 64736050,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "sysstat",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: sysstat: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 67731573,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "conntrack-tools",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: conntrack-tools: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 98041982,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "0"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "0"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "exit-status",
    vsphere:             "resource-id": "kubeadm version -o json | jq .clientVersion.gitVersion | tr -d '\"' | awk '{print substr($1,2); }'",
    vsphere:             "resource-type": "Command",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Command: kubeadm version -o json | jq .clientVersion.gitVersion | tr -d '\"' | awk '{print substr($1,2); }': exit-status: matches expectation: [0]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 15067,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "1.23.10+vmware.1"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "1.23.10+vmware.1"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "stdout",
    vsphere:             "resource-id": "kubeadm version -o json | jq .clientVersion.gitVersion | tr -d '\"' | awk '{print substr($1,2); }'",
    vsphere:             "resource-type": "Command",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Command: kubeadm version -o json | jq .clientVersion.gitVersion | tr -d '\"' | awk '{print substr($1,2); }': stdout: matches expectation: [1.23.10+vmware.1]",
    vsphere:             "test-type": 2,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 43288,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "\"8192\""
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "\"8192\""
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "value",
    vsphere:             "resource-id": "net.ipv4.neigh.default.gc_thresh2",
    vsphere:             "resource-type": "KernelParam",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "KernelParam: net.ipv4.neigh.default.gc_thresh2: value: matches expectation: [\"8192\"]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 37179,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "\"524288\""
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "\"524288\""
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "value",
    vsphere:             "resource-id": "net.ipv4.tcp_limit_output_bytes",
    vsphere:             "resource-type": "KernelParam",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "KernelParam: net.ipv4.tcp_limit_output_bytes: value: matches expectation: [\"524288\"]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 40709,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "\"16384\""
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "\"16384\""
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "value",
    vsphere:             "resource-id": "net.ipv4.neigh.default.gc_thresh3",
    vsphere:             "resource-type": "KernelParam",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "KernelParam: net.ipv4.neigh.default.gc_thresh3: value: matches expectation: [\"16384\"]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 19243,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "\"4096\""
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "\"4096\""
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "value",
    vsphere:             "resource-id": "net.ipv6.neigh.default.gc_thresh1",
    vsphere:             "resource-type": "KernelParam",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "KernelParam: net.ipv6.neigh.default.gc_thresh1: value: matches expectation: [\"4096\"]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 28023,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "\"1\""
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "\"1\""
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "value",
    vsphere:             "resource-id": "net.bridge.bridge-nf-call-ip6tables",
    vsphere:             "resource-type": "KernelParam",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "KernelParam: net.bridge.bridge-nf-call-ip6tables: value: matches expectation: [\"1\"]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 28141,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "\"1\""
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "\"1\""
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "value",
    vsphere:             "resource-id": "net.ipv4.ip_forward",
    vsphere:             "resource-type": "KernelParam",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "KernelParam: net.ipv4.ip_forward: value: matches expectation: [\"1\"]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 28205,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "\"1\""
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "\"1\""
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "value",
    vsphere:             "resource-id": "net.ipv6.conf.all.forwarding",
    vsphere:             "resource-type": "KernelParam",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "KernelParam: net.ipv6.conf.all.forwarding: value: matches expectation: [\"1\"]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 28518,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "\"1\""
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "\"1\""
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "value",
    vsphere:             "resource-id": "net.bridge.bridge-nf-call-iptables",
    vsphere:             "resource-type": "KernelParam",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "KernelParam: net.bridge.bridge-nf-call-iptables: value: matches expectation: [\"1\"]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 22812,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "\"16384\""
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "\"16384\""
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "value",
    vsphere:             "resource-id": "net.ipv6.neigh.default.gc_thresh3",
    vsphere:             "resource-type": "KernelParam",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "KernelParam: net.ipv6.neigh.default.gc_thresh3: value: matches expectation: [\"16384\"]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 30924,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "\"4096\""
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "\"4096\""
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "value",
    vsphere:             "resource-id": "net.ipv4.neigh.default.gc_thresh1",
    vsphere:             "resource-type": "KernelParam",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "KernelParam: net.ipv4.neigh.default.gc_thresh1: value: matches expectation: [\"4096\"]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 27686,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "\"8192\""
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "\"8192\""
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "value",
    vsphere:             "resource-id": "net.ipv6.neigh.default.gc_thresh2",
    vsphere:             "resource-type": "KernelParam",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "KernelParam: net.ipv6.neigh.default.gc_thresh2: value: matches expectation: [\"8192\"]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 19066,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "\"9223372036854775807\""
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "\"9223372036854775807\""
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "value",
    vsphere:             "resource-id": "fs.file-max",
    vsphere:             "resource-type": "KernelParam",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "KernelParam: fs.file-max: value: matches expectation: [\"9223372036854775807\"]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 29099,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "\"0\""
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "\"0\""
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "value",
    vsphere:             "resource-id": "net.ipv6.conf.all.disable_ipv6",
    vsphere:             "resource-type": "KernelParam",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "KernelParam: net.ipv6.conf.all.disable_ipv6: value: matches expectation: [\"0\"]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 73090032,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "false"
    vsphere:             ],
    vsphere:             "human": "Expected\n    \u003cbool\u003e: false\nto equal\n    \u003cbool\u003e: true",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "nfs-utils",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 1,
    vsphere:             "successful": false,
    vsphere:             "summary-line": "Package: nfs-utils: installed:\nExpected\n    \u003cbool\u003e: false\nto equal\n    \u003cbool\u003e: true",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 72355410,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "open-vm-tools",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: open-vm-tools: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 112430963,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "0"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "0"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "exit-status",
    vsphere:             "resource-id": "crictl ps",
    vsphere:             "resource-type": "Command",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Command: crictl ps: exit-status: matches expectation: [0]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 80632261,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "python3-pip",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: python3-pip: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 82198514,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "audit",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: audit: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 74345777,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "cloud-utils",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: cloud-utils: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 78364183,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "python-requests",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: python-requests: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 77396663,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "net-tools",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: net-tools: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 73944805,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "installed",
    vsphere:             "resource-id": "ebtables",
    vsphere:             "resource-type": "Package",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Package: ebtables: installed: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 145517664,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "0"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "0"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "exit-status",
    vsphere:             "resource-id": "kubectl version --short --client=true -o json | jq .clientVersion.gitVersion | tr -d '\"' | awk '{print substr($1,2); }'",
    vsphere:             "resource-type": "Command",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Command: kubectl version --short --client=true -o json | jq .clientVersion.gitVersion | tr -d '\"' | awk '{print substr($1,2); }': exit-status: matches expectation: [0]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 10058,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "1.23.10+vmware.1"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "1.23.10+vmware.1"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "stdout",
    vsphere:             "resource-id": "kubectl version --short --client=true -o json | jq .clientVersion.gitVersion | tr -d '\"' | awk '{print substr($1,2); }'",
    vsphere:             "resource-type": "Command",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Command: kubectl version --short --client=true -o json | jq .clientVersion.gitVersion | tr -d '\"' | awk '{print substr($1,2); }': stdout: matches expectation: [1.23.10+vmware.1]",
    vsphere:             "test-type": 2,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 149739398,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "0"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "0"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "exit-status",
    vsphere:             "resource-id": "kubelet --version | awk -F' ' '{print $2}'  | tr -d '\"' | awk '{print substr($1,2); }'",
    vsphere:             "resource-type": "Command",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Command: kubelet --version | awk -F' ' '{print $2}'  | tr -d '\"' | awk '{print substr($1,2); }': exit-status: matches expectation: [0]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 7485,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "1.23.10+vmware.1"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "1.23.10+vmware.1"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "stdout",
    vsphere:             "resource-id": "kubelet --version | awk -F' ' '{print $2}'  | tr -d '\"' | awk '{print substr($1,2); }'",
    vsphere:             "resource-type": "Command",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Command: kubelet --version | awk -F' ' '{print $2}'  | tr -d '\"' | awk '{print substr($1,2); }': stdout: matches expectation: [1.23.10+vmware.1]",
    vsphere:             "test-type": 2,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 62272042,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "false"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "false"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "enabled",
    vsphere:             "resource-id": "dockerd",
    vsphere:             "resource-type": "Service",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Service: dockerd: enabled: matches expectation: [false]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 20644198,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "false"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "false"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "running",
    vsphere:             "resource-id": "dockerd",
    vsphere:             "resource-type": "Service",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Service: dockerd: running: matches expectation: [false]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 65773735,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "enabled",
    vsphere:             "resource-id": "containerd",
    vsphere:             "resource-type": "Service",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Service: containerd: enabled: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 18159690,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "running",
    vsphere:             "resource-id": "containerd",
    vsphere:             "resource-type": "Service",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Service: containerd: running: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 58361772,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "enabled",
    vsphere:             "resource-id": "kubelet",
    vsphere:             "resource-type": "Service",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Service: kubelet: enabled: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 18462803,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "false"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "false"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "running",
    vsphere:             "resource-id": "kubelet",
    vsphere:             "resource-type": "Service",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Service: kubelet: running: matches expectation: [false]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 77957073,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "false"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "false"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "enabled",
    vsphere:             "resource-id": "conntrackd",
    vsphere:             "resource-type": "Service",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Service: conntrackd: enabled: matches expectation: [false]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 22462736,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "false"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "false"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "running",
    vsphere:             "resource-id": "conntrackd",
    vsphere:             "resource-type": "Service",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Service: conntrackd: running: matches expectation: [false]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 66898103,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "enabled",
    vsphere:             "resource-id": "networkd-dispatcher",
    vsphere:             "resource-type": "Service",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Service: networkd-dispatcher: enabled: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 11014421,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "running",
    vsphere:             "resource-id": "networkd-dispatcher",
    vsphere:             "resource-type": "Service",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Service: networkd-dispatcher: running: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 58245320,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "enabled",
    vsphere:             "resource-id": "chronyd",
    vsphere:             "resource-type": "Service",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Service: chronyd: enabled: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 14300317,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "running",
    vsphere:             "resource-id": "chronyd",
    vsphere:             "resource-type": "Service",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Service: chronyd: running: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 66981034,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "false"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "false"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "enabled",
    vsphere:             "resource-id": "apparmor",
    vsphere:             "resource-type": "Service",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Service: apparmor: enabled: matches expectation: [false]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 10594373,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "false"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "false"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "running",
    vsphere:             "resource-id": "apparmor",
    vsphere:             "resource-type": "Service",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Service: apparmor: running: matches expectation: [false]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 67507859,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "enabled",
    vsphere:             "resource-id": "auditd",
    vsphere:             "resource-type": "Service",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Service: auditd: enabled: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         },
    vsphere:         {
    vsphere:             "duration": 10329547,
    vsphere:             "err": null,
    vsphere:             "expected": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "found": [
    vsphere:                 "true"
    vsphere:             ],
    vsphere:             "human": "",
    vsphere:             "meta": null,
    vsphere:             "property": "running",
    vsphere:             "resource-id": "auditd",
    vsphere:             "resource-type": "Service",
    vsphere:             "result": 0,
    vsphere:             "successful": true,
    vsphere:             "summary-line": "Service: auditd: running: matches expectation: [true]",
    vsphere:             "test-type": 0,
    vsphere:             "title": ""
    vsphere:         }
    vsphere:     ],
    vsphere:     "summary": {
    vsphere:         "failed-count": 2,
    vsphere:         "summary-line": "Count: 65, Failed: 2, Duration: 0.168s",
    vsphere:         "test-count": 65,
    vsphere:         "total-duration": 168422616
    vsphere:     }
    vsphere: }
==> vsphere: Goss validate failed
==> vsphere: Inspect mode on : proceeding without failing Packer
==> vsphere:
==> vsphere:
==> vsphere:
==> vsphere: Downloading spec file and debug info
    vsphere: Downloading Goss specs from, /tmp/goss-spec.yaml and /tmp/debug-goss-spec.yaml to current dir
==> vsphere: Executing shutdown command...
==> vsphere: Deleting Floppy drives...
==> vsphere: Eject CD-ROM drives...
    vsphere: Starting export...
    vsphere: Downloading: photon-3-kube-v1.23.10_vmware.1-disk-0.vmdk
    vsphere: Exporting file: photon-3-kube-v1.23.10_vmware.1-disk-0.vmdk
    vsphere: Writing ovf...
==> vsphere: Clear boot order...
==> vsphere: Running post-processor: packer-manifest (type manifest)
==> vsphere: Running post-processor: vsphere (type shell-local)
==> vsphere (shell-local): Running local shell script: /tmp/packer-shell2767289316
    vsphere (shell-local): Opening OVF source: photon-3-kube-v1.23.10+vmware.1.ovf
    vsphere (shell-local): Opening OVA target: photon-3-kube-v1.23.10+vmware.1.ova
    vsphere (shell-local): Writing OVA package: photon-3-kube-v1.23.10+vmware.1.ova
    vsphere (shell-local): Transfer Completed
    vsphere (shell-local): Warning:
    vsphere (shell-local):  - No manifest file found.
    vsphere (shell-local):  - No supported manifest(sha1, sha256, sha512) entry found for: 'photon-3-kube-v1.23.10_vmware.1-disk-0.vmdk'.
    vsphere (shell-local): Completed successfully
    vsphere (shell-local): image-build-ova: cd .
    vsphere (shell-local): image-build-ova: loaded photon-3-kube-v1.23.10+vmware.1
    vsphere (shell-local): image-build-ova: create ovf photon-3-kube-v1.23.10+vmware.1.ovf
    vsphere (shell-local): image-build-ova: creating OVA from photon-3-kube-v1.23.10+vmware.1.ovf using ovftool
    vsphere (shell-local): image-build-ova: create ova checksum photon-3-kube-v1.23.10+vmware.1.ova.sha256
==> vsphere: Running post-processor: custom-post-processor (type shell-local)
==> vsphere (shell-local): Running local shell script: /tmp/packer-shell4018393751
Build 'vsphere' finished after 13 minutes 36 seconds.

==> Wait completed after 13 minutes 36 seconds

==> Builds finished. The artifacts of successful builds are:
--> vsphere: photon-3-kube-v1.23.10_vmware.1
--> vsphere: photon-3-kube-v1.23.10_vmware.1
--> vsphere: photon-3-kube-v1.23.10_vmware.1
--> vsphere: photon-3-kube-v1.23.10_vmware.1
```
```shell
## output 폴더 OVA 생성

## 1.6 
ls output/photon-3-kube-v1.23.10_vmware.1/
packer-manifest.json  photon-3-kube-v1.23.10+vmware.1.ova  photon-3-kube-v1.23.10+vmware.1.ova.sha256  photon-3-kube-v1.23.10+vmware.1.ovf  photon-3-kube-v1.23.10_vmware.1-disk-0.vmdk  photon-3-kube-v1.23.10_vmware.1.ovf

## 2.1
ls output/photon-3-kube-v1.24.9_vmware.1/
packer-manifest.json  photon-3-kube-v1.24.9_vmware.1-disk-0.vmdk  photon-3-kube-v1.24.9+vmware.1.ova  photon-3-kube-v1.24.9+vmware.1.ova.sha256  photon-3-kube-v1.24.9+vmware.1.ovf  photon-3-kube-v1.24.9_vmware.1.ovf
```
{{< /admonition >}}

## 6. TKR 등록
{{< admonition tip "TKR 등록" >}}
```shell
## 1.6
vi ~/.config/tanzu/tkg/bom/tkr-bom-v1.23.10+vmware.1-tkg.1.yaml

## 아래 ova를 찾아서 추가 해준다. 
ova:
- name: ova-photon-3-rt
  osinfo:
    name: photon
    version: "3"
    arch: amd64
  version: v1.23.10+vmware.1-dokyung.0
- name: ova-ubuntu-2004-rt
  osinfo:
    name: ubuntu
    version: "20.04"
    arch: amd64
  version: v1.23.10+vmware.1-dokyung.0
- name: ova-rhel-8-rt
  osinfo:
    name: rhel
    version: "8"
    arch: amd64
  version: v1.23.10+vmware.1-dokyung.0

## 2.1
vi ~/.config/tanzu/tkg/bom/tkr-bom-v1.24.9+vmware.1-tkg.1.yaml

## 아래 ova를 찾아서 추가 해준다. 
ova:
- name: ova-photon-3-rt
  osinfo:
    name: photon
    version: "3"
    arch: amd64
  version: v1.24.9+vmware.1-dokyung.0
- name: ova-ubuntu-2004-rt
  osinfo:
    name: ubuntu
    version: "20.04"
    arch: amd64
  version: v1.24.9+vmware.1-dokyung.0
- name: ova-rhel-8-rt
  osinfo:
    name: rhel
    version: "8"
    arch: amd64
  version: v1.24.9+vmware.1-dokyung.0
```
{{< /admonition >}}

## 7. OVA 업로드
{{< admonition tip "업로드" >}}
```shell
## 1.6
### photon
ovftool --acceptAllEulas --net:nic0={NIC}--datastore={STORE} --vmFolder={FOLDER} --importAsTemplate output/photon-3-kube-v1.23.10_vmware.1/photon-3-kube-v1.23.10+vmware.1.ova 'vi://{ID}:{PW}}@{vCenter FQDN or IP}/{DATACENTER}/host/{CLUSTER}/'
### ubuntu
ovftool --acceptAllEulas --net:nic0={NIC}--datastore={STORE} --vmFolder={FOLDER} --importAsTemplate output/ubuntu-2004-kube-v1.23.10_vmware.1/ubuntu-2004-kube-v1.23.10+vmware.1.ova 'vi://{ID}:{PW}}@{vCenter FQDN or IP}/{DATACENTER}/host/{CLUSTER}/'
### rhel
ovftool --acceptAllEulas --net:nic0={NIC}--datastore={STORE} --vmFolder={FOLDER} --importAsTemplate output/rhel-8-kube-v1.23.10_vmware.1/rhel-8-kube-v1.23.10+vmware.1.ova 'vi://{ID}:{PW}}@{vCenter FQDN or IP}/{DATACENTER}/host/{CLUSTER}/'

## 2.1
### photon
ovftool --acceptAllEulas --net:nic0={NIC}--datastore={STORE} --vmFolder={FOLDER} --importAsTemplate output/photon-3-kube-v1.24.9_vmware.1/photon-3-kube-v1.24.9+vmware.1.ova 'vi://{ID}:{PW}}@{vCenter FQDN or IP}/{DATACENTER}/host/{CLUSTER}/'
### ubuntu
ovftool --acceptAllEulas --net:nic0={NIC}--datastore={STORE} --vmFolder={FOLDER} --importAsTemplate output/ubuntu-2004-kube-v1.24.9_vmware.1/ubuntu-2004-kube-v1.24.9+vmware.1.ova 'vi://{ID}:{PW}}@{vCenter FQDN or IP}/{DATACENTER}/host/{CLUSTER}/'
### rhel
ovftool --acceptAllEulas --net:nic0={NIC}--datastore={STORE} --vmFolder={FOLDER} --importAsTemplate output/rhel-8-kube-v1.24.9_vmware.1/rhel-8-kube-v1.24.9+vmware.1.ova 'vi://{ID}:{PW}}@{vCenter FQDN or IP}/{DATACENTER}/host/{CLUSTER}/'

```
{{< /admonition >}}
## 6. 배포
{{< admonition tip "클러스터 배포" >}}

```shell
tanzu cluster create -f {FILE} -v 9 -y
```
{{< /admonition >}}

## 7. 확인

> 1.6
{{< figure src="/images/tanzu-custom-image/1-3.png" title="rhel node" >}}
{{< figure src="/images/tanzu-custom-image/1-2.png" title="photon node" >}}

> 2.1
{{< figure src="/images/tanzu-custom-image/1-4.png" title="All node" >}}
