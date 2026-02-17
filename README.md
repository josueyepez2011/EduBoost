# EduBoost - Aplicación para Estudiantes

Una aplicación Flutter moderna diseñada para ayudar a estudiantes a organizar sus tareas, seguir sus calificaciones y mejorar su rendimiento académico con la ayuda de un tutor virtual con IA.

## Características

- 📝 Gestión de tareas con prioridades y recordatorios
- 📊 Seguimiento de calificaciones y análisis de rendimiento
- 🤖 Tutor virtual con IA para ayuda académica
- 🏆 Sistema de logros y gamificación
- 🎨 Interfaz moderna y atractiva

## CI/CD - Build Automático iOS

Este proyecto incluye GitHub Actions configurado para compilar y firmar automáticamente la app iOS.

### Configuración Rápida

1. Lee la guía completa en [.github/IOS_SETUP.md](.github/IOS_SETUP.md)
2. Ejecuta el script helper (en macOS):
   ```bash
   chmod +x .github/scripts/generate-secrets.sh
   ./.github/scripts/generate-secrets.sh
   ```
3. Agrega los secretos generados en GitHub → Settings → Secrets and variables → Actions

### Ejecutar Build

El workflow se ejecuta automáticamente en push a `main` o `develop`, o manualmente desde la pestaña Actions.

El IPA firmado estará disponible como artifact descargable.

