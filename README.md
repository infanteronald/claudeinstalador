<p align="center">
  <img src="https://img.shields.io/badge/macOS-13.0+-000000?style=for-the-badge&logo=apple&logoColor=white" alt="macOS 13.0+">
  <img src="https://img.shields.io/badge/Swift-5.9+-F05138?style=for-the-badge&logo=swift&logoColor=white" alt="Swift 5.9+">
  <img src="https://img.shields.io/badge/SwiftUI-Native-007AFF?style=for-the-badge&logo=swift&logoColor=white" alt="SwiftUI">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="MIT License">
  <img src="https://img.shields.io/github/v/release/infanteronald/claudeinstalador?style=for-the-badge&color=orange" alt="Release">
</p>

<h1 align="center">Claude Code Installer for macOS</h1>

<p align="center">
  <strong>One-click installer for Claude Code on Mac</strong><br>
  <sub>No terminal knowledge required &bull; No npm &bull; No Homebrew &bull; No Node.js</sub>
</p>

<p align="center">
  <a href="#-download--descarga">Download</a> &bull;
  <a href="#-english">English</a> &bull;
  <a href="#-español">Español</a> &bull;
  <a href="#-architecture--arquitectura">Architecture</a>
</p>

---

## ⬇ Download / Descarga

<table>
<tr>
<td width="50%" align="center">

### English

