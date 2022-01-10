# Django LocalDev with Vagrant

This project will let you quickly set up a VM on your machine that will locally host a Django project of your choosing.

The Django web server will run directly from the VM, while any data storage will be run using docker-compose, to allow for better control of what versions of storage software are used.<br>
In this example project, we are going to be using MySQL 5.7 and LocalStack (as a stand-in for Amazon S3).

(_These instructions are written for a Mac machine._)



## y u do dis?

_Why Virtualization and Docker?_ Personally, I rather like being able to fully isolate my developer environment from my host machine. It allows me to more comfortably "delete and start over", and manipulating a Linux VM gets me closer to how the application may run on a server.

_But why put the storage in Docker?_ Because I wanted some more fine-grain control over the version of storage software used. Meanwhile, I wanted to leave my Django files directly on the machine.... because.<br>
Yes, a better solution would be to put **all** of this into a collection of Docker Containers. That'll be another project.



## Remaining ToDo items

- [ ] Try redoing for [Ubuntu 20.04 ARM](https://app.vagrantup.com/bento/boxes/ubuntu-20.04-arm64) to avoid issues caused by Mac M1 chip.
- [ ] Put some files in my S3 buckets, and have Django retrieve them.
    - Possible ideas: image file, CSV file.
- [ ] Have Django view that gets data from Sakila database.
- [ ] Actually test this out on an x86 Mac
    - My personal machine is a 2020 Macbook Pro with an M1 Processor. As such, VirtualBox is not an option, and VMWare Fusion requires a license for the CLI utilities that Vagrant needs (and I'm not yet ready to shell out for a license).<br>
    There is [some virtualization software](https://github.com/hashicorp/vagrant/issues/12518) for M1 processors, but most don't have a [Vagrant Plugin](https://github.com/hashicorp/vagrant/issues/12518) yet.
- [ ] Redo `install` and `configure` bash scripts as Ansible playbooks.

----

## Installation

### Software Dependencies

You will need to install a few pieces of software before you can create your VM.
- [Homebrew](https://brew.sh/)
- [Vagrant](https://formulae.brew.sh/cask/vagrant) (_using Homebrew_)
- [VirtualBox](https://formulae.brew.sh/cask/virtualbox) (_using Homebrew_)<br>
  _or_<br>
  [VMWare Fusion](https://formulae.brew.sh/cask/vmware-fusion).<br>
    - You will also need to install the [Vagrant Plugin](https://www.vagrantup.com/docs/providers/vmware/installation) for VMWare Fusion.

### Install Steps

#### Vagrant Home Setup

1. Clone this repository to a location of your choosing, preferably in the same directory where your Django project resides. This repository includes a "template Django project", which you can safely delete if you have an existing Django project.<br>
The location that you clone this repository to will be referred to as the **Vagrant Home** in the rest of this walkthrough.

2. Modify the `Vagrantfile` as necessary.<br>
There are a few variables at the top of the file that may need to be modified based on what you want the VM to be named and where you placed the source code for your Django project (_relative to the `Vagrantfile`_).

3. Download your starting data for the MySQL database.<br>
For this example repository, I am going to use the [Sakila Sample Database](https://dev.mysql.com/doc/sakila/en/sakila-installation.html).

4. Extract the SQL files and place them in the `dbinit/mysql` folder.<br>
You will need to rename the files so that they are executed in the correct order when the Docker Container starts up.
    - Rename `sakila-schema.sql` to `03-sakila-schema.sql`.
    - Rename `sakila-data.sql` to `04-sakila-data.sql`.
    > !! NOTE !!<br>
    > If you are reusing this project for your own environment and want to commit any SQL files you place in the directory, end the filename with `-keepme.sql`. The `.gitignore` file is currently configured to ignore any SQL files that do not end this way.


#### Django Setup

_This sample Django project is using Django 4, and will depend on Python version 3.9._

5. There is no extra setup needed of the included Django project, `example_django`. It really doesn't do much. The intention is to simply show a Django server running and consuming data from the MySQL and LocalStack Docker Containers.<br>
If you need special configuration of server settings, consider modifying the `provision/install.sh` and `provision.configure.sh` scripts. For example, the function `set_environment_files` in `provision/install.sh` add content to the vagrant user's `~/.profile` file, so that some environment variables are defined whenever the user logs in.


#### Creating VM with Vagrant

6. Open a Terminal window, navigate to the Vagrant home and run `vagrant up --provider=PROVIDER`.<br>
If you are using VirtualBox as your VM Host, define `PROVIDER` as `virtualbox`.<br>
If you are using VMWare Fusion as your VM Host, define `PROVIDER` as `vmware_fusion`.<br>
Once the VM has fully initialized, follow the steps below to complete the steps below using an SSH connection.

#### Starting Docker, Chatbot, and Employer_Dashboard

7. Open a new Terminal window and navigate to the Vagrant home.<br>
Use the `vagrant ssh` command to connect to the VM and run the following commands:
    ```bash
    cd ~/docker
    docker-compose up
    ```
    **Wait for the initialization of all Containers to fully complete** before continuing to the next step.<br>
    The MySQL data dump will take the longest to load and there won't be any progress indicators, so wait until that initialization process has completed. Review the log messages printed to your console to determine if all Docker containers have fully initialized.

8. Open another Terminal window and navigate to the Vagrant home.<br>
Use the `vagrant ssh` command to connect to the VM and run the following commands:
    ```bash
    cd ~/chatbot/chatproj
    workon chatbot

    ./manage.py runserver 0:8000
    ```

**And with that, your local development instance of a Django server is now up and running!**

----

### Suspending/Resuming your LocalDev

#### Suspending

1. The `docker-compose` and `manage.py` processes might still be running in some Terminal windows. Check that all of these processes are stopped by pressing `ctrl-C` in the Terminal windows.

2. From a Terminal window in your Vagrant home, execute the command:
    ```bash
    vagrant suspend
    ```

#### Resuming

1. If your VM is suspended, open a Terminal window, navigate to the Vagrant home, and execute the command:
    ```bash
    vagrant resume
    ```

2. Open a new Terminal window and navigate to the Vagrant home. Use the `vagrant ssh` command to connect to the VM and run the following commands:
    ```bash
    cd ~/docker
    docker-compose up
    ```

3. Open another Terminal window and navigate to the Vagrant home. Use the `vagrant ssh` command to connect to the VM and run the following commands:
    ```bash
    cd ~/django
    workon django
    ./manage.py runserver 0:8000
    ```



## Other Helpful Hints

#### Adding files to LocalStack S3

Your running instance of LocalStack will function much like the actual Amazon Web Services you would interact with, and this means that you can use the same CLI tools to interface with it. Follow these instructions to set up your Mac machine to manage files in your LocalStack S3 buckets.

1. Download and install the [AWS CLI using Homebrew](https://formulae.brew.sh/formula/awscli).

2. Create an alias on your host machine for the command `awslocal`. I prefer to add this line to my `~/.zshrc` file.
    ```bash
    alias awslocal='AWS_ACCESS_KEY_ID=development AWS_SECRET_ACCESS_KEY=development AWS_DEFAULT_REGION=$(DEFAULT_REGION:-development) aws --endpoint-url=http://$(LOCALSTACK_HOST:-localhost):4566'
    ```

3. You can now use the [s3](https://docs.aws.amazon.com/cli/latest/reference/s3/) and [s3api](https://docs.aws.amazon.com/cli/latest/reference/s3api/) commands to manipulate the content in your LocalStack S3 buckets.<br>
For example, you might use the following commands:
    - List all of the buckets currently available.
        ```bash
        awslocal s3api list-buckets --query "Buckets[].Name"
        ```
    - Add a file to a bucket.
        ```bash
        awslocal s3 cp my-local-file s3://my-s3-bucket
        ```
    - Add all JSON files to a bucket.
        ```bash
        awslocal s3 cp . s3://my-s3-bucket --recursive --exclude "*" --include "*.json"
        ```
    - Make a new bucket.
        ```bash
        awslocal s3 mb s3://my-new-s3-bucket
        ```
