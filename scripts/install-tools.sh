#!/usr/bin/env bash
set -euo pipefail

PLAYBOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INVENTORY="${PLAYBOOK_DIR}/inventory.ini"
PLAYBOOK="${PLAYBOOK_DIR}/site.yml"

# Ensure Ansible is installed
if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "🔧 Installing Ansible..."
  sudo apt-get update -y
  sudo apt-get install -y software-properties-common
  sudo add-apt-repository --yes --update ppa:ansible/ansible
  sudo apt-get install -y ansible
  echo "✅ Ansible installed."
fi

ACTION="${1:-install}"  # install|uninstall|verify

case "$ACTION" in
  install)
    exec ansible-playbook -K -i "$INVENTORY" "$PLAYBOOK" -e tools_state=present
    ;;
  uninstall)
    exec ansible-playbook -K -i "$INVENTORY" "$PLAYBOOK" -e tools_state=absent
    ;;
  verify)
    exec ansible-playbook -i "$INVENTORY" "$PLAYBOOK" --tags verify
    ;;
  *)
    echo "Usage: $0 [install|uninstall|verify]" >&2
    exit 1
    ;;
esac
