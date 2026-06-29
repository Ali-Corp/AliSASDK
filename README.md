# AliSASDK

Prebuilt CocoaPods (and Swift Package Manager) distribution for the ALI super-app MiniApp SDK.

## Release a new CocoaPods version

1. Update the podspec version in `AliSASDK.podspec`:

   ```ruby
   s.version = '<VERSION>'
   ```

2. Rebuild the binary artifacts under `iOS/` from the parent `superapp-ios-sdk` repo. `build.sh` builds `AliSASDK` and its SPM-only dependencies into xcframeworks and copies them in:

   ```sh
   ./build.sh
   ```

   This refreshes:

   - `iOS/AliSASDK.xcframework`
   - `iOS/CodeScanner.xcframework`
   - `iOS/NavigationStackBackport.xcframework`

3. Update dependency versions in `AliSASDK.podspec` (and `Package.swift`) if the frameworks were built against newer dependency versions:

   ```ruby
   s.dependency 'AliMiniAppSDK',     '5.10.4'
   s.dependency 'ExyteMediaPicker',  '~> 2.2'
   s.dependency 'CropViewController','~> 2.8'
   ```

4. Commit the release changes:

   ```sh
   git add AliSASDK.podspec Package.swift iOS/AliSASDK.xcframework iOS/CodeScanner.xcframework iOS/NavigationStackBackport.xcframework
   git commit -m "Release AliSASDK <VERSION>"
   ```

5. Create and push a git tag that exactly matches `s.version`. The podspec source uses `s.version` as the tag, so the tag must be available remotely before pushing the podspec.

   ```sh
   git tag <VERSION>
   git push origin main
   git push origin <VERSION>
   ```

6. Lint the podspec with the private and public sources:

   ```sh
   pod lib lint AliSASDK.podspec --sources='https://github.com/Ali-Corp/PodSpecs.git,https://cdn.cocoapods.org/'
   ```

7. Push the podspec to the private specs repo:

   ```sh
   pod repo push ali-corp-podspecs AliSASDK.podspec --sources='https://github.com/Ali-Corp/PodSpecs.git,https://cdn.cocoapods.org/'
   ```

8. Verify CocoaPods can resolve the released version:

   ```sh
   pod spec which AliSASDK --version=<VERSION>
   ```

## Swift Package Manager

The same tag also serves the SPM distribution. `Package.swift` exposes the `AliSASDK` product as a binary target plus a thin carrier target that wires in the remote dependencies. Consumers add:

```
https://github.com/Ali-Corp/AliSASDK.git
```

### Troubleshooting

#### `Unable to find a specification for AliSASDK`

This usually means CocoaPods is not using the private Ali specs source. Ensure the private specs repo is set up locally and include the private source whenever linting, pushing, or resolving this pod.

```sh
pod repo add ali-corp-podspecs https://github.com/Ali-Corp/PodSpecs.git
pod repo update ali-corp-podspecs
pod spec which AliSASDK --version=<VERSION> --sources='https://github.com/Ali-Corp/PodSpecs.git,https://cdn.cocoapods.org/'
```

If a consumer app fails with this error, add the private source before the public CDN in its `Podfile`:

```ruby
source 'https://github.com/Ali-Corp/PodSpecs.git'
source 'https://cdn.cocoapods.org/'
```
