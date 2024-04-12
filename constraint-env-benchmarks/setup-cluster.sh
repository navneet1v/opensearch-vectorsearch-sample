#!/bin/bash
set -ex
cd /home/ci-runner/opensearch-2.14.0-SNAPSHOT

#./bin/opensearch-plugin install file:///home/ci-runner/k-NN/artifacts/plugins/opensearch-knn-2.14.0.0-SNAPSHOT.zip  --verbose --batch

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/ci-runner/opensearch-2.14.0-SNAPSHOT/plugins/opensearch-knn/lib

function usage() {
    echo "Usage: $0 [args]"
    echo ""
    echo "Arguments:"
    echo -e "-v VERSION\t[Required] OpenSearch version."
    echo -e "-q QUALIFIER\t[Optional] Version qualifier."
    echo -e "-s SNAPSHOT\t[Optional] Build a snapshot, default is 'false'."
    echo -e "-p PLATFORM\t[Optional] Platform, ignored."
    echo -e "-a ARCHITECTURE\t[Optional] Build architecture, ignored."
    echo -e "-o OUTPUT\t[Optional] Output path, default is 'artifacts'."
    echo -e "-h help"
}


while getopts ":h:c:" arg; do
    case $arg in
        h)
            HEAP=$OPTARG
            ;;
        c)
            CB_LIMIT=$OPTARG
            ;;
        :)
            echo "Error: -${OPTARG} requires an argument"
            usage
            exit 1
            ;;
        ?)
            echo "Invalid option: -${arg}"
            exit 1
            ;;
    esac
done

echo "CB"
echo $CB_LIMIT

cat <<EOT >> config/opensearch.yml
network.host: 0.0.0.0
cluster.name: "opensearch"
http.port: 9200
discovery.type: single-node
knn.faiss.avx2.disabled: true
knn.memory.circuit_breaker.limit: $CB_LIMIT%
EOT

sed -i -e "s/-Xms$HEAP/-Xms$HEAP/g" config/jvm.options

echo "Running Opensearch"
./bin/opensearch-plugin install file:///home/ci-runner/k-NN/artifacts/plugins/opensearch-knn-2.14.0.0-SNAPSHOT.zip  --verbose --batch
./bin/opensearch