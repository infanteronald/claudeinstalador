# Contribuir a Claude Code Installer

Gracias por tu interés en contribuir. Esta guía te ayudará a empezar.

## Requisitos previos

- macOS 13.0 (Ventura) o superior
- Swift 5.9+ (incluido con Xcode Command Line Tools)
- Git

```bash
# Instalar Command Line Tools (si no los tienes)
xcode-select --install

# Verificar Swift
swift --version
```

## Configuración del entorno

```bash
# Clonar el repositorio
git clone https://github.com/TU_USUARIO/claudeinstalador.git
cd claudeinstalador

# Compilar
swift build

# Ejecutar
swift run

# Tests
swift test
```

## Convenciones del proyecto

### Estructura de código

| Directorio | Contenido |
|-----------|-----------|
| `App/` | Entry point, estado global, delegate |
| `Models/` | Structs, enums, tipos de datos |
| `Services/` | Lógica de negocio (un servicio por responsabilidad) |
| `Views/` | Vistas SwiftUI |
| `Views/Components/` | Componentes reutilizables |
| `Utilities/` | Helpers y wrappers |
| `Resources/` | Archivos estáticos (templates, configuración) |

### Strings bilingües

Toda cadena visible al usuario **debe** tener versión en español e inglés:

```swift
// Correcto
Text(Locale.isSpanish
    ? "Descarga completada"
    : "Download complete")

// Incorrecto — solo un idioma
Text("Download complete")
```

### Errores

Usar `InstallerError` para todos los errores. Cada caso incluye `humanReadableMessage` bilingüe:

```swift
throw InstallerError.downloadFailed(url: urlString, statusCode: code)
```

### Servicios

Los servicios deben ser `Sendable`-safe y usar `async/await`:

```swift
final class MiServicio: @unchecked Sendable {
    func ejecutar() async throws {
        // ...
    }
}
```

### Concurrencia

- Usar `async/await` (no callbacks ni Combine)
- `AppState` es `@MainActor`
- `ShellExecutor.run()` soporta timeout para evitar bloqueos

### Seguridad

- **Nunca usar `sudo`** — manejar permisos con `chown` o `AuthorizationServices`
- **Operaciones idempotentes** — verificar antes de modificar archivos de perfil
- **No almacenar secretos en código** — usar Keychain para claves API

## Flujo de contribución

1. **Fork** el repositorio
2. **Crea un branch** desde `main`:
   ```bash
   git checkout -b feature/mi-mejora
   ```
3. **Haz tus cambios** siguiendo las convenciones
4. **Compila y verifica**:
   ```bash
   swift build && swift test
   ```
5. **Commit** con mensaje descriptivo:
   ```bash
   git commit -m "Add: descripción breve del cambio"
   ```
6. **Push** y crea un **Pull Request**

### Formato de commits

```
Add: nueva funcionalidad
Fix: corrección de bug
Update: mejora a funcionalidad existente
Refactor: cambio de estructura sin cambio funcional
Docs: cambios en documentación
```

## Áreas donde se necesita ayuda

- Mejoras de UI/UX en las vistas del wizard
- Soporte para más shells (fish, nushell)
- Tests unitarios adicionales
- Traducciones a otros idiomas
- Script de creación de .dmg para distribución
- Firma y notarización de la app

## Reportar bugs

Abre un issue con:

1. Versión de macOS
2. Arquitectura (Apple Silicon / Intel)
3. Paso donde ocurrió el error
4. Mensaje de error (si aplica)
5. Captura de pantalla (si aplica)

## Código de conducta

Sé respetuoso. Sé constructivo. Todos estamos aquí para aprender.
