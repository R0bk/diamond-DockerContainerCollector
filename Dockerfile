# Docker image containing the Diamond collector
#
# VERSION               0.0.1
FROM python:2.7.13

# Install dependencies
ENV HANDLERS=diamond.handler.stats_d.StatsdHandler,diamond.handler.graphite.GraphiteHandler \
    GRAPHITE_HOST=127.0.0.1 \
    GRAPHITE_PORT=2003 \
    STATSD_HOST=127.0.0.1 \
    STATSD_PORT=8125 \
    DOCKER_HOSTNAME=docker-hostname \
    INTERVAL=5

RUN apt-get update && \
    pip install diamond statsd && \
    mkdir /usr/local/share/diamond/collectors/dockercontainer && \
    find /usr/local/share/diamond/collectors/  -type f -name "*.py" -print0 | xargs -0 sed -i 's/\/proc/\/host_proc/g' && \
    pip install docker-py

#add diamond config dir
ADD diamond /etc/diamond/

#add docker container collector
ADD dockercontainer.py /usr/local/share/diamond/collectors/dockercontainer/

#startup script
ADD config_diamond.sh /config_diamond.sh
RUN chmod +x /config_diamond.sh

ADD entrypoint.sh /

VOLUME ["/usr/local/share/diamond/collectors", "/usr/local/share/diamond/handlers", "/etc/diamond"]

#start
ENTRYPOINT ["/entrypoint.sh"]
