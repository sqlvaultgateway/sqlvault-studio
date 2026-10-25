#!/bin/sh
# Installe SQLVault Studio (dernière version) sur macOS ou Linux.
#   curl -fsSL https://raw.githubusercontent.com/sqlvaultgateway/sqlvault-studio/main/install.sh | sh
# Désinstaller : le même script avec « --uninstall » (vos bases et réglages sont conservés).
set -eu

REPO="sqlvaultgateway/sqlvault-studio"
API="${SQLVAULT_STUDIO_API:-https://api.github.com/repos/$REPO/releases/latest}"

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31mErreur :\033[0m %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "la commande « $1 » est nécessaire."; }

OS=$(uname -s)
case "$OS" in
  Darwin) APPDIR="${SQLVAULT_STUDIO_APPDIR:-/Applications}"; [ -w "$APPDIR" ] || APPDIR="$HOME/Applications" ;;
  Linux) DEST="$HOME/.local/share/sqlvault-studio"; BIN="$HOME/.local/bin" ;;
  *) die "système non pris en charge ($OS). Sous Windows, utilisez install.ps1." ;;
esac

if [ "${1:-}" = "--uninstall" ]; then
  if [ "$OS" = Darwin ]; then
    rm -rf "/Applications/SQLVault Studio.app" "$HOME/Applications/SQLVault Studio.app"
  else
    rm -rf "$DEST" "$BIN/sqlvault-studio" "$HOME/.local/share/applications/sqlvault-studio.desktop"
  fi
  say "SQLVault Studio est désinstallé. Vos bases et réglages sont conservés."
  exit 0
fi

need curl
case "$(uname -m)" in
  x86_64|amd64) ARCH=amd64 ;;
  arm64|aarch64) ARCH=arm64 ;;
  *) die "processeur non pris en charge ($(uname -m))." ;;
esac
if [ "$OS" = Darwin ]; then PATTERN='macOS\.dmg'; else PATTERN="linux-$ARCH\.zip"; need unzip; fi

say "Recherche de la dernière version…"
JSON=$(curl -fsSL "$API") || die "impossible de joindre GitHub (connexion Internet ?)."
urls=$(printf '%s' "$JSON" | grep -o '"browser_download_url": *"[^"]*"' | sed 's/.*"\(http[^"]*\)"$/\1/')
URL=$(printf '%s\n' "$urls" | grep -E "$PATTERN\$" | head -n 1)
SUMS=$(printf '%s\n' "$urls" | grep -E 'SHA256SUMS\.txt$' | head -n 1)
[ -n "$URL" ] || die "aucun fichier pour ce système dans la dernière version."
FILE=$(basename "$URL")

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
say "Téléchargement de $FILE…"
curl -fL --progress-bar -o "$TMP/$FILE" "$URL"
if [ -n "$SUMS" ]; then
  curl -fsSL -o "$TMP/SHA256SUMS.txt" "$SUMS"
  expected=$(grep " $FILE\$" "$TMP/SHA256SUMS.txt" | cut -d' ' -f1)
  if command -v shasum >/dev/null 2>&1; then actual=$(shasum -a 256 "$TMP/$FILE" | cut -d' ' -f1); else actual=$(sha256sum "$TMP/$FILE" | cut -d' ' -f1); fi
  [ "$expected" = "$actual" ] || die "le fichier téléchargé est altéré (empreinte SHA-256 différente)."
  say "Empreinte SHA-256 vérifiée."
fi

if [ "$OS" = Darwin ]; then
  mkdir -p "$APPDIR"
  hdiutil attach -quiet -nobrowse -mountpoint "$TMP/mnt" "$TMP/$FILE"
  rm -rf "$APPDIR/SQLVault Studio.app"
  cp -R "$TMP/mnt/SQLVault Studio.app" "$APPDIR/"
  hdiutil detach -quiet "$TMP/mnt"
  xattr -dr com.apple.quarantine "$APPDIR/SQLVault Studio.app" 2>/dev/null || true
  say "Installé dans $APPDIR. Lancez « SQLVault Studio » depuis le Launchpad, ou : open -a \"SQLVault Studio\""
else
  rm -rf "$DEST"; mkdir -p "$DEST" "$BIN" "$HOME/.local/share/applications"
  unzip -q "$TMP/$FILE" -d "$TMP/x"
  cp -R "$TMP"/x/*/. "$DEST/"
  chmod +x "$DEST/sqlvault-studio"
  ln -sf "$DEST/sqlvault-studio" "$BIN/sqlvault-studio"
  cat > "$HOME/.local/share/applications/sqlvault-studio.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=SQLVault Studio
Comment=Client SQL gratuit pour apprendre et développer
Exec=$DEST/sqlvault-studio
Terminal=true
Categories=Development;Database;
EOF
  say "Installé. Lancez : sqlvault-studio   (l'interface s'ouvre dans le navigateur)"
  case ":$PATH:" in *":$BIN:"*) ;; *) say "Ajoutez $BIN à votre PATH, par exemple : echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc" ;; esac
fi
