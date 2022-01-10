# -*- mode: ruby -*-
# vi: set ft=ruby :



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
## CUSTOM VARIABLES
# The following variables will be used later on when your VM is being set up.
# Please change them to match how you like to have things set up on your machine.

# (1)
# This will be the name of the VM, the VM's hostname, and the DNS name that will
# be added to your machine's `/private/etc/hosts` file.
@vm_name = "my-project-localdev-v"

# (2)
# This is the relative paths to where you cloned the repository for
# your Django project.
@django_dir = "example_django"
# @django_dir = "../my_actual_project"

# (3)
# These variable define how Django will be set up; ie. what version of Python
# will be installed, and what name will be given to the virtual environment.
@django_py_ver = "python3.9"
@django_venv_name = "django"

## END CUSTOM VARIABLES
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #



# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
    # The most common configuration options are documented and commented below.
    # For a complete reference, please see the online documentation at
    # https://docs.vagrantup.com.

    # Every Vagrant development environment requires a box. You can search for
    # boxes at https://vagrantcloud.com/search.
    config.vm.box = "bento/ubuntu-18.04"
    config.vm.hostname = @vm_name

    # When accessing `localhost` on the ports below, all of the traffic will be
    # forwarded to this Vagrant VM, which is good because it is what will be
    # running our Django application and such.
    #
    # Port 8000 is for the Django webserver
    config.vm.network "forwarded_port", guest: 8000, host: 8000
    # Port 3306 is for the MySQL Docker container that is spun up
    config.vm.network "forwarded_port", guest: 3306, host: 3306
    # Port 4566 is for the S3 portion of the Localstack container
    config.vm.network "forwarded_port", guest: 4566, host: 4566

    # Setting the default provider. This Vagrantfile was written under the
    # assumption that Parallels is being used as the provider
    config.vm.provider "virtualbox" do |vb|
        vb.name = @vm_name
        vb.check_guest_additions = true
        vb.memory = 4096
        vb.cpus = 4
    end
    config.vm.provider "vmware_fusion" do |vb|
        vb.vmx['displayname'] = @vm_name
        vb.memory = 4096
        vb.cpus = 4
    end

    # Share an additional folder to the guest VM. The first argument is
    # the path on the host to the actual folder, and is relative to where
    # you are executing the `vagrant up` command. The second argument is
    # the path on the guest to mount the folder, and is an absolute path.
    # There are other optional keyword arguments that can be given, and are
    # documented here.
    # https://www.vagrantup.com/docs/synced-folders/basic_usage
    config.vm.synced_folder \
        @django_dir, "/home/vagrant/django", \
        create: true
    config.vm.synced_folder \
        "docker", "/home/vagrant/docker", \
        create: true

    @username = Vagrant::Util::Platform.windows? ? "#{ENV['USERNAME']}" : "#{ENV['USER']}"
    config.vm.provision "install", \
        type: "shell", privileged: false, \
        reset: true, \
        path: "./provision/install.sh", \
        env: {
            "HOST_USER" => "#{@username}",
            "DJANGO_VENV_NAME" => "#{@django_venv_name}",
            "DJANGO_PY_VER" => "#{@django_py_ver}"
        }
    # This configuration needs to happen after all of the supporting stuff has
    # been installed. The SSH connection should have been reset after the
    # previous script, so that modified bash profile files are applied, users
    # are added to groups, and such
    config.vm.provision "configure", \
        type: "shell", privileged: false, \
        path: "./provision/configure.sh", \
        env: {
            "HOST_USER" => "#{@username}",
            "DJANGO_VENV_NAME" => "#{@django_venv_name}",
            "DJANGO_PY_VER" => "#{@django_py_ver}"
        }
end
