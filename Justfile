# Avisblue - Custom Universal Blue distro based on Bazzite
# Local build commands

# Default recipe
default:
    @just --list

# Build avisblue-main (Mesa + Dev + ROCm)
build-main:
    podman build -f Containerfile.main -t avisblue-main:local .

# Build avisblue-nvidia-gaming (NVIDIA + Gaming + Dev + CUDA)
build-nvidia-gaming:
    podman build -f Containerfile.nvidia-gaming -t avisblue-nvidia-gaming:local .

# Build all images
build-all: build-main build-nvidia-gaming
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
