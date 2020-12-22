#!/usr/bin/env bash

set -

base_dir=$(readlink -nf $(dirname $0)/../..)
source "$base_dir/lib/prelude_apply.bash"
source "$base_dir/etc/settings.bash"

if [[  "${DISTRIB_CODENAME}" == "bionic" ]]; then
    exit 0
fi

mkdir "$chroot/usr/src/ixgbevf-4.6.3"

tar -xzf "$assets_dir/ixgbevf-4.6.3.tar.gz" \
  -C "$chroot/usr/src/ixgbevf-4.6.3" \
  --strip-components=1

cp $assets_dir/usr/src/ixgbevf-4.6.3/dkms.conf $chroot/usr/src/ixgbevf-4.6.3/dkms.conf

pkg_mgr install dkms

kernelver=$(ls -rt "$chroot/lib/modules" | tail -1)
run_in_chroot "$chroot" "dkms -k ${kernelver} add -m ixgbevf -v 4.6.3"
run_in_chroot "$chroot" "dkms -k ${kernelver} build -m ixgbevf -v 4.6.3"
run_in_chroot "$chroot" "dkms -k ${kernelver} install -m ixgbevf -v 4.6.3"

run_in_chroot "$chroot" "dracut --force --kver ${kernelver}"
