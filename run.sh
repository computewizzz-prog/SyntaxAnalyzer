#!/bin/bash

# Script to run syntax analyzer on all test cases

EXECUTABLE="./syntax_analyzer"
TEST_DIR="test"
OUTPUT_FILE="test_results.txt"

# Check if executable exists
if [ ! -f "$EXECUTABLE" ]; then
    echo "Error: Executable '$EXECUTABLE' not found. Please run 'make' first."
    exit 1
fi

# Create test directory if it doesn't exist and copy test files
if [ ! -d "$TEST_DIR" ]; then
    echo "Creating test directory and copying test files..."
    mkdir -p "$TEST_DIR"
    cp test*.c "$TEST_DIR/" 2>/dev/null || true
fi

# Check if test directory has files
if [ ! "$(ls -A $TEST_DIR/*.c 2>/dev/null)" ]; then
    echo "Error: No test files found in '$TEST_DIR' directory."
    echo "Please ensure test files (*.c) are in the test directory."
    exit 1
fi

# Clear previous output file
> "$OUTPUT_FILE"

echo "Running Syntax Analyzer on all test cases..."
echo "=============================================="

# Also output to console and file simultaneously
{
    echo "Running Syntax Analyzer on all test cases..."
    echo "=============================================="
    echo

    # Run tests on all .c files in test directory
    for test_file in "$TEST_DIR"/*.c; do
        if [ -f "$test_file" ]; then
            echo "Testing: $(basename "$test_file")"
            echo "----------------------------------------"
            
            # Run the syntax analyzer and capture both stdout and stderr
            if "$EXECUTABLE" "$test_file"; then
                echo "✓ SUCCESS: Syntax analysis completed successfully"
            else
                echo "✗ FAILED: Syntax analysis failed with errors"
            fi
            
            echo "----------------------------------------"
            echo
        fi
    done

    echo "=============================================="
    echo "All tests completed."
    echo "Output saved to $OUTPUT_FILE"
} | tee "$OUTPUT_FILE"

echo
echo "Test Results Summary:"
echo "---------------------"

# Count successful and failed tests
success_count=$(grep -c "✓ SUCCESS" "$OUTPUT_FILE")
failure_count=$(grep -c "✗ FAILED" "$OUTPUT_FILE")
total_count=$((success_count + failure_count))

echo "Total tests run: $total_count"
echo "Successful: $success_count"
echo "Failed: $failure_count"

if [ $failure_count -eq 0 ]; then
    echo "🎉 All tests passed!"
    exit 0
else
    echo "⚠️  Some tests failed. Check the output above for details."
    exit 1
fi