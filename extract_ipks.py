#!/usr/bin/env python3
"""Extract data payloads from LuCI .ipk files into a staging dir and bundle
them for `tar -xzf -C /` on the device.

README (AIRTEL-A0D450-ODU-README.md) §5: this firmware's opkg reports every
installed package as having no valid architecture, so package installation is
done by extracting the data.tar payload of each .ipk directly.

luci-app-firewall is intentionally skipped: the vendor firmware has no
`firewall` package, so its dependency can never resolve.
"""
import glob
import io
import os
import subprocess
import sys
import tarfile

SRC = "/home/dc/Documents/airtel-zyxel-4101/luci packets"
STAGE = "/tmp/odu-luci-stage"
BUNDLE = "/tmp/odu-luci-files.tar.gz"
SKIP = {"luci-app-firewall"}  # README §5/§12: firewall package absent from firmware

def safe_extract(tar, path):
    try:
        tar.extractall(path, filter="data")
    except (TypeError, tarfile.FilterError):
        tar.extractall(path)

os.makedirs(STAGE, exist_ok=True)
for ipk in sorted(glob.glob(os.path.join(SRC, "*.ipk"))):
    name = os.path.basename(ipk)
    if any(name.startswith(s) for s in SKIP):
        print(f"SKIP  {name} (no firewall package in vendor firmware)")
        continue
    with tarfile.open(ipk, "r:*") as outer:
        member = next(m for m in outer.getmembers()
                      if os.path.basename(m.name).startswith("data.tar"))
        with tarfile.open(fileobj=io.BytesIO(outer.extractfile(member).read()),
                          mode="r:*") as inner:
            safe_extract(inner, STAGE)
    print(f"staged {name}")

subprocess.run(["tar", "czf", BUNDLE, "-C", STAGE, "."], check=True)
print(f"\nbundle: {BUNDLE} ({os.path.getsize(BUNDLE)} bytes)")

for line in subprocess.run(["find", STAGE, "-type", "f"], capture_output=True,
                           text=True).stdout.splitlines():
    print("  " + line[len(STAGE):])
