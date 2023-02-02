FROM chocolatey/choco:latest-linux as choco

FROM arillso/ansible:2.14.1 as production

USER root

RUN apk --update --no-cache add \
	mono \
    mono-dev \
    libgdiplus \
    --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    && apk --no-cache add ca-certificates bash icu-libs krb5-libs libgcc libintl libssl1.1 libstdc++ zlib wget \
    && rm -rf /var/cache/apk/* \
    && update-ca-certificates 

RUN wget --progress=dot:giga https://dot.net/v1/dotnet-install.sh \
    && chmod +x dotnet-install.sh \
    && ./dotnet-install.sh -c 6.0 --install-dir /usr/share/dotnet

COPY --from=choco usr/local/bin/choco.exe /usr/local/bin

COPY --from=choco  /opt/chocolatey /opt/chocolatey

COPY . /opt/chocomilk

RUN /usr/bin/ansible-galaxy \
   collection install -r \
   /opt/chocomilk/collections/requirements.yml \
   -p /usr/share/ansible/collections

# Command to run when starting the container
CMD ["/usr/bin/ansible-playbook", "/opt/chocomilk/chocomilk.yml", "-vvvv"]
