# Contributing / Contribuir

<table>
<tr>
<td width="50%">

## 🇬🇧 English

Thanks for your interest in contributing!

</td>
<td width="50%">

## 🇪🇸 Español

¡Gracias por tu interés en contribuir!

</td>
</tr>
</table>

---

## Prerequisites / Requisitos Previos

- macOS 13.0 (Ventura) or later / o superior
- Swift 5.9+ (included with Xcode Command Line Tools)
- Git

```bash
# Install Command Line Tools (if you don't have them)
# Instalar Command Line Tools (si no los tienes)
xcode-select --install

# Verify Swift / Verificar Swift
swift --version
```

## Setup / Configuración

```bash
# Clone / Clonar
git clone https://github.com/infanteronald/claudeinstalador.git
cd claudeinstalador

# Build / Compilar
swift build

# Run / Ejecutar
swift run

# Test
swift test
```

## Project Conventions / Convenciones del Proyecto

### Code Structure / Estructura de Código

| Directory / Directorio | Contents / Contenido |
|-----------|-----------|
| `App/` | Entry point, global state, delegate |
| `Models/` | Structs, enums, data types / tipos de datos |
| `Services/` | Business logic (one service per responsibility / un servicio por responsabilidad) |
| `Views/` | SwiftUI views / Vistas SwiftUI |
| `Views/Components/` | Reusable components / Componentes reutilizables |
| `Utilities/` | Helpers and wrappers |
| `Resources/` | Static files (templates, config / configuración) |

### Bilingual Strings / Strings Bilingües

Every user-facing string **must** have both English and Spanish versions:

Toda cadena visible al usuario **debe** tener versión en inglés y español:

```swift
// Correct / Correcto
Text(Locale.isSpanish
    ? "Descarga completada"
    : "Download complete")

// Wrong / Incorrecto — only one language / solo un idioma
Text("Download complete")
```

### Errors / Errores

Use `InstallerError` for all errors. Each case includes a bilingual `humanReadableMessage`:

```swift
throw InstallerError.downloadFailed(url: urlString, statusCode: code)
```

### Services / Servicios

Services must be `Sendable`-safe and use `async/await`:

```swift
final class MyService: @unchecked Sendable {
    func execute() async throws {
        // Async logic
    }
}
```

### Concurrency / Concurrencia

- Use `async/await` (not callbacks or Combine)
- `AppState` is `@MainActor`
- `ShellExecutor.run()` supports timeout to prevent hangs

### Security / Seguridad

- **Never use `sudo`** — handle permissions with `chown` or `AuthorizationServices`
- **Idempotent operations** — check before modifying shell profile files
- **No secrets in code** — use Keychain for API keys

## Contribution Flow / Flujo de Contribución

1. **Fork** the repository / el repositorio
2. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/my-improvement
   ```
3. **Make changes** following conventions / siguiendo las convenciones
4. **Build and verify / Compila y verifica**:
   ```bash
   swift build && swift test
   ```
5. **Commit** with a descriptive message / con mensaje descriptivo:
   ```bash
   git commit -m "Add: brief description of change"
   ```
6. **Push** and create a **Pull Request**

### Commit Format / Formato de Commits

```
Add: new feature / nueva funcionalidad
Fix: bug fix / corrección de bug
Update: improvement to existing feature / mejora a funcionalidad existente
Refactor: structural change without functional change / cambio sin cambio funcional
Docs: documentation changes / cambios en documentación
```

## Areas Where Help is Needed / Áreas de Ayuda

- UI/UX improvements in wizard views / Mejoras de UI/UX
- Support for more shells (fish, nushell)
- Additional unit tests / Tests unitarios adicionales
- Translations to other languages / Traducciones a otros idiomas
- App signing and notarization / Firma y notarización de la app
- CI/CD pipeline

## Reporting Bugs / Reportar Bugs

Open an issue with / Abre un issue con:

1. macOS version / Versión de macOS
2. Architecture / Arquitectura (Apple Silicon / Intel)
3. Step where the error occurred / Paso donde ocurrió el error
4. Error message (if applicable) / Mensaje de error (si aplica)
5. Screenshot (if applicable) / Captura de pantalla (si aplica)

## Code of Conduct / Código de Conducta

Be respectful. Be constructive. We're all here to learn.

Sé respetuoso. Sé constructivo. Todos estamos aquí para aprender.
