# arrayfire-docker

Dockerfile for Building and Using ArrayFire https://github.com/arrayfire/arrayfire.git

## Dependencies

[nvidia-docker](https://github.com/NVIDIA/nvidia-docker)

## Building image

Make sure to modify ArrayFire's build arguments in the `Dockerfile` to suit
your needs prior to running the following command:

```
nvidia-docker build -t arrayfire .
```

## Running container

```
nvidia-docker run --rm -ti arrayfire
```

