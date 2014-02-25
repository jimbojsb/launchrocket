LaunchRocket
============

<a href="https://flattr.com/submit/auto?user_id=jimbojsb&url=http%3A%2F%2Fgithub.com%2Fjimbojsb%2Flaunchrocket" target="_blank"><img src="https://api.flattr.com/button/flattr-badge-large.png" alt="Flattr this" title="Flattr this" border="0"></a>

A Mac PreferencePane for managing services with launchd/launchctl. LaunchRocket was primarily created for managing various services installed by Homebrew, though it should work with most launchd-compatible plists.

Of particular note is the ability to run some services as root. With Homebrew, most services can simply run as the current user, and this is the desired behavior for a development environment. However, some services (dnsmasq) require being bound to privileged ports, and others (nginx, apache) don't require it, but might in some circumstances. For example, many times it's just easier to run Apache on port 80 and 443 than to deal with code that might not like port numbers in the URLs. I recommend you only run things as root if you absolutely must, to get them working properly.

<img src="https://raw2.github.com/jimbojsb/launchrocket/master/screenshots/LaunchRocket.png">

Features
--------
* **Green/Yellow/Red status indicators**
    * Green - launchctl reports process is running
    * Yellow - LaunchRocket is current executing or waiting on a start/stop command
    * Red - launchctl reports process is not running
* **Start/Stop buttons**
    * Dynamically updates state based on running state of service
* **As Root option**
    * Checking this will cause launchrocket to use root privileges to access launchctl
    * Checking this will NOT restart a running service automatically as root
    * LaunchRocket will prompt you to authenticate and elevate privileges
        * We ask for credentials as seldom as possible, however when launchrocket loads, it checks the current status of every service it's tracking. This means that if you have services running as root, it will prompt you for credentials immediately on load, as an unprivileged account cannot even list launchd services run by a privileged one
* **Preferences file**
    * LaunchRocket stores a preferences file in ~/Library/Preferences/com.joshbutts.launchrocket.plist

Installing
------------

**Requirements**

* MacOS 10.7 or above
* Gatekeeper must be set to allow all apps to run (See issues [#3][] and [#25][])

[#3]: https://github.com/jimbojsb/launchrocket/issues/3
[#25]: https://github.com/jimbojsb/launchrocket/issues/25

The binary release should work on Mac OSX 10.7.0 and above, and might even work on older versions, though it has not been tested on those. The latest builds are compiled on 10.9.1 and targeted at 10.7 in xCode.

**Direct Download**

Download and unzip the binary release from the [release page](https://github.com/jimbojsb/launchrocket/releases)

*Note: This zip was created with Finder's "Compress" utility. I've heard that there are issues unzipping it with other tools. I will try to provide a more compatible zipfile on the releases page. ([related info here](http://stackoverflow.com/questions/107903/how-to-create-a-zip-file-in-the-same-format-as-the-finders-compress-menu-item))*

**Homebrew**

Launchrocket is available as a Cask for [Homebrew Cask](https://github.com/phinze/homebrew-cask).

    brew tap jimbojsb/launchrocket
    brew cask install launchrocket


Further information about running as root
-----------------------------------------
LaunchRocket uses an AppleScript helper to obtain root privileges. This is a hacky way of accomplishing it, but it avoids having to actually install a privileged helper outside of the prefpane bundle with SMJobBless and is WAY simpler. This is not the most secure approach and does not use code signing. As such, it is possible that if LaunchRocket's AppleScript helper has cached your privileged authorization, another application maliciously address that helper and request it execute other commands with root level privileges. I considered this a reasonable tradeoff between security, usability and code simplicity. Closing System Preferences or simply switching back to the main view will terminate the helper and drop privileges. If you don't have anything running as root, no programs can request that the helper execute code with privilieges without triggering a credential prompt.

Contributing
------------
Found a bug? File an issue and I'll take a look. Pull requests are welcome.
