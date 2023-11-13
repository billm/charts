{{- define "dashy.workload" -}}
workload:
  dashy:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.dashyNetwork.hostNetwork }}
      containers:
        dashy:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.dashyRunAs.user }}
            runAsGroup: {{ .Values.dashyRunAs.group }}
          env:
            NODE_ENV: production
            IS_DOCKER: "true"
            PORT: {{ .Values.dashyNetwork.webPort }}
          {{ with .Values.dashyConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: exec
              command:
                - node
                - /app/services/healthcheck
            readiness:
              enabled: true
              type: exec
              command:
                - node
                - /app/services/healthcheck
            startup:
              enabled: true
              type: exec
              command:
                - node
                - /app/services/healthcheck
      initContainers:
        init-config:
          enabled: true
          type: init
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.dashyRunAs.user }}
            runAsGroup: {{ .Values.dashyRunAs.group }}
          command:
            - /bin/sh
          args:
            - -c
            - |
              if [ -z "$(ls -A /data)" ]; then
                echo "App directory is empty, copying default files"
                cp -r /app/public/* /data/
                exit 0
              fi

              echo "App directory is not empty, skipping copy"
              exit 0
{{- end -}}