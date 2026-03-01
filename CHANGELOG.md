# Changelog

Todos los cambios notables de este proyecto se documentan aquí.

El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).

## [1.0.0] - 2025-03-01

### Agregado

- Wizard de instalación de 6 fases con interfaz gráfica nativa SwiftUI
- **Fase 1 - Verificación del Sistema:** Auditoría automática de macOS, RAM, CPU, shell y conflictos
- **Fase 2 - Descarga:** Descarga directa del binario desde GCS con barra de progreso y verificación SHA256
- **Fase 3 - PATH:** Configuración automática e idempotente del PATH en `~/.zshrc` o `~/.bash_profile`
- **Fase 4 - Autenticación:** Soporte para OAuth por navegador y clave API directa con Keychain
- **Fase 5 - Configuración:** Generación de `CLAUDE.md`, `.gitignore`, `.claudeignore` y `settings.json`
- **Fase 6 - Lanzamiento:** Botón "Iniciar Claude Code" que abre Terminal.app con `claude` ejecutándose
- Detección de versiones previas con opción de actualizar o mantener la existente
- Comparación semántica de versiones (e.g., v2.1.44 vs v2.1.50)
- Interfaz bilingüe (Español / Inglés) con detección automática del idioma del sistema
- Selector de nivel de experiencia (Principiante, Intermedio, Avanzado, Experto)
- Selector de nivel de confianza para configuración de permisos
- Barra de menús macOS con acciones rápidas (Abrir Claude, Diagnóstico, Purgar Caché)
- Botón "Omitir" en autenticación visible incluso durante procesamiento
- Timeout configurable en `ShellExecutor` para evitar procesos bloqueados
- Componentes UI reutilizables: GlassCard, PhaseProgressBar, StepCheckmark, PulsingDotView
- Panel de diagnósticos integrado en la fase de finalización
- Escaneo de conflictos en 5 ubicaciones (Homebrew, npm, symlinks, binarios corruptos)
- Caché local de descargas para evitar re-descargas innecesarias

### Seguridad

- Verificación SHA256 de todos los binarios descargados
- Almacenamiento de claves API en Keychain con protección biométrica (Touch ID)
- Operaciones sin `sudo` — solo permisos de usuario
- Variable `CLAUDE_TELEMETRY=0` configurada por defecto
