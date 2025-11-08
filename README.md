# 🏥 MediCare+ - Smart Healthcare Assistant

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

A comprehensive mobile healthcare application built with Flutter & Firebase that helps users monitor and manage their health with AI-powered diagnostics and personalized recommendations.

---

## 📱 About

MediCare+ is an intelligent healthcare assistant application that provides users with multiple health diagnostic tools, daily health tips, emergency services, and an AI chatbot. The app uses Firebase for authentication and data management, offering a seamless and secure healthcare experience.

---

## ✨ Features

### 🔐 User Authentication (Firebase)
- Register with **Name, Age, Email, Allergies, and Password**
- Login using email & password
- Change Password and Logout options
- User information stored securely using **Firebase Authentication** and **Firebase Database**

### 🎬 Splash Screen
- Smooth and attractive splash screen shown at app launch
- Professional animations and branding

### 🏠 Home Dashboard
Offers multiple health and utility features:
- **Hair Diagnosis** - Comprehensive hair health assessment
- **Skin Diagnosis** - Skin condition analysis and treatment recommendations
- **Dental Diagnosis** - Oral health evaluation
- **BMI / Health Calculator** - Calculate and track Body Mass Index
- **Daily Health Tips** - Get new wellness advice every day
- **Emergency SOS Numbers** - Quick access to emergency contacts
- **AI Chat Bot** - Intelligent health assistant
- **Settings Panel** - Customize app preferences

### 🩺 Diagnosis System
- Health diagnosis based on selected symptoms
- Uses **CheckBoxes** and **Radio Buttons** for user input
- Multi-step questionnaire format
- Displays detailed results and personalized recommendations based on user choices
- Confidence score and analysis reports
- Treatment plans with priority levels

### 🤖 AI Chat Bot
- Users can ask questions related to health and app usage
- Smart responses and guidance
- 24/7 availability
- Context-aware conversations
- Application-specific help

### 🎨 Theme Support
- **Light Mode** and **Dark Mode**
- Smooth theme transitions
- Saves user preference across sessions
- Eye-friendly color schemes

### ⚙️ Bottom Modal Sheet Settings
Menu allows:
- **Change Password** - Update account password securely
- **Switch Theme** - Toggle between Light/Dark mode
- **Change Language** - Multi-language support (if enabled)
- **Logout** - Secure sign out
- **App Preferences** - Customize app behavior

### 💡 Daily Health Tips
- Shows helpful and important health tips daily
- Preventive healthcare information
- Wellness advice and recommendations

### 🚨 Emergency SOS
- Quick-access emergency medical contact numbers available
- One-tap emergency alerts
- Important emergency services information

### 📊 Additional Features
- **Medicine Reminder** - Track and manage medications
- **Health Reports** - Store and view diagnosis history
- **Appointments** - Schedule and manage healthcare appointments
- **AI Health Suggestions** - Personalized recommendations based on profile

---

## 🛠️ Technology Used

| Component     | Technology / Tool |
|--------------|-------------------|
| Framework    | Flutter           |
| Language     | Dart              |
| Backend      | Firebase Auth, Firestore / Realtime Database |
| UI Design    | Flutter Widgets + Material UI |
| State Management | Provider |
| Hosting/Data | Firebase Services |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |

---

## 📥 How to Run This Project

### Prerequisites
- Flutter SDK installed on your system
- Android Studio / VS Code with Flutter extensions
- Firebase account

### Installation Steps

