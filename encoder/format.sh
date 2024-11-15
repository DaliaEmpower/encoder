#!/bin/bash

# Función para convertir videos a HLS
convert_to_hls() {
  local input_file="$1"
  local base_input_dir="$2"
  local base_output_dir="$3"
 
  # Obtener el nombre base del archivo sin extensión
  local filename=$(basename -- "$input_file")
  local name="${filename%.*}"
 
  # Construir el path de salida replicando la estructura del directorio de entrada
  local relative_dir="${input_file#$base_input_dir}"
  relative_dir="$(dirname "$relative_dir")"
  local output_subdir="$base_output_dir$relative_dir/$name"
  mkdir -p "$output_subdir"
 
  # Convertir el video a HLS con diferentes resoluciones y bitrates
  ffmpeg -i "$input_file" -map 0:v -map 0:a -c:v h264_nvenc -c:a aac \
    -vf "scale=1920:1080" -b:v 8000k -b:a 320k -ar 48000 -ac 2 -hls_time 6 -hls_list_size 0 -hls_playlist_type vod -hls_segment_filename "$output_subdir/1080p_%03d.ts" "$output_subdir/1080p.m3u8" \
    -vf "scale=1280:720" -b:v 5000k -b:a 256k -ar 24000 -ac 2 -hls_time 6 -hls_list_size 0 -hls_playlist_type vod -hls_segment_filename "$output_subdir/720p_%03d.ts" "$output_subdir/720p.m3u8" \
    -vf "scale=960:540" -b:v 2500k -b:a 192k -ar 16000 -ac 2 -hls_time 6 -hls_list_size 0 -hls_playlist_type vod -hls_segment_filename "$output_subdir/540p_%03d.ts" "$output_subdir/540p.m3u8" \
    -vf "scale=640:360" -b:v 1000k -b:a 128k -ar 12000 -ac 2 -hls_time 6 -hls_list_size 0 -hls_playlist_type vod -hls_segment_filename "$output_subdir/360p_%03d.ts" "$output_subdir/360p.m3u8" \
    -vf "scale=426:240" -b:v 800k -b:a 96k -ar 11025 -ac 2 -hls_time 6 -hls_list_size 0 -hls_playlist_type vod -hls_segment_filename "$output_subdir/240p_%03d.ts" "$output_subdir/240p.m3u8"
 
  # Escribir el archivo de playlist maestro
  echo "#EXTM3U" > "$output_subdir/master.m3u8"
  echo "#EXT-X-STREAM-INF:BANDWIDTH=48000,RESOLUTION=1920x1080" >> "$output_subdir/master.m3u8"
  echo "1080p.m3u8" >> "$output_subdir/master.m3u8"
  echo "#EXT-X-STREAM-INF:BANDWIDTH=24000,RESOLUTION=1280x720" >> "$output_subdir/master.m3u8"
  echo "720p.m3u8" >> "$output_subdir/master.m3u8"
  echo "#EXT-X-STREAM-INF:BANDWIDTH=16000,RESOLUTION=960x540" >> "$output_subdir/master.m3u8"
  echo "540p.m3u8" >> "$output_subdir/master.m3u8"
  echo "#EXT-X-STREAM-INF:BANDWIDTH=12000,RESOLUTION=640x360" >> "$output_subdir/master.m3u8"
  echo "360p.m3u8" >> "$output_subdir/master.m3u8"
  echo "#EXT-X-STREAM-INF:BANDWIDTH=11025,RESOLUTION=426x240" >> "$output_subdir/master.m3u8"
  echo "240p.m3u8" >> "$output_subdir/master.m3u8"
}

# Directorios de entrada y salida
input_dir="./ts-hans"
output_dir="./output"

# Crear el directorio de salida si no existe
mkdir -p "$output_dir"

# Cambiar al directorio donde reside el script para manejar las rutas relativas
cd "$(dirname "$0")"

# Listar los directorios de primer nivel dentro del directorio de entrada
dirs=($(find "$input_dir" -mindepth 1 -maxdepth 1 -type d))

# Iterar sobre cada directorio en el array
for dir in "${dirs[@]}"; do
  echo "Procesando videos en el directorio: $dir"

  # Listar todos los videos .mp4 en el directorio actual
  videos=($(find "$dir" -maxdepth 1 -type f -name "*.mp4"))

  # Iterar sobre cada video en el array
  for video in "${videos[@]}"; do
    echo "Convirtiendo el video: $video"
    convert_to_hls "$video" "$input_dir" "$output_dir"
  done

  echo "Proceso completado en directorio: $dir"
done

echo "Proceso global completado."
