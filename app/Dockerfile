FROM node

WORKDIR /usr/app
#RUN npm install dotenv --save

COPY app/server.js .
COPY *.sh .
RUN chmod +x *.sh

EXPOSE 8080
CMD [ "node", "server.js" ]