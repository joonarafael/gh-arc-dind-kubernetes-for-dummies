# GitHub Actions Runner Controller for Kubernetes

Updated 2025-06-10.

**Self-hosted runners for GitHub Actions**. Run all your workflows on your own infrastructure.

Configured to run on an automatically scaled set of runners (Kubernetes controller). Built to use **Docker in Docker** (**DinD**) to run the runners. Documentation includes the additional steps to use your custom runner image as the base image for the runners, which is most likely required as the default image for self-hosted ARC systems **does not include everything within** `ubuntu-latest` image available for GitHub-hosted runners.

This documentation has been composed from my own notes. After many hours of trial and error, I've finally got it working and decided to write the notes down.

**NOTE**! If you have any strict security requirements, or any other specific needs, please make sure to review the documentation and any related code before using it.

### Official Docs

You can find the entrypoint for the original GitHub documentation for self-hosted runners [here](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners "About self-hosted runners - GitHub Docs").

The official Quickstart for Actions Runner Controller by GitHub is located behind [this link](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/quickstart-for-actions-runner-controller "Quickstart for Actions Runner Controller - GitHub Docs").

### Editor's Note

_This documentation is written for absolutely noobs and dummies like myself. I've tried to write it so that anyone can understand it and follow the steps, even without any previous experience with Kubernetes or GitHub Actions. If you've got any additional questions or feedback, please feel free to send me message or open an issue/PR._

_However, please keep in mind the target audience. Many of these steps can be done in a different way. Maybe some steps can be skipped. Or maybe some tools or services can be used in a different way or replaced with something else. But the goal is to just get it working. So remember that this is just a guide and not a strict set of instructions. Also the implementation might not be the best possible or most optimized way to do it._

## 00 Motivation, Considerations & Goal

The goal of this project is to provide a self-hosted runner set to run all your GitHub Actions workflows for one of your own repositories. The complete runner set is configured to run on your own infrastructure.

The runner set is configured to run on an automatically scaled set of runners, powered by a Kubernetes controller. It will be configured to use Docker in Docker (DinD) to **enable users to use any Docker features within their workflows**. Please note that the provided assets are configured to run in DinD mode. Consult other documentation as well if you need a non-DinD setup.

This DinD runner set was my goal from the get-go, but I just could not find any comprehensive documentation **from one place** on how to do this. So I read the GitHub Actions documentation, issues, various forums, articles, and blog posts. And a lot of trial and error. But finally, I've got it working and decided to write the notes down into a single source. A really valuable resource has also been [this great blog post](https://some-natalie.dev/blog/kubernoodles-pt-5/ "Creating custom images for actions-runner-controller | Some Natalie's corner of the internet") by [@some-natalie](https://github.com/some-natalie "some-natalie (Natalie Somersall)").

## 01 Prerequisites

Start by identifying and choosing the hardware to run on. I've run it on a separate physical server machine running [Proxmox](https://www.proxmox.com/en/ "Proxmox - Powerful open source server solutions"). I've got 8 cores, 16GB of RAM and 256GB of storage. I think the listed hardware is kind of an low-endish setup. Less cores or less RAM might just not be enough.

