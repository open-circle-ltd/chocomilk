FROM chocolatey/choco:latest-linux as choco

FROM arillso/ansible:2.12.0 as production

USER root

ADD https://ssl-ccp.godaddy.com/repository/gdig2.crt.pem /usr/local/share/ca-certificates
ADD https://letsencrypt.org/certs/isrgrootx1.pem /usr/local/share/ca-certificates
ADD https://letsencrypt.org/certs/lets-encrypt-r3.pem /usr/local/share/ca-certificates

RUN apk --update --no-cache add \
	mono \
    --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    && apk --no-cache add ca-certificates \
    && rm -rf /var/cache/apk/* \
    && update-ca-certificates

COPY --from=choco usr/local/bin/choco.exe /usr/local/bin

COPY --from=choco  /opt/chocolatey /opt/chocolatey

COPY . /opt/chocomilk

RUN /usr/bin/ansible-galaxy \
   collection install -r \
   /opt/chocomilk/collections/requirements.yml \
   -p /usr/share/ansible/collections

# Command to run when starting the container
CMD ["/usr/bin/ansible-playbook", "/opt/chocomilk/chocomilk.yml", "-vvvv"]
