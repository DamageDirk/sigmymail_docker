# ---- Build Stage ----
FROM oven/bun:1 AS builder

WORKDIR /app

COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

COPY . .

# ENV-Variablen werden zur Build-Zeit eingebunden (VITE_ prefix)
ARG VITE_AWS_S3_URL
ARG VITE_AWS_S3_BASKET
ARG VITE_AWS_S3_ID
ARG VITE_AWS_S3_KEY
ARG VITE_AWS_S3_REGION

ENV VITE_AWS_S3_URL=$VITE_AWS_S3_URL
ENV VITE_AWS_S3_BASKET=$VITE_AWS_S3_BASKET
ENV VITE_AWS_S3_ID=$VITE_AWS_S3_ID
ENV VITE_AWS_S3_KEY=$VITE_AWS_S3_KEY
ENV VITE_AWS_S3_REGION=$VITE_AWS_S3_REGION

RUN bun run build

# ---- Serve Stage ----
FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html

# SPA-Routing: alle Pfade auf index.html umleiten
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
