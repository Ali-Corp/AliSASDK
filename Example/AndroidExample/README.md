# alisa-sample-app

Standalone Android sample app for `vn.ali.sa:alisa-sdk:1.2.1`.

## What this project is

- Independent standalone Gradle project outside the main host-app repo
- Uses Maven dependency `vn.ali.sa:alisa-sdk:1.2.1`
- Does not include the `:alisa-sdk` source module

## Requirements

- JDK 17
- Android SDK / Android Studio
- Access to the private package repositories required by the published SDK, unless you explicitly opt into a local Maven repo

## Runtime configuration

The app build does **not** store SDK credentials in source control. Provide these via environment variables or Gradle properties before running the sample:

```bash
export ALISA_SAMPLE_SDK_PROJECT_ID=<sdk-project-id>
export ALISA_SAMPLE_SDK_SUBSCRIPTION_KEY=<sdk-subscription-key>
export ALISA_SAMPLE_HOST_BASE_URL=https://apihoststag.taxidayroi.vn
export ALISA_SAMPLE_COMPANY_ID=30
```

You can also place them in your local `gradle.properties`:

```properties
ALISA_SAMPLE_SDK_PROJECT_ID=...
ALISA_SAMPLE_SDK_SUBSCRIPTION_KEY=...
ALISA_SAMPLE_HOST_BASE_URL=https://apihoststag.taxidayroi.vn
ALISA_SAMPLE_COMPANY_ID=30
```

## Resolve SDK dependency

This project resolves the SDK from private package repositories by default:

1. **GitHub Packages**: `https://maven.pkg.github.com/Ali-Corp/AliSASDK`
2. **GitLab Maven** for internal `vn.ali.*` transitives when required
3. **AliOTT GitHub Packages** for internal `vn.ali.*` transitives when required

The sample does **not** default to any local Maven repository. A local repo is used only when you explicitly provide one.

- GitLab Maven: `https://gitlab.ali.vn/api/v4/projects/377/packages/maven`
- GitHub Packages: `https://maven.pkg.github.com/Ali-Corp/AliOTT`

### Option A: Build with GitHub Packages

Set credentials in your shell:

```bash
export GITHUB_ACTOR=<your-github-username-or-x-access-token>
export GITHUB_TOKEN=<github-package-read-token>
export GITLAB_377_TOKEN=<gitlab-package-read-token>
```

Then build:

```bash
./gradlew :app:assembleDebug
```

### Option B: Build with an explicit local published SDK repo

From the host project root:

```bash
cd "../Android Host App"
./gradlew :alisa-sdk:publishReleasePublicationToLocalRepository --no-build-cache --rerun-tasks
```

Then from this project, opt into that repo explicitly:

```bash
export ALISA_SDK_LOCAL_REPO="../Android Host App/build/repo"
./gradlew :app:assembleDebug
```

If your local Maven repo is elsewhere, point to it with either:

```bash
export ALISA_SDK_LOCAL_REPO=/absolute/path/to/build/repo
```

or in `gradle.properties`:

```properties
alisaSdkLocalRepo=/absolute/path/to/build/repo
```

## Notes

- App identity has been renamed to `vn.ali.sa.sample`
- No GitHub credentials are stored in source control
- SDK runtime credentials are intentionally externalized from source control
- Private package repository credentials are intentionally externalized from source control
- Firebase/google-services is intentionally not configured in this standalone sample
