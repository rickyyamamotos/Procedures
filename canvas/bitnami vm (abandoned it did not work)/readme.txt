                    Bitnami Canvas LMS Stack 2018.06.02.26-0
                  ==============================


1. OVERVIEW

The Bitnami Project was created to help spread the adoption of freely available, 
high quality, open source web applications. Bitnami aims to make it easier than 
ever to discover, download and install open source software such as document and 
content management systems, wikis and blogging software.

You can learn more about Bitnami at https://bitnami.com

Canvas LMS is the new, open-source learning management system that's 
revolutionizing the way we educate. Easy to learn, easy to use. 

You can learn more about CanvasLMS at http://www.canvaslms.com

The Bitnami Canvas LMS Stack is an installer that greatly simplifies the
installation of CanvasLMS and runtime dependencies. It includes ready-to-run
versions of Apache, PostgreSQL and Ruby On Rails.

Bitnami Canvas LMS Stack is distributed for free under the Apache 2.0 license. 
Please see the appendix for the specific licenses of all open source components 
included.

You can learn more about Bitnami Stacks at https://bitnami.com/stacks/

2. FEATURES

- Easy to Install

Bitnami Stacks are built with one goal in mind: to make it as easy as
possible to install open source software. Our installers completely automate
the process of installing and configuring all of the software included in
each Stack, so you can have everything up and running in just a few clicks.

- Independent

Bitnami Stacks are completely self-contained, and therefore do not interfere
with any software already installed on your system. For example, you can
upgrade your system's PostgreSQL or Apache without fear of 'breaking' your
Bitnami Stack.

- Integrated

By the time you click the 'finish' button on the installer, the whole stack
will be integrated, configured and ready to go. 

- Relocatable

Bitnami Stacks can be installed in any directory. This allows you to have
multiple instances of the same stack, without them interfering with each other. 

3. COMPONENTS

Bitnami Canvas LMS Stack ships with the following software versions:

  - CanvasLMS 2018.06.02.26
  - Apache 2.4.33
  - PostgreSQL 9.6.7
  - PHP 7.1.18
  - Ruby 2.4.4
  - Rails 5.0.2
  - Redis 3.2.9
  - Node.js 8.11.3
  - phppgmyadmin 5.1

4. REQUIREMENTS

To install Bitnami Canvas LMS Stack you will need:

    - Intel x86 or compatible processor
    - Minimum of 4096 MB RAM 
    - Minimum of 150 MB hard drive space
    - TCP/IP protocol support
    - Compatible operating systems:
      - An x86 or x64 Linux operating system.

5. INSTALLATION

The Bitnami Canvas LMS Stack is distributed as a binary executable installer.
It can be downloaded from:

https://bitnami.com/stacks/

The downloaded file will be named something similar to:

bitnami-canvaslms-2018.06.02.26-0-linux-installer.run on Linux or
bitnami-canvaslms-2018.06.02.26-0-linux-x64-installer.run on Linux 64 bit.

On Linux, you will need to give it executable permissions:

chmod 755 bitnami-canvaslms-2018.06.02.26-0-linux.run

To begin the installation process, double-click on that file, and you will
be greeted by the 'Welcome' screen. Pressing 'Next' will take you to the
Component Selection screen.

The next screen is the Installation Folder, where you can select where Bitnami 
stack will be installed. If the destination directory does not exist, it will 
be created as part of the installation. 

The next screen will prompt you for data necessary to create the initial
<Username> user: 

Username and password: You will use this information to log-in into the
Administrative interface. The password you provide here will also be used to
protect other parts of the installation. Please see the section named
"Usernames and Passwords" later in this document.

Email address: Your email address.

The next screen will vary, depending on whether the ports needed by the
bundled Apache and PostgreSQL are already taken. The default listening port for
Apache is 80 and for PostgreSQL is 5432. If those ports are already in use by 
other applications, you will be prompted for alternate ports to use.

The next screen will allow you to configure the final details of your
CanvasLMS installation:

Hostname: The hostname for your blog, such as www.example.com. This
information will be used by CanvasLMS when creating certain links. You can
use an IP address but there were login issues using different browsers. It
is advisable to use a fully qualified domain name.

Once the information has been entered, the installation will proceed to copy
the files to the target installation directory and configure the different
components. One this process has  been completed, you will see the
'Installation Finished' page. You can choose to launch Bitnami CanvasLMS
Stack at this point. If you do so, your default web browser will open and
display the Welcome page for the Bitnami CanvasLMS Stack. 

If you received an error message during installation, please refer to
the Troubleshooting section.

