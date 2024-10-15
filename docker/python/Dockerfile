FROM python:3.11.1-alpine

RUN apk update && apk add ca-certificates

RUN apk add \
    ffmpeg \
    libwebp \
    libwebp-tools \
    make automake \
    gcc \
    g++

WORKDIR /app/python