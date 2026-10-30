# Google Calendar setup

The app talks to the Google Calendar API directly from the phone (no backend). Android sign-in needs a Google Cloud project with two OAuth clients. This is a one-time setup done by the owner in the Google Cloud console.

## 1. Project and API
1. Open https://console.cloud.google.com/ and create a project, e.g. `calendar-kixelar`.
2. *APIs & Services → Library* → enable **Google Calendar API**.

## 2. OAuth consent screen (*Google Auth Platform*)
1. *Branding*: app name `Calendar`, support email, developer email.
2. *Audience*: **External**. While the app is in **Testing**, only accounts added under *Test users* can sign in (max 100). Add your own Google account there.
3. *Data access*: add the scope `https://www.googleapis.com/auth/calendar`.
   This is a *sensitive* scope: fine for testing; publishing the app to everyone later requires Google verification.

## 3. OAuth clients (*Clients → Create client*)
1. **Android** client:
   - package name: `com.kixelar.calendar`
   - SHA-1 of the signing key. Builds are signed with the debug key for now:
     `1E:E5:1B:CA:39:AD:AA:CF:91:82:FE:E9:D5:78:B5:A5:B7:5F:3F:F2`
     (check with `keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -storepass android -alias androiddebugkey`).
     When a release key is added, create a second Android client with its SHA-1.
2. **Web application** client (no redirect URIs needed). Its **client ID** is what the app needs.

## 4. Give the client ID to the build
The web client ID is not a secret. Put it in `config.json` at the repo root:

```json
{ "GOOGLE_SERVER_CLIENT_ID": "1234567890-abc.apps.googleusercontent.com" }
```

and build with `--dart-define-from-file=config.json` (see docs/WORKFLOW.md). Without it the "Sign in with Google" button shows a message instead of signing in.

## Troubleshooting
- `[16] Account reauth failed` / `developer error` / sign-in closes at once: the SHA-1 or package name of the Android client does not match the APK, or your account is not a test user.
- `403 accessNotConfigured`: Calendar API is not enabled in the project.
