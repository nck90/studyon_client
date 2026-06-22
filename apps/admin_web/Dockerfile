FROM node:22-alpine AS base
WORKDIR /app

FROM base AS deps
COPY package.json package-lock.json ./
RUN npm ci

FROM deps AS builder
ARG API_URL=http://api:3000
ARG NEXT_PUBLIC_PARENT_WEB_URL=http://localhost:11113
ENV API_URL=$API_URL
ENV NEXT_PUBLIC_PARENT_WEB_URL=$NEXT_PUBLIC_PARENT_WEB_URL
ENV NEXT_OUTPUT_FILE_TRACING_ROOT=/app
COPY . .
RUN npm run build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=11111
ENV HOSTNAME=0.0.0.0
ARG API_URL=http://api:3000
ARG NEXT_PUBLIC_PARENT_WEB_URL=http://localhost:11113
ENV API_URL=$API_URL
ENV NEXT_PUBLIC_PARENT_WEB_URL=$NEXT_PUBLIC_PARENT_WEB_URL
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/static ./.next/static
EXPOSE 11111
CMD ["node", "server.js"]
