FROM willhallonline/ansible:2.16.4-alpine-3.18

RUN apk add --update --no-cache sshpass

WORKDIR /workdir