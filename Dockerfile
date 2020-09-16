# == STAGE 1 : builder : fetch required packages to build node_modules and then create node_modules from package.lock.json
FROM node:12-alpine as builder

WORKDIR /app

RUN apk update && apk --no-cache add python make g++

COPY ./server/package*.json /app/
RUN npm ci

# == STAGE 2 : main : fetch node_modules from previous stage and sources from project, then build the server
FROM node:10-alpine

WORKDIR /app

COPY --from=builder /app/node_modules /app/node_modules
COPY ./server/*.json /app/
COPY ./server/src src

RUN npm run build

COPY ./server/scripts/version2json.ts /app/scripts/version2json.ts

RUN npm run --silent ver2json > /var/server.version.json && \
cat /var/server.version.json

# health check on Docker
EXPOSE 3000
COPY healthcheck.js /app/healthcheck.js
HEALTHCHECK --interval=20s --timeout=5m --start-period=10s CMD node /app/healthcheck.js

CMD npm run start:prod

# add build context to image details should be added in the ci
COPY service.version /var/service.version
