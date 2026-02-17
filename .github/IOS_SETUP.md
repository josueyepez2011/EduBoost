# Configuración de GitHub Actions para iOS

Este documento explica cómo configurar los secretos necesarios en GitHub para compilar y firmar tu app iOS.

## Requisitos Previos

1. Una cuenta de Apple Developer activa
2. Certificado de distribución de iOS (.p12)
3. Provisioning Profile para tu app
4. Acceso a tu repositorio de GitHub

## Secretos Requeridos en GitHub

Ve a tu repositorio → Settings → Secrets and variables → Actions → New repository secret

### 1. BUILD_CERTIFICATE_BASE64

Tu certificado de distribución en formato base64.

**Cómo obtenerlo:**

```bash
# En macOS, exporta tu certificado desde Keychain Access como .p12
# Luego conviértelo a base64:
base64 -i TuCertificado.p12 | pbcopy
```

### 2. P12_PASSWORD

La contraseña que usaste al exportar el certificado .p12

### 3. KEYCHAIN_PASSWORD

Una contraseña temporal para el keychain (puede ser cualquier string seguro, ej: `temp-keychain-password-123`)

### 4. PROVISIONING_PROFILE_BASE64

Tu provisioning profile en formato base64.

**Cómo obtenerlo:**

```bash
# Descarga tu provisioning profile desde Apple Developer
# Luego conviértelo a base64:
base64 -i TuProfile.mobileprovision | pbcopy
```

### 5. EXPORT_OPTIONS_PLIST

Archivo de configuración para exportar el IPA.

**Contenido ejemplo:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>TU_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>compileBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>manual</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.tuempresa.eduboost</key>
        <string>NOMBRE_DE_TU_PROVISIONING_PROFILE</string>
    </dict>
</dict>
</plist>
```

**Nota:** Cambia `method` según tu necesidad:
- `app-store` - Para subir a App Store
- `ad-hoc` - Para distribución ad-hoc
- `enterprise` - Para distribución enterprise
- `development` - Para desarrollo

## Pasos para Configurar

### 1. Obtener Certificado de Distribución

1. Ve a [Apple Developer](https://developer.apple.com/account/resources/certificates)
2. Crea o descarga tu certificado de distribución
3. Abre Keychain Access en macOS
4. Encuentra tu certificado
5. Click derecho → Export
6. Guarda como .p12 con una contraseña

### 2. Obtener Provisioning Profile

1. Ve a [Apple Developer Profiles](https://developer.apple.com/account/resources/profiles)
2. Crea o descarga el provisioning profile para tu app
3. Asegúrate de que coincida con tu Bundle ID

### 3. Configurar Bundle ID en Xcode

1. Abre `ios/Runner.xcworkspace` en Xcode
2. Selecciona el proyecto Runner
3. En la pestaña "Signing & Capabilities"
4. Configura tu Team y Bundle Identifier (ej: `com.tuempresa.eduboost`)

### 4. Agregar Secretos a GitHub

1. Ve a tu repositorio en GitHub
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Agrega cada uno de los 5 secretos mencionados arriba

## Ejecutar el Workflow

El workflow se ejecutará automáticamente cuando:
- Hagas push a las ramas `main` o `develop`
- Crees un Pull Request hacia `main`
- Lo ejecutes manualmente desde la pestaña Actions

Para ejecutar manualmente:
1. Ve a la pestaña "Actions" en GitHub
2. Selecciona "Build iOS App"
3. Click en "Run workflow"

## Descargar el IPA

Una vez completado el build:
1. Ve a la pestaña "Actions"
2. Click en el workflow completado
3. Descarga el artifact "EduBoost-iOS"
4. Descomprime el archivo para obtener el .ipa

## Subir a App Store Connect

Puedes subir el IPA a App Store Connect usando:

```bash
xcrun altool --upload-app --type ios --file EduBoost.ipa \
  --username "tu@email.com" \
  --password "app-specific-password"
```

O usa Transporter app de Apple.

## Troubleshooting

### Error: "No signing certificate"
- Verifica que el certificado base64 esté correcto
- Asegúrate de que la contraseña P12 sea correcta

### Error: "No provisioning profile"
- Verifica que el provisioning profile base64 esté correcto
- Asegúrate de que el Bundle ID coincida

### Error: "Code signing failed"
- Verifica que el Team ID en ExportOptions.plist sea correcto
- Asegúrate de que el provisioning profile esté asociado al certificado

## Recursos Adicionales

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
