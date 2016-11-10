FROM node
COPY . /root
ENV PATH "/root/check-types/bin:$PATH"
