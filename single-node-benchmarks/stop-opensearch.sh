#!/bin/bash
set -euxo pipefail

docker compose -f cluster.yml down
