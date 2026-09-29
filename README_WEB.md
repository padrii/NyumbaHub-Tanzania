# NyumbaHub Tanzania - Web Version

Flutter + Firebase MVP marketplace platform para sa nyumba za kupanga na huduma za mafundi Tanzania.

## Run kwa simu using GitHub Codespaces

1. Bukas repository kwenye GitHub
2. Press `.` (dot key) ili kufungua Codespaces
3. Kwenye terminal, run:
```bash
flutter pub get
flutterfire configure
flutter run -d web
```

4. App itafunguka kama web version kwenye browser

## Roles
- **Tenant (Mpangaji)**: Search nyumba, view details, book viewing
- **Landlord (Mwenye nyumba)**: Add property listings with GPS, images, video
- **Provider (Fundi)**: Add services, receive requests
- **Admin**: Verify users, listings, services

## Features (MVP)
- Email/password authentication
- Role-based dashboards
- Property listing system with verification
- Service provider system
- Admin moderation dashboard
- Firestore backend
- Firebase Storage for media
- Notification framework

## Firebase Setup

Kabla `flutter run`, create Firebase project:
1. https://console.firebase.google.com
2. Enable:
   - Authentication (Email/Password)
   - Firestore Database
   - Storage
3. Run `flutterfire configure` na chagua project
4. Update credentials automatically

## Run
```bash
flutter pub get
flutter run -d web
```

## Test accounts (after setup)
- Email: test@test.com
- Password: password123

## Web version limitations
- GPS capture haiwezi kufanya kwenye browser (simulator)
- Camera upload kawaida huvuta file selector instead
- Notifications display kama in-app messages

## Next steps
- Configure real Firebase credentials via `flutterfire configure`
- Test role flows
- Deploy to Firebase Hosting kwa production
