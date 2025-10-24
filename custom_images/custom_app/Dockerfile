FROM alpine:3.22.2

RUN apk add --no-cache curl && \
    adduser -D mirror

USER mirror
WORKDIR /home/mirror

CMD ["sh"]
