# IFS Cloud Auth Flutter Example

This example demonstrates how to use the IFS Cloud Auth Flutter library to authenticate users with IFS Cloud.

## Setup

1. **Configure your OAuth2 client in IFS Cloud**:
   - Create a new OAuth2 client in your IFS Cloud administration
   - Set the client type to "public" (for mobile apps)
   - Enable "Authorization Code Flow" with PKCE
   - Add redirect URIs in the format: `your-client-id://`

2. **Update the configuration**:
   - Open `main.dart`
   - Replace `your-company.ifscloud.com` with your actual IFS Cloud domain
   - Replace `your-client-id` with your OAuth2 client ID

3. **Configure platform-specific settings**:

   **Android** (`android/app/build.gradle`):
   ```gradle
   android {
       defaultConfig {
           manifestPlaceholders += [
               'appAuthRedirectScheme': 'your-client-id'
           ]
       }
   }
   ```

   **iOS** (`ios/Runner/Info.plist`):
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLName</key>
           <string>your-client-id</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>your-client-id</string>
           </array>
       </dict>
   </array>
   ```

## Running the Example

```bash
flutter pub get
flutter run
```

## Features Demonstrated

- **Authentication**: Perform OAuth2/OpenID Connect authentication with IFS Cloud
- **Token Management**: Display token information and expiry status
- **Token Refresh**: Refresh access tokens using refresh tokens
- **Logout**: End the user session properly
- **Error Handling**: Handle various authentication errors gracefully

## Notes

- The example uses placeholder values that need to be replaced with your actual IFS Cloud configuration
- Make sure your IFS Cloud instance is properly configured for OAuth2 authentication
- The redirect URI scheme must match your client ID for the example to work