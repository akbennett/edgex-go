#!/usr/bin/env bash
set -x

arch="bogus"
[ `arch` == i386 ] && arch="-amd64"
[ `arch` == aarch64 ] && arch="-arm64"
[ `arch` == armhf ] && arch="-arm"
[ `arch` == armv7l ] && arch="-arm"
[ `arch` == x86_64 ] && arch="-amd64"

# create_and_push_manifest
# this function attempts to brute-force push the manifest
function create_and_push_manifest {
    ACCOUNT=$1
    D=$2
    # create a manifest for atleast 1 image
    docker manifest create --amend \
        ${ACCOUNT:-opensourcefoundries}/$D:latest \
            ${ACCOUNT:-opensourcefoundries}/$D:latest$arch

    # create a manifest for atlearst 2 images
    docker manifest create --amend \
        ${ACCOUNT:-opensourcefoundries}/$D:latest \
            ${ACCOUNT:-opensourcefoundries}/$D:latest-arm64 \
            ${ACCOUNT:-opensourcefoundries}/$D:latest-amd64
    docker manifest create --amend \
        ${ACCOUNT:-opensourcefoundries}/$D:latest \
            ${ACCOUNT:-opensourcefoundries}/$D:latest-arm64 \
            ${ACCOUNT:-opensourcefoundries}/$D:latest-arm
    docker manifest create --amend \
        ${ACCOUNT:-opensourcefoundries}/$D:latest \
            ${ACCOUNT:-opensourcefoundries}/$D:latest-arm \
            ${ACCOUNT:-opensourcefoundries}/$D:latest-amd64

    # create a manifest for atleast 2 images
    docker manifest create --amend \
        ${ACCOUNT:-opensourcefoundries}/$D:latest \
            ${ACCOUNT:-opensourcefoundries}/$D:latest-arm64 \
            ${ACCOUNT:-opensourcefoundries}/$D:latest-amd64 \
            ${ACCOUNT:-opensourcefoundries}/$D:latest-arm

    # push the manifest that won the battle
    docker manifest push --purge ${ACCOUNT:-opensourcefoundries}/$D:latest

}

function tag-push-manifest {
    docker tag $1/$2 ${ACCOUNT:-opensourcefoundries}"/edgex-$2:latest$arch"

    docker push ${ACCOUNT:-opensourcefoundries}"/edgex-$2:latest$arch"
    create_and_push_manifest ${ACCOUNT:-opensourcefoundries} "edgex-$2"
}

#build the containers
#make docker
tag-push-manifest "edgexfoundry" "docker-core-metadata"
tag-push-manifest "edgexfoundry" "docker-core-data"
tag-push-manifest "edgexfoundry" "docker-core-command"
tag-push-manifest "edgexfoundry" "docker-export-client"
tag-push-manifest "edgexfoundry" "docker-export-distro"
#tag-push-manifest "edgexfoundry" "docker-support-logging"

#pull containers yet to be 'go-ized'
function pull-tag-push-manifest {
    docker pull $1"/"$2
    tag-push-manifest $1 $2
}
pull-tag-push-manifest "edgexfoundry" "docker-support-logging"
pull-tag-push-manifest "edgexfoundry" "docker-edgex-volume"
pull-tag-push-manifest "edgexfoundry" "docker-edgex-mongo"
pull-tag-push-manifest "edgexfoundry" "docker-core-config-seed"
pull-tag-push-manifest "edgexfoundry" "docker-support-notifications"
pull-tag-push-manifest "edgexfoundry" "docker-support-scheduler"
pull-tag-push-manifest "edgexfoundry" "docker-support-rulesengine"
pull-tag-push-manifest "edgexfoundry" "docker-device-virtual"
