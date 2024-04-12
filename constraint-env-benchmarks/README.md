## Build the image
Ensure that the Dockerfile are in the directory.

```
docker build -f Dockerfile -t constraint-env-bench:latest .
```

## Running the image
```
docker run -d -it -m 3g --cpus 4 -p 0.0.0.0:9200:9200 constraint-env-bench:latest
```

## SSH in the container
```
docker exec -i -t <ContainerID> bash
```

## Running K-NN inside
```
chown -R 1000:1000 `pwd`
```

```
su `id -un 1000` -c "whoami && java -version && ./gradlew run -Dsimd.enabled=false -Djvm.heap.size=2g"
```

## Plugin Install Command
```
./bin/opensearch-plugin install file:///home/ci-runner/k-NN/artifacts/plugins/opensearch-knn-2.14.0.0-SNAPSHOT.zip  --verbose --batch
```

```
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/ci-runner/opensearch-2.14.0-SNAPSHOT/plugins/opensearch-knn/lib
```