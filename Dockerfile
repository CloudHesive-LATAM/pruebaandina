FROM alpine:latest
    ARG GLIBC_VERSION=2.34-r0

    # Add glibc compatibility for alpine
    RUN apk --no-cache add \
            binutils \
            jq \
            gettext \
            curl \
            tar \
        && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
        && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
        && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk \
        && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk \
        && apk add --no-cache \
            glibc-${GLIBC_VERSION}.apk \
            glibc-bin-${GLIBC_VERSION}.apk \
            glibc-i18n-${GLIBC_VERSION}.apk \
        && /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8
  
    # Add awscli v2
    RUN wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O "awscliv2.zip"
    RUN unzip awscliv2.zip
    RUN ./aws/install
    RUN alias aws="/usr/local/bin/aws"
    
    RUN rm -rf /usr/local/aws-cli/v2/current/dist/awscli/examples glibc-*.apk 
    RUN find /usr/local/aws-cli/v2/current/dist/awscli/botocore/data -name examples-1.json -delete && apk --no-cache del binutils curl && rm -rf /var/cache/apk/*
    RUN rm -rf awscliv2.zip aws /usr/local/aws-cli/v2/current/dist/aws_completer /usr/local/aws-cli/v2/current/dist/awscli/data/ac.index
    


