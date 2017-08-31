#!/bin/bash

GIGPATCHDIR="$(pwd)/patches"

mkdir -m 600 -p "${ROOTDIR}"/root/.ssh
rm -f "${ROOTDIR}"/root/.ssh/authorized_keys

if [ "${BUILDMODE}" = "debug" ]; then
    for user in $(curl https://api.github.com/orgs/zero-os/members | awk -F'"' '/login/ { print $4 }'); do
        echo "[+] authorizing ssh key: $user"
        curl -s https://github.com/${user}.keys >> "${ROOTDIR}"/root/.ssh/authorized_keys
    done

    chmod 600 "${ROOTDIR}"/root/.ssh/authorized_keys
fi

if [ "${BUILDMODE}" = "release" ]; then
    echo "[+] patching kernel for secure boot restriction"

    pushd "${WORKDIR}/linux-4.9.35/"

    if [ ! -f .patched_linux-secureboot-restriction.patch ]; then
        patch -p1 < "${GIGPATCHDIR}/linux-secureboot-restriction.patch"
        touch .patched_linux-secureboot-restriction.patch
    fi

    popd
fi
