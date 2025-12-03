#!/bin/sh

outputFile="$(pwd)/test/coverage_test.dart"
packageName="$(cat pubspec.yaml| grep '^name: ' | awk '{print $2}')"

if [ "$packageName" = "" ]; then
    echo "Run $0 from the root of your Dart/Flutter project"
    exit 1
fi

echo "// ignore_for_file: unused_import" > "$outputFile"
find lib -name '*.dart' | grep -v '.g.dart' | grep -v 'generated_plugin_registrant' | grep -v '_state\.dart$' | grep -v '_event\.dart$' | grep -v 'main\.dart$' | grep -v 'firebase_options\.dart$' | grep -v 'app_localizations.*\.dart$' | grep -v '_widget\.dart$' | grep -v '_page\.dart$' | grep -v 'queries\.dart$' | grep -v '/presentacion/' | grep -v '/config/' | grep -v 'remote_.*data_provider\.dart$' | grep -v 'recorded_route_data_provider\.dart$' | grep -v '/data/dataProviders/' | awk -v package=$packageName '{gsub("^lib", "", $1); printf("import '\''package:%s%s'\'';\n", package, $1);}' >> "$outputFile"
echo "" >> "$outputFile"
echo "void main() {}" >> "$outputFile"

flutter test --coverage
lcov --ignore-errors unused,unused --remove coverage/lcov.info '*/main.dart' '*/firebase_options.dart' '*/app_localizations*.dart' '*/graphql/*' '*/presentacion/*' '*/config/*' '*/data/dataproviders/*remote*' '*/datos/dataproviders/*remote*' '*/data/dataProviders/*' '*/recorded_route_data_provider.dart' -o coverage/lcov.info
genhtml coverage/lcov.info -o coverage/html | grep "lines.......:"