# fluentd/Dockerfile

FROM fluent/fluentd:v1.15.3-debian-1.1
USER root
RUN gem uninstall -I elasticsearch && gem install elasticsearch -v 7.17.7
RUN ["gem", "install", "fluent-plugin-elasticsearch", "--no-document", "--version", "5.2.4"]
USER fluent
