# Our Productive Configuration

# Serverside

We have 3 servers:
* ontohub.org: stable system.
* staging.ontohub.org: represents the development state on staging so there are more new features than on ontohub.org. Should be stable, but may still contain bugs.
* develop.ontohub.org: On this we test our feature branches. May be broken due unreviewed code or conflicts between branches

The configuration of each server is maintained in a branch with the domain name of the server. For deploymant, you just need to check out this branch. The configuration files shown below (except for crontabs) are automatically set up by this step. Hence, the files below have only informative purpose.

## Crontabs

the crontab of the user ontohub on the server are looking on our servers like this:

ontohub.org

```
# m h  dom mon dow   command

RAILS_ENV=production
SHELL=/usr/local/rvm/bin/rvm-shell

15 */6  * * *   ~/current/script/rails runner 'SidetiqWorker.new.perform'
```

staging.ontohub.org and develop.ontohub.org

```
# m h  dom mon dow   command

RAILS_ENV=production
SHELL=/usr/local/rvm/bin/rvm-shell

0 *  * * *  ~/current/script/rails runner 'SidetiqWorker.new.perform'

*/2 *  * * *  ~/update_ontohub.sh
```

# Ontohubside

The configuration on the Ontohub application side is to make on a few yaml files.

## ontohub.org
In this section you can find links to files which configures the ontohub site
### settings.yaml

https://github.com/ontohub/ontohub/blob/ontohub.org/config/settings.yml

### Environment specific overwrites
#### production

https://github.com/ontohub/ontohub/blob/ontohub.org/config/settings/production.yml

#### development

https://github.com/ontohub/ontohub/blob/ontohub.org/config/settings/development.yml

#### test

https://github.com/ontohub/ontohub/blob/ontohub.org/config/settings/test.yml

## staging.ontohub.org

### settings.yaml

https://github.com/ontohub/ontohub/blob/staging.ontohub.org/config/settings.yml

### Environment specific overwrites
#### production
can be found under:

https://github.com/ontohub/ontohub/blob/staging.ontohub.org/config/settings/production.yml

#### development

https://github.com/ontohub/ontohub/blob/staging.ontohub.org/config/settings/development.yml

#### test

https://github.com/ontohub/ontohub/blob/staging.ontohub.org/config/settings/test.yml

## develop.ontohub.org

### settings.yaml

https://github.com/ontohub/ontohub/blob/develop.ontohub.org/config/settings.yml

### Environment specific overwrites
#### production
can be found under:

https://github.com/ontohub/ontohub/blob/develop.ontohub.org/config/settings/production.yml

#### development

https://github.com/ontohub/ontohub/blob/develop.ontohub.org/config/settings/development.yml

#### test

https://github.com/ontohub/ontohub/blob/develop.ontohub.org/config/settings/test.yml
