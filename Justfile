# Avisblue - Clean Universal Blue distro based on Aurora-dx
# Local build commands

# Default recipe
default:
    @just --list

# Build avisblue (Aurora-dx, AMD/Intel — the base image)
build:
    podman build -f Containerfile -t avisblue:local .

# Build avisblue-nvidia (Aurora-dx NVIDIA open)
build-nvidia:
    podman build -f Containerfile.nvidia -t avisblue-nvidia:local .

# Build all images
build-all: build build-nvidia
    @echo "All images built successfully"

# List local avisblue images
list:
    podman images | grep avisblue

# Clean local avisblue images
clean:
    podman rmi -f $(podman images -q 'avisblue*:local') 2>/dev/null || true

# Generate cosign keypair (run once)
generate-keys:
    COSIGN_PASSWORD="" cosign generate-key-pair
    @echo "Keys generated. Add cosign.key contents to GitHub secret SIGNING_SECRET"
    @echo "WARNING: Never commit cosign.key to git!"

# Test rebase to local image (dry run)
test-rebase image:
    @echo "To rebase to {{image}}, run:"
    @echo "sudo bootc switch localhost/{{image}}:local"
