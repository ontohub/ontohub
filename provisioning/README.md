# Ontohub Provisioning

This directory contains scripts to help install Ontohub on a variety of target systems. We use three main tools: [VirtualBox](https://www.virtualbox.org) and [Vagrant](http://www.vagrantup.com) for setting up virtual machines (optional), and [Chef](https://www.getchef.com) for installing software. They work particularly well together.

NOTE: This system is not complete. The database and service configuration have not been started yet.


# Virtual Box

Ontohub development focuses on deployment to [Ubuntu](http://www.ubuntu.com) Linux. But this guide was developed on a laptop running Mac OS X using VirtualBox to host Ubuntu virtual machines. This is particularly convenient for testing, because a new virtual machine can easily be set up from scratch and deleted when finished. VirtualBox is meant for development, not deployment.

Install VirtualBox and the Extension Pack from: <https://www.virtualbox.org/wiki/Downloads>. Version 4.3.16 was used for this guide.


# Vagrant

Vagrant is very useful for scripting VirtualBox virtual machines, but also works with various cloud hosting providers -- collectively called "boxes". Version 1.6.5 was used for this guide, along with some critical plugins. Install Vagrant from <http://www.vagrantup.com/downloads.html> and install these two plugins:

    vagrant plugin install vagrant-vbguest
    vagrant plugin install vagrant-librarian-chef

Another nice thing about Vagrant is that it will automatically run Chef to provision software on the new box. But you can also use Chef by itself.

In a terminal, change to this directory, then use these commands to start, log in to, then destroy a box:

    vagrant up
    vagrant ssh
    vagrant destroy

The `Vagrantfile` contains all the configuration.


# Chef

Chef is a tool for provisioning software. It abstract away from many of the differences between systems and allows for repeatable, predictable installations. Chef "cookbooks" contain instructions for installing and configuring a particular application. We define two cookbooks, for hets and ontohub, and use [Librarian-Chef](https://github.com/applicationsonline/librarian-chef) to fetch some other cookbooks that ours depend on.

The main Librarian-Chef configuration is in the `Cheffile`, which gives a source for cookbooks to fetch into the `cookbooks`. Our own cookbooks have separate directories with a `metadata.rb` and `recipes/default.rb` file. The `metadata.rb` file provides information and specified dependencies, while the `defalt.rb` file contains the instructions for Chef.

TODO: code for running Chef by itself, without Vagrant.



