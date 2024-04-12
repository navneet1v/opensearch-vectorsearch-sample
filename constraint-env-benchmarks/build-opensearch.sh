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
    
    git clone https://github.com/navneet1v/k-NN.git  --branch memory-fix --recursive
    # go inside k-NN
    cd ./k-NN
    echo "Starting setup lib"
    pwd
    gcc --version | head -n 1 | cut -d ' ' -f3
    echo "Running the scl_setup"
    # This is needed if you are using ci-image
    bash /usr/local/bin/scl_setup
    # git submodule update --init -- jni/external/nmslib
    # git submodule update --init -- jni/external/faiss

    # cd jni/external/faiss
    # git branch
    # git status
    # git apply --ignore-space-change --ignore-whitespace --3way ../../patches/faiss/0001-Custom-patch-to-support-multi-vector.patch
    # rm ../../patches/faiss/0001-Custom-patch-to-support-multi-vector.patch
    # git apply --ignore-space-change --ignore-whitespace --3way ../../patches/faiss/0002-Enable-precomp-table-to-be-shared-ivfpq.patch
    # rm ../../patches/faiss/0002-Enable-precomp-table-to-be-shared-ivfpq.patch


    # cd ../nmslib
    # git apply --ignore-space-change --ignore-whitespace --3way ../../patches/nmslib/0001-Initialize-maxlevel-during-add-from-enterpoint-level.patch
    # rm ../../patches/nmslib/0001-Initialize-maxlevel-during-add-from-enterpoint-level.patch
    # cd ../../
    # cd ..
    # pwd
    chmod 755 ./scripts/build.sh
    ./scripts/build.sh -v "2.14.0" -s "true"

    # return back
    #cd ..
}

# For custom code of Opensearch, we will need to fix this function
create_opensearch_min_dis() {
    wget 'https://artifacts.opensearch.org/snapshots/core/opensearch/2.14.0-SNAPSHOT/opensearch-min-2.14.0-SNAPSHOT-linux-x64-latest.tar.gz'
    tar -xvf opensearch-min-2.14.0-SNAPSHOT-linux-x64-latest.tar.gz
    rm -rf opensearch-min-2.14.0-SNAPSHOT-linux-x64-latest.tar.gz
}

create_opensearch_min_dis
build_knn


