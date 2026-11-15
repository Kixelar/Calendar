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

## Signing key
- Keystore `<your keystore>` (outside the repo, next to the project folder), alias `calendar`,
  password in `<your password note>`. **The owner must back up this folder outside the computer**:
  without it installed apps can never be updated, and the Google OAuth Android client is tied to its SHA-1.
- `android/key.properties` (git-ignored) points Gradle at it: `storeFile`, `storePassword`, `keyAlias`, `keyPassword`.
  Debug and release builds both use it, so one SHA-1 is registered with Google. Without the file Gradle uses the debug key.
- SHA-1 `<SHA-1 of your key>`,
  SHA-256 `<SHA-256 of your key>`.

## Checks before a commit
```powershell
flutter analyze
flutter test
$env:CAL_SHOTS='<folder>'; flutter test test/screens_test.dart   # optional: PNG renders to compare with the mockup
$env:CAL_LANG='en'                                                # optional: the renders in English (README images)
```

## End of a working session
Update `docs/STATUS.md` (state, next steps, traps), tick `docs/TODO.md`, add to `CHANGELOG.md`, commit and push `dev`.

## Secrets
Keystores, `key.properties`, `google-services.json`, OAuth client secrets: never in the repo (`.gitignore`).
The web OAuth client ID in `config.json` is public by design, but the file is git-ignored (it was committed once, in
the early history).
