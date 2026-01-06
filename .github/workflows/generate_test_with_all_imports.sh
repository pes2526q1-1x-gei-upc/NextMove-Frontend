#!/bin/sh
outputFile="test/coverage_test.dart"
packageName="$(cat pubspec.yaml| grep '^name: ' | awk '{print $2}')"

if [ "$packageName" = "" ]; then
    echo "Run $0 from the root of your Dart/Flutter project"
    exit 1
fi

echo "// ignore_for_file: unused_import" > "$outputFile"
find lib -name '*.dart' \
    -not -name '*.g.dart' \
    -not -name '*_state.dart' \
    -not -name '*_event.dart' \
    -not -path '*/main.dart' \
    -not -path '*/firebase_options.dart' \
    -not -path '*/app_localizations*.dart' \
    -not -path '*/queries.dart' \
    -not -path '*/mutations.dart' \
    -not -path '*/l10n/*' \
    -not -path '*/config/*' \
    -not -path '*/graphql/*' \
    -not -path '*/enums/*' \
    -not -path '*/theme/*' \
    -not -name '*_*data_provider.dart' \
| awk -v package=$packageName '{gsub("^lib", "", $1); printf("import '\''package:%s%s'\'';\n", package, $1);}' >> "$outputFile"

echo "" >> "$outputFile"
echo "void main() {}" >> "$outputFile"