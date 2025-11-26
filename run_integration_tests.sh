#!/bin/bash

# NextMove Integration Tests Runner Script
# This script helps run integration tests on different devices

set -e

echo "🚀 NextMove Integration Tests Runner"
echo "======================================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"
echo ""

# Function to run tests
run_tests() {
    local device=$1
    local test_file=$2
    
    echo "📱 Running tests on device: $device"
    echo "📄 Test file: $test_file"
    echo ""
    
    if [ -z "$device" ]; then
        flutter test "$test_file"
    else
        flutter test "$test_file" -d "$device"
    fi
}

# Show available devices
echo "📱 Available devices:"
flutter devices
echo ""

# Parse command line arguments
TEST_FILE="integration_test/app_test.dart"
DEVICE=""
USE_DRIVER=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--device)
            DEVICE="$2"
            shift 2
            ;;
        -f|--file)
            TEST_FILE="$2"
            shift 2
            ;;
        --driver)
            USE_DRIVER=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -d, --device DEVICE    Specify device ID to run tests on"
            echo "  -f, --file FILE        Specify test file (default: integration_test/app_test.dart)"
            echo "  --driver               Use flutter drive instead of flutter test"
            echo "  -h, --help             Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Run on default device"
            echo "  $0 -d chrome                          # Run on Chrome"
            echo "  $0 -f integration_test/features_test.dart  # Run specific test file"
            echo "  $0 --driver                           # Use flutter drive"
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Check if test file exists
if [ ! -f "$TEST_FILE" ]; then
    echo "❌ Test file not found: $TEST_FILE"
    exit 1
fi

# Run tests
echo "🧪 Starting integration tests..."
echo ""

if [ "$USE_DRIVER" = true ]; then
    echo "Using flutter drive..."
    if [ -z "$DEVICE" ]; then
        flutter drive \
            --driver=test_driver/integration_test.dart \
            --target="$TEST_FILE"
    else
        flutter drive \
            --driver=test_driver/integration_test.dart \
            --target="$TEST_FILE" \
            -d "$DEVICE"
    fi
else
    run_tests "$DEVICE" "$TEST_FILE"
fi

echo ""
echo "✅ Tests completed!"
