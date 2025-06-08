# GitHub Actions Runner Controller for Kubernetes

Self-hosted runners for GitHub Actions. Run all your workflows on your own infrastructure.

Configured to run on an automatically scaled set of runners, run as a Kubernetes controller. Setup to use Docker in Docker (DinD) to run the runners. Documentation includes the additional steps to use your custom runner image as the base image for the runners.

**This documentation has been composed from my own notes. After many hours of trial and error, I've finally got it working and decided to write the notes down.**

If you've got any additional questions or feedback, please feel free to send me message or open a issue/PR.
