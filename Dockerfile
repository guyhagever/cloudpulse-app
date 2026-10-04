# Stage 1: Build
FROM golang:1.24-alpine AS builder

WORKDIR /app

# Download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build statically linked binary without debug symbols
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o cloudpulse main.go

# Stage 2: Final Minimal Runtime
FROM gcr.io/distroless/static:nonroot

WORKDIR /

# Copy compiled binary from builder
COPY --from=builder /app/cloudpulse /cloudpulse

# Default non-root user in distroless
USER nonroot:nonroot

EXPOSE 8080

ENTRYPOINT ["/cloudpulse"]
