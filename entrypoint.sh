#!/bin/sh
set -eu

export GIT_CEILING_DIRECTORIES="/github/workspace"

mkdir -p "$GITHUB_WORKSPACE/.abuild"
mkdir -p "$HOME/.abuild"

echo "$INPUT_RSA_PRIVATE_KEY" > "$GITHUB_WORKSPACE/key"
echo "$INPUT_RSA_PUBLIC_KEY" > "$GITHUB_WORKSPACE/key.pub"
chmod 600 "$GITHUB_WORKSPACE/key"
chmod 644 "$GITHUB_WORKSPACE/key.pub"

echo "PACKAGER_PRIVKEY=$GITHUB_WORKSPACE/key" > "$HOME/.abuild/abuild.conf"

cp "$GITHUB_WORKSPACE/key.pub" /etc/apk/keys

cd "$GITHUB_WORKSPACE/$INPUT_PACKAGE_PATH"

sed -i "s/pkgver=.*/pkgver=$INPUT_RELEASE_VERSION/g" APKBUILD
sed -i "s/pkgrel=.*/pkgrel=0/g" APKBUILD

abuild -F checksum && abuild -F -r
