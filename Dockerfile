FROM node
COPY . /root
ENV PATH "/root/check-types/bin:$PATH"
RUN apt-get install html2text
