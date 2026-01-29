# FitTrack

Learning project to explore communication between microservices using gRPC with Go and Python.

## Setup

1. **Install Protocol Buffers**
   ```bash
   brew install protobuf
   ```

2. **Install Go protobuf plugins**
   ```bash
   go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
   go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
   ```

3. **Set up Python virtual environment**
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   pip install grpcio grpcio-tools protobuf
   ```

4. **Generate proto files**
   ```bash
   source .venv/bin/activate
   ./scripts/generate-proto.sh
   ```
