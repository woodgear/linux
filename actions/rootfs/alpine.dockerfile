FROM alpine:3.13
COPY ./init-alpine.sh ./
RUN ./init-alpine.sh