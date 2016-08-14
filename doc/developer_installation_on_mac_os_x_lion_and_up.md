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

As the *caveats*-section suggests we need to also start the
service and add to the ones, that are supposed to be automatically
started on boot. `brew services start postgresql` takes care of this.

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

You'll also need to create the two databases:

- `bundle exec rake db:create`, will create these databases:
  - *ontohub_development*
  - *ontohub_test*

## phantomjs
We use `phantomjs` as a headless javascript-enabled browser for our integration
tests. You only need to install the package:
```
brew install phantomjs
```

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
  
## java

A few tools need java-support. Specifically elasticsearch and the *mandatory* provers
pellet and owltools have been built upon java. This means that java needs to be installed
on your system. *pellet* however isn't compatible with java8 yet, which means that we also
need to install a specific version of java:

```
brew tap caskroom/versions
brew cask install java7
```

## elasticsearch

```
brew install elasticsearch
brew services start elasticsearch
```

## redis

In order for resque to work, we need to install redis.
We use homebrew for that:

```
brew install redis
brew services start redis
```


a call to `redis-cli` should successfully connect you to the database.
*exit* with `exit`.

## hets

The Heterogenous Toolset is needed to perform Operations during Ontology import.
You can fetch it from its [Uni Bremen Homepage][hets_link]. Just download the
most current version, open it and drag the Hets file (actually the Hets.app
directory) into your Applications directory.

**Important:** As of January 30th 2014 the hets builds provided by the Uni Bremen homepage
will **only** work with Mac OS X Mavericks (10.9) and up.

However the recommended way of working with hets on Mac OS X is to use the
provided homebrew-formula.

We can install it like this:

```
brew tap spechub/hets

brew cask install xquartz

# either
brew install hets
# or
brew install hets-server
```

If there is a new version released you can update hets through the homebrew process (`brew upgrade`).
In the repository you need to configure the hets-executable path:

```
hets:
  # This is the path to the hets executable we use in `rake hets:*` and for the
  # process manager in production mode (god)

  # supply either hets-server or hets
  executable_path: /usr/local/bin/hets-server
```

## Extra executables

The SSH-Key handling requires an additional executable `data/.ssh/cp_keys` to exist.
This can be compiled easily from the supplied C-code with (in the ontohub directory)

    GIT_HOME=$(pwd)/tmp/git bundle exec rake git:compile_cp_keys

Providing the `GIT_HOME` variable is mandatory for this rake task.
It will print a message about changing permissions, but you don't need to do as the message says as long as you are in a development environment.
It is only important for securing production systems.

## setup

You can start everything needed with (in the ontohub directory):
```
invoker start invoker.ini
```
And you can (re)build the database with:
```
script/rebuild-ontohub
```

Now you should be ready...

[hets_link]: http://www.informatik.uni-bremen.de/agbkb/forschung/formal_methods/CoFI/hets/intel-mac/dmgs/
