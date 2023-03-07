# fluentd/Dockerfile

FROM fluent/fluentd:v1.15.3-debian-1.1
USER root
RUN ["gem", "install", "fluent-plugin-grafana-loki", "--no-document", "--version", "1.2.20"]
USER fluent
