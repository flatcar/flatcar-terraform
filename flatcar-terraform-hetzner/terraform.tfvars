# Variables

# Server names are [cluster]-[machine #1], [cluster]-[machine #2] ... etc.
cluster_name = "flatcar"

# Uses server1.yaml.
machines = ["server1"]

# One of nbg1, fsn1, hel1, or ash
location = "fsn1"

# Smallest instance size
server_type = "cx11"

# Additional SSH keys for core user.
# ssh_keys = [ "...", "..." ]

# One of "lts", "stable", "beta", or "alpha"
release_channel = "stable"
