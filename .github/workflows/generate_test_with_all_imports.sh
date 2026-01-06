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
    -not -path 'lib/main.dart' \
    -not -path 'lib/firebase_options.dart' \
    -not -path 'lib/l10n/*' \
    -not -path 'lib/config/*' \
    -not -path 'lib/graphql/*' \
    -not -path 'lib/enums/*' \
    -not -path 'lib/theme/*' \
    -not -path 'lib/data/dataProviders/*' \
    -not -name '*_widget.dart' \
    -not -name '*_page.dart' \
    -not -name '*data_provider.dart' \
| awk -v package=$packageName '{gsub("^lib", "", $1); printf("import '\''package:%s%s'\'';\n", package, $1);}' >> "$outputFile"

echo "" >> "$outputFile"
echo "void main() {}" >> "$outputFile"