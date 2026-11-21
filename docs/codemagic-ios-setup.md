# Publishing the iOS app with Codemagic (no Mac needed)

Codemagic builds the app on its own Macs, signs it, and uploads it to
TestFlight. The build recipe is `codemagic.yaml` at the repo root. Everything
below is one-time setup, except step 11 which you repeat for each release.

App facts this setup relies on:

| | |
|---|---|
| Bundle ID | `com.anstopcovoiturage` |
| Apple Team ID in the Xcode project | `H88K4S3Z2R` (confirm it is your team) |
| Version | from `pubspec.yaml` (`1.0.2`); the build number is set automatically |
| Secrets bundled at build time | `STRIPE_PUBLISHABLE_KEY`, `GOOGLE_MAPS_API_KEY` (the `.env` file) |

---

## Part A: Apple side

### 1. Apple Developer Program
- Enrol at <https://developer.apple.com/programs/enroll/> (US$99 per year).
  An individual account is quickest. A company account needs a D-U-N-S number.
- Approval can take from minutes to a couple of days.

### 2. Register the bundle ID
1. <https://developer.apple.com/account> > Certificates, Identifiers & Profiles > Identifiers > **+**.
2. App IDs > App > Continue.
3. Description `Anstop`, Bundle ID **Explicit** `com.anstopcovoiturage`.
4. Tick **Push Notifications** (the app uses Firebase push). Register.

### 3. Create the app in App Store Connect
1. <https://appstoreconnect.apple.com> > Apps > **+** > New App.
2. Platform iOS, name `Anstop`, primary language, bundle ID `com.anstopcovoiturage`,
   any SKU (for example `anstop-ios`), access Full.
3. Open the app > App Information and copy the **Apple ID** (a 10-digit
   number). Put it in `codemagic.yaml` as `APP_STORE_APPLE_ID`.

### 4. App Store Connect API key (lets Codemagic sign and upload for you)
1. App Store Connect > Users and Access > **Integrations** > App Store Connect API > Team Keys > **+**.
2. Name `Codemagic`, access **App Manager** (use Admin if signing fails with a permission error).
3. Download the `.p8` file. **Apple lets you download it only once.**
4. Write down the **Key ID** (in the table) and the **Issuer ID** (top of the page).

### 5. Push notifications key for Firebase (iOS pushes do not work without it)
1. Apple Developer > Keys > **+** > name `Anstop APNs`, tick **Apple Push Notifications service (APNs)** > Register > download the `.p8` (once only). Note its Key ID.
2. Firebase console > project `ride-sharing-app-ee4aa` > Project settings > Cloud Messaging > Apple app configuration > **Upload** the APNs authentication key, with the Key ID and your Team ID.

---

## Part B: Codemagic side

### 6. Create the account and add the app
1. <https://codemagic.io/signup> > sign up with GitHub.
2. Applications > Add application > choose GitHub > select `anstop-app` > type **Flutter App** > Finish.
3. When asked, choose **Switch to codemagic.yaml configuration** (the file is already in the repo).

### 7. Connect App Store Connect
1. Codemagic > Teams > Personal account > **Integrations** > App Store Connect > Connect.
2. Name it exactly **`anstop-asc`** (the yaml refers to this name).
3. Enter the Issuer ID and Key ID from step 4 and upload the `.p8`. Save.

### 8. Add the secrets
1. Your app in Codemagic > **Environment variables** (or Teams > Global variables and secrets).
2. Create a group named **`anstop_secrets`** with two variables, both marked **Secure**:
   - `STRIPE_PUBLISHABLE_KEY` = the `pk_live_...` key
   - `GOOGLE_MAPS_API_KEY` = the Maps key
3. The build stops with a clear message if either is missing, and warns if the
   Stripe key is a test key.

### 9. First build
1. Start new build > branch `main` > workflow **iOS release (TestFlight)** > Start.
2. First run takes about 15 to 25 minutes. Codemagic creates the distribution
   certificate and App Store profile by itself (Apple allows at most 3
   distribution certificates per account).
3. On success the `.ipa` is attached to the build and uploaded to TestFlight.

### 10. Install on a phone
1. App Store Connect > your app > TestFlight. The build shows "Processing" for 5 to 30 minutes.
2. Fill in the **Export Compliance** question if shown. The app only uses standard HTTPS encryption.
3. Internal Testing > add yourself (an App Store Connect user) as a tester.
4. Install the **TestFlight** app on the iPhone, sign in with that Apple ID, install Anstop.

### 11. Each later release
1. Bump the version name in `pubspec.yaml` only when you want a new version (for example `1.0.3+1`); the build number is automatic.
2. Push to `main`, then Start new build in Codemagic.

---

## Part C: Before submitting for App Store review

In App Store Connect > your app > the version page:

- **Screenshots** for the 6.9" iPhone size (and 6.5" if asked), description, keywords, support URL.
- **Privacy Policy URL**: the policy text is in the app; it also needs a public web page.
- **App Privacy** (nutrition labels): declare name, email, phone number, precise location, payment info (handled by Stripe), and user content (ID documents for drivers).
- **App Review Information**: give a working **demo rider account** and a **demo driver account** (the app needs sign-in; drivers need approval, so say how a reviewer can reach the home screen). Without this the review is rejected.
- **Age rating**, category (Travel or Navigation), pricing (Free).
- Then pick the TestFlight build on the version page and **Submit for Review** (review usually takes 1 to 2 days).

## Things worth knowing

- **Google Maps key**: it is written in plain text in `ios/Runner/AppDelegate.swift`. In Google Cloud Console, restrict that key to the iOS bundle ID `com.anstopcovoiturage` so it cannot be used elsewhere.
- **`external-accessory` background mode** is listed in `Info.plist`. If the app does not talk to Bluetooth/hardware accessories, remove it before review, because Apple may ask why it is there.
- **Free minutes**: Codemagic gives a monthly allowance of free macOS build minutes for personal accounts; check <https://codemagic.io/pricing> for the current amount. Builds start only when you start them.
- **Flutter version** is pinned to 3.41.9 in `codemagic.yaml` (the version the project was verified with). `.fvmrc` says 3.38.0, so update one of them if you want them aligned.
