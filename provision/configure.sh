#!/bin/bash
set -e

PF_FUNC_START="\n>>>>>>>> %s <<<<<<<<\n\n"
PF_FUNC_LOG="\n >>> %s \n\n"

DOCKER_RESOURCES="/vagrant/docker"
DOCKER_COMPOSE_FILE="/home/vagrant/docker/docker-compose.yml"
DJANGO_HOME="/home/vagrant/django"
PROFILE_FILE="/home/vagrant/.profile"



set_up_docker_folder() {
    printf "${PF_FUNC_START}" "Setting up Docker folder"

    ## There are permissions issues that Parallels complains about when we attempt
    ## to sync the `docker` folder to the VM. So we'll just dumb copy all the data.
    sudo cp -rpv ${DOCKER_RESOURCES} /home/vagrant
}

pull_docker_images() {
    printf "${PF_FUNC_START}" "Pulling base Docker images"

    sudo service docker start
    docker-compose --file ${DOCKER_COMPOSE_FILE} pull
}

create_django_venv() {
    printf "${PF_FUNC_START}" "Creating Django's Virtual Env"

    curdir=$(pwd)

    cd ${DJANGO_HOME}
    set +e
    mkvirtualenv -p ${DJANGO_PY_VER} ${DJANGO_VENV_NAME}
    set -e
    workon ${DJANGO_VENV_NAME}

    pip install -U pip
    pip install -U -r requirements.txt

    python manage.py migrate

    cd $curdir
}



main() {
    ## Docker setup stuff
    set_up_docker_folder
    pull_docker_images

    ## Django stuff
    create_django_venv
}

main
