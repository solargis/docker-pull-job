#!/bin/bash

IMAGE_NAME="${IMAGE_NAME:-solargis/init-job}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

cd "$(realpath "$(dirname "$BASH_SOURCE")")"
me() { "$BASH_SOURCE" "$@"; }
error() { echo -e "\x1b[31mError\x1b[0m: \x1b[1m$*\x1b[0m" >&2; }
warn() { echo -e "\x1b[33mWarning\x1b[0m: \x1b[1m$*\x1b[0m" >&2; }
fail() { "$@"; exit 1; }
includes() { local item="$1"; shift; for i; do [ "$i" == "$item" ] && return 0; done; return 1; }

next_version() {
    local current_version="$1"; shift
    ! includes --amend "$@" || {
        ! [ -z "$current_version" ] || fail error "No previous release found."
        echo "$current_version"
        return
    }
    f=2
    ! includes --patch "$@" || f=3
    ! includes --major "$@" || f=1
    echo "${current_version:-0.0}" | awk -F'.' -v f="$f" -v OFS='.' '{ $f++; NF=f<2?2:f; if(f==1) $2=0; print $0}'
}

case "$1" in
build)
    opts=( -t "$IMAGE_NAME:$IMAGE_TAG" )
    [ -z "$UBUNTU_VERSION" ] || opts=( "${opts[@]}" --build-arg UBUNTU_VERSION )
    docker build . "${opts[@]}"
    ;;
run)
    me build && docker run -it --rm "$IMAGE_NAME:$IMAGE_TAG" "$@"
    ;;
push)
    me build && docker push "$IMAGE_NAME:$IMAGE_TAG"
    ;;
release)
    shift
    set -e
    [ -z "$(git diff HEAD --numstat)" ] || {
        git diff HEAD --stat >&2
        includes --force "$@" || fail error "Dirty workspace."
        warn "Dirrty workspace."
    }
    git fetch --tags
    LAST=$(git for-each-ref --format="%(refname)" --sort=-authordate --count=1 refs/tags/v* | awk '{print substr($1,12)}')
    VERSION="$(next_version "$LAST" "$@")"
    git tag -a "v$VERSION" -m "version $VERSION"
    git push origin "v$VERSION"
    IMAGE_TAG="v$VERSION" me build
    docker push "$IMAGE_NAME:v$VERSION"
    ;;
*)
    echo "Usage:"
    echo "  $0 build"
    echo "  $0 run COMMAND [...ARGS]"
    echo "  $0 push"
    echo "  $0 release [--force] [--major|--patch|--amend]"
    ;;
esac