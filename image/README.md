# Custom ARC Image

A custom image is most likely required as the default image for self-hosted ARC systems **is not the same as** `ubuntu-latest` image available for GitHub-hosted runners. The default image for self-hosted ARC systems lacks many tools and libraries that are available in the `ubuntu-latest` image and your workflows most likely won't run without them. You can still always test first!

Here I've provided a single Dockerfile that creates an image that will both run as the listener pod and the runner pod. To learn more about the image, check the [Dockerfile](./Dockerfile "Dockerfile"). You can read all the details there and see what kind of tools and libraries are installed. The image is already built and ready for download on [Docker Hub](https://hub.docker.com/repository/docker/poser/custom-arc-runner/general "poser/custom-arc-runner | Docker Hub").

If you are not happy with the image, you can always create your own custom image. Feel free to use my Dockerfile as a reference or consult the official starter file for a custom runner image, found [here](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/about-actions-runner-controller#creating-your-own-runner-image "About Actions Runner Controller - GitHub Docs").

The image has been built and configured to run in the DinD mode. If you need a non-DinD image, this is not the image for you.

**NOTE**! You cannot create any arbitrary Docker image. It has to be a valid Docker image capable of running the ARC runner set, both listener and runner pods.

## About My Custom Image

Heavily inspired by [this great blog post](https://some-natalie.dev/blog/kubernoodles-pt-5/ "Creating custom images for actions-runner-controller | Some Natalie's corner of the internet") by [@some-natalie](https://github.com/some-natalie "some-natalie (Natalie Somersall)").

The runners are built on the base image of Ubuntu 24.04. The first tag of the image, `v1`, was built on Ubuntu 22.04. If you need to use the image on Ubuntu 22.04, use the `v1` tag. If you wish to customize your own image based on the `v1` version, please check the old Dockerfile from [this release](https://github.com/joonarafael/gh-arc-dind-kubernetes-for-dummies/releases/tag/v1 "Release v1: 2025-09-06: Init · joonarafael/gh-arc-dind-kubernetes-for-dummies").

On top of the required software to run the ARC runner set, the image also includes _Caddy_ and _Nginx_, as well as _Node.js_, _Yarn_, _Golang_, _GitHub CLI_, _Docker Compose_, _Python_, and _AWS CLI_.

## Customizing The Image

You can check available Ubuntu base images from [Docker Hub](https://hub.docker.com/_/ubuntu "ubuntu - Official Image | Docker Hub"). Updating the version might break something, so be careful.

Make sure to update the following versions in the Dockerfile:

- `RUNNER_VERSION`, check releases [here](https://github.com/actions/runner/releases "Releases • actions/runner").

- `RUNNER_CONTAINER_HOOKS_VERSION`, check releases [here](https://github.com/actions/runner-container-hooks/releases "Releases • actions/runner-container-hooks").

- `DUMB_INIT_VERSION`, check releases [here](https://github.com/Yelp/dumb-init/releases "Releases • Yelp/dumb-init").

- `DOCKER_VERSION`, check latest versions, for example, from the [release notes](https://docs.docker.com/tags/release-notes/ "Release notes | Docker Docs").

- `COMPOSE_VERSION`, check latest versions, for example, from the [release notes](https://docs.docker.com/compose/release-notes/ "Release notes | Docker Docs").

- `GO_VERSION`, check latest versions, for example, from the [release notes](https://go.dev/dl/ "All releases - The Go Programming Language").

- `NODE_VERSION`, check latest versions, for example, from the [release notes](https://nodejs.org/en/about/previous-releases "Node.js - Node.js Releases").

### Environment variables

Any required environment variables can be imported with the `images/.env` file into the Dockerfile.

**NOTE**! If you fork this repository, make sure to ignore the `.env` file not to ever commit any secrets to version control.

### Runner-specific stuff

The required runner-specific stuff is installed within the Dockerfile, including the actual runner and the container hooks.

### Helper scripts

Other software is installed using various helper scripts in the `images/software` directory.

## Pushing images to Docker Hub

Here's a short step-by-step guide on how to push your images to Docker Hub, assuming that you've got a Docker Hub account.

**1. Login to Docker Hub**

In your terminal, execute `docker login` and enter your Docker Hub credentials when prompted.

**2. Build the image**

Next to the associated `Dockerfile`, execute `docker build -t <your-username>/<your-image-name>:<tag> .` to build the image.

**3. Push the image**

After a successful build, execute `docker push <your-username>/<your-image-name>:<tag>` to push the image to Docker Hub.

Make sure the image and tag are correct. You can always check all your images and tags with `docker images`.
