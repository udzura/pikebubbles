# Pikebubbles

`pikebubbles` is a so simple service that receive input from FIFO and then redirect it to a container's stdout.

This is intended to use sidecar container, with `exec`'ing into it.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pikebubbles'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pikebubbles

## Usage

Using kubernetes, we can use [`udzura/pikebubbles:X.X.X`](https://hub.docker.com/r/udzura/pikebubbles) container as sidecar.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: frontend
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: frontend
    spec:
      # It would be useful sharing PID namespace
      # or mount points using volumes
      shareProcessNamespace: true
      containers:
      - image: wordpress:5.2.2-apache
        name: wordpress
        env:
        - name: WORDPRESS_DB_HOST
          value: ...
        - name: WORDPRESS_DB_PASSWORD
          value: ...
        ports:
        - containerPort: 80
          name: wordpress
      - image: udzura/pikebubbles:0.1.1 # <= here
        name: sidecar
```

After deployed this, let's trace sidecar's stdout:

```console
$ kubectl logs -f wordpress-9c87bc758-XXXXX sidecar             
Opened FIFO: /var/run/pikebubbles.fifo

```

Then, `exec` into this container and run some command redirecting to `/var/run/pikebubbles.fifo`

```console
$ kubectl exec -ti wordpress-9c87bc758-x5x2v -c pikebubbles-sidecar bash 
root@wordpress-9c87bc758-XXXXX:~#
root@wordpress-9c87bc758-XXXXX:~#
root@wordpress-9c87bc758-XXXXX:~# echo Hi > /var/run/pikebubbles.fifo
root@wordpress-9c87bc758-XXXXX:~# echo Hi > /var/run/pikebubbles.fifo
root@wordpress-9c87bc758-XXXXX:~#
root@wordpress-9c87bc758-XXXXX:~# ( apt update ) > /var/run/pikebubbles.fifo
```

On the `kubectl logs` console it appears.

```
...
Hi
Hi
Get:1 http://security-cdn.debian.org/debian-security buster/updates InRelease [39.1 kB]                                                                          
Get:2 http://cdn-fastly.deb.debian.org/debian buster InRelease [118 kB]
Get:3 http://security-cdn.debian.org/debian-security buster/updates/main amd64 Packages [82.1 kB]                                                                
Get:4 http://cdn-fastly.deb.debian.org/debian buster-updates InRelease [49.3 kB]
Get:5 http://cdn-fastly.deb.debian.org/debian buster/main amd64 Packages [7897 kB]                                                                               
Get:6 http://cdn-fastly.deb.debian.org/debian buster-updates/main amd64 Packages [884 B]                                                                         
Fetched 8186 kB in 2s (3689 kB/s)
Reading package lists...
Building dependency tree...
Reading state information...
1 package can be upgraded. Run 'apt list --upgradable' to see it.
```

The logs are standard container log, so it can be handled by host-level `/var/log/containers/*` log.

## TODO

* Should accept options...

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

BTW Docker container can be built by:

```console
$ docker build -t udzura/pikebubbles:0.X.X misc/
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/udzura/pikebubbles.
