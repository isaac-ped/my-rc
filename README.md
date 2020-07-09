# MY-RC

This is a repository for my configuration files.

I am tired of redoing everthing when I get a new machine.

This might help.


## Install

use:
```shell
zsh shell/install.sh
```
to install for zsh, or
```shell
bash shell/install.sh
```
to install for bash


## better-ssh

The shellrc file sets `alias ssh=better-ssh`

To use normal ssh afterwards, type `\ssh` instead.

Running the install script will create a file in `~/.ssh/host-config.yml` that
sets a default host for better-ssh. Other entries set patterns that apply
when using `better-ssh` (including `sshh` for ssh-here), `copyup`, or `copydown`

A sample:


```yaml
# Automatically enter into docker container
.docker-entrypoint: &DOCKER >-
    cd ~/my/scripts/and/stuff/ && docker run -it bash

# my-server2 will automatically run the docker command upon ssh-ing
my-server[1-4]:
    entrypoint: *DOCKER

# my-server1-dev will also run docker on better-ssh, will redirect to my-server-1,
# and also sshh will place you in the same directory as pwd but relative to ~/dev
# and copyup and copydown will use the same path
(.*)-dev:
    hostname: '\1'
    root-dir: ~/dev

# By default, ssh to my-server-1 (better-ssh uses '-' as the default value)
-(dev)?:
    hostname: my-server-1

```
