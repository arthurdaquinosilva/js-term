# Runs the test suite in a clean Linux environment:
#   docker build -t js-term-test . && docker run --rm js-term-test
#   docker build --build-arg NODE=20.12 -t js-term-test-20 . && docker run --rm js-term-test-20
ARG NODE=24
FROM node:${NODE}-slim
RUN apt-get update && apt-get install -y --no-install-recommends tmux && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
CMD ["npm", "test"]
