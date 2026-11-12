FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y curl software-properties-common

RUN add-apt-repository -y ppa:deadsnakes/ppa && \
    apt update && \
    apt install -y python3.9 python3.9-distutils

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.9 get-pip.py

RUN pip3 install onnx==1.14.0
