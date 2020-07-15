# Better-ssh
A set of scripts for simplifying ssh-life

## ~/.ssh/host-config.yml
The host config is an extension of `~/.ssh/config` that has more parameters:

```yaml
'': # Provide an empty key to have a default host
    hostname: my-fave-server.com

(.*)-tmp: # Matching is done by regular expressions
    # Use regex backreferences to modify hostnames
    hostname: \1
    # Specify a directory to treat as the default when ssh-ing or scp-ing
    root-dir: /tmp/

whattimeisitrightnow.com:
    # Specify a command to automatically run upon ssh-ing
    # (such as entering a docker container)
    entrypoint: cd my/repo && docker run -it zsh

# This entry is special, and defines custom shell shortcuts as described below
\._suffixes: ['tmp']
```

## ssh-config
A wrapper around `ymlook` for getting entries in the host config which accepts defaults.

```shell
$ ssh-config 'abc-tmp' hostname
abc

$ ssh-config '-tmp' hostname # recurses on hostname retrieval
my-fave-server.com

$ ssh-config '-tmp' root-dir # (but only on hostname retrieval)
/tmp

$ ssh-config bleb.co hostname bleb.co # Returns default if no match found
bleb.co
```

## better-ssh
Makes use of ssh-config to have a default hostname and the ability to 'ssh-here' with `-h`

The alias `sshh` is mapped to `ssh -h` for quickly sshing to pwd.

```shell
[~/my/project]$ sshh
# (ssh'es to the folder ~/my/project my-fave-server.com)

[~/my/project]$ sshh whattimeisitrightnow.com
# (ssh'es to my-fave-server.com and puts you in a docker container in the folder ~/my/project)

[~/my/project]$ sshh somewhere.com-tmp
# (ssh'es to the folder /tmp/my/project on somewhere.com)
```

### auto-functions
The values from the `._suffixes` key in the host config are used to generate `sshh` aliases
which automatically append those defaults.

For example, with the config above, `sshtmp abc.com` translates to `sshh abc.com-tmp`,
and thus `better-ssh` will respect the `-tmp` root directories or extrypoints.

(`sshtmp` alone will call `sshh -tmp`, which will cd to `pwd` on the default host)

## cpup, cpdn
Wrappers around scp that use the ssh-config, and allow copying relative to current directory

```shell
[~/my/project]$ cpdn abc.com-tmp:test.txt
# (copies /tmp/my/project/test.txt from abc.com to ~/my/project/test.txt

[~/my/project]$ cpdn my/file.txt other/place.txt
# (copies ~/my/project/my/file.txt from my-fave-server.com to ~/my/project/other/place.txt)

[~/my/project]$ cpup -r my/dir/ whattimeisitrightnow.com:
# (copies the directory ~/my/project/my/dir/ to ~/my/project/my/dir/ on whattimeisitrightnow.com)
