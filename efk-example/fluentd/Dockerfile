# fluentd/Dockerfile

FROM fluent/fluentd:v1.15.3-debian-1.1
USER root
RUN ["gem", "install", "fluent-plugin-elasticsearch", "--no-document", "--version", "5.2.4"]
USER fluent
