# Workflow

## Branches
- `dev`: all current work, pushed after every working change.
- `main`: stable releases only. Merge `dev` → `main`, tags and GitHub Releases **only when the owner says so**.

## Versions
- Version = date `YYYY.MM.DD`; `-dev` suffix on `dev`, none on `main`. Bump to today's date with the first change of each working day.
- `pubspec.yaml` versions are semver, which forbids leading zeros: write `2026.11.5-dev`, not `2026.11.05-dev`
  (shown to people as `2026.11.05`). Example: `2026.10.30-dev+30435889`. The part after `+` is the Android `versionCode` = **30 000 000 + minutes since 2026-01-01 UTC**, so it always grows
  (Android refuses to install a lower one). Compute it at build time and pass `--build-number=<code>`.
- Record each version in `CHANGELOG.md` and `docs/STATUS.md`.

## Commits
Conventional Commits in English (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, `test:`), one logical change each.

## Build an APK
Gradle does not run in Claude's sandbox; build in a normal terminal:

```powershell
$code = 30000000 + [int]((Get-Date).ToUniversalTime() - [datetime]'2026-01-01').TotalMinutes
flutter build apk --release --split-per-abi --build-number=$code --dart-define-from-file=config.json
```

APKs land in `build/app/outputs/flutter-apk/` (`app-arm64-v8a-release.apk` for modern phones).
Release builds are signed with the **debug key** until a release keystore is created (then: `android/key.properties`,
never committed, plus a new Android OAuth client with the release SHA-1, see docs/GOOGLE.md).

## Checks before a commit
```powershell
flutter analyze
flutter test
$env:CAL_SHOTS='<folder>'; flutter test test/screens_test.dart   # optional: PNG renders to compare with the mockup
```

## End of a working session
Update `docs/STATUS.md` (state, next steps, traps), tick `docs/TODO.md`, add to `CHANGELOG.md`, commit and push `dev`.

## Secrets
Keystores, `key.properties`, `google-services.json`, OAuth client secrets: never in the repo (`.gitignore`).
The web OAuth client ID in `config.json` is public by design and may be committed.
