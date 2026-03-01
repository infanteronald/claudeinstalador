<p align="center">
  <img src="https://img.shields.io/badge/macOS-13.0+-000000?style=flat-square&logo=apple&logoColor=white" alt="macOS 13.0+">
  <img src="https://img.shields.io/badge/Swift-5.9+-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift 5.9+">
  <img src="https://img.shields.io/badge/SwiftUI-Native-007AFF?style=flat-square&logo=swift&logoColor=white" alt="SwiftUI">
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="MIT License">
  <img src="https://img.shields.io/badge/Idioma-ES%20%7C%20EN-blueviolet?style=flat-square" alt="Bilingual">
</p>

<h1 align="center">
  Claude Code Installer
</h1>

<p align="center">
  <strong>Instalador nativo macOS para Claude Code</strong><br>
  <em>Cero conocimientos t&eacute;cnicos requeridos</em>
</p>

<p align="center">
  Una aplicaci&oacute;n nativa macOS con interfaz gr&aacute;fica que automatiza<br>
  la instalaci&oacute;n completa de Claude Code en 6 pasos guiados.
</p>

---

## El problema

Instalar Claude Code en macOS requiere conocimientos de terminal que la mayor&iacute;a de usuarios no tiene:

| Barrera | Qu&eacute; ve el usuario |
|---------|------------------|
| PATH no configurado | `command not found: claude` |
| Dependencias Node.js | Versiones incompatibles, NVM, npm |
| Autenticaci&oacute;n | Bucles de Keychain, tokens inv&aacute;lidos |
| Permisos | `EACCES: permission denied` |
| Configuraci&oacute;n | Archivos `.zshrc`, variables de entorno |

**Este instalador elimina todas esas barreras con una interfaz visual.**

## La soluci&oacute;n

```
 ┌──────────────────────────────────────────────┐
 │        Claude Code — Smart Installer         │
 │                                              │
 │    ● Verificaci&oacute;n ─── ● Descarga ─── ● PATH  │
 │                                              │
 │    ● Auth ──────── ● Config ─── ● Listo!    │
 │                                              │
 │           [ Iniciar Claude Code ]            │
 └──────────────────────────────────────────────┘
```

6 fases autom&aacute;ticas. Sin terminal. Sin conocimientos previos.

## Caracter&iacute;sticas

- **Descarga directa** &mdash; Binario nativo desde los servidores de Anthropic, sin npm ni Homebrew
- **Detecci&oacute;n inteligente** &mdash; Verifica macOS, RAM, arquitectura (Apple Silicon / Intel), shell
- **Actualizaciones** &mdash; Detecta versiones previas y ofrece actualizar
- **PATH autom&aacute;tico** &mdash; Configura `~/.zshrc` o `~/.bash_profile` de forma idempotente
- **Autenticaci&oacute;n flexible** &mdash; OAuth por navegador o clave API directa con Keychain
- **Verificaci&oacute;n SHA256** &mdash; Checksum de integridad con CryptoKit
- **Biling&uuml;e** &mdash; Espa&ntilde;ol e ingl&eacute;s, detecci&oacute;n autom&aacute;tica del idioma del sistema
- **Bot&oacute;n de lanzamiento** &mdash; Al finalizar, un clic abre Terminal con Claude Code listo

## Requisitos del sistema

| Requisito | M&iacute;nimo |
|-----------|--------|
| macOS | 13.0 Ventura o superior |
| RAM | 4 GB |
| CPU | Apple Silicon (M1-M4) o Intel x64 |
| Disco | ~250 MB libres |
| Swift | 5.9+ (incluido con Xcode CLI Tools) |

## Inicio r&aacute;pido

### Compilar y ejecutar

```bash
# Clonar el repositorio
git clone https://github.com/TU_USUARIO/claudeinstalador.git
cd claudeinstalador

# Compilar
swift build

# Ejecutar
swift run
```

### Compilar como .app

```bash
# Build en modo release
swift build -c release

# El binario estar&aacute; en:
# .build/release/ClaudeInstaller
```

> **Nota:** No necesitas Xcode IDE. Solo las Command Line Tools:
> ```bash
> xcode-select --install
> ```

