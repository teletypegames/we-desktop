#!/bin/sh
# Builds the macOS package on this Mac and adds it to the catalog release the CI
# published. The electron platform builds Linux and Windows in the CI; Apple's
# signing only exists on a Mac, so the macOS zip is uploaded from here as
# <name>-<version>-mac-<arch>.zip, then the release is published again (a publish
# re-reads the release folder, the CI's packages stay). Both go through warp-engine,
# the WarpEngine CLI:
#
#   curl -fsSL https://git.teletypegames.org/engines/warp-engine-cli/raw/branch/master/install.sh | sh
#
#   WARP_TOKEN=<application token, update + upload scopes> scripts/upload-mac.sh
#
# The catalog is warpEngine.updates.catalogUrl in package.json; WARP_SERVER overrides it.
set -eu

die() { echo "[mac] error: $*" >&2; exit 1; }
[ -f package.json ] || die "run this from the repository root"
[ "$(uname -s)" = Darwin ] || die "the macOS package is built on a Mac"
[ -n "${WARP_TOKEN:-}" ] || die "WARP_TOKEN is not set (an application token of the catalog)"
WARP_ENGINE="${WARP_ENGINE:-warp-engine}"
command -v "$WARP_ENGINE" >/dev/null 2>&1 || die "$WARP_ENGINE (the WarpEngine CLI) is not installed"

NAME="$(node -p 'require("./package.json").name')"
VERSION="$(node -p 'require("./package.json").version')"
SERVER="${WARP_SERVER:-$(node -p '(require("./package.json").warpEngine?.updates?.catalogUrl) || ""')}"
SERVER="${SERVER%/}"
[ -n "$SERVER" ] || die "no catalog: set warpEngine.updates.catalogUrl or WARP_SERVER"
ARCH="$(node -p 'process.arch')"

rm -rf dist
npm run build
npx --no-install electron-builder --mac zip "--$ARCH" --publish never
BUILT="$(find dist -maxdepth 1 -name '*.zip' | head -n 1)"
[ -n "$BUILT" ] || die "electron-builder made no zip"
UPLOAD="dist/$NAME-$VERSION-mac-$ARCH.zip"
mv "$BUILT" "$UPLOAD"

echo "[mac] $UPLOAD -> $SERVER"
export WARP_TOKEN
"$WARP_ENGINE" release upload --server "$SERVER" --name "$NAME" --version "$VERSION" "$UPLOAD"
"$WARP_ENGINE" release publish --server "$SERVER" --name "$NAME" --version "$VERSION" --platform electron
echo "[mac] published $NAME $VERSION with the macOS package"
