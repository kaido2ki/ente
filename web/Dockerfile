FROM node:22-alpine AS builder

WORKDIR /app
COPY . .

ARG NEXT_PUBLIC_ENTE_ENDPOINT=https://ente.example.com
ENV NEXT_PUBLIC_ENTE_ENDPOINT=${NEXT_PUBLIC_ENTE_ENDPOINT}

ARG NEXT_PUBLIC_ENTE_ALBUMS_ENDPOINT=https://album.example.com
ENV NEXT_PUBLIC_ENTE_ALBUMS_ENDPOINT=${NEXT_PUBLIC_ENTE_ALBUMS_ENDPOINT}

ARG NEXT_PUBLIC_ENTE_ACCOUNTS_URL=https://accounts.example.com
ENV NEXT_PUBLIC_ENTE_ACCOUNTS_URL=${NEXT_PUBLIC_ENTE_ACCOUNTS_URL}

RUN npm install -g yarn
RUN yarn install && yarn build:photos && yarn build:auth && yarn build:accounts

FROM node:22-alpine

WORKDIR /app
COPY --from=builder /app/apps/photos/out /app/photos
COPY --from=builder /app/apps/auth/out /app/auth
COPY --from=builder /app/apps/accounts/out /app/accounts

RUN npm install -g serve

ENV WEBPORT=3000
EXPOSE ${WEBPORT}

ENV ACCOUNTS=3001
EXPOSE ${ACCOUNTS}

ENV AUTHPORT=3005
EXPOSE ${AUTHPORT}

CMD ["sh", "-c", "serve /app/photos -l tcp://0.0.0.0:${WEBPORT} & serve /app/auth -l tcp://0.0.0.0:${AUTHPORT} & serve /app/accounts -l tcp://0.0.0.0:${ACCOUNTS}"]
