#!/usr/bin/env sh
#
# This script will:
#    1. build the target project using cmake and make
#    2. [optional] make suppresions from a reference binary, if provided.
#    3. run valgrind
#    4. report on the results
#
# It expects the following variables:
#    BUILD_PATH: The path where to run cmake and build
#    BINARY_PATH: The path where the binaries are located
#    REPORT_FILE: The file that will contain valgrind's report
#    TEST_BIN: Binary to test with valgrind
#    SUPPRESSION_BIN: Binary to use as base of suppression

BUILD_PATH=${BUILD_PATH:-.}
BINARY_PATH=${BINARY_PATH:-$BUILD_PATH}
REPORT_FILE=${REPORT_FILE:-/tmp/valgrind_report}
TEST_BIN=${TEST_BIN:-mem_test}

#######################################################
# Build application using cmake and make on BUILD_PATH
######################################################
buildBinaries() {
  echo "Building application..."
  cd "${BUILD_PATH}" || exit 1
  cmake -DCMAKE_BUILD_TYPE=Debug || exit 1
  make || exit 1
}

####################################
# Generate a random supression name
####################################
randomSuppressionName() {
  echo "suppresion_$(
    head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32
    echo ''
  )"
}
############################################
# Generate suppressions from SUPPRESSION_BIN
############################################
makeSuppressions() {
  if [ -z "$SUPPRESSION_BIN" ]; then
    echo "No suppressions"
  else
    echo "Generating suppressions file"
    valgrind --gen-suppressions=all \
      --leak-check=full \
      --show-leak-kinds=all \
      ./"${SUPPRESSION_BIN}" 2>/tmp/suppressions
    # Remove useless lines
    sed -i '/^==/ d' /tmp/suppressions
    # Replace suppresion names with random id
    while grep "insert_a_suppression_name_here" /tmp/suppressions; do
      sed -i 's@insert_a_suppression_name_here@'"$(randomSuppressionName)"'@' /tmp/suppressions
    done
  fi
}

################
# Run valgrind
###############
runValgrind() {
  cd "${BINARY_PATH}" || exit 1
  echo "Checking for leaks..."
  if [ -z ${SUPPRESSION_BIN+x} ]; then
    valgrind --tool=memcheck \
      --leak-check=yes \
      --show-reachable=yes \
      --num-callers=20 \
      --track-fds=yes \
      ./"${TEST_BIN}" 2>"${REPORT_FILE}"
  else
    valgrind --tool=memcheck \
      --leak-check=yes \
      --show-reachable=yes \
      --num-callers=20 \
      --track-fds=yes \
      --suppressions=/tmp/suppressions \
      ./"${TEST_BIN}" 2>"${REPORT_FILE}"
  fi
}

###################
# Check for errors
###################
checkResults() {
  if grep -q "0 errors from 0 contexts" "${REPORT_FILE}"; then
    echo "No memory leak errors found."
  else
    echo "FAILED: There are memory leaks. Refer to the README file of run Valkyrie locally to get more info."
    cat "${REPORT_FILE}"
    exit 1
  fi
}

# Execution
buildBinaries
makeSuppressions
runValgrind
checkResults
