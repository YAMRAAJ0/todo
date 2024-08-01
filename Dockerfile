FROM node:20

WORKDIR /myapp

COPY  . . 

RUN npm install

EXPOSE 3000

CMD ["node", "index.js"]

