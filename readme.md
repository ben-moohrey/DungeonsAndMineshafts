# Dungeons And Mineshafts Pack

Welcome to the Dungeons And Mineshafts mod pack! This repository contains everything you need to manage, distribute, and update your custom Minecraft server mod configuration using Packwiz.

📦 Pack Contents

All of your mod list, lock file, and configuration live under the packwiz/ directory:

packwiz/pack.toml – Metadata and version for this pack.

packwiz/lock.toml – Auto‑generated file locking each mod’s download URL and checksum.

Your actual mod list is managed by Packwiz; see Usage below.

🚀 Quick Start

Download the Prism Instance Zip below.
https://ben-moohrey.github.io/DungeonsAndMineshafts/

Open in the Prism Launcher.

# In repo root:
🛠 Version Bumping & Releases

We follow Semantic Versioning with tags like vMAJOR.MINOR.PATCH.

To cut a new release:

Run the script:

scripts/create-release.sh

Choose one of major, minor, or patch.

The script will bump packwiz/pack.toml, run packwiz refresh, commit and push, tag vX.Y.Z, and push the tag.

Once your tag is pushed, jsDelivr will serve it at:

https://cdn.jsdelivr.net/gh/ben-moohrey/DungeonsAndMineshafts@latest/packwiz/pack.toml

🤝 Contributing

Fork the repo and work on a feature branch.

Update packwiz/pack.toml or add/remove mods via:

cd packwiz
packwiz add <mod-url>
packwiz remove <mod-id>

Open a PR against main.