## C&oacute;mo funciona

El instalador ejecuta 6 fases secuenciales, cada una completamente autom&aacute;tica:

### Fase 1 &mdash; Verificaci&oacute;n del Sistema

Audita silenciosamente el entorno del usuario:

- Versi&oacute;n de macOS (&ge; 13.0)
- Memoria RAM (&ge; 4 GB)
- Arquitectura CPU (ARM64 / x64)
- Shell activo (zsh / bash)
- Instalaciones previas de Claude Code
- Conflictos (Homebrew, npm, symlinks rotos)

### Fase 2 &mdash; Descarga del Binario

Descarga el binario nativo directamente de Google Cloud Storage:

```
https://storage.googleapis.com/.../claude-code-releases/{VERSION}/{PLATFORM}/claude
```

- Barra de progreso con porcentaje, velocidad (MB/s) y tama&ntilde;o
- Verificaci&oacute;n de integridad SHA256 contra el manifest
- Cach&eacute; local para evitar re-descargas
- Si ya existe una versi&oacute;n instalada, ofrece actualizar o saltar

### Fase 3 &mdash; Configuraci&oacute;n del PATH

Inyecta la ruta del binario en el perfil de shell:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

- Detecta el archivo correcto (`~/.zshrc`, `~/.bash_profile`)
- Verificaci&oacute;n de idempotencia (nunca duplica entradas)
- Fallback a `/etc/paths.d/claude` si es necesario

### Fase 4 &mdash; Autenticaci&oacute;n

Dos opciones presentadas visualmente:

1. **OAuth por navegador** &mdash; Abre la p&aacute;gina de login de Anthropic
2. **Clave API directa** &mdash; Campo seguro para pegar la clave desde `console.anthropic.com`

Incluye bot&oacute;n "Omitir" para autenticar despu&eacute;s.

### Fase 5 &mdash; Configuraci&oacute;n del Entorno

- Genera `CLAUDE.md` seg&uacute;n nivel de experiencia (Principiante &rarr; Experto)
- Crea `.gitignore` y `.claudeignore` con patrones est&aacute;ndar
- Configura `~/.claude/settings.json` con nivel de confianza elegido
- Inyecta variables de entorno necesarias

### Fase 6 &mdash; Lanzamiento

Bot&oacute;n prominente **"Iniciar Claude Code"** que abre Terminal.app y ejecuta `claude` autom&aacute;ticamente en el directorio del proyecto.

## Arquitectura

```
Sources/ClaudeInstaller/
├── App/
│   ├── ClaudeInstallerApp.swift    # Entry point (@main)
│   ├── AppState.swift              # Estado central (ObservableObject)
│   └── AppDelegate.swift           # NSApplicationDelegate
├── Models/
│   ├── InstallationPhase.swift     # 6 fases del wizard
│   ├── InstallerError.swift        # Errores biling&uuml;es
│   ├── SystemAuditResult.swift     # Resultado de auditor&iacute;a
│   ├── ClaudeManifest.swift        # Manifest GCS (Codable)
│   └── UserProfile.swift           # Nivel de habilidad, auth mode
├── Services/
│   ├── SystemAuditor.swift         # Verificaci&oacute;n del sistema
│   ├── ConflictScanner.swift       # Detecci&oacute;n de conflictos
│   ├── BinaryDownloader.swift      # Descarga + checksum
│   ├── PathConfigurator.swift      # Inyecci&oacute;n PATH
│   ├── KeychainManager.swift       # Keychain + autenticaci&oacute;n
│   ├── APIKeyManager.swift         # Validaci&oacute;n de API key
│   ├── ClaudeMDGenerator.swift     # Generaci&oacute;n CLAUDE.md
│   ├── ProjectConfigurator.swift   # .gitignore, .claudeignore
│   ├── SettingsConfigurator.swift  # settings.json
│   ├── EnvironmentConfigurator.swift # Variables de entorno
│   ├── OnboardingOrchestrator.swift  # Lanzamiento de Terminal
│   ├── MenuBarManager.swift        # Barra de men&uacute;s macOS
│   └── DiagnosticRunner.swift      # Diagn&oacute;sticos
├── Views/
│   ├── MainInstallerView.swift     # Vista ra&iacute;z + navegaci&oacute;n
│   ├── WelcomeView.swift           # Pantalla de bienvenida
│   ├── SystemCheckView.swift       # Fase 1 UI
│   ├── DownloadProgressView.swift  # Fase 2 UI
│   ├── PathConfigView.swift        # Fase 3 UI
│   ├── AuthenticationView.swift    # Fase 4 UI
│   ├── ProjectConfigView.swift     # Fase 5 UI
│   ├── OnboardingCompleteView.swift # Fase 6 UI
│   ├── SkillLevelPickerView.swift  # Selector de nivel
│   └── Components/
│       ├── PhaseProgressBar.swift  # Barra de progreso
│       ├── GlassCard.swift         # Tarjeta frosted glass
│       ├── StepCheckmark.swift     # Checkmark animado
│       └── PulsingDotView.swift    # Indicador de actividad
└── Utilities/
    ├── ShellExecutor.swift         # Wrapper de Process (con timeout)
    ├── FileSystemHelper.swift      # Operaciones de archivos
    ├── ChecksumVerifier.swift      # SHA256 con CryptoKit
    └── ErrorMapper.swift           # Traducci&oacute;n de errores
```

