#!/bin/bash

# TODO
# - [ ] take a look at any Linux OS to Silverblue (e.g Ubuntu)
# - [ ] install previous user installed packages as overlay
# - [ ] install previous system Flatpaks

# RUN AS ROOT
# USE AT YOUR OWN RISK

# inspired by https://asamalik.fedorapeople.org/fedora-docs-translations/en-US/fedora-silverblue/installation-dual-boot/

set -o errexit
set -o nounset
set -o pipefail

if [ ! "$(id -u)" = 0 ]; then
  echo "this script must be run as root" >/dev/stderr
fi

CMDN="${1}"

COUNTER=0
cmd() {
  if [ ! "$COUNTER" -ge "${CMDN}" ]; then
    COUNTER=$((COUNTER += 1))
    return
  fi
  CMD=$*
  (
    echo "$(date): exec[$COUNTER]: ${CMD}"
    eval "${CMD}" 2>&1
  ) | tee -a "${FWS2SBLOG:-/var/log/fedora-ws2sb.log}"
  COUNTER=$((COUNTER += 1))
}

cat <<EOF
Migrate to Silverblueize, where you convert your existing Fedora Workstation install into Fedora Silverblue.
This process may be harmful and is irreversable without disk or partition snapshots (see LVM or btrfs).
User data, via home partition will persist and programs or other system configurations will likely not.

The procedure will feel like a new install but with persisting user data

By proceeding, you understand the risk.
Press [enter] to proceed.
EOF
read -r -p ''

cmd dnf install -y ostree ostree-grub2

cmd ostree admin init-fs /
cmd ostree remote add --set=gpgkeypath=/etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-38-x86_64 fedora https://ostree.fedoraproject.org --set=contenturl=mirrorlist=https://ostree.fedoraproject.org/mirrorlist
cmd ostree --repo=/ostree/repo pull fedora:fedora/38/x86_64/silverblue
cmd rm -r /boot/loader
cmd ostree admin os-init fedora
cmd mv /boot/grub2/grub.cfg /boot/grub2/grub.cfg.bak
cmd cp /boot/efi/EFI/fedora/grub.cfg /boot/efi/EFI/fedora/grub.cfg.bak
cmd ostree admin deploy --os=fedora --karg-proc-cmdline fedora:fedora/38/x86_64/silverblue
OSTREE_DEPLOY_ROOT="$(find /ostree/deploy/fedora/deploy -mindepth 1 -maxdepth 1 -type d)"

# TODO add /etc/passwd /etc/shadow ?
for i in /etc/fstab /etc/default/grub /etc/locale.conf /etc/ostree/remotes.d/fedora.conf; do
  cmd cp "${i}" "${OSTREE_DEPLOY_ROOT}/${i}"
done
cmd sed -i -e 's,/home,/var/home,g' /ostree/deploy/fedora/deploy/*.0/etc/fstab
cmd cp /boot/loader/grub.cfg /boot/grub2/grub.cfg || true

cat <<EOF
Automatic migration complete.
Depending on your system config, you may have addition changes or preparations you may wish to make.
The OSTree deploy root is "${OSTREE_DEPLOY_ROOT}"

IMPORTANT: after reboot, create a user account with the same username as your current one ($USER)

To reboot run
\`\`\`
systemctl reboot
\`\`\`
EOF
