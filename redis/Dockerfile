FROM redis:4-alpine

RUN mkdir -p /redis
WORKDIR /redis

COPY --chown=redis:redis *.conf ./
COPY entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 6379 26379

ENTRYPOINT ["entrypoint.sh"]
