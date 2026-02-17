#!/bin/bash

# Script para generar los secretos necesarios para GitHub Actions
# Ejecutar en macOS con los archivos de certificado y provisioning profile

echo "==================================="
echo "Generador de Secretos para iOS CI"
echo "==================================="
echo ""

# Función para leer input
read_input() {
    read -p "$1: " value
    echo "$value"
}

# 1. Certificado
echo "1. CERTIFICADO DE DISTRIBUCIÓN (.p12)"
echo "-----------------------------------"
cert_path=$(read_input "Ruta al archivo .p12")

if [ -f "$cert_path" ]; then
    echo ""
    echo "BUILD_CERTIFICATE_BASE64:"
    echo "-----------------------------------"
    base64 -i "$cert_path"
    echo ""
    echo "✓ Copia el valor de arriba y agrégalo como secreto BUILD_CERTIFICATE_BASE64"
    echo ""
else
    echo "❌ Archivo no encontrado: $cert_path"
    exit 1
fi

# 2. Provisioning Profile
echo ""
echo "2. PROVISIONING PROFILE (.mobileprovision)"
echo "-----------------------------------"
profile_path=$(read_input "Ruta al archivo .mobileprovision")

if [ -f "$profile_path" ]; then
    echo ""
    echo "PROVISIONING_PROFILE_BASE64:"
    echo "-----------------------------------"
    base64 -i "$profile_path"
    echo ""
    echo "✓ Copia el valor de arriba y agrégalo como secreto PROVISIONING_PROFILE_BASE64"
    echo ""
else
    echo "❌ Archivo no encontrado: $profile_path"
    exit 1
fi

# 3. Información adicional
echo ""
echo "3. INFORMACIÓN ADICIONAL"
echo "-----------------------------------"
team_id=$(read_input "Tu Apple Team ID (10 caracteres)")
bundle_id=$(read_input "Bundle ID de tu app (ej: com.empresa.app)")
profile_name=$(read_input "Nombre del Provisioning Profile")
method=$(read_input "Método de distribución (app-store/ad-hoc/enterprise/development)")

# 4. Generar ExportOptions.plist
echo ""
echo "EXPORT_OPTIONS_PLIST:"
echo "-----------------------------------"
cat << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>$method</string>
    <key>teamID</key>
    <string>$team_id</string>
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
        <key>$bundle_id</key>
        <string>$profile_name</string>
    </dict>
</dict>
</plist>
EOF
echo ""
echo "✓ Copia el XML de arriba y agrégalo como secreto EXPORT_OPTIONS_PLIST"
echo ""

# 5. Resumen
echo ""
echo "==================================="
echo "RESUMEN DE SECRETOS A CONFIGURAR"
echo "==================================="
echo ""
echo "En GitHub → Settings → Secrets and variables → Actions, agrega:"
echo ""
echo "1. BUILD_CERTIFICATE_BASE64 (generado arriba)"
echo "2. P12_PASSWORD (la contraseña que usaste al exportar el .p12)"
echo "3. KEYCHAIN_PASSWORD (cualquier contraseña segura, ej: temp-keychain-123)"
echo "4. PROVISIONING_PROFILE_BASE64 (generado arriba)"
echo "5. EXPORT_OPTIONS_PLIST (generado arriba)"
echo ""
echo "==================================="
echo "✓ Script completado"
echo "==================================="
