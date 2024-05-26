## Build the image
Ensure that the Dockerfile are in the directory.

### Float Vector Values Version
```
docker build -f Dockerfile_3_0_0_float_vector_values -t float-vector-values:3-0 .
```

### Baseline Version
```
docker build -f Dockerfile_3_0_0_baseline -t float-vector-values:3-0-baseline .
```


## Running the image
### FloatVector Values
```
docker run -d -it -p 0.0.0.0:9200:9200 float-vector-values:3-0
```

### Baseline
```
docker run -d -it -p 0.0.0.0:9200:9200 float-vector-values:3-0-baseline
```

## SSH in the container
```
docker exec -i -t <ContainerID> bash
```