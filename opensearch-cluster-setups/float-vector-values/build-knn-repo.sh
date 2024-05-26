#
# SPDX-License-Identifier: Apache-2.0
#
# The OpenSearch Contributors require contributions made to
# this file be licensed under the Apache-2.0 license or a
# compatible open source license.
#
# Modifications Copyright OpenSearch Contributors. See
# GitHub history for details.
#
set -ex

pwd

git clone https://github.com/navneet1v/k-NN.git  --branch $KNN_BRANCH --recursive

gcc --version | head -n 1 | cut -d ' ' -f3
echo "Running the scl_setup"
# This is needed if you are using ci-image
bash /usr/local/bin/scl_setup
cd k-NN
chmod 755 ./scripts/build.sh
./scripts/build.sh -v "$OS_VERSION" -s "$IS_SNAPSHOT"
if [ "$IS_SNAPSHOT" == "true" ]
then
    mv /home/ci-runner/k-NN/artifacts/plugins/opensearch-knn-${OS_VERSION}.0-SNAPSHOT.zip /home/ci-runner/k-NN/artifacts/plugins/opensearch-knn.zip
else
    mv /home/ci-runner/k-NN/artifacts/plugins/opensearch-knn-${OS_VERSION}.0.zip /home/ci-runner/k-NN/artifacts/plugins/opensearch-knn.zip
fi