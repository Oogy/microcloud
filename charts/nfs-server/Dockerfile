FROM alpine:3.21
RUN apk add --no-cache nfs-utils
COPY nfsd.sh /usr/local/bin/
EXPOSE 2049
ENTRYPOINT ["/usr/local/bin/nfsd.sh"]
