FROM alpine

RUN apk add curl
RUN apk add coreutils

RUN mkdir app
WORKDIR app

COPY *.sh .
RUN ls -la
RUN chmod +x *.sh

CMD ./addUserToCaseWatchlist.sh
