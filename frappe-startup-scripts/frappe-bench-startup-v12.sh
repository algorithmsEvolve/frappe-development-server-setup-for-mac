#!/usr/bin/env bash

sudo chown frappe:frappe ../workspace

echo "alias ll='ls -al'" >> ~/.bashrc
alias ll='ls -al'

sudo apt update

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

echo "installing v14"
source ~/.nvm/nvm.sh && nvm deactivate && nvm uninstall 16 && nvm install 14 && nvm use 14 && nvm alias default 14 && nvm alias default node

npm install -g yarn

# install node-sass
npm install -g node-sass

# yes we need to install bz2 library
sudo apt-get install libbz2-dev -y

# then we have to update the path for our shell
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
echo 'eval "$(pyenv init --path)"' >> ~/.profile

echo 'if command -v pyenv >/dev/null; then eval "$(pyenv init -)"; fi' >> ~/.bashrc
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
pyenv init --path

# make sure we have the right python, this should compile new python with bz2
pyenv install -v 3.7.12 -f
pyenv install -v 2.7.18 -f

# now set the new python as global
pyenv global 3.7.12 2.7.18

pip install frappe-bench

# sometimes bench won't work since it's not linking to bin/bench
# rm /home/frappe/.local/bin/bench
# ln /home/frappe/.pyenv/shims/bench /home/frappe/.local/bin/bench

pip install markupsafe==2.0.1

# initialize bench
bench init --skip-redis-config-generation --python "/home/frappe/.pyenv/shims/python" --frappe-branch version-12 frappe-bench --verbose
cd frappe-bench
bench set-mariadb-host $MARIADB_CONTAINER_NAME
bench set-redis-cache-host $REDIS_CACHE_CONTAINER_NAME:6379
bench set-redis-queue-host $REDIS_QUEUE_CONTAINER_NAME:6379
bench set-redis-socketio-host $REDIS_SOCKETIO_CONTAINER_NAME:6379

# set line endings
cd apps/frappe/
git config core.autocrlf input
git config core.filemode false

# create a new site
cd /workspace/frappe-bench
bench new-site $SITE_NAME --mariadb-root-password root --admin-password administrator --no-mariadb-socket --db-name erpnext
bench --site $SITE_NAME set-config developer_mode 1
bench --site $SITE_NAME clear-cache
