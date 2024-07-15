FROM docker.elastic.co/logstash/logstash:8.14.1
RUN logstash-plugin install microsoft-sentinel-logstash-output
RUN echo "api.enabled: false\nxpack.monitoring.enabled: false" > /usr/share/logstash/config/logstash.yml
RUN echo "input {syslog {port => 514\ncodec => cef {ecs_compatibility => disabled}}} output {stdout {codec => rubydebug}}" > /usr/share/logstash/pipeline/logstash.conf
ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
