# Automated Installation Scripts

**NOTE**! Always read the contents of any script before executing it on your own machine!

## Scripts

- `a-setup.sh`: Fetches all the other scripts and adds permissions to execute them.
- `b-docker.sh`: Installs Docker and evaluates the group membership again to gain access to the Docker socket.
- `c-run.sh`: Controls the two remaining scripts.
- `d-deps.sh`: Installs the dependencies for the runner set. Installs Go, kubectl, kind and Helm.
- `e-clusters.sh`: Creates the Kind cluster and installs the runner set.
- `f-clean.sh`: Deletes the scripts from your machine.

## Execution order:

### `a-setup.sh`

```bash
./a-setup.sh
```

### `b-docker.sh`

```bash
./b-docker.sh
```

### `c-run.sh`

```bash
GO_VERSION=1.24.4
KIND_VERSION=0.29.0
GITHUB_CONFIG_URL="https://github.com/user/repo"
GITHUB_PAT="<PAT>"
./c-run.sh $GO_VERSION $KIND_VERSION $GITHUB_CONFIG_URL $GITHUB_PAT
```
