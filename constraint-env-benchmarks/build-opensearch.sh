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

build_knn() {
    if [ "$OS_VERSION" == "2.14.0" ]
    then
        if [ "$MEMORY_FIX" == "true" ]
        then
            git clone https://github.com/navneet1v/k-NN.git  --branch memory-fix --recursive
        else
            KNN_BRANCH=$(echo "$OS_VERSION" | rev | cut -c3- | rev)
            git clone https://github.com/opensearch-project/k-NN.git  --branch 2.x --recursive
        fi
    else
        KNN_BRANCH=$(echo "$OS_VERSION" | rev | cut -c3- | rev)
        git clone https://github.com/opensearch-project/k-NN.git --branch $KNN_BRANCH --recursive
    fi
    # go inside k-NN
    cd ./k-NN
    #git reset --hard 172dc846c96fcaa2c7b0fc55df719526f9f60379
    echo "Starting setup lib"
    pwd
    gcc --version | head -n 1 | cut -d ' ' -f3
    echo "Running the scl_setup"
    # This is needed if you are using ci-image
    bash /usr/local/bin/scl_setup

    chmod 755 ./scripts/build.sh
    ./scripts/build.sh -v "$OS_VERSION" -s "$IS_SNAPSHOT"
    if [ "$IS_SNAPSHOT" == "true" ]
    then
        mv /home/ci-runner/k-NN/artifacts/plugins/opensearch-knn-${OS_VERSION}.0-SNAPSHOT.zip /home/ci-runner/k-NN/artifacts/plugins/opensearch-knn.zip
    else
        mv /home/ci-runner/k-NN/artifacts/plugins/opensearch-knn-${OS_VERSION}.0.zip /home/ci-runner/k-NN/artifacts/plugins/opensearch-knn.zip
    fi
}

# For custom code of Opensearch, we will need to fix this function
create_opensearch_min_dis() {
    if [ "$IS_SNAPSHOT" == "true" ]
    then
        wget https://artifacts.opensearch.org/snapshots/core/opensearch/${OS_VERSION}-SNAPSHOT/opensearch-min-${OS_VERSION}-SNAPSHOT-linux-x64-latest.tar.gz
        tar -xvf opensearch-min-${OS_VERSION}-SNAPSHOT-linux-x64-latest.tar.gz
        rm -rf opensearch-min-${OS_VERSION}-SNAPSHOT-linux-x64-latest.tar.gz
        mv opensearch-${OS_VERSION}-SNAPSHOT opensearch
    else
        wget https://artifacts.opensearch.org/releases/core/opensearch/${OS_VERSION}/opensearch-min-${OS_VERSION}-linux-x64.tar.gz
        tar -xvf opensearch-min-${OS_VERSION}-linux-x64.tar.gz
        rm -rf opensearch-min-${OS_VERSION}-linux-x64.tar.gz
        mv opensearch-${OS_VERSION} opensearch
    fi
    
}

create_opensearch_min_dis
build_knn
