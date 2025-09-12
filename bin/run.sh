#!/usr/bin/env sh

# Synopsis:
# Run the test runner on a solution.

# Arguments:
# $1: exercise slug
# $2: path to solution folder
# $3: path to output directory

# Output:
# Writes the test results to a results.json file in the passed-in output directory.
# The test results are formatted according to the specifications at https://github.com/exercism/docs/blob/main/building/tooling/test-runners/interface.md

# Example:
# ./bin/run.sh two-fer path/to/solution/folder/ path/to/output/directory/

# If any required arguments is missing, print the usage and exit
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "usage: ./bin/run.sh exercise-slug path/to/solution/folder/ path/to/output/directory/"
    exit 1
fi

slug="$1"
solution_dir=$(realpath "${2%/}")
output_dir=$(realpath "${3%/}")
results_file="${output_dir}/results.json"

# Create the output directory if it doesn't exist
mkdir -p "${output_dir}"

echo "${slug}: testing..."

# Run the tests for the provided implementation file and redirect stdout and
# stderr to capture it
# TODO: Replace 'RUN_TESTS_COMMAND' with the command to run the tests
test_output=$(bash ${solution_dir}/test.sh ${slug} 2>&1)

# Write the results.json file based on the exit code of the command that was 
# just executed that tested the implementation file
if [ $? -eq 0 ]; then
    if echo "$test_output" | tail -4 | grep -Pz '^ *[[:digit:]]+ TEST CASES WERE EXECUTED\n *[[:digit:]]+ PASSED\n *[[:digit:]]+ FAILED\n={49}' 2>&1 1>/dev/null; then
        jq -n '{version: 1, status: "pass"}' > ${results_file}
    else
        sanitized_test_output=$(printf "${test_output}" | sed '1,/^COMPILE AND RUN TEST$/d' | sed '/warning: ignoring redundant \. \[-Wothers\]/ d' | sed '/test.cob: in paragraph .\(UT-BEFORE-EACH\|UT-AFTER-EACH\|UT-LOOKUP-FILE\|UT-BEFORE\)./ d' )
        sanitized_test_output="${sanitized_test_outputtest} $(printf " \nSOME TESTS WERE NOT PERFORMED. A PARAGRAPH BEING TESTED MUST HAVE FORCED THE PROGRAM EXECUTION TO TERMINATE (E.G. USING STOP RUN, GOBACK, ETC.)")"
        jq -n --arg output "${sanitized_test_output}" '{version: 1, status: "fail", message: $output}' > ${results_file}
    fi
else
    # OPTIONAL: Sanitize the output
    # In some cases, the test output might be overly verbose, in which case stripping
    # the unneeded information can be very helpful to the student
    printf "${test_output}" | grep "COMPILE AND RUN TEST" 2>&1 1>/dev/null
    if [ -f ${solution_dir}/test.cob ] && [ $? -eq 0 ]; then
        sanitized_test_output=$(printf "${test_output}" | sed '1,/^COMPILE AND RUN TEST$/d' | sed '/warning: ignoring redundant \. \[-Wothers\]/ d' | sed '/test.cob: in paragraph .\(UT-BEFORE-EACH\|UT-AFTER-EACH\|UT-LOOKUP-FILE\|UT-BEFORE\)./ d' )
    else
        sanitized_test_output="${test_output} $(printf " \nSOMETHING WENT WRONG DURING TEST SETUP, PLEASE OPEN A TICKET AT: https://github.com/exercism/cobol/issues/new")"
    jq -n --arg output "${sanitized_test_output}" '{version: 1, status: "fail", message: $output}' > ${results_file}
        
    fi

    # OPTIONAL: Manually add colors to the output to help scanning the output for errors
    # If the test output does not contain colors to help identify failing (or passing)
    # tests, it can be helpful to manually add colors to the output
    # colorized_test_output=$(echo "${test_output}" \
    #      | GREP_COLOR='01;31' grep --color=always -E -e '^(ERROR:.*|.*failed)$|$' \
    #      | GREP_COLOR='01;32' grep --color=always -E -e '^.*passed$|$')

    jq -n --arg output "${sanitized_test_output}" '{version: 1, status: "fail", message: $output}' > ${results_file}
fi

echo "${slug}: done"
