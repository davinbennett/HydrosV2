
# ! PROD
# Build stage
# FROM golang:1.25.3-alpine AS builder
# WORKDIR /app
# COPY go.mod go.sum ./
# RUN go mod download
# COPY . .
# RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o hydros-backend main.go


# # Run stage
# FROM alpine:latest
# RUN apk --no-cache add ca-certificates tzdata
# WORKDIR /app
# COPY --from=builder /app/hydros-backend .

# EXPOSE 8081
# CMD ["./hydros-backend"]


# ! DEV
# Build stage
FROM golang:1.25.3-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .

# Run stage for development
FROM golang:1.25.3-alpine
WORKDIR /app
RUN apk --no-cache add ca-certificates tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime && \
    echo "Asia/Jakarta" > /etc/timezone
RUN go install github.com/air-verse/air@latest

EXPOSE 8081
CMD ["air"]
