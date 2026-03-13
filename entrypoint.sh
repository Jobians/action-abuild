#!/bin/sh
set -eu

export GIT_CEILING_DIRECTORIES="/github/workspace"

# Create abuild directory
mkdir -p "$GITHUB_WORKSPACE/.abuild"

# Write secrets to files
echo "$INPUT_RSA_PRIVATE_KEY" > "$GITHUB_WORKSPACE/key"
echo "$INPUT_RSA_PUBLIC_KEY" > "$GITHUB_WORKSPACE/key.pub"
chmod 600 "$GITHUB_WORKSPACE/key"
chmod 644 "$GITHUB_WORKSPACE/key.pub"

# Tell abuild where the private key is
echo "PACKAGER_PRIVKEY=$GITHUB_WORKSPACE/key" > "$HOME/.abuild/abuild.conf"

# Copy the public key to APK keys
cp "$GITHUB_WORKSPACE/key.pub" /etc/apk/keys

# Go to package directory
cd "$GITHUB_WORKSPACE/$INPUT_PACKAGE_PATH"

# Update version
sed -i "s/pkgver=.*/pkgver=$INPUT_RELEASE_VERSION/g" APKBUILD
sed -i "s/pkgrel=.*/pkgrel=0/g" APKBUILD

# Build package
abuild -F checksum && abuild -F -r
