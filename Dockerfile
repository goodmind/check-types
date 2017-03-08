FROM node
COPY . /root

ENV TERM xterm
ENV PATH "/root/check-types/bin:$PATH"

RUN apt-get update
RUN apt-get install html2text

RUN cd /root/remote-types; npm prune
RUN npm cache clean
RUN npm i -g /root/remote-types
RUN check-types update /root/cycle-telegram/src/runtime-types
RUN ls
RUN check-types /root/cycle-telegram/src/runtime-types
