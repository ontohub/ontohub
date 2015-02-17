# Developer Installation on Mac OS X Lion and up

*This guide is for Lion (10.7) and up... especially Mountain Lion (10.8)*

## Homebrew

Using Homebrew on a development system is always a good idea.
Max Howell actually documented the installation very well
in his [guide](http://mxcl.github.io/homebrew/).

But here is what you have to do:

- `ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"`
- After this succeeded you should execute `brew doctor` to learn
  what you have to do next.

## Ruby (rbenv and ruby-build)

- `brew install rbenv ruby-build`
- `rbenv install 2.0.0-p247`
  The ruby-version can and should be replace with
  the actually current version of ruby.

Now we just have to tell the shell to use rbenv
to determine the Ruby Version. As **bash** is the
default-shell on Mac OS X these are the snippets:

- `echo 'export RBENV_ROOT=/usr/local/var/rbenv' >> ~/.bash_profile`
- `echo 'eval "$(rbenv init -)"' >> ~/.bash_profile`

If you are using **zsh**, just replace the *.bash_profile* with
*.zshrc* (or the config file for your shell, if you are using
different one).

### rbenv aliases

As we use the *.ruby-version* to specify ontohubs ruby version,
you might need rbenv aliases in order to use the **right**
local version.

- `brew install rbenv-aliases`
- `rbenv alias --auto`

## PostgreSQL

Of course you can install postgresql via the *.dmg*-based installer.
But here we will explain how to use **homebrew** to achieve that goal.
*(First and foremost because it makes it easier to deinstall postgresql
or to update it.)*

- `brew install postgresql`

Now we have to add postgresql to **launchd**, the launch-daemon used
in OSX, to ensure that postgresql starts with the system.

- `ln -sfv /usr/local/opt/postgresql/homebrew.mxcl.postgresql.plist  ~/Library/LaunchAgents`
- `launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist`

Mac OS X Version equal or higher to 10.7 (Lion) are shipped
with postgresql-libraries. In order to use our homebrew
version we have to do one of three things.

1. Delete the postgresql-specific files in */usr/bin*
2. In *.profile* (At the beginning): `export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/texbin`
3. In *.profile* (anywhere **preferred**): `export PATH=/usr/local/bin:$PATH`

After this we should create the config directory for postgres:

- `initdb /usr/local/var/postgres -E utf8`

Now when you use `psql` you should be connected to the
database (`\q` lets you quit).

Now we have to create the user to be used by ontohub in development:

- `createuser -d -w -s postgres`

You'll also (probably) need to create the two databases:

- `createdb ontohub_development`
- `createdb ontohub_test`

## gems

Switch to the directory where you clone ontohub.

We use **capybara-webkit** for integration testing. This gem needs a **qt**-Engine
on the system, so we will have to install one:

- `brew install qt`

Now we can actually start installing the necessary gems:

- `gem install bundler`
- `bundle install`
  - If it fails because of a **mysql** dependency, remove that dependency from the *Gemfile*.
  - and try again...

## solr

On Lion and up Java isn't installed automatically anymore.
To force a java installation issue the following command:

- `java –version`

After this a window will appear which will prompt the java installation.

## redis

In order for resque to work, we need to install redis.
We use homebrew for that:

- `brew install redis`

Ensure that redis is managed by launchd:

- `ln -sfv /usr/local/opt/redis/*.plist ~/Library/LaunchAgents`
- `launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist`

a call to `redis-cli` should successfully connect you to the database.
*exit* with `exit`.

## hets

The Heterogenous Toolset is needed to perform Operations during Ontology import.
You can fetch it from its [Uni Bremen Homepage][hets_link]. Just download
the most current version (at the time of writing: [2013-06-28][hets_current_dmg]), open
it and drag the Hets file (actually the Hets.app directory) into your Applications directory.

**Important:** As of January 30th 2014 the hets builds provided by the Uni Bremen homepage
will **only** work with Mac OS X Mavericks (10.9) and up.

Furthermore, we now have a homebrew package for hets, which will build hets from scratch.

We can install it like this:

```
brew tap 0robustus1/hets
brew install hets --with-wrapper
```

If there is a new version released you can update hets through the homebrew process (`brew upgrade`).

## setup

In ontohub directory:

- `rake db:migrate:reset`
- `rake sunspot:solr:start`
- `rake resque:work`

Now you should be ready...

## Optional: pow

Managing multiple rails applications in development can be quite
of a hassle. So for that, just use [**pow**](http://pow.cx/).

You can either install it via `curl get.pow.cx | sh` or
you can just use homebrew again: `brew install pow`.

Now we have to do the same thing to pow, which we did to the shell:
adjust the PATH. This command will take care of that:

- `echo 'export PATH=$(rbenv root)/shims:$(rbenv root)/bin:$PATH' >> ~/.powconfig`

A simple `gem install powder` actually makes it even easier,
because when in an application directory you can perform
`powder link` once and you can access your application
by http://application_folder-name.dev in your browser

Usually pow restarts applications when needed, but you can
force it with `powder restart`.

[hets_link]: http://www.informatik.uni-bremen.de/agbkb/forschung/formal_methods/CoFI/hets/intel-mac/dmgs/
[hets_current_dmg]: http://www.informatik.uni-bremen.de/agbkb/forschung/formal_methods/CoFI/hets/intel-mac/dmgs/Hets-2013-06-28.dmg
