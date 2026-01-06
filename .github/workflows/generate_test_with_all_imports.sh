#!/bin/sh
outputFile="test/coverage_test.dart"
packageName="$(cat pubspec.yaml| grep '^name: ' | awk '{print $2}')"

if [ "$packageName" = "" ]; then
    echo "Run $0 from the root of your Dart/Flutter project"
    exit 1
fi

echo "// ignore_for_file: unused_import" > "$outputFile"
grep -r --include="*.dart" -l "^" lib/ | grep -v -E "(\.g\.dart$|_state\.dart$|_event\.dart$|.*/main\.dart$|.*/firebase_options\.dart$|.*/l10n/|.*/config/|.*/graphql/|.*/enums/|.*/theme/|.*/data/dataProviders/|_widget\.dart$|_page\.dart$|data_provider\.dart$)" \
| awk -v package=$packageName '{gsub("^lib", "", $1); printf("import '\''package:%s%s'\'';\n", package, $1);}' >> "$outputFile"

echo "" >> "$outputFile"
echo "void main() {}" >> "$outputFile"