**[Download ClaudeCodeInstaller.dmg](https://github.com/infanteronald/claudeinstalador/releases/latest)**

1. Download the `.dmg` file
2. Open it
3. Drag the app to **Applications**
4. Open the app
5. Follow the 6-step wizard

**That's it. No terminal needed.**

</td>
<td width="50%" align="center">

### Español

**[Descargar ClaudeCodeInstaller.dmg](https://github.com/infanteronald/claudeinstalador/releases/latest)**

1. Descarga el archivo `.dmg`
2. Ábrelo
3. Arrastra la app a **Applications**
4. Abre la app
5. Sigue los 6 pasos del wizard

**Eso es todo. Sin terminal.**

</td>
</tr>
</table>

---

## 🇬🇧 English

### What is this?

**Claude Code Installer** is a native macOS app that installs [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (Anthropic's AI coding assistant) on your Mac — completely automatically.

If you've ever tried to install Claude Code and hit errors like `command not found: claude`, incompatible Node.js versions, `EACCES: permission denied`, or authentication loops — this app fixes all of that with a visual interface.

### The Problem

Installing Claude Code on macOS requires terminal knowledge most users don't have:

| Barrier | What the user sees |
|---------|-------------------|
| PATH not configured | `command not found: claude` |
| Node.js dependencies | Incompatible versions, NVM, npm |
| Authentication | Keychain loops, invalid tokens |
| Permissions | `EACCES: permission denied` |
| Configuration | `.zshrc` files, environment variables |

### The Solution

A 6-step guided wizard that handles everything:

```
 ┌───────────────────────────────────────────────┐
 │        Claude Code — Smart Installer          │
 │                                               │
 │   ● System Check ── ● Download ── ● PATH     │
 │                                               │
 │   ● Auth ────────── ● Config ──── ● Done!    │
 │                                               │
 │           [ Launch Claude Code ]              │
 └───────────────────────────────────────────────┘
```

### Features

- **Direct binary download** — Native binary from Anthropic servers, no npm or Homebrew needed
- **Smart detection** — Checks macOS version, RAM, CPU architecture (Apple Silicon / Intel), shell
- **Update support** — Detects existing installations, offers to update or keep current version
- **Automatic PATH setup** — Configures `~/.zshrc` or `~/.bash_profile` idempotently
- **Flexible authentication** — Browser OAuth or direct API key with Keychain storage
- **SHA256 verification** — Every downloaded binary is verified against the official manifest
- **Bilingual UI** — English and Spanish, automatic system language detection
- **One-click launch** — When done, a single button opens Terminal with Claude Code running

### System Requirements

| Requirement | Minimum |
|-------------|---------|
| macOS | 13.0 Ventura or later |
| RAM | 4 GB |
| CPU | Apple Silicon (M1–M4) or Intel x64 |
| Disk | ~250 MB free |

### How It Works

#### Phase 1 — System Check

Silently audits the user's environment:
- macOS version (≥ 13.0), RAM (≥ 4 GB), CPU architecture
- Active shell (zsh / bash)
- Existing Claude Code installations
- Conflicts (Homebrew, npm, broken symlinks)

#### Phase 2 — Binary Download

Downloads the native binary directly from Google Cloud Storage:
- Progress bar with percentage, speed (MB/s), and size
- SHA256 integrity verification
- Local cache to avoid re-downloads
- If a version is already installed, offers to update or skip

#### Phase 3 — PATH Configuration

Injects the binary path into the shell profile:
```bash
export PATH="$HOME/.local/bin:$PATH"
```
- Detects the correct file (`~/.zshrc`, `~/.bash_profile`)
- Idempotent — never duplicates entries
- Fallback to `/etc/paths.d/claude` if needed

#### Phase 4 — Authentication

Two options presented visually:
1. **Browser OAuth** — Opens the Anthropic login page
2. **Direct API key** — Secure field to paste your key from `console.anthropic.com`

Includes a "Skip for now" button to authenticate later.

#### Phase 5 — Environment Configuration

- Generates `CLAUDE.md` based on skill level (Beginner → Expert)
- Creates `.gitignore` and `.claudeignore` with standard patterns
- Configures `~/.claude/settings.json` with chosen trust level
- Injects necessary environment variables

#### Phase 6 — Launch

A prominent **"Launch Claude Code"** button opens Terminal.app and runs `claude` automatically in the project directory.

### Security

- **No sudo** — All operations use current user permissions
- **SHA256 verification** — Every binary checked against official manifest
- **Native Keychain** — API keys stored in macOS Keychain with biometric protection
- **No telemetry** — Sets `CLAUDE_TELEMETRY=0` by default
- **Idempotent** — Running the installer multiple times causes no damage or duplicates

---

## 🇪🇸 Español

### ¿Qué es esto?

**Claude Code Installer** es una aplicación nativa macOS que instala [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (el asistente de programación con IA de Anthropic) en tu Mac — de forma completamente automática.

Si alguna vez intentaste instalar Claude Code y te salieron errores como `command not found: claude`, versiones incompatibles de Node.js, `EACCES: permission denied`, o bucles de autenticación — esta app soluciona todo eso con una interfaz visual.

### El Problema

Instalar Claude Code en macOS requiere conocimientos de terminal que la mayoría no tiene:

| Barrera | Qué ve el usuario |
|---------|-------------------|
| PATH no configurado | `command not found: claude` |
| Dependencias Node.js | Versiones incompatibles, NVM, npm |
| Autenticación | Bucles de Keychain, tokens inválidos |
| Permisos | `EACCES: permission denied` |
| Configuración | Archivos `.zshrc`, variables de entorno |

### La Solución

Un wizard guiado de 6 pasos que lo maneja todo:

```
 ┌──────────────────────────────────────────────┐
 │      Claude Code — Instalador Inteligente    │
 │                                              │
 │   ● Verificación ── ● Descarga ── ● PATH   │
 │                                              │
 │   ● Auth ────────── ● Config ──── ● Listo! │
 │                                              │
 │          [ Iniciar Claude Code ]             │
 └──────────────────────────────────────────────┘
```

### Características

- **Descarga directa** — Binario nativo desde los servidores de Anthropic, sin npm ni Homebrew
- **Detección inteligente** — Verifica macOS, RAM, arquitectura (Apple Silicon / Intel), shell
- **Actualizaciones** — Detecta versiones previas y ofrece actualizar o mantener la existente
- **PATH automático** — Configura `~/.zshrc` o `~/.bash_profile` de forma idempotente
- **Autenticación flexible** — OAuth por navegador o clave API directa con Keychain
- **Verificación SHA256** — Cada binario se verifica contra el manifest oficial
- **Bilingüe** — Español e inglés, detección automática del idioma del sistema
- **Un clic para lanzar** — Al finalizar, un botón abre Terminal con Claude Code corriendo

### Requisitos del Sistema

| Requisito | Mínimo |
|-----------|--------|
| macOS | 13.0 Ventura o superior |
| RAM | 4 GB |
| CPU | Apple Silicon (M1–M4) o Intel x64 |
| Disco | ~250 MB libres |

### Cómo Funciona

#### Fase 1 — Verificación del Sistema

Audita silenciosamente el entorno:
- Versión de macOS (≥ 13.0), RAM (≥ 4 GB), arquitectura CPU
- Shell activo (zsh / bash)
- Instalaciones previas de Claude Code
- Conflictos (Homebrew, npm, symlinks rotos)

#### Fase 2 — Descarga del Binario

Descarga el binario nativo directamente de Google Cloud Storage:
- Barra de progreso con porcentaje, velocidad (MB/s) y tamaño
- Verificación de integridad SHA256
- Caché local para evitar re-descargas
- Si ya existe una versión, ofrece actualizar o saltar

#### Fase 3 — Configuración del PATH

Inyecta la ruta del binario en el perfil de shell:
```bash
export PATH="$HOME/.local/bin:$PATH"
```
- Detecta el archivo correcto (`~/.zshrc`, `~/.bash_profile`)
- Idempotente — nunca duplica entradas
- Fallback a `/etc/paths.d/claude` si es necesario

#### Fase 4 — Autenticación

Dos opciones presentadas visualmente:
1. **OAuth por navegador** — Abre la página de login de Anthropic
2. **Clave API directa** — Campo seguro para pegar tu clave desde `console.anthropic.com`

Incluye botón "Omitir por ahora" para autenticar después.

#### Fase 5 — Configuración del Entorno

- Genera `CLAUDE.md` según nivel de experiencia (Principiante → Experto)
- Crea `.gitignore` y `.claudeignore` con patrones estándar
- Configura `~/.claude/settings.json` con nivel de confianza elegido
- Inyecta variables de entorno necesarias

#### Fase 6 — Lanzamiento

Botón prominente **"Iniciar Claude Code"** que abre Terminal.app y ejecuta `claude` automáticamente en el directorio del proyecto.

### Seguridad

- **Sin sudo** — Todas las operaciones usan permisos del usuario actual
- **Verificación SHA256** — Cada binario verificado contra el manifest oficial
- **Keychain nativo** — Claves API almacenadas en Keychain de macOS con protección biométrica
- **Sin telemetría** — Se configura `CLAUDE_TELEMETRY=0` por defecto
- **Idempotente** — Ejecutar el instalador múltiples veces no causa daños ni duplicados

---

## 🏗 Architecture / Arquitectura

```
Sources/ClaudeInstaller/
├── App/
│   ├── ClaudeInstallerApp.swift    # Entry point (@main)
│   ├── AppState.swift              # Central state machine (ObservableObject)
│   └── AppDelegate.swift           # NSApplicationDelegate
├── Models/
│   ├── InstallationPhase.swift     # 6 wizard phases
│   ├── InstallerError.swift        # Bilingual error messages
│   ├── SystemAuditResult.swift     # System audit result
│   ├── ClaudeManifest.swift        # GCS manifest (Codable)
│   └── UserProfile.swift           # Skill level, auth mode, trust level
├── Services/
│   ├── SystemAuditor.swift         # System verification
│   ├── ConflictScanner.swift       # Conflict detection
│   ├── BinaryDownloader.swift      # Download + SHA256 checksum
│   ├── PathConfigurator.swift      # PATH injection
│   ├── KeychainManager.swift       # Keychain + authentication
│   ├── APIKeyManager.swift         # API key validation
│   ├── ClaudeMDGenerator.swift     # CLAUDE.md generation
│   ├── ProjectConfigurator.swift   # .gitignore, .claudeignore
│   ├── SettingsConfigurator.swift  # settings.json
│   ├── EnvironmentConfigurator.swift # Environment variables
│   ├── OnboardingOrchestrator.swift  # Terminal launch
│   ├── MenuBarManager.swift        # macOS menu bar
│   └── DiagnosticRunner.swift      # Diagnostics
├── Views/
│   ├── MainInstallerView.swift     # Root view + navigation
│   ├── WelcomeView.swift           # Welcome screen
│   ├── SystemCheckView.swift       # Phase 1 UI
│   ├── DownloadProgressView.swift  # Phase 2 UI
│   ├── PathConfigView.swift        # Phase 3 UI
│   ├── AuthenticationView.swift    # Phase 4 UI
│   ├── ProjectConfigView.swift     # Phase 5 UI
│   ├── OnboardingCompleteView.swift # Phase 6 UI
│   ├── SkillLevelPickerView.swift  # Skill level picker
│   └── Components/
│       ├── PhaseProgressBar.swift  # Progress bar
│       ├── GlassCard.swift         # Frosted glass card
│       ├── StepCheckmark.swift     # Animated checkmark
│       └── PulsingDotView.swift    # Activity indicator
└── Utilities/
    ├── ShellExecutor.swift         # Process wrapper (with timeout)
    ├── FileSystemHelper.swift      # File operations
    ├── ChecksumVerifier.swift      # SHA256 with CryptoKit
    └── ErrorMapper.swift           # Error translation
```

### Tech Stack

| Component | Technology |
|-----------|-----------|
| Language | Swift 5.9+ with Swift Concurrency (async/await) |
| UI | SwiftUI (macOS 13.0+) |
| Build | Swift Package Manager (no Xcode needed) |
| Networking | Native URLSession |
| Security | Security.framework + CryptoKit |
| Shell | Foundation.Process with configurable timeout |

### Build from Source / Compilar desde Código Fuente

```bash
# Clone / Clonar
git clone https://github.com/infanteronald/claudeinstalador.git
cd claudeinstalador

# Build and run / Compilar y ejecutar
swift run

# Build .app bundle / Crear .app
./Scripts/build-app.sh

# Create .dmg installer / Crear instalador .dmg
./Scripts/create-dmg.sh

# Run tests / Ejecutar tests
swift test
```

> **Note / Nota:** You only need Xcode Command Line Tools / Solo necesitas las Command Line Tools:
> ```bash
> xcode-select --install
> ```

---

## 🤝 Contributing / Contribuir

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Consulta [CONTRIBUTING.md](CONTRIBUTING.md) para las guías de contribución.

## 📄 License / Licencia

MIT — See [LICENSE](LICENSE) for details.

MIT — Ver [LICENSE](LICENSE) para más detalles.

---

<p align="center">
  Built with Swift and SwiftUI for macOS<br>
  <sub>Construido con Swift y SwiftUI para macOS</sub><br><br>
  <sub>Not officially affiliated with Anthropic<br>No afiliado oficialmente con Anthropic</sub>
</p>

<!-- SEO Keywords / Palabras clave SEO -->
<!-- claude code installer, claude code mac, install claude code macos, claude code setup, anthropic claude installer -->
<!-- instalador claude code, instalar claude code mac, claude code macos español, configurar claude code, anthropic claude instalador -->
<!-- claude code command not found fix, claude code path error, claude code node version error, claude code eacces permission denied -->
<!-- how to install claude code on mac, como instalar claude code en mac, claude ai coding assistant, claude code gui installer -->
<!-- claude code without terminal, claude code sin terminal, claude code one click install, claude code apple silicon m1 m2 m3 m4 -->
