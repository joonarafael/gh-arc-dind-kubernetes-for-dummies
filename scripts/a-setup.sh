#!/usr/bin/env bash

#########################################
# SETUP TO FETCH ALL THE REQUIRED SCRIPTS

curl -LO https://raw.githubusercontent.com/joonarafael/gh-arc-dind-kubernetes-for-dummies/refs/heads/master/scripts/b-docker.sh
curl -LO https://raw.githubusercontent.com/joonarafael/gh-arc-dind-kubernetes-for-dummies/refs/heads/master/scripts/c-run.sh
curl -LO https://raw.githubusercontent.com/joonarafael/gh-arc-dind-kubernetes-for-dummies/refs/heads/master/scripts/d-deps.sh
curl -LO https://raw.githubusercontent.com/joonarafael/gh-arc-dind-kubernetes-for-dummies/refs/heads/master/scripts/e-clusters.sh
curl -LO https://raw.githubusercontent.com/joonarafael/gh-arc-dind-kubernetes-for-dummies/refs/heads/master/scripts/f-clean.sh

chmod u+x ./b-docker.sh
chmod u+x ./c-run.sh
chmod u+x ./d-deps.sh
chmod u+x ./e-clusters.sh
chmod u+x ./f-clean.sh
