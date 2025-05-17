#!/bin/bash
set -e

# Create cookbook package
VERSION=$(grep -m 1 "^version" metadata.rb | sed -e "s/version ['\"]\([^'\"]*\)['\"]*/\1/")
COOKBOOK_NAME=$(grep -m 1 "^name" metadata.rb | sed -e "s/name ['\"]\([^'\"]*\)['\"]*/\1/")

echo "Packaging $COOKBOOK_NAME version $VERSION"

# Create dist directory if it doesn't exist
mkdir -p dist

# Create tarball
tar -czf dist/${COOKBOOK_NAME}-${VERSION}.tgz --exclude='.git' --exclude='dist' --exclude='test' --exclude='spec' .

echo "Package created: dist/${COOKBOOK_NAME}-${VERSION}.tgz"

# Build Docker image
docker build -t ${COOKBOOK_NAME}:${VERSION} .
docker tag ${COOKBOOK_NAME}:${VERSION} ${COOKBOOK_NAME}:latest

echo "Docker image built: ${COOKBOOK_NAME}:${VERSION}"
echo ""
echo "To push to GitHub Packages:"
echo "docker tag ${COOKBOOK_NAME}:${VERSION} ghcr.io/<your-github-username>/${COOKBOOK_NAME}:${VERSION}"
echo "docker push ghcr.io/<your-github-username>/${COOKBOOK_NAME}:${VERSION}"