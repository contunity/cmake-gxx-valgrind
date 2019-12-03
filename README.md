This image will build a target C or C++ project using cmake, run valgrind and
report on the results. It is mostly intended to be run inside CI pipelines.

## Usage

To simply check for leaks on a project, run:

```shell script
docker run -ti \
  -e BUILD_PATH=/project \
  -e TEST_BIN=my_project_bin \
  -v /path/to/project:/project \
  contunity/cmake-gxx-valgrind:ubuntu-18.04
```

Or the equivalent on Gitlab's pipeline configuration:

```yaml
memory-leaks:
  image: contunity/cmake-gxx-valgrind
  stage: test
  variables:
    TEST_BIN: my_project_bin
  script:
    - check-leaks
```

The following environment variables can be used:

| Variable        | Default              | Description                               |
|-----------------|----------------------|-------------------------------------------|
| BUILD_PATH      | .                    | The path where cmake should be ran        |
| BINARY_PATH     | .                    | The path of the generated binaries        |
| REPORT_FILE     | /tmp/valgrind_report | Where to store Valgrind's report          |
| TEST_BIN        | mem_test             | Target binary to run Valgrind on          |
| SUPPRESSION_BIN |                      | Benchmark binary to generate suppressions |