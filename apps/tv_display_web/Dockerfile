FROM node:22-alpine AS base
WORKDIR /app

FROM base AS deps
COPY package.json ./
RUN npm install

FROM deps AS builder
COPY . .
RUN npm run build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=11112
ENV HOSTNAME=0.0.0.0
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/static ./.next/static
EXPOSE 11112
CMD ["node", "server.js"]
