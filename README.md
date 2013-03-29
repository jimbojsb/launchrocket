LaunchRocket
============

A Mac PrefPane to manage launchd services. While not specifically restricted to Homebrew-installed services, that is the use case I built it for.

<img src="https://raw.github.com/jimbojsb/launchrocket/master/LaunchRocket/rocket.png" height="100" width="100"/>


How to use
==========
With a service that already has a .plist for launchd:
* create a symlink for the plist inside /usr/local/etc/launchrocket
  * edit the plist to have a new dictionary value named "launchrocket"
  * add a new key in the launchrocket dictionary called "name" and give your service a name
  * add a new key in the launchrocket dictionary called "image" and either use one of the built-in .png files or provide an absolute path on disk to a 150x50 .png file
    * build in images:
      * postgres.png
      * mysql.png   
      * nginx.png
      * php-fpm.png
      * beanstalkd.png    
      * mongodb.png
      * redis.png
