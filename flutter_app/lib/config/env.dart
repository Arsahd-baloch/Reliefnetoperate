// class Env {
//   static const String apiUrl = String.fromEnvironment(
//     'API_URL',
//     defaultValue: 'http://127.0.0.1:3000/api',
//   );
//   static const String cloudinaryCloudName = String.fromEnvironment(
//     'CLOUDINARY_CLOUD_NAME',
//     defaultValue: '',
//   );
//   static const String cloudinaryUploadPreset = String.fromEnvironment(
//     'CLOUDINARY_UPLOAD_PRESET',
//     defaultValue: '',
//   );
// }
class Env {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    // USB debugging (adb reverse tcp:3000 tcp:3000 — run this first)
    defaultValue: 'http://localhost:3000/api',
    // LAN / WiFi (no USB): use your PC's current IP instead
    // defaultValue: 'http://10.30.139.177:3000/api',
  );
  static const String cloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: '',
  );
  static const String cloudinaryUploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: '',
  );
}
