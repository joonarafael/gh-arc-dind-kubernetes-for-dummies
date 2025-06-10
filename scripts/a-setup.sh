#!/usr/bin/env bash

#########################################
# SETUP TO FETCH ALL THE REQUIRED SCRIPTS

curl -LO https://raw.githubusercontent.com/joonarafael/gh-arc-dind-kubernetes-for-dummies/refs/heads/master/scripts/b-docker.sh b-docker.sh
curl -LO https://raw.githubusercontent.com/joonarafael/gh-arc-dind-kubernetes-for-dummies/refs/heads/master/scripts/c-run.sh c-run.sh
curl -LO https://raw.githubusercontent.com/joonarafael/gh-arc-dind-kubernetes-for-dummies/refs/heads/master/scripts/d-deps.sh d-deps.sh

chmod u+x b-docker.sh
chmod u+x c-run.sh
chmod u+x d-deps.sh
