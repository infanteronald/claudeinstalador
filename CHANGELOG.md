# Changelog

All notable changes to this project are documented here.
Todos los cambios notables de este proyecto se documentan aquí.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.0] - 2025-03-01

### Added / Agregado

- 6-phase installation wizard with native SwiftUI GUI / Wizard de instalación de 6 fases con interfaz gráfica nativa SwiftUI
- **Phase 1 - System Check:** Automatic audit of macOS, RAM, CPU, shell, and conflicts / Auditoría automática de macOS, RAM, CPU, shell y conflictos
- **Phase 2 - Download:** Direct binary download from GCS with progress bar and SHA256 verification / Descarga directa del binario desde GCS con barra de progreso y verificación SHA256
- **Phase 3 - PATH:** Automatic idempotent PATH configuration in `~/.zshrc` or `~/.bash_profile` / Configuración automática e idempotente del PATH
- **Phase 4 - Authentication:** Browser OAuth and direct API key with Keychain support / Soporte para OAuth por navegador y clave API directa con Keychain
- **Phase 5 - Configuration:** Generation of `CLAUDE.md`, `.gitignore`, `.claudeignore`, and `settings.json` / Generación de archivos de configuración
- **Phase 6 - Launch:** "Launch Claude Code" button that opens Terminal.app with `claude` running / Botón "Iniciar Claude Code" que abre Terminal.app
- Previous version detection with update or keep option / Detección de versiones previas con opción de actualizar
- Semantic version comparison (e.g., v2.1.44 vs v2.1.50) / Comparación semántica de versiones
- Bilingual interface (English / Spanish) with automatic language detection / Interfaz bilingüe con detección automática
- Skill level selector (Beginner, Intermediate, Advanced, Expert) / Selector de nivel de experiencia
- Trust level selector for permission configuration / Selector de nivel de confianza
- macOS menu bar with quick actions (Open Claude, Diagnostics, Purge Cache) / Barra de menús con acciones rápidas
- "Skip" button in authentication visible even during processing / Botón "Omitir" visible incluso durante procesamiento
- Configurable timeout in `ShellExecutor` to prevent process hangs / Timeout configurable para evitar bloqueos
- Reusable UI components: GlassCard, PhaseProgressBar, StepCheckmark, PulsingDotView / Componentes UI reutilizables
- Built-in diagnostics panel / Panel de diagnósticos integrado
- Conflict scanning in 5 locations (Homebrew, npm, symlinks, corrupt binaries) / Escaneo de conflictos en 5 ubicaciones
- Local download cache / Caché local de descargas
- `.app` bundle build script / Script de creación de .app
- `.dmg` installer with drag-to-Applications / Instalador .dmg con arrastrar a Applications
- Custom app icon (gradient with terminal symbol) / Ícono personalizado

### Security / Seguridad

- SHA256 verification of all downloaded binaries / Verificación SHA256 de todos los binarios
- API keys stored in Keychain with biometric protection (Touch ID) / Claves API en Keychain con protección biométrica
- No `sudo` operations — user permissions only / Sin `sudo` — solo permisos de usuario
- `CLAUDE_TELEMETRY=0` set by default / configurado por defecto
