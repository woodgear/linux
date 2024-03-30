FROM ubuntu:20.04
RUN apt-get update
RUN apt-get install -y init openssh-server
RUN yes | unminimize