The rest of this guide assumes that you installed Bitnami CanvasLMS
Stack in /home/user/canvaslms-2018.06.02.26-0 on Linux.

6. STARTING AND STOPPING BITNAMI CANVASLMS STACK

To start/stop/restart application on Linux you can use the included ctlscript.sh
utility, as shown below:

       ./ctlscript.sh (start|stop|restart)
       ./ctlscript.sh (start|stop|restart) postgres
       ./ctlscript.sh (start|stop|restart) redis
       ./ctlscript.sh (start|stop|restart) apache

  start      - start the service(s)
  stop       - stop  the service(s)
  restart    - restart or start the service(s)


That will start Apache service. Once started, you can open your
browser and access the following URL on Linux:

http://127.0.0.1:80/

If you are accessing the machine remotely, you will need to replace
127.0.0.1 with the appropriate IP address or hostname.

7. DIRECTORY STRUCTURE

The installation process will create several subfolders under the main
installation directory:

	apache2/: Apache Web server.
	ruby/: Ruby language.
	redis/: Redis server.
	postgresql/: PostgreSQL Database.
        php/: PHP language
	apps/
	  phppgmyadmin/: phppgmyadmin application folder
	  canvaslms/: CanvasLMS application folder
	    conf/: CanvasLMS Apache configuration files
	    htdocs/: CanvasLMS application files

8. DEFAULT USERNAMES AND PASSWORDS

The CanvasLMS Administrative user and password are the ones you set at
installation time. You need to login with the email you introduced.

PostgreSQL <Username> user is called 'postgres', and its password is the same as the
CanvasLMS Administrative user password.

The default PostresSQL non-root account used to access the database is named
'bn_canvaslms', and its password is randomly generated during installation. 

9. TROUBLESHOOTING

This version of the Bitnami CanvasLMS stack is a preview version, and as
such, may contain a number of bugs and be a little bit rough around the
edges. We are working on the next release, which will contain several
improvements along with expanded documentation. In addition to the resources
provided below, we encourage you to post your questions and suggestions at:

https://community.bitnami.com/

We also encourage you to sign up for our newsletter, which we'll use to
announce new releases and new stacks. To do so, just <Site> at:
https://bitnami.com/newsletter.

9.1 Installer

# Installer Payload Error

If you get the following error while trying to run the installer from the
command line:

"Installer payload initialization failed. This is likely due to an
incomplete or corrupt downloaded file" 

The installer binary is not complete, likely because the file was
not downloaded correctly. You will need to download the file and
repeat the installation process. 

9.2 Apache

If you find any problem starting Apache, the first place you should check is
the Apache error log file:

/home/user/canvaslms-2018.06.02.26-0/apache2/logs/error.log on Linux or

10. LICENSES

CanvasLMS is distributed under the AGPLv3,
which is located at http://www.gnu.org/licenses/agpl.html

Redis is distributed under the terms of the three clause BSD license,
wich is located at 
http://redis.io/topics/license

Apache Web Server is distributed under the Apache License v2.0, which
is located at http://www.apache.org/licenses/LICENSE-2.0

PostgreSQL is distributed under the PostgreSQL License, which is
located at https://www.postgresql.org/about/licence/

Ruby is released under the two clause BDS license, wich is located at
https://www.ruby-lang.org/en/about/license.txt

Rails is released under the MIT license, which is located 
http://www.opensource.org/licenses/mit-license.php

Rake is released under the Ruby License, which is located at
http://www.ruby-lang.org/en/LICENSE.txt

OpenSSL is released under the terms of the Apache License, which is
located at http://www.openssl.org/source/license.html

Ncurses is released under the MIT license, which is located at
http://www.opensource.org/licenses/mit-license.php

Readline is released under the GPL license, which is located at
http://www.gnu.org/copyleft/gpl.html

Zlib is released under the zlib License (a free software license/compatible 
with GPL), which is located at http://www.gzip.org/zlib/zlib_license.html

Libiconv is released under the LGPL license, which is located at
http://www.gnu.org/licenses/lgpl.html

Expat is released under the MIT license, which is located at
http://www.opensource.org/licenses/mit-license.php

Neon is released under the GNU General Public License, which is located at
http://www.gnu.org/copyleft/gpl.html

RedCloth is released under the BSD License, which is located at
http://www.opensource.org/licenses/bsd-license.php

Rmagick is released under the MIT license, which is located 
http://www.opensource.org/licenses/mit-license.php

Freetype is released under The Freetype Project License, that is located at
http://freetype.sourceforge.net/FTL.TXT
