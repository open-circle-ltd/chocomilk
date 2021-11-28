FROM chocolatey/choco:latest-linux as choco

FROM arillso/ansible:2.12.0 as production

USER root

RUN apk --update --no-cache add \
    ca-certificates \
    && apk --update --no-cache add \
	mono \
    --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing 

COPY --from=choco usr/local/bin/choco.exe /usr/local/bin

COPY --from=choco  /opt/chocolatey /opt/chocolatey

COPY . /opt/chocomilk

RUN /usr/bin/ansible-galaxy \
   collection install -r \
   /opt/chocomilk/collections/requirements.yml \
   -p /usr/share/ansible/collections

RUN curl https://ssl-ccp.godaddy.com/repository/gdig2.crt.pem -o gdig2.crt.pem \
    && cat gdig2.crt.pem >> /etc/ssl/certs/ca-certificates.crt \
    && update-ca-certificates
# Command to run when starting the container
CMD ["/usr/bin/ansible-playbook", "/opt/chocomilk/chocomilk.yml", "-vvvv"]
