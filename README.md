# CampusVote Flutter

Cliente móvil Flutter para el sistema académico de votación CampusVote.
Consume **únicamente** la API REST del backend Node.js/Express/PostgreSQL.

## Configuración de entorno

El backend por defecto es **producción**: `https://campusvote-rg13.onrender.com`.

Puedes sobreescribirlo con `--dart-define`:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:3000 \
  --dart-define=ENV=development
```

| Variable        | Descripción                                | Default                                  |
| --------------- | ------------------------------------------ | ---------------------------------------- |
| `API_BASE_URL`  | URL base del backend                       | `https://campusvote-rg13.onrender.com`   |
| `ENV`           | `development` \| `staging` \| `production` | `development`                            |
| `APP_NAME`      | Nombre mostrado en branding por defecto    | `CampusVote`                             |

## Estructura

```text
lib/
├── app/        → bootstrap, router, tema raíz
├── core/
│   ├── config/        → env, endpoints, constantes
│   ├── di/            → providers raíz
│   ├── errors/        → Failure tipado
│   ├── network/       → Dio, interceptors, ApiResponse, NetworkInfo
│   ├── routing/       → rutas nombradas, guards
│   ├── storage/       → SecureStorage + LocalStorage
│   ├── theme/         → AppColors, AppTheme, AppTypography, AppDimensions, AppShadows
│   ├── widgets/       → UI Kit reutilizable
│   ├── branding/      → OrganizationBranding dinámico
│   ├── utils/         → Result, helpers
│   └── extensions/    → date_format, context
├── features/
│   ├── auth/          → login, refresh, /me, TOTP
│   └── voting/        → flujo completo de votación
└── main.dart
```

## Ejecución

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```