#!/bin/sh
set -eu

export GIT_CEILING_DIRECTORIES="/github/workspace"

mkdir -p "$GITHUB_WORKSPACE/.abuild"
mkdir -p "$HOME/.abuild"

# Write RSA keys
echo "$INPUT_RSA_PRIVATE_KEY" > "$GITHUB_WORKSPACE/key"
echo "$INPUT_RSA_PUBLIC_KEY" > "$GITHUB_WORKSPACE/key.pub"
chmod 600 "$GITHUB_WORKSPACE/key"
chmod 644 "$GITHUB_WORKSPACE/key.pub"

# Configure abuild
echo "PACKAGER_PRIVKEY=$GITHUB_WORKSPACE/key" > "$HOME/.abuild/abuild.conf"
cp "$GITHUB_WORKSPACE/key.pub" /etc/apk/keys

# Go to package directory
cd "$GITHUB_WORKSPACE/$INPUT_PACKAGE_PATH"

# Update pkgver and pkgrel safely
sed -i'' -e "s/^pkgver=.*/pkgver=$INPUT_RELEASE_VERSION/" \
        -e "s/^pkgrel=.*/pkgrel=0/" APKBUILD

# Force LF line endings for abuild
if command -v dos2unix >/dev/null 2>&1; then
    dos2unix APKBUILD
else
    # fallback using sed if dos2unix is not installed
    sed -i 's/\r$//' APKBUILD
fi

# FIX: Force abuild to save into the persistent workspace
export REPODEST="$GITHUB_WORKSPACE/packages"

# Build the package
abuild -F checksum
abuild -F -r
