# Características de Ongaku Player

## 🎯 Objetivos del proyecto

Crear un reproductor de música de YouTube ligero para terminal, similar a lowfi, pero con capacidades completas de búsqueda y reproducción.

## ✨ Características implementadas

### 🔍 Búsqueda en YouTube
- Búsqueda integrada usando yt-dlp
- Resultados con título y duración
- Selección interactiva con tty-prompt
- Filtrado de resultados

### 🎵 Reproducción
- Streaming directo (sin descargas)
- Backend con mpv (muy eficiente)
- Solo audio (no video)
- Reproducción en background

### 🎮 Controles
- ⏸️ Pausar/Reanudar
- ⏹️ Detener
- ⏭️ Siguiente canción
- ⏮️ Canción anterior
- 🔊/🔉 Control de volumen
- ⏩/⏪ Adelantar/Retroceder

### 📋 Gestión de cola
- Cola de reproducción
- Ver todas las canciones
- Saltar a cualquier canción
- Indicador de canción actual

### 🎨 Interfaz
- UI con tty-prompt (menús interactivos)
- Cajas decorativas con tty-box
- Colores con pastel
- Diseño minimalista

### 🚀 Modo Demo
- Lista de canciones de ejemplo
- Funciona sin conexión
- Detección automática de conectividad
- Útil para pruebas

## 🏗️ Arquitectura

```
ongaku-player/
├── ongaku.rb              # Archivo principal ejecutable
├── lib/
│   ├── youtube_search.rb  # Búsqueda en YouTube con yt-dlp
│   ├── player.rb          # Reproductor con mpv
│   ├── ui.rb              # Interfaz de usuario
│   └── demo_mode.rb       # Modo demo sin conexión
├── demo.rb                # Demo visual
├── test_search.rb         # Script de prueba
├── Gemfile                # Dependencias Ruby
├── README.md              # Documentación principal
└── FEATURES.md            # Este archivo
```

## 🔧 Dependencias

### Sistema
- `yt-dlp`: Para buscar y obtener URLs de YouTube
- `mpv`: Para reproducir el audio

### Ruby (gemas)
- `tty-prompt`: Menús interactivos
- `tty-box`: Cajas decorativas
- `tty-cursor`: Control del cursor
- `pastel`: Colores en terminal
- `down`: Descarga de archivos (opcional)

## 💡 Decisiones de diseño

### ¿Por qué yt-dlp?
- Más mantenido que youtube-dl
- Soporte para múltiples sitios
- Actualizado frecuentemente
- Excelente para extraer URLs de streaming

### ¿Por qué mpv?
- Muy ligero y eficiente
- Soporte para streaming
- Control por socket IPC
- Sin interfaz gráfica necesaria

### ¿Por qué Ruby?
- Sintaxis elegante y clara
- Excelentes gemas para terminal (tty-*)
- Fácil de leer y mantener
- Ideal para scripts de sistema

### ¿Por qué no descargar los archivos?
- Streaming directo ahorra espacio
- Reproducción inmediata
- No requiere limpieza de archivos temporales
- Menor uso de disco

## 🎯 Casos de uso

1. **Programadores**: Música de fondo mientras codean
2. **Estudiantes**: Música para estudiar/concentrarse
3. **Servidores remotos**: Reproducción en SSH
4. **Minimalistas**: Sin necesidad de navegador
5. **Usuarios de terminal**: Todo desde la línea de comandos

## 🔮 Posibles mejoras futuras

- [ ] Playlists guardadas
- [ ] Historial de reproducción
- [ ] Ecualización de audio
- [ ] Letras sincronizadas
- [ ] Soporte para SoundCloud
- [ ] Búsqueda por artista/álbum
- [ ] Visualizador de espectro ASCII
- [ ] Hotkeys globales
- [ ] Guardado de estado entre sesiones
- [ ] Modo aleatorio (shuffle)
- [ ] Repetir canción/cola

## 📊 Comparación con otras soluciones

### vs lowfi
- ✅ Similar en concepto
- ✅ Ongaku tiene búsqueda completa
- ✅ Más opciones de control
- ✅ Cola de reproducción

### vs YouTube en navegador
- ✅ Mucho más ligero
- ✅ Sin consumo de RAM del navegador
- ✅ Interfaz más rápida
- ❌ Sin comentarios/likes

### vs spotify-tui
- ✅ No requiere cuenta premium
- ✅ Acceso a todo YouTube
- ❌ Spotify tiene mejor catálogo organizado

## 📝 Licencia

MIT
