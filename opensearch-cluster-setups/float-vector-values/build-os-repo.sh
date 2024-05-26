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

git clone https://github.com/navneet1v/Opensearch.git  --branch $OS_BRANCH

cd Opensearch
./gradlew publishToMavenLocal -Drepos.mavenLocal=true
./gradlew :distribution:archives:linux-tar:assemble -Drepos.mavenLocal=true
cp distribution/archives/linux-tar/build/distributions/opensearch-min-${OS_VERSION}-SNAPSHOT-linux-x64.tar.gz .
tar -xvf opensearch-min-${OS_VERSION}-SNAPSHOT-linux-x64.tar.gz
mv opensearch-${OS_VERSION}-SNAPSHOT opensearch
mv opensearch /home/ci-runner/
cd ..