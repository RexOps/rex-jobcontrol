# Rex::JobControl

Rex::JobControl is a simple Webinterface to Rex.

Currently the Webinterface is in early development stage. So if you see bugs, have ideas for improvement or want to help developing please contact us via the issue tracker or via irc (irc.freenode.net #rex).

## Some Screenshots

* Login:

![Login](https://raw.githubusercontent.com/RexOps/rex-jobcontrol/master/screenshots/login.png)


* Project:

![Project view](https://raw.githubusercontent.com/RexOps/rex-jobcontrol/master/screenshots/projects.png)


* Job:

![Job view](https://raw.githubusercontent.com/RexOps/rex-jobcontrol/master/screenshots/job.png)


* Execute:

![Execute a job](https://raw.githubusercontent.com/RexOps/rex-jobcontrol/master/screenshots/execute.png)


## Installation

Currently there are no packages, but the installation is quite simple.

### Requirements

* Perl (>= 5.10.1)
* Mojolicious
* Mojolicious::Plugin::Authentication
* Minion
* DateTime
* YAML
* Digest::Bcrypt

### Install the source

```
git clone git@github.com:RexOps/rex-jobcontrol.git
cd rex-jobcontrol
cpanm --installdeps .
```

## Configuration

The configuration file is searched in these places:

* /etc/rex/jobcontrol.conf
* /usr/local/etc/rex/jobcontrol.conf
* ./jobcontrol.conf

```perl
{
  project_path => "./projects/",
  minion_db_file => "./minion.data",

  rex => "/usr/bin/rex",
  rexify => "/usr/bin/rexify",

  session => {
    key => 'Rex::JobControl',
  },

  auth => {
    salt => '1cN46DkL2A(dk(!&', # 16 bytes long
    cost => 1, # between 1 and 31
    passwd => './passwd',
  },
}
```

## Manage users

Currently there is no webinterface to manage the users, but you can use a cli command to do this.

Add user:
```
bin/rex_job_control jobcontrol adduser -u $user -p $password
```

Remove user:
```
bin/rex_job_control jobcontrol deluser -u $user
```

List user:
```
bin/rex_job_control jobcontrol listuser
```

## Start the services

Rex::JobControl consists of 2 services. The Webinterface and the Worker.

To start the worker you have to run the following command. You can start as many worker as you need/want.

```
bin/rex_job_control minion worker
```

To start the Webinterface you have to run this command. This will start a webserver at port 8080. 
```
hypnotoad bin/rex_job_control 
```



## REST API

Every object can be accessed via a REST api.

### Nodes

Get information of a node:

```
curl -D- -XGET \
  http://admin:admin@localhost:3000/api/1.0/project/{project_id}/node/{node_id}
```

Create a new node:

```javascript
{
  "name"  : "foo01",
  "type"  : "docker",
  "parent": "db188e3449615a2c64685abe0802f55f_a673946c007d6a9927f70bdf5d491861",
  "data": {
    "image": "centos:centos6"
  }
}
```

```
curl -D- -XPOST -d@node_create.json \
  http://admin:admin@localhost:3000/api/1.0/project/{project_id}/node
```

Delete a node:

```
curl -D- -XDELETE \
  http://admin:admin@localhost:3000/api/1.0/project/{project_id}/node/{node_id}
```

