# sentinel-logstash

docker run -v ${PWD}/logstash.conf:/usr/share/logstash/pipeline/logstash.conf -p 514:514 logstash