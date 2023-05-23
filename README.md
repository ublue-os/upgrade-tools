# upgrade-tools

Migration Tools

# NOTE: THIS IS ALPHA SOFTWARE

# silverblueize.sh

> a hack to install Silverblue on top of an existing Fedora Workstation install

## Steps

- install dependencies
- init ostree
- pull Fedora Silverblue
- init the ostree repo to the filesystem/disk
- deploy ostree Fedora deploy
- copy across a few files

## Use Cases

- You're an nvidia user and the traditional rpmfusion consumption model isn't working out for you, but you want to stay on Fedora.
- You've decided to leave Fedora anyway for something else and you have nothing to lose if you try this new fangled Silverblue and/or Universal Blue on your way out. Who knows, you might like it!
- You're helping a friend and don't have time because upgrading in place is faster than restoring their user data after a clean reinstall. 
- No need to make a new USB key or download a new image manually, we'll do it on the spot for you. 

## Uncertainties

- are there remaining Fedora Workstation files install on disk? (e.g /usr/bin)
- why does it prompt for user account creation again?
- non-standard/non-default partition configs

## Cool ideas for the future

- move from Ubuntu or other traditional Linux OS
- carry across existing installed rpms as overlays
- carry across existing system installed Flatpaks

## Extra notes

- must run as root
- logs are left in `/var/log/fedora-ws2sb.log`

---

**these programs come with absolutely no warranty and you use them at your own risk**
