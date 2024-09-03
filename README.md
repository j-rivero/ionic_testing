# Testing platform for Gazebo Ionic

Gazebo Ionic is supported for Linux only on Ubuntu Noble (24.04). For the
testers that don't run this platform it is possible to use a virtual
environment with GPU support to run this.

A couple of options to run the docker container:
  * A: use docker and rocker
  * B: use docker compose

## Option A: using docker + rocker

### Docker ionic-prerelease image

The repository contains a `Dockerfile` ready to setup an Ubuntu Noble with
the necessary packages from the prerelease repository to run Gazebo Ionic.

Build it with:
```
docker build --target=ionic-nightly -t ionic-prerelease - < Dockerfile
```

### Running the images with GPU support

To run the ionic-prerelease image created the recommended tool is `rocker`:
https://github.com/osrf/rocker .


#### Installing rocker

The `master` branch is needed to support Ubuntu Noble systems:
```
 python3 -m venv rocker_ws/
 . rocker_ws/bin/activate
 pip3 install git+https://github.com/osrf/rocker@master
```

Be sure of using the same shell to launch rocker from it or run the activate
command in the desired shell.

#### Launching the ionic image: Nvidia users

```
rocker --user --x11 --nvidia -- ionic-prerelease
# User should be now inside the Noble system with Ionic installed
# to launch the simulator: gz sim --verbose
```

#### Launching the ionic image: Intel users

```
rocker --user --x11 --devices /dev/dri --group-add video  -- ionic-prerelease
# User should be now inside the Noble system with Ionic installed
# to launch the simulator: gz sim --verbose
```

### Using the nightly packages

During the testing period some hot fixes land everyday in the Gazebo
repositories. Nightly packages are released every night into the nightly
repository using the latest commits in the Gazebo Ionic repositories.

To use the nightly image just repeat the steps before changing ionic-prerelease
by ionic-nightly in docker build and rocker.

## Option B: using docker compose

### Docker ionic-prerelease image

The repository contains a `Dockerfile` ready to setup an Ubuntu Noble with
the necessary packages from the prerelease repository to run Gazebo Ionic.

Build it with:
```
# For intel users
docker compose build ionic-build

# For nvidia users
docker compose build ionic-build-nvidia
```
### Running the images with GPU support

#### Launching the ionic image: Nvidia users

The [nvidia-container-toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
installation is required to use the docker compose successfully.

```
docker compose run ionic-nvidia-run
# User should be now inside the Noble system with Ionic installed
# to launch the simulator: gz sim --verbose
```

#### Launching the ionic image: Intel users

```
docker compose run ionic-intel-run
# User should be now inside the Noble system with Ionic installed
# to launch the simulator: gz sim --verbose
```

### Using the nightly packages

During the testing period some hot fixes land everyday in the Gazebo
repositories. Nightly packages are released every night into the nightly
repository using the latest commits in the Gazebo Ionic repositories.

To use the nightly image just repeat the docker compose steps adding
`BUILD_TYPE=nightly` before the docker compose executions.
