## Deployment on vagrant

- This directory can be used to set up a local vm using Vagrant and deploy our CRUD app within the vm.
- It is designed to set up 2 api servers, 1 db, and an Nginx server to work as a proxy and load balancer.
- Currently, the Nginx server follows a round-robin(default) load balancing method.
    - You can customize the load balancing method by making changes to the upstream method
      in [the nginx conf file](../deploy-vagrant/nginx.conf) by
      following [the docs](https://docs.nginx.com/nginx/admin-guide/load-balancer/http-load-balancer/#choosing-a-load-balancing-method).

- The apis are reachable on the ip: `192.168.56.20`. So, all api calls being made to http://localhost/ will have to now
  be made to http://192.168.56.20/.

### Requirements:

- VirtualBox 7.2.4
- Vagrant 2.4.9

### Setting up the vagrant deployment:

- Ensure all the requirements are installed.
- `cd` into current directory.
- Copy the `.env.example` file over as `.env` file and set the variables accordingly.
    - There are some optional vars which need not be configured in case no customization is required.
    - Make sure that the dockerhub repo, image, and version that are provided exist and that the user(configured via
      dockerhub username and password) has pull permissions to the image from the repo.
- Use the commands:
    - `vagrant up` to up the vm (includes: creating, configuring, and provisioning)
    - `vagrant ssh` to ssh into the vm (the services will be running as docker containers in the vm, and hence ssh-ing
      into the machine can be useful to check logs, status of the containers etc.)
    - `vagrant provision` in case you decide to make changes to any of the config files (eg:
      `docker-compose.vagrant.yml` or `nginx.conf` or `provision.sh`).
    - `vagrant reload` in case you make changes to the [Vagrantfile](Vagrantfile). PS: This will not re-provision the
      services. You can force it to re-provision by using the flag `--provision`.
- PS: The vm which will be running the application is an ubuntu os designed for arm64. In case this does not work for
  your machine, you may change the vagrant vm box config:
    - from `"bento/ubuntu-22.04"` to `"generic/ubuntu2204"`
    - This config is present in the [Vagrant file](Vagrantfile) as vm box config(config.vm.box).