FROM alpine:3.21
RUN apk add jq curl
COPY script.sh /opt/script.sh
RUN chmod +x /opt/script.sh
ENTRYPOINT ["/opt/script.sh"]
