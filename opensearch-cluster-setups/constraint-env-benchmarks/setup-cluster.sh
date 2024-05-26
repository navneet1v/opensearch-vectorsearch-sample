#!/bin/bash
set -ex
cd /home/ci-runner/opensearch

# Enable the jemalloc and sets the path for k-NN libraries
export LD_PRELOAD=/usr/lib64/libjemalloc.so.1
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/ci-runner/opensearch/plugins/opensearch-knn/lib

function usage() {
    echo "Usage: $0 [args]"
    echo ""
    echo "Arguments:"
    echo -e "-h HEAP\t[Required] Heap size for Opensearch cluster"
    echo -e "-c CB_LIMIT\t[Required] Circuit Breaker limit for kNN"
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

rm config/opensearch.yml
touch config/opensearch.yml

cat <<EOT >> config/opensearch.yml
network.host: 0.0.0.0
cluster.name: "opensearch"
http.port: 9200
discovery.type: single-node
knn.faiss.avx2.disabled: true
knn.memory.circuit_breaker.limit: $CB_LIMIT%
EOT

sed -i -e "s/-Xms1g/-Xms$HEAP/g" config/jvm.options
sed -i -e "s/-Xmx1g/-Xmx$HEAP/g" config/jvm.options

DIR=/home/ci-runner/opensearch/plugins/opensearch-knn

if [ ! -d "$DIR" ]; then
    echo "Installing k-NN plugin"
    ./bin/opensearch-plugin install file:///home/ci-runner/k-NN/artifacts/plugins/opensearch-knn.zip  --verbose --batch
fi
echo "Running Opensearch"

./bin/opensearch