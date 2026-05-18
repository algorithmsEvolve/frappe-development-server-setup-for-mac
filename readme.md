# Frappe Docker Development

This repo starts a local Frappe development stack with Docker. New developers should use the wizard first. The wizard creates the environment file, chooses safe ports, starts Docker Compose, optionally copies an SSH key into the Frappe container, and then opens the Frappe container shell.

## Prerequisites

Install these first:

- Git
- Docker Desktop on Windows or macOS
- Docker Engine and Docker Compose on Linux

For Windows users, run this repo from WSL, not from `C:\...`. Docker + Frappe is much faster when the project lives inside the WSL filesystem, for example under `~/codes`.

Optional WSL memory limit:

```powershell
wsl --shutdown
notepad "$env:USERPROFILE/.wslconfig"
```

Example `.wslconfig`:

```ini
[wsl2]
memory=3GB
processors=4
```

## Quick Start

Clone this repo and enter it:

```bash
git clone <THIS_REPO_URL> <PROJECT_NAME>-docker
cd <PROJECT_NAME>-docker
```

Run the wizard:

```bash
./setup-frappe-dev.sh
```

Answer the questions. Most people can accept the defaults.

The wizard will:

- ask for a project name
- ask for the Frappe version
- find available Frappe and Socket.IO ports
- find an unused Docker subnet
- optionally copy an SSH key into the Frappe container
- optionally create a custom SSH host config inside the Frappe container
- create `.env.<PROJECT_NAME>`
- create `<PROJECT_NAME>-docker/`
- run Docker Compose
- open a shell inside `frappe-<PROJECT_NAME>`

## Initialize Frappe

When the wizard opens the Frappe container, run the startup script it shows.

For example, for Frappe v16:

```bash
source frappe-bench-startup-v16.sh
```

Use the script that matches the Frappe version you selected:

```bash
source frappe-bench-startup-v12.sh
source frappe-bench-startup-v13.sh
source frappe-bench-startup-v14.sh
source frappe-bench-startup-v15.sh
source frappe-bench-startup-v16.sh
```

Important: use `source`, not `bash`. The startup scripts update shell paths for tools like Node, Python, pyenv, and bench.

The startup scripts are stored in this repo under `frappe-startup-scripts/`, but Docker mounts them into the container as `/workspace/frappe-bench-startup-v*.sh`. That is why the command inside the container stays simple.

## After Setup

After the startup script finishes, your Frappe bench is in:

```bash
/workspace/frappe-bench
```

Common commands:

```bash
cd /workspace/frappe-bench
bench start
```

The site name is set by the wizard and stored in the container as `$SITE_NAME`.

## Optional: Install ERPNext

Run these inside the Frappe container after the startup script finishes:

```bash
cd /workspace/frappe-bench
bench get-app --branch version-16 erpnext https://github.com/frappe/erpnext.git
bench --site "$SITE_NAME" install-app erpnext
```

Use the ERPNext branch that matches your Frappe version, for example `version-14`, `version-15`, or `version-16`.

## Optional: Install A Project App

For HTTPS Git URLs:

```bash
cd /workspace/frappe-bench
bench get-app https://example.com/myapp.git
bench --site "$SITE_NAME" install-app myapp
```

For SSH Git URLs:

```bash
cd /workspace/frappe-bench
bench get-app git@example.com:group/myapp.git
bench --site "$SITE_NAME" install-app myapp
```

If the SSH URL needs a custom port or host alias, let the wizard create a custom SSH host config when it asks. The wizard writes the config only inside the Frappe container.

Example custom SSH config values for a Git server that uses a custom SSH port:

```text
Host: git.example.com
HostName: git.example.com
Port: 2222
```

The wizard will use the copied key automatically as `IdentityFile` and set `IdentitiesOnly yes`.

## Re-enter An Existing Container

If the stack is already running and you only need to enter the Frappe container:

```bash
docker exec -e "TERM=xterm-256color" -it frappe-<PROJECT_NAME> bash
```

If the stack is stopped:

```bash
docker compose --env-file ./.env.<PROJECT_NAME> up -d
docker exec -e "TERM=xterm-256color" -it frappe-<PROJECT_NAME> bash
```

Older systems may use:

```bash
docker-compose --env-file ./.env.<PROJECT_NAME> up -d
```

## Working With Code

Your code lives inside:

```text
<PROJECT_NAME>-docker/frappe-bench/apps
```

On WSL, open the repo or apps folder with VS Code:

```bash
code .
```

From Windows File Explorer, WSL files are visible under:

```text
\\wsl$
```

## Multiple Projects

One repo directory should run one project stack. For another project, clone this repo into another directory and run the wizard again.

The wizard tries to avoid port and Docker subnet conflicts automatically.

## Import Data From Another Instance

1. Install the same apps locally that exist on the source instance.
2. Download a database backup from the source instance.
3. Put the uncompressed `.sql` file inside `<PROJECT_NAME>-docker/`.
4. Enter the Frappe container.
5. Import the database:

```bash
mysql -uroot -proot -h mariadb-<PROJECT_NAME> erpnext < backup.sql
cd /workspace/frappe-bench
bench migrate
```

## Troubleshooting

### Docker is not running

Start Docker Desktop or the Docker daemon, then run the wizard again.

### Port conflict

Run the wizard again and choose re-scan on the network screen, or manually choose another port range.

### Wrong project name

Stop the stack, remove the generated env/workspace for that test project, then run the wizard again:

```bash
docker compose --env-file ./.env.<PROJECT_NAME> down
rm -rf .env.<PROJECT_NAME> <PROJECT_NAME>-docker
```

### `Database erpnext already exists` or `Access denied for user erpnext`

This usually means the wizard or startup script was run again while the old MariaDB Docker volume still existed. The workspace may be new, but the MariaDB database files can still be old.

Run the wizard again. If it detects an existing MariaDB volume, choose the reset option only when you want a clean local database for this stack.

Resetting the MariaDB volume deletes local databases for this Docker stack. It does not delete your repo files, `.env.<PROJECT_NAME>`, SSH keys, or app source code.

### Startup script says `bash\r` or has Windows line-ending errors

Inside the Frappe container:

```bash
sudo apt update
sudo apt install dos2unix
dos2unix /workspace/frappe-bench-startup-v*.sh
```

This should be rare because the scripts are mounted from the repo.

### SSH clone fails

Check these:

- the correct key was selected in the wizard
- the public key is added to GitHub/GitLab
- the wizard custom SSH host config matches the Git host and port
- the app Git URL matches the SSH host alias

Inside the Frappe container:

```bash
ls -la /home/frappe/.ssh
cat /home/frappe/.ssh/config
ssh -T git@example.com
```

Replace `git@example.com` with the host you configured.

### Need to inspect Docker names

```bash
docker ps
docker network ls
docker inspect frappe-<PROJECT_NAME>
```

## Manual Reference

The wizard replaces the old manual setup. If you need to debug by hand, these are the core pieces:

- `.env.<PROJECT_NAME>` controls names, ports, and Docker subnet.
- `docker-compose.yml` mounts `<PROJECT_NAME>-docker/` into the Frappe container as `/workspace`.
- Startup scripts live on the host in `frappe-startup-scripts/`.
- Startup scripts appear inside the container as `/workspace/frappe-bench-startup-v*.sh`.
- The Frappe container name is `frappe-<PROJECT_NAME>`.
- The MariaDB container name is `mariadb-<PROJECT_NAME>`.
