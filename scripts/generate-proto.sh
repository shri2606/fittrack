#!/bin/bash
set -e

# Add tool locations to PATH, but append (not prepend) to preserve venv priority
[ -d "/opt/homebrew/bin" ] && [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]] && export PATH="$PATH:/opt/homebrew/bin"
[ -d "/usr/local/go/bin" ] && [[ ":$PATH:" != *":/usr/local/go/bin:"* ]] && export PATH="$PATH:/usr/local/go/bin"
command -v go >/dev/null 2>&1 && export PATH="$PATH:$(go env GOPATH)/bin"

# Validate required tools are available
PYTHON_CMD=$(command -v python3 || command -v python)

echo "Validating required tools..."

if ! command -v protoc >/dev/null 2>&1; then
    echo "Error: protoc not found. Please install Protocol Buffers compiler."
    echo "  macOS: brew install protobuf"
    exit 1
fi

if ! command -v protoc-gen-go >/dev/null 2>&1; then
    echo "Error: protoc-gen-go not found."
    echo "  Run: go install google.golang.org/protobuf/cmd/protoc-gen-go@latest"
    exit 1
fi

if ! command -v protoc-gen-go-grpc >/dev/null 2>&1; then
    echo "Error: protoc-gen-go-grpc not found."
    echo "  Run: go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest"
    exit 1
fi

if ! $PYTHON_CMD -c "import grpc_tools.protoc" 2>/dev/null; then
    echo "Error: grpcio-tools not found."
    echo "  Activate venv and run: pip install grpcio-tools"
    exit 1
fi

echo "All tools found. Generating code from proto files..."

# Each service gets its own generated code
# Generate for Go services
protoc -I./proto \
  --go_out=./src/frontend --go_opt=paths=source_relative \
  --go-grpc_out=./src/frontend --go-grpc_opt=paths=source_relative \
  proto/*.proto

protoc -I./proto \
  --go_out=./src/workoutservice --go_opt=paths=source_relative \
  --go-grpc_out=./src/workoutservice --go-grpc_opt=paths=source_relative \
  proto/*.proto

# Generate for Python services
# Use python from current environment (venv if activated, system otherwise)

$PYTHON_CMD -m grpc_tools.protoc -I./proto \
  --python_out=./src/progressservice \
  --grpc_python_out=./src/progressservice \
  proto/*.proto

$PYTHON_CMD -m grpc_tools.protoc -I./proto \
  --python_out=./src/notificationservice \
  --grpc_python_out=./src/notificationservice \
  proto/*.proto

echo "Code generation complete!"