1. **Install Flutter SDK**
   - Download from [Flutter Official Website](https://flutter.dev)
   - Add Flutter to your system PATH

2. **Clone or download this project**
```bash
git clone https://github.com/yourusername/medicare_plus.git
cd medicare_plus
```

3. **Open project folder**
   - Open in **VS Code** or **Android Studio**

4. **Connect Firebase:**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS app to Firebase project
   - Download `google-services.json` (Android) and place it in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place it in `ios/Runner/`
   - Enable **Email/Password Authentication** in Firebase Console
   - Create **Firestore** or **Realtime Database** as required
   - Set up database rules for security

5. **Install dependencies**
```bash
flutter pub get
```

6. **Run the app:**
```bash
flutter run
```

---

## 📂 Project Structure

```
medicare_plus/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── splash_screen.dart                 # Splash screen
│   ├── login_screen.dart                  # Login page
│   ├── register_screen.dart               # Registration page
│   ├── auth_service.dart                  # Authentication logic
│   ├── home_screen.dart                   # Main dashboard
│   ├── profile_screen.dart                # User profile
│   ├── hair_diagnosis_screen.dart         # Hair health check
│   ├── skin_diagnosis_screen.dart         # Skin condition check
│   ├── dental_check_screen.dart           # Dental assessment
│   ├── bmi_tracker_screen.dart            # BMI calculator
│   ├── medicine_reminder_screen.dart      # Medicine reminders
│   ├── daily_tips_screen.dart             # Health tips
│   ├── emergency_screen.dart              # Emergency SOS
│   ├── reports_screen.dart                # Health reports
│   ├── appointment_screen.dart            # Appointments
│   ├── health_suggestions_screen.dart     # AI suggestions
│   ├── ai_chat_agent.dart                 # AI chatbot widget
│   ├── theme_provider.dart                # Theme management
│   └── models.dart                        # Data models
├── android/
│   └── app/
│       └── google-services.json           # Firebase config (Android)
├── ios/
│   └── Runner/
│       └── GoogleService-Info.plist       # Firebase config (iOS)
└── pubspec.yaml                           # Dependencies
```

---

## 🎨 Key UI Features

- **Modern Gradient Designs** - Beautiful color gradients throughout the app
- **Smooth Animations** - Fade transitions and interactive elements
- **Card-Based Layouts** - Clean, organized information display
- **Bottom Navigation** - Easy access to 5 main sections (Home, Medicine, Health, Reports, Appointments)
- **Responsive Design** - Works perfectly on different screen sizes and orientations
- **Custom Widgets** - Reusable component library for consistent UI
- **Progress Indicators** - Visual feedback for multi-step processes
- **Material Design** - Following Google's Material Design guidelines

---

## 🔒 Security Features

- Secure Firebase Authentication
- Password encryption and validation
- User data privacy protection
- Secure database rules in Firestore
- Input validation and sanitization
- Protected API endpoints

---

## 📱 App Sections

### Bottom Navigation Bar
1. **Home** - Dashboard with quick actions and feature cards
2. **Medicine** - Medicine reminders and medication tracking
3. **Health** - Health check center with all diagnostic tools
4. **Reports** - View, manage, and share health reports
5. **Appointments** - Schedule and manage healthcare appointments

---

## 📦 Dependencies

Key packages used in this project:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: latest
  firebase_auth: latest
  cloud_firestore: latest
  provider: latest
  shared_preferences: latest
```

---

## 🚀 Future Enhancements

- [ ] Integration with wearable devices
- [ ] Telemedicine video consultation
- [ ] Pharmacy integration for medicine delivery
- [ ] Multi-language support expansion
- [ ] Health data analytics dashboard
- [ ] Integration with health insurance providers
- [ ] Prescription OCR scanning
- [ ] Voice-enabled AI assistant

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'Add some feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Developer

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com
- LinkedIn: [Your LinkedIn Profile](https://linkedin.com/in/yourprofile)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Material Design for UI components
- Open-source community for various packages and inspiration

---

## 📞 Support

For support, questions, or feedback:
- Email: your.email@example.com
- Open an issue in the repository
- Join our community discussions

---

## 📸 Screenshots

_Add screenshots of your app here to showcase the UI and features_

---

## ⭐ Show Your Support

If you found this project helpful or interesting, please consider giving it a ⭐ star on GitHub!

---

**Made with ❤️ using Flutter & Firebase**
