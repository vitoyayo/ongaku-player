# 🎵 Ongaku Player

Un reproductor de música de YouTube ligero para terminal, escrito en Ruby.

## Características

- 🎧 Reproduce música directamente desde YouTube
- 🖥️ Interfaz sencilla en terminal
- ⚡ Ligero y rápido
- 🎮 Controles intuitivos
- 🔍 Búsqueda integrada de YouTube

## Requisitos

- Ruby 2.7+
- `yt-dlp` (para obtener URLs de YouTube)
- `mpv` (para reproducir audio)

### Instalación de dependencias del sistema

#### Ubuntu/Debian
```bash
sudo apt-get install yt-dlp mpv
```

#### macOS
```bash
brew install yt-dlp mpv
```

#### Arch Linux
```bash
sudo pacman -S yt-dlp mpv
```

## Instalación

### Método 1: Instalación automática (Recomendado)

```bash
# Clonar el repositorio
git clone https://github.com/vitoyayo/ongaku-player.git
cd ongaku-player

# Ejecutar instalador (instala todo automáticamente)
./install.sh
```

El instalador detectará tu sistema operativo e instalará:
- Dependencias del sistema (yt-dlp, mpv)
- Gemas de Ruby necesarias
- El ejecutable `ongaku` en tu PATH

### Método 2: Instalación como gema de Ruby

```bash
# Clonar el repositorio
git clone https://github.com/vitoyayo/ongaku-player.git
cd ongaku-player

# Construir e instalar la gema
gem build ongaku-player.gemspec
gem install ongaku-player-*.gem

# Instalar dependencias del sistema manualmente
# Ubuntu/Debian:
sudo apt-get install yt-dlp mpv

# macOS:
brew install yt-dlp mpv

# Arch Linux:
sudo pacman -S yt-dlp mpv
```

### Método 3: Instalación con Rake

```bash
# Clonar el repositorio
git clone https://github.com/vitoyayo/ongaku-player.git
cd ongaku-player

# Instalar dependencias del sistema primero (ver Método 2)

# Instalar con rake
rake install
```

### Método 4: Instalación manual

```bash
# Clonar el repositorio
git clone https://github.com/vitoyayo/ongaku-player.git
cd ongaku-player

# Instalar dependencias del sistema
sudo apt-get install yt-dlp mpv  # Ubuntu/Debian

# Instalar gemas de Ruby
gem install tty-prompt tty-box tty-cursor pastel

# Hacer ejecutable
chmod +x ongaku.rb
```

## Uso

```bash
# Si instalaste con install.sh o como gema
ongaku

# O ejecutar directamente desde el repositorio
./bin/ongaku

# Con ruby
ruby ongaku.rb

# Con rake (modo desarrollo)
rake run

# Modo demo (sin conexión a internet)
DEMO_MODE=1 ongaku
# o
rake demo
```

### Modos de operación

**Modo Normal**: Busca y reproduce música directamente desde YouTube usando yt-dlp.

**Modo Demo**: Si no hay conexión a internet, el reproductor automáticamente usa una lista de canciones de ejemplo. Puedes forzar el modo demo con:
```bash
DEMO_MODE=1 ./ongaku.rb
```

### Controles

- `🔍 Buscar música`: Busca canciones en YouTube (o en la lista demo)
  - Búsqueda normal: "lofi hip hop"
  - Búsqueda por tags: "#ambient" o "#lofi beats"
  - Combinar: "study music #chill"
- `📋 Ver cola`: Ver y gestionar la cola de reproducción
- `⏯️ Reproducción`: Controles de reproducción (pausar, siguiente, volumen, etc.)
- `❌ Salir`: Cerrar el reproductor

### Controles de reproducción

- ⏸️ Pausar/Reanudar
- ⏹️ Detener
- ⏭️ Siguiente canción
- ⏮️ Canción anterior
- 🔊 Subir volumen
- 🔉 Bajar volumen
- ⏩ Adelantar 10 segundos
- ⏪ Retroceder 10 segundos

## Arquitectura

El reproductor está diseñado para ser lo más ligero posible:

- Usa `yt-dlp` para obtener URLs de streaming de YouTube
- Usa `mpv` como backend de audio (muy eficiente)
- Interfaz minimalista con `tty-prompt`
- Sin descargas de archivos (streaming directo)

## Comandos útiles

```bash
# Construir la gema
rake build

# Instalar localmente
rake install

# Desinstalar
rake uninstall

# Ejecutar en desarrollo
rake run

# Modo demo
rake demo

# Mostrar demo visual
rake show_demo

# Probar búsqueda
rake test_search

# Limpiar y reinstalar
rake reinstall
```

## Desarrollo

### Estructura del proyecto

```
ongaku-player/
├── bin/
│   └── ongaku              # Ejecutable principal
├── lib/
│   ├── ongaku_player.rb    # Módulo principal
│   ├── youtube_search.rb   # Búsqueda en YouTube
│   ├── player.rb           # Reproductor con mpv
│   ├── ui.rb               # Interfaz de usuario
│   └── demo_mode.rb        # Modo demo
├── ongaku-player.gemspec   # Especificación de la gema
├── Gemfile                 # Dependencias
├── Rakefile                # Tareas de rake
├── install.sh              # Instalador automático
├── README.md               # Este archivo
├── FEATURES.md             # Características detalladas
└── LICENSE                 # Licencia MIT
```

### Contribuir

1. Fork el proyecto
2. Crea tu rama de características (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## Licencia

MIT - Ver [LICENSE](LICENSE) para más detalles.
