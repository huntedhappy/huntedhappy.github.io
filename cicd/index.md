# The Documentation CICD


간단하게 CICD의 대해 구성 하는 것을 기술 할 예정
사용자가 VS를 사용하여 Docker 내용을 수정 후 Git에 Push를 하면 Jenkins에서 5분에 한번씩 Polling을 하여 Git에 변화가 있으면 Pipeline이 동작 하면서 자동으로 Docker Build를 수행 후 Harbor에 이미지를 Push 후 새로운 이미지의 대한 Version을 Manifest의 변경 하여 다시 Git에 Push, 이후 3분에 한번씩 Argo가 Git의 내용의 변화가 있는지 확인 후 변화가 있으면 K8S의 환경의 Manifest를 적용
