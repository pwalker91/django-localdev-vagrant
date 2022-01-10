#!/bin/bash
set -e

PF_FUNC_START="\n>>>>>>>> %s <<<<<<<<\n\n"
PF_FUNC_LOG="\n >>> %s \n\n"

BASH_ALIASES_FILE="/home/vagrant/.bash_aliases"
PROFILE_FILE="/home/vagrant/.profile"

VENV_EXPORTS="
#Virtualenvwrapper settings:
export WORKON_HOME=\$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export VIRTUALENVWRAPPER_VIRTUALENV=\$HOME/.local/bin/virtualenv
source \$HOME/.local/bin/virtualenvwrapper.sh"

DJANGO_EXPORTS="
#Chatbot settings:
export ENVIRONMENT=localdev_${HOST_USER:-noname}
export AWS_ACCESS_KEY_ID=development
export AWS_DEFAULT_REGION=development
export AWS_SECRET_ACCESS_KEY=development"

HELPFUL_BASH_ALIASES="
alias go-docker='cd ~/docker'
alias go-django='cd ~/django && workon ${DJANGO_VENV_NAME}'"



install_docker() {
    printf "${PF_FUNC_START}" "Installing docker"

    sudo apt-get update && sudo apt-get install -y docker.io docker-compose
    sudo systemctl enable --now docker

    sudo usermod -aG docker vagrant
}

install_mysql_libs() {
    printf "${PF_FUNC_START}" "Installing MySQL-related libs"

    sudo apt install -y \
        libmariadb3 \
        libmariadb-dev-compat \
        libpython3-dev \
        libssl-dev
}

install_virtualenv() {
    printf "${PF_FUNC_START}" "Installing virtualenv"

    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt-get update && sudo apt-get install -y ${DJANGO_PY_VER} python3-pip
    pip3 install virtualenv virtualenvwrapper
}

set_environment_files() {
    printf "${PF_FUNC_START}" "Creating necessary environment files"

    set_helpful_aliases() {
        printf "${PF_FUNC_LOG}" "Creating ${BASH_ALIASES_FILE}"

        echo "${HELPFUL_BASH_ALIASES}" | tee ${BASH_ALIASES_FILE}
        sudo chown vagrant:vagrant ${BASH_ALIASES_FILE}
    }

    modify_bash_profile() {
        printf "${PF_FUNC_LOG}" "Adding to ${PROFILE_FILE}"

        #First we save a backup of the default '.profile' file.
        [ ! -f ${PROFILE_FILE}.default ] && sudo cp -pv ${PROFILE_FILE} ${PROFILE_FILE}.default
        sudo cp -pv ${PROFILE_FILE}.default ${PROFILE_FILE}

        #Now we can modify the '.profile' file
        echo "${VENV_EXPORTS}" | tee -a ${PROFILE_FILE}
        echo "${DJANGO_EXPORTS}" | tee -a ${PROFILE_FILE}

        sudo chown vagrant:vagrant ${PROFILE_FILE}
    }

    set_helpful_aliases
    modify_bash_profile

    printf "${PF_FUNC_LOG}" "Reloading vagrant user's ~/.profile file."
    source ${PROFILE_FILE}
}

do_final_cleanup() {
    printf "${PF_FUNC_START}" "Performing cleanup actions"

    do_apt_autoremove() {
        printf "${PF_FUNC_LOG}" "Removing unnecessary packages"

        sudo apt-get autoremove -y
    }

    fix_other_permissions() {
        sudo chown -R vagrant:vagrant /home/vagrant/.virtualenvs
        ## I'm not entirely sure why the `.ssh` folder's group isn't owned
        ## by the vagrant user, but lt's fix that.
        sudo chown -R vagrant:vagrant /home/vagrant/.ssh
    }

    do_apt_autoremove
    fix_other_permissions
}



main() {
    ## installing stuff for chatbot core
    install_docker
    install_mysql_libs
    install_virtualenv

    ## Some setup of necessary environment files
    set_environment_files

    ## And now some final cleanup
    do_final_cleanup
}

main
