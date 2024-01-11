FROM alpine
# FROM cgr.dev/chainguard/python:latest-dev

ARG BUILD_DATE
ARG BUILD_VERSION

LABEL org.opencontainers.image.authors="clemenko@gmail.com" \
      org.opencontainers.image.source="https://github.com/clemenko/dockerfiles/tree/master/flask_redis" \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.title="clemenko/flask_demo" \
      org.opencontainers.image.description="The repository contains a simple flask application "
  
RUN apk -U upgrade && apk add --no-cache python3 curl py3-pip &&\
    pip3 install --no-cache-dir --upgrade pip &&\
    pip3 install --no-cache-dir flask redis &&\
    #apk --purge del apk-tools &&\
    rm -rf /var/cache/apk/*
    
WORKDIR /code
ADD . /code
EXPOSE 5000
HEALTHCHECK CMD curl -f http://localhost:5000/healthz || exit 1
CMD ["python3", "app.py"]
