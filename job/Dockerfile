FROM alpine

RUN apk add curl
RUN apk add coreutils

RUN mkdir app
WORKDIR app

COPY *.sh .
RUN chmod +x *.sh
RUN ls -la

CMD ./addUserToCaseWatchlist.sh
