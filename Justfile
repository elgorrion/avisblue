# Avisblue - Custom Universal Blue distro for CASA fleet
# Local build commands

# Default recipe
default:
    @just --list

# Build avisblue-main (Mesa base)
build-main:
    podman build -f Containerfile.main -t avisblue-main:local .

# Build avisblue-main-dev (Mesa + Dev + ROCm)
build-main-dev: build-main
    podman build -f Containerfile.main-dev -t avisblue-main-dev:local \
        --build-arg BASE_IMAGE=localhost/avisblue-main:local .

# Build avisblue-nvidia-gaming (NVIDIA + Gaming)
build-nvidia-gaming:
    podman build -f Containerfile.nvidia-gaming -t avisblue-nvidia-gaming:local .

# Build avisblue-nvidia-gaming-dev (NVIDIA + Gaming + Dev + CUDA)
build-nvidia-gaming-dev: build-nvidia-gaming
    podman build -f Containerfile.nvidia-gaming-dev -t avisblue-nvidia-gaming-dev:local \
        --build-arg BASE_IMAGE=localhost/avisblue-nvidia-gaming:local .

# Build all images
build-all: build-main build-main-dev build-nvidia-gaming build-nvidia-gaming-dev
    @echo "All images built successfully"

# List local avisblue images
list:
    podman images | grep avisblue

# Clean local avisblue images
clean:
    podman rmi -f $(podman images -q 'avisblue-*:local') 2>/dev/null || true

# Generate cosign keypair (run once)
generate-keys:
    COSIGN_PASSWORD="" cosign generate-key-pair
    @echo "Keys generated. Add cosign.key contents to GitHub secret SIGNING_SECRET"
    @echo "WARNING: Never commit cosign.key to git!"

# Test rebase to local image (dry run)
test-rebase image:
    @echo "To rebase to {{image}}, run:"
    @echo "sudo bootc switch localhost/{{image}}:local"
