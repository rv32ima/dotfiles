#!/usr/bin/env python3
import json
import os

net_dir = "/sys/class/net"
result = {}

for iface in sorted(os.listdir(net_dir)):
    if iface.startswith("swp"):
        with open(os.path.join(net_dir, iface, "address")) as f:
            result[iface] = f.read().strip()

print(json.dumps(result, indent=2))
