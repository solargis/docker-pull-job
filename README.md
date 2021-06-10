# docker-pull-job

## Environment options

| Name | Default value | Description |
|--|--:|--|
| **SYNC_KNOWN_HOTS** | |Public ID with public keys of knwon hosts. Optional. Every new host will be automatically added.
| **SYNC_PRIVATE_KEY** | | Client identification private key.
| **SYNC_SOURCE** | | Source like [user@]host[:/path].
| **SYNC_SOURCE_PORT** | `22` | Port used for SSH connection.
| **SYNC_TARGET** | `/data/` | Target where are data synchronized
| **PUID** | `0` | User ID of running process.
| **PGID** | `0` | Group ID of running process.
| **RSYNC_INCLUDE** | | New-line separated list of includion pattern
| **RSYNC_EXCLUDE** | | New-line separated list of excludion pattern.
