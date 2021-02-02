systemd:
  units:
    - name: "kubelet.service"
      enabled: true
storage:
  files:
    - path: /opt/scripts/download-kubelet.sh
      filesystem: root
      mode: 0755
      contents:
        inline: |
          #!/bin/bash
          set -euo pipefail
          mkdir -p /opt/data/kubelet
          docker run --rm --network host -v /opt/data/kubelet:/kubelet amazon/aws-cli s3 sync \
            s3://amazon-eks/1.17.12/2020-11-02/bin/linux/amd64/ /kubelet/
          mkdir -p /opt/cni/bin /etc/cni/net.d
          tar -C /opt/cni/bin -zxvf /opt/data/kubelet/cni-amd64-v0.6.0.tgz
          tar -C /opt/cni/bin -zxvf /opt/data/kubelet/cni-plugins-linux-amd64-v0.8.6.tgz
          chmod +x /opt/data/kubelet/kubelet
          chmod +x /opt/data/kubelet/aws-iam-authenticator
    - path: /etc/eks/kubelet-conf.yaml
      filesystem: root
      contents:
        inline: |
          ---
          kind: KubeletConfiguration
          apiVersion: kubelet.config.k8s.io/v1beta1
          address: 0.0.0.0
          authentication:
            anonymous:
              enabled: false
            webhook:
              cacheTTL: 2m0s
              enabled: true
            x509:
              clientCAFile: "/etc/eks/ca.crt"
          authorization:
            mode: Webhook
            webhook:
              cacheAuthorizedTTL: 5m0s
              cacheUnauthorizedTTL: 30s
          clusterDomain: cluster.local
          clusterDNS:
            - 10.100.0.10
          hairpinMode: hairpin-veth
          runtimeRequestTimeout: 15m
          featureGates:
            RotateKubeletServerCertificate: true
            CSIMigration: false
          serializeImagePulls: false
          serverTLSBootstrap: true
          configMapAndSecretChangeDetectionStrategy: Cache
          tlsCipherSuites:
            - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
          maxPods: 58
    - path: /etc/eks/kubelet-kubeconfig
      filesystem: root
      contents:
        inline: |
          apiVersion: v1
          kind: Config
          clusters:
          - cluster:
              certificate-authority: /etc/eks/ca.crt
              server: ${cluster_endpoint}
            name: kubernetes
          contexts:
          - context:
              cluster: kubernetes
              user: kubelet
            name: kubelet
          current-context: kubelet
          users:
          - name: kubelet
            user:
              exec:
                apiVersion: client.authentication.k8s.io/v1alpha1
                command: /opt/data/kubelet/aws-iam-authenticator
                args:
                  - "token"
                  - "-i"
                  - "${cluster_name}"
                  - --region
                  - "${aws_region}"
    - path: /etc/eks/ca.crt
      filesystem: root
      contents:
        inline: !!binary |
          ${cluster_auth}
    - path: /etc/systemd/system/kubelet.service
      filesystem: root
      contents:
        inline: |
          [Unit]
          Description=Kubelet
          Wants=docker.service
          Wants=coreos-metadata.service
          Requires=coreos-metadata.service
          Requires=docker.service
          After=docker.service
          
          [Service]
          EnvironmentFile=/run/metadata/flatcar
          ExecStartPre=/opt/scripts/download-kubelet.sh
          ExecStartPre=/sbin/iptables -P FORWARD ACCEPT -w 5
          
          ExecStart=/opt/data/kubelet/kubelet \
              --cloud-provider=aws \
              --cni-bin-dir=/opt/cni/bin \
              --cni-conf-dir=/etc/cni/net.d \
              --config=/etc/eks/kubelet-conf.yaml \
              --kubeconfig=/etc/eks/kubelet-kubeconfig \
              --network-plugin=cni \
              --container-runtime=docker \
              --node-ip $${COREOS_EC2_IPV4_LOCAL} \
              --hostname-override $${COREOS_EC2_HOSTNAME}
          
          Restart=on-failure
          RestartSec=10
          
          [Install]
          WantedBy=multi-user.target


