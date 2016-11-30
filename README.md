# arrayfire-docker

Dockerfile for Building and Using ArrayFire https://github.com/arrayfire/arrayfire.git

## Dependencies

[nvidia-docker](https://github.com/NVIDIA/nvidia-docker)

## Building image

```
nvidia-docker build -t arrayfire .
```

Make sure to modify ArrayFire's
[build arguments](https://github.com/arrayfire/arrayfire-docker/blob/master/Dockerfile#L43)
in the `Dockerfile` to suit your needs prior to building the image.

## Running container

```
nvidia-docker run --rm -ti arrayfire
```

Once running, invoke the
[unified backend](http://arrayfire.org/docs/unifiedbackend.htm) test to show
available devices for each of ArrayFire's backends:

```
./build/test/backend_unified
```

## Compiling stand-alone examples

```
cp -R /opt/arrayfire/share/ArrayFire/examples /root/arrayfire-examples
cd /root/arrayfire-examples && mkdir build && cd build
cmake .. -DArrayFire_DIR=/opt/arrayfire/share/ArrayFire/cmake
make -j8
```

Take a look at the examples
[`README.md`](https://github.com/arrayfire/arrayfire/blob/devel/examples/README.md)
for more information.

### Support and Contact Info

* Google Groups: https://groups.google.com/forum/#!forum/arrayfire-users
* ArrayFire Services:  [Consulting](http://arrayfire.com/consulting/)  |  [Support](http://arrayfire.com/support/)   |  [Training](http://arrayfire.com/training/)
* ArrayFire Blogs: http://arrayfire.com/blog/
* Email: <mailto:technical@arrayfire.com>
