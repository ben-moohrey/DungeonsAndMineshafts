#!/usr/bin/env bash
set -euo pipefail

# 0) Ensure we’re on the main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" != "main" ]]; then
  echo "🔀 Switching to 'main' branch..."
  git fetch origin main
  git checkout main
  git pull --ff-only origin main
fi

# 1) Ask bump type
read -rp "What kind of update? (major/minor/patch): " TYPE
if [[ ! "$TYPE" =~ ^(major|minor|patch)$ ]]; then
  echo "⛔ Invalid type: $TYPE"
  exit 1
fi

# 2) Grab current version
TOML="packwiz/pack.toml"
VERSION=$(grep -E '^version\s*=' "$TOML" | head -1 | sed -E 's/.*"([^"]+)".*/\1/')
IFS='.' read -r MAJ MIN PAT <<< "$VERSION"
MIN=${MIN:-0}
PAT=${PAT:-0}

# 3) Bump version
case "$TYPE" in
  major) MAJ=$((MAJ+1)); MIN=0; PAT=0 ;;
  minor) MIN=$((MIN+1)); PAT=0 ;;
  patch) PAT=$((PAT+1)) ;;
esac
NEW_VERSION="${MAJ}.${MIN}.${PAT}"
echo "🔖 Bumping version: $VERSION → $NEW_VERSION"

# 4) Update pack.toml
sed -i.bak -E "s/^version\s*=.*/version = \"${NEW_VERSION}\"/" "$TOML" && rm "${TOML}.bak"

# 5) Refresh packwiz lock/hashes
echo "⏳ Running packwiz refresh…"
pushd packwiz >/dev/null
packwiz refresh
popd >/dev/null

# 6) Commit & push version + lock changes
git add "$TOML" packwiz
git commit -m "chore: bump version to v${NEW_VERSION}"
git push origin main

# 7) Create & push tag
TAG="v${NEW_VERSION}"
git tag -a "$TAG" -m "Release $TAG"
git push origin "$TAG"

echo "✅ Released $TAG on branch main"
