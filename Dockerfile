FROM chocolatey/choco:latest-linux as choco

FROM arillso/ansible:2.12.0 as production

USER root

ADD https://ssl-ccp.godaddy.com/repository/gdig2.crt.pem /usr/local/share/ca-certificates
ADD https://letsencrypt.org/certs/lets-encrypt-r3.pem /usr/local/share/ca-certificates

RUN apk --update --no-cache add \
	mono \
    mono-dev \
    libgdiplus \
    --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    && apk --no-cache add ca-certificates bash icu-libs krb5-libs libgcc libintl libssl1.1 libstdc++ zlib wget \
    && rm -rf /var/cache/apk/* \
    && update-ca-certificates 

RUN mkdir -p /usr/share/dotnet \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet 

RUN wget https://dot.net/v1/dotnet-install.sh
RUN chmod +x dotnet-install.sh

RUN ./dotnet-install.sh -c 6.0 --install-dir /usr/share/dotnet

COPY --from=choco usr/local/bin/choco.exe /usr/local/bin

COPY --from=choco  /opt/chocolatey /opt/chocolatey

COPY . /opt/chocomilk

RUN /usr/bin/ansible-galaxy \
   collection install -r \
   /opt/chocomilk/collections/requirements.yml \
   -p /usr/share/ansible/collections \
   && cert-sync --user /usr/local/share/ca-certificates/lets-encrypt-r3.pem \
   && cert-sync --user /usr/local/share/ca-certificates/gdig2.crt.pem

# Command to run when starting the container
CMD ["/usr/bin/ansible-playbook", "/opt/chocomilk/chocomilk.yml", "-vvvv"]
