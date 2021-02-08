FROM frolvlad/alpine-glibc:latest

RUN echo "http://mirrors.aliyun.com/alpine/v3.13/main/" > /etc/apk/repositories && \
    apk update && \
    apk --no-cache add tzdata ca-certificates libgcc libstdc++

COPY shiney /shiney

CMD [ "sh", "-c", "/shiney"]