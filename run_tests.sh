#!/usr/bin/env bash

set -xeuo pipefail

# Profiling file (no profiling if empty)
profile_file=
profile_prefix=''
if [ $# -gt 0 ] && [ "$1" == "--profile" ]; then
    profile_prefix='profile_file'
fi

# Using the Docker image developed for ALE
docker_image=w0rp/ale
docker_image_id=67896c9c2c0f

docker images -q "${docker_image}" | grep "^${docker_image_id}" > /dev/null \
    || docker pull "${docker_image}"

vim_binaries=$(docker run --rm "${docker_image}" ls /vim-build/bin \
             | grep -E '^(neo)?vim' )

set +e
exit_status=0

# Run tests
for vim in ${vim_binaries}; do

    # Collect profiling data if an output file name is provided
    if [ "${profile_prefix}" != '' ]; then
        profile_file="${profile_prefix}_${vim}"
    fi

    find test -name '*.swp' -delete

	# Run tests with mocked Python
	#
	# Add the test folder to the beginning of PATH to replace
	# python with the mock script there.
    docker run \
        --rm \
        -a stderr \
        -e VADER_OUTPUT_FILE=/dev/stderr \
        -e VIM_PROFILE_FILE="${profile_file}" \
        -v "$PWD:/testplugin" \
        -v "$PWD/test:/home"\
        -w /testplugin \
        "${docker_image}" \
		bash -c "export PATH=\$(pwd)/test:\$PATH; /vim-build/bin/${vim} -u test/vimrc '+Vader! ./test/*.vader'" 2>&1

    # shellcheck disable=SC2181
    if [ "$?" -ne 0 ]; then
        exit_status=1
    fi
done

# Run vint
docker run \
    --rm \
    -a stdout \
    -v "$PWD:/testplugin" \
    -v "$PWD/test:/home"\
    -w /testplugin \
    "${docker_image}" \
        find . -type f -name '*.vim' -exec vint -s '{}' + 2>&1

# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
    exit_status=1
fi

# Run flake8
find . -type f -name '*.py' -exec python -m flake8 '{}' +

# shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
    exit_status=1
fi

exit ${exit_status}