I initialized a new VM on the Proxmox and installed [Ubuntu Server 24.04 LTS](https://ubuntu.com/download/server "Get Ubuntu Server | Download | Ubuntu") on it. For the runner VM, I gave it 4 cores and 8GB of RAM. When needed, I added more RAM with swap. Proxmox is a great way to run multiple virtual machines on a single physical machine. Of course, it is not a prerequisite, but it's a great way to run the runner set on a separate, completely isolated VM, in a dedicated environment reserved just for the ARC set.

The runner set can be run on any machine, of course, but I recommend to run it on a separate, dedicated VM. This ensures that there are no conflicting installations, mismatching dependencies, Docker problems, or other environment issues.

Now I assume you've got the Ubuntu (or some Debian-based system) ready, whichever solution you've chosen.

Update all packages to the latest version. I also recommend to install `openssh` to access the system via SSH. Configure SSH via `/etc/ssh/sshd_config`. Read complete documentation of `openssh` behind [this link](https://documentation.ubuntu.com/server/how-to/security/openssh-server/index.html "OpenSSH server - Ubuntu Server documentation").

Important fields in the SSH configuration file include the following:

```bash
Port 22 # required to enable SSH
PermitRootLogin no # recommended to disable root login
PasswordAuthentication yes # required if you want to login with a password
```

## 02 Install Docker

Install Docker. Read the [Docker documentation](https://docs.docker.com/engine/install/ubuntu/ "Ubuntu | Docker Docs") for the latest instructions. Note that it's enough to have the Docker Engine installed here, on the host. For example, in my understanding, the `docker-compose` plugin is not needed for the host if it's installed on the runner image. The runner image will only need the **access** to the Docker Engine and **access** to the Docker socket (in DinD mode).

After the Docker installation, there's a good chance that you need to update the Docker permissions. Usually the commands you need to execute are the following:

```bash
sudo groupadd docker
sudo usermod -aG docker ${USER}
```

## 03 Install Go

Install the Go programming language. Read [Go documentation](https://go.dev/doc/install "Download and install - The Go Programming Language") for the latest instructions.

On a headless system, files and folders can be fetched from the internet, for example, via `curl`. Here you want to use `curl -LO <url>`.

As an post-install step for Go, you might need to add the Go binary to your `PATH`. Edit the `~/.bashrc` file and add the following lines:

```bash
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$(go env GOPATH)/bin
```

## 04 Install `kubectl`

Install `kubectl`. Read the [Kubernetes documentation](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/ "Install and Set Up kubectl on Linux | Kubernetes") for the latest instructions.

## 05 Install `kind`

Install `kind`. Make sure to install `kind` with `go install` method as instructed [here](https://kind.sigs.k8s.io/docs/user/quick-start/#installing-with-go-install "kind - Quick Start").

As the documentation states, the `go install` will most likely add the binary under `/home/user/go/bin`. You might need to add this to your `PATH` variable. Edit the `~/.bashrc` file and add the following lines:

```bash
export PATH=$PATH:/home/user/go/bin
```

## 06 Install Helm

Install `helm` from script. Read the [Helm documentation](https://helm.sh/docs/intro/install/#from-script "Install Helm | Helm") and follow the instructions on "script installation".

## 07 Initialize Kind Cluster

Spawn the default kind cluster with `kind create cluster`. You may also create a custom cluster, of course, with `kind create cluster --name <cluster-name>` or configure it further if you want, but please note that the default configuration is sufficient for this project. Also the remaining steps in this documentation are based on the default cluster.

Initializing the cluster might take a while, so give it some time.

## 08 Configurations

Create a new file called `values.yml` with `touch values.yml`. I've placed the file in the home directory of the user, but you can place it anywhere you want. **However**, the remaining commands in this documentation have to be executed from the same directory as the `values.yml` file. This file contains the configurations for the runner set.

Open the file (for example, with `nano values.yml`) and add the content found in the [adjacent example file](./values.yml "values.yml").

### Configure The `values.yml` File

Set the minimum and maximum number of runners to some reasonable values. Low-end machines might not be able to handle more than a couple of runners. The computational strain of a single runner largely depends on the workflows you run on it.

If you want, you can set maximum hardware resource limits for the runners, along with many other configurations. This is optional and not required. The complete original `values.yml` file provided by GitHub can be found [here](https://github.com/actions/actions-runner-controller/blob/master/charts/gha-runner-scale-set/values.yaml "actions-runner-controller/charts/gha-runner-scale-set/values.yaml at master · actions/actions-runner-controller").

Please note that DinD mode will override some of the configurations. In general, do not tamper with the configuration if you are not sure what you are doing.

Update the `runnerImage` (present in two different places). If you are using a custom runner image, update the image name and tag. If you are using the default runner image, you can comment it out.

### Custom Runner Images

With "Runner Images" I mean the images that are used to run the workflows. For the GitHub-hosted runners, the default image is `ubuntu-latest`. For the self-hosted runners, the default image is `actions/runner:latest`. The self-hosted image is a bit more limited than the GitHub-hosted one and most likely not sufficient for your needs.

To run your workflows on a custom runner image, you need to first create the custom image. The default documentation about this topic by GitHub can be found [here](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/about-actions-runner-controller#creating-your-own-runner-image "About Actions Runner Controller - GitHub Docs").

I created a custom image called `custom-arc-runner`. The source Dockerfile used to build the image can be found [here](./image/Dockerfile "Dockerfile"). The prebuilt image ready for download is available [here](https://hub.docker.com/repository/docker/poser/custom-arc-runner/general "poser/custom-arc-runner | Docker Hub"). If that's sufficient for your needs, you can freely use it out-of-the-box. Otherwise, you can create your own custom image and use my Dockerfile as a reference.

The official starter Dockerfile for a custom runner image can be found [here](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/about-actions-runner-controller#creating-your-own-runner-image "About Actions Runner Controller - GitHub Docs"). It's wise to preinstall the tools you need in your workflows into the custom runner image.

Build and push the image to Docker Hub. I've written more about this step in the [image/README.md](./image/README.md "image/README.md") file. Perform this step before continuing with the rest of the documentation.

With my custom runner image now pushed to Docker Hub, the line in the `values.yml` file would be `docker.io/poser/custom-arc-runner:vX` where `vX` is the tag of the image.

You don't have to opt for a custom image, as you can use the default one. If you do not specify the `runnerImage`, the runner set will use the default one. **Please note**, that the default image for self-hosted ARC systems **is not the same as** `ubuntu-latest` image available for GitHub-hosted runners. **The default self-hosted image does not include everything within** `ubuntu-latest`.

So it's highly likely that you need to create a custom runner image. One option is always to start installing the tools you need **within the workflows**, but of course, this is not the most optimal solution.

## 09 Initialize the ARC System

To initialize the runner set, run the following command next to the `values.yml` file:

```bash
NAMESPACE="arc-systems"
VERSION="0.11.0"
helm install arc \
    --version "${VERSION}" \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    -f values.yml \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller
```

**NOTE**! Make sure to update the `VERSION` variable to the latest version of the runner set or use the specific version you want to use. All releases for `arc` can be found [here](https://github.com/actions/actions-runner-controller/releases "Releases • actions/actions-runner-controller").

**NOTE**! You can change the `NAMESPACE` to your liking, but in such case the remaining commands of this documentation require further adjustments.

## 10 Get a Private Access Token

From your GitHub account, go to _Settings_ -> _Developer settings_ -> _Personal access tokens_ and create a new private access token, or PAT.

Add the following scopes:

- `admin:gpg_key`
- `read:packages`
- `repo`
- `workflow`

Not sure if all of these are needed, but I've added them all just to be safe.

Copy the PAT and save it somewhere safe. You will need it later.

## 11 Initialize The ARC Runners

Again, execute the following command next to the `values.yml` file:

```bash
INSTALLATION_NAME="self-hosted-runners"
NAMESPACE="arc-runners"
GITHUB_CONFIG_URL="https://github.com/user/repo"
GITHUB_PAT="<PAT>"
VERSION="0.11.0"
helm install "${INSTALLATION_NAME}" \
    --version "${VERSION}" \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    -f values.yml \
    --set githubConfigUrl="${GITHUB_CONFIG_URL}" \
    --set githubConfigSecret.github_token="${GITHUB_PAT}" \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set
```

**NOTE**! The `INSTALLATION_NAME` is the name of the runner set. You can use any name you want, but it's a good idea to use a name that is easy to remember and identify. **This is the name you will have to use in the workflow files** to actually get the runners to run the workflows.

**NOTE**! Make sure to update the `VERSION` variable to the latest version of the runner set or use the specific version you want to use.

**NOTE**! Make sure to update the `GITHUB_CONFIG_URL` variable to the URL of your GitHub repository. This is the URL of the repository where you want to run the workflows. The runner will not be able to run workflows from other repositories. It can be both a public or a private repository.

**NOTE**! Make sure to update the `GITHUB_PAT` variable to the PAT you created in step 10.

## 12 Verify The Runners

To check the status of the runner set, run the following command:

```bash
helm list -A
```

You should see the following output:

```bash
NAME               	NAMESPACE  	REVISION	UPDATED                                	STATUS  	CHART                                 	APP VERSION
arc                	arc-systems	1       	2025-06-10 10:05:54.123735703 +0000 UTC	deployed	gha-runner-scale-set-controller-0.11.0	0.11.0
self-hosted-runners	arc-runners	1       	2025-06-10 10:10:27.055450595 +0000 UTC	deployed	gha-runner-scale-set-0.11.0           	0.11.0
```

To check the status of the pods, run the following command:

```bash
kubectl get pods -n arc-systems
```

You should see the following output:

```bash
NAME                                    READY   STATUS    RESTARTS   AGE
arc-gha-rs-controller-57c67d4c7-wc5wb   1/1     Running   0          15m
self-hosted-runners-754b578d-listener   1/1     Running   0          10m
```

No pods should be restarting. However, it might take a while for the runners to be ready. So after the initial deployment, you might need to wait for a few minutes before the runners are ready. If they are restarting or exiting after 5 minutes, you might need to check the logs for the pods.

One common problem can be that you have named the runner set with a conflicting name. One repository can not have multiple runner sets with the same name.

Later on, when you've got actual workflows running, you can check the status of the workflow runner pods by running the following command:

```bash
kubectl get pods -n arc-runners
```

## 13 Logs & Troubleshooting

If you encounter some issues here, you can always check the logs for the pods. First identify the names of the relevant pods under the `NAME` column from the output of the following command.

```bash
kubectl get pods -n arc-systems
```

If the names were to be `arc-gha-rs-controller-57c67d4c7-wc5wb` and `self-hosted-runners-754b578d-listener`, the logs would be available with:

```bash
kubectl logs arc-gha-rs-controller-57c67d4c7-wc5wb -n arc-systems
```

and

```bash
kubectl logs self-hosted-runners-754b578d-listener -n arc-runners
```

respectively.

### Other Useful `kubectl logs` Options

If you need to follow logs as they happen, e.g. stream logs in real-time (like `tail -f`), you can use the following command:

```bash
kubectl logs -f arc-gha-rs-controller-57c67d4c7-wc5wb -n arc-systems
```

(Assuming the aforementioned names of the pods.)

To display only the last _N_ lines of the logs, you can use the following command:

```bash
kubectl logs --tail=20 arc-gha-rs-controller-57c67d4c7-wc5wb -n arc-systems
```

To show logs newer than a specified duration (e.g., `1h`, `5m`, `30s`), you can use the following command:

```bash
kubectl logs --since=5m arc-gha-rs-controller-57c67d4c7-wc5wb -n arc-systems
```

To view logs of a previous incarnation of a container (if it restarted), you can use the following command:

```bash
kubectl logs -p arc-gha-rs-controller-57c67d4c7-wc5wb -n arc-systems
```

More documentation about `kubectl logs` can be found [here](https://kubernetes.io/docs/reference/kubectl/quick-reference/ "kubectl Quick Reference | Kubernetes").

## X0 Automated Scripts

If you are inpatient, you can use the automated scripts to install all the required dependencies and initialize the runner set with little effort. Please still read through the scripts to understand what you are literally executing on your own machine!

**Step 1: Fetch the setup scripts.**

```bash
curl -LO https://raw.githubusercontent.com/joonarafael/gh-arc-dind-kubernetes-for-dummies/refs/heads/master/scripts/a-setup.sh
chmod u+x ./a-setup.sh
./a-setup.sh
```

Enter your password if prompted.

**Step 2: Run the Docker installation script.**

At the end, the script will ask to re-evaluate your group membership. Enter your password.

```bash
./b-docker.sh
```

Type in `docker ps -a` to ensure that Docker is running and you've got connection to the Docker socket.

**Step 3: Run the dependencies installation & runner set initialization script.**

```bash
GO_VERSION=1.24.4
KIND_VERSION=0.29.0
GITHUB_CONFIG_URL="https://github.com/user/repo"
GITHUB_PAT="<PAT>"
./c-run.sh $GO_VERSION $KIND_VERSION $GITHUB_CONFIG_URL $GITHUB_PAT
```

Please replace the `GITHUB_CONFIG_URL` and `GITHUB_PAT` with your own values. The Go and Kind versions can be also updated, if new versions are available.

## X1 Nuclear Bomb

If everything went wrong, you can always delete the runner set and start over. This following command will permanently delete everything Kubernetes-related from all namespaces. Please be careful with this command as you will lose everything on your machine.

```bash
helm ls -a --all-namespaces | awk 'NR > 1 { print  "-n "$2, $1}' | xargs -L1 helm delete &&
kubectl delete all --all --all-namespaces &&
kind delete cluster
```