### Patrones de dise&ntilde;o

| Patr&oacute;n | Implementaci&oacute;n |
|--------|--------------|
| **State Machine** | `AppState` (ObservableObject) orquesta las 6 fases |
| **Service Layer** | Cada servicio encapsula una responsabilidad (&uacute;nica) |
| **Sendable Safety** | Servicios marcados `@unchecked Sendable` para concurrencia |
| **Bilingual** | `Locale.isSpanish` para detecci&oacute;n autom&aacute;tica de idioma |
| **Idempotent Ops** | Verificaciones regex antes de modificar archivos de perfil |
| **Graceful Timeout** | `ShellExecutor` con timeout configurable para evitar bloqueos |

## Stack tecnol&oacute;gico

| Componente | Tecnolog&iacute;a |
|------------|-----------|
| Lenguaje | Swift 5.9+ con Swift Concurrency |
| UI | SwiftUI (macOS 13.0+) |
| Build | Swift Package Manager (sin Xcode) |
| Networking | URLSession nativo |
| Seguridad | Security.framework + CryptoKit |
| Shell | Foundation.Process |

## Desarrollo

### Estructura de un servicio

Cada servicio sigue la misma convenci&oacute;n:

```swift
final class MiServicio: @unchecked Sendable {
    func ejecutar() async throws {
        // L&oacute;gica as&iacute;ncrona
    }
}
```

### Agregar strings biling&uuml;es

Todas las cadenas de UI usan el patr&oacute;n ternario:

```swift
Text(Locale.isSpanish
    ? "Texto en espa&ntilde;ol"
    : "Text in English")
```

### Agregar una nueva fase

1. A&ntilde;adir caso al enum `InstallationPhase`
2. Crear el servicio en `Services/`
3. Crear la vista en `Views/`
4. Agregar ejecuci&oacute;n en `AppState.executeCurrentPhase()`
5. Agregar vista en `MainInstallerView`

### Tests

```bash
swift test
```

## Seguridad

- **Sin sudo** &mdash; Todas las operaciones usan permisos del usuario actual
- **Verificaci&oacute;n SHA256** &mdash; Cada binario descargado se verifica contra el manifest oficial
- **Keychain nativo** &mdash; Las claves API se almacenan en el Keychain de macOS con protecci&oacute;n biom&eacute;trica
- **Sin telemetr&iacute;a** &mdash; Se configura `CLAUDE_TELEMETRY=0` por defecto
- **Idempotente** &mdash; Ejecutar el instalador m&uacute;ltiples veces no causa da&ntilde;os ni duplicados

## Licencia

Este proyecto est&aacute; bajo la licencia MIT. Ver [LICENSE](LICENSE) para m&aacute;s detalles.

---

<p align="center">
  Construido con Swift y SwiftUI para macOS<br>
  <sub>No afiliado oficialmente con Anthropic</sub>
</p>
