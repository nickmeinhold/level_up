## CI Settings

ci: flutter

## Test Settings

test-command: flutter test
coverage-threshold: 80

Note: Coverage threshold applies to Dart/Flutter tests. Cloud Functions Jest tests
collect coverage for reporting but don't enforce thresholds (tests are mock-based,
pending rewrite to import real source).
