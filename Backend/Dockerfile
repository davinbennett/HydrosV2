
# ! PROD
# Build stage
FROM golang:1.25.3-alpine AS builder
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy all source
COPY . .

# Build binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o hydros-backend ./main.go


# -------- Stage 2: Runner --------
FROM alpine:3.19

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/hydros-backend /app/hydros-backend

# Copy config folder (termasuk firebase service account JSON)
COPY config /app/config

# Allow binary execution
RUN chmod +x /app/hydros-backend

EXPOSE 8081

CMD ["/app/hydros-backend"]



# ! DEV
# Build stage
# FROM golang:1.25.3-alpine AS builder
# WORKDIR /app
# COPY go.mod go.sum ./
# RUN go mod download
# COPY . .

# # Run stage for development
# FROM golang:1.25.3-alpine
# WORKDIR /app
# RUN apk --no-cache add ca-certificates tzdata && \
#     ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime && \
#     echo "Asia/Jakarta" > /etc/timezone
# RUN go install github.com/air-verse/air@latest

# EXPOSE 8081
# CMD ["air"]
