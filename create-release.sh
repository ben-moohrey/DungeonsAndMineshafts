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

# 2) Repo coords
REPO="ben-moohrey/DungeonsAndMineshafts"

# 3) Try to fetch current version from GitHub latest tag
API_URL="https://api.github.com/repos/${REPO}/releases/latest"
REMOTE_TAG=$(curl -s "$API_URL" \
  | grep '"tag_name"' \
  | head -n1 \
  | sed -E 's/.*"([^"]+)".*/\1/' || true)

if [[ -n "$REMOTE_TAG" ]]; then
  echo "📡 Found remote latest tag: $REMOTE_TAG"
  CURRENT_VERSION="${REMOTE_TAG#v}"
else
  echo "⚠️ No remote release; falling back to pack.toml"
  CURRENT_VERSION=$(grep -E '^[[:space:]]*version[[:space:]]*=' packwiz/pack.toml \
    | head -1 \
    | sed -E 's/.*=[[:space:]]*"([^"]+)".*/\1/')
fi

# 4) Split into semver parts
IFS='.' read -r MAJ MIN PAT <<< "$CURRENT_VERSION"
MIN=${MIN:-0}
PAT=${PAT:-0}

# 5) Bump
case "$TYPE" in
  major) ((MAJ++)); MIN=0; PAT=0 ;;
  minor) ((MIN++)); PAT=0 ;;
  patch) ((PAT++)) ;;
esac
NEW_VERSION="${MAJ}.${MIN}.${PAT}"
echo "🔖 Bumping: $CURRENT_VERSION → $NEW_VERSION"

# 6) Write new version into pack.toml
sed -i.bak -E \
  "s|^[[:space:]]*version[[:space:]]*=.*|version = \"${NEW_VERSION}\"|" \
  packwiz/pack.toml
rm packwiz/pack.toml.bak

# 7) Refresh lock
echo "⏳ packwiz refresh…"
pushd packwiz >/dev/null
packwiz refresh
popd >/dev/null

# 8) Commit & push
git add packwiz/pack.toml packwiz
git commit -m "chore: bump version to v${NEW_VERSION}"
git push origin main

# 9) Tag & push
TAG="v${NEW_VERSION}"
git tag -a "$TAG" -m "Release $TAG"
git push origin "$TAG"

echo "✅ Released $TAG"
