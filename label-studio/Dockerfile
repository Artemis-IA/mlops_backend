# label-studio/Dockerfile
FROM heartexlabs/label-studio:latest

USER root

RUN apt-get update && apt-get install -y jq

COPY entrypoint.sh /entrypoint_label_studio.sh
COPY cors.json /label-studio/data/cors.json

RUN chmod +x /entrypoint_label_studio.sh

USER 1001

EXPOSE 8081

ENTRYPOINT ["/entrypoint_label_studio.sh"]

EXPOSE ${LABEL_STUDIO_PORT}
