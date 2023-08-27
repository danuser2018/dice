#!/bin/bash

genera_key() {
  caracteres_base64="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/"
  key=$(echo "$caracteres_base64" | fold -w1 | shuf | tr -d '\n')

  echo "$key"
}

guarda_key() {
  key="$1"
  echo "$key" > ~/.dice/key
}	

verifica_key() {
  local clave="$1"
  local caracteres_base64="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/"
  
  # Verificar si la clave contiene todos los caracteres de Base64
  for ((i = 0; i < ${#caracteres_base64}; i++)); do
    car=${caracteres_base64:i:1}
    if [[ ! "$clave" == *"$car"* ]]; then
      print_clave_incorrecta
      exit 1
    fi
  done

  # Verificar si la clave contiene caracteres repetidos
  local caracteres_unicos=""
  for ((i = 0; i < ${#clave}; i++)); do
    car=${clave:i:1}
    if [[ "$caracteres_unicos" == *"$car"* ]]; then
      print_clave_incorrecta
      exit 1
    fi
    caracteres_unicos="$caracteres_unicos$car"
  done

  # Verificar si la clave contiene otros caracteres que no pertenezcan a Base64
  if [[ "$clave" =~ [^${caracteres_base64}] ]]; then
    print_clave_incorrecta
    exit 1
  fi
  
  return 0
}

crea_matriz() {
  key="$(cat ~/.dice/key)"
  verifica_key "$key"
  matriz=()
  
  for ((i = 0; i < 8; i++)); do
    fila="${key:i*8:8}"
    matriz+=("$fila")
  done
}	

caracter_to_fila_columna() {
  caracter="$1"
  indice=0
  
  for fila in "${matriz[@]}"; do
    if [[ $fila == *"$caracter"* ]]; then
      for ((col = 0; col < ${#fila}; col++)); do
        if [[ "${fila:$col:1}" == "$caracter" ]]; then
          echo "$indice$col"
          return
        fi
      done
    fi
    ((indice++))
  done
}

fila_columna_to_caracter() {
  cadena="$1"
  fila=${cadena:0:1}
  columna=${cadena:1:1}
  echo "${matriz[$fila]:columna:1}"
}	

codifica_fila() {
  digito="$1"

  fila="${matriz[$digito]}"
  columna=$((RANDOM % 7))
  echo "${fila:columna:1}"
}

decodifica_fila() {
  caracter="$1"
  indice=0

  for fila in "${matriz[@]}"; do
    if [[ $fila == *"$caracter"* ]]; then
      echo "$indice"
      return
    fi
    ((indice++))
  done
}  

codifica_columna() {
  columna="$1"

  fila=$((RANDOM % 7))
  echo "${matriz[$fila]:columna:1}"
}

decodifica_columna() {
  caracter="$1"

  for fila in "${matriz[@]}"; do
    if [[ $fila == *"$caracter"* ]]; then
      for ((col = 0; col < ${#fila}; col++)); do
        if [[ "${fila:$col:1}" == "$caracter" ]]; then
          echo "$col"
          return
        fi
      done
    fi  
  done
}	

base64_pad() {
  mensaje="$1"
  pad=""
  if [[ $mensaje =~ (=*)$ ]]; then
    pad="${BASH_REMATCH[1]}"
  fi
  echo "$pad"
}

codifica_mensaje() {
  mensaje="$1"
  mensaje_digitos=""
  mensaje_codificado=""
 
  crea_matriz

  for ((i = 0; i < ${#mensaje}; i++)); do
    caracter="${mensaje:i:1}"
    if [ "$caracter" = "=" ]; then
      resultado=$caracter
    else
      resultado=$(caracter_to_fila_columna "$caracter")
    fi  
    mensaje_digitos+="$resultado"
  done

  for ((i = 0; i < ${#mensaje_digitos}; i++)); do
    digito="${mensaje_digitos:i:1}"
    if [ "$digito" = "=" ]; then
      resultado=$digito	    
    elif [ $((i % 2)) -eq 0 ]; then
      resultado=$(codifica_fila "$digito")
    else  
      resultado=$(codifica_columna "$digito")    
    fi  
    mensaje_codificado+="$resultado"
  done  
  
  echo "$mensaje_codificado"
}

decodifica_mensaje() {
  mensaje="$1"
  pad=$(base64_pad "$mensaje")
  mensaje_sin_pad="${mensaje%%pad}"
  mensaje_digitos=""
  mensaje_base64=""

  crea_matriz

  for ((i = 0; i < ${#mensaje_sin_pad}; i++)); do
    caracter="${mensaje:i:1}"
    if [ $((i % 2)) -eq 0 ]; then
      resultado=$(decodifica_fila "$caracter")
    else
      resultado=$(decodifica_columna "$caracter")
    fi
    mensaje_digitos+="$resultado"
  done  

  for ((i = 0; i < ${#mensaje_digitos} - 1; i += 2)); do
    resultado=$(fila_columna_to_caracter "${mensaje_digitos:i:2}")
    mensaje_base64+="$resultado"
  done
  mensaje_base64+="$pad"
  
  echo "$mensaje_base64"
}

print_uso() {
  echo "Uso: $0 [OPCION] [ARCHIVO]"
  echo "Para ver la ayuda, utiliza: $0 -h"
}

print_ayuda() {
  echo "Uso: $0 [OPCION] [ARCHIVO]"
  echo "$0 codifica/decodifica ARCHIVO, o la entrada estándar, a la salida estándar."
  echo ""
  echo "Si no se pasa ARCHIVO, utiliza la entrada estándar."
  echo ""
  echo "Opciones:"
  echo "  -e  Codifica"
  echo "  -d  Decodifica"
  echo "  -r  Rota la clave para encriptar/desencriptar. Si se pasa ARCHIVO"
  echo "      con la clave, establece esa, sino genera una al azar." 
  echo "  -h  Muestra esta ayuda"
  echo "  -v  Muestra información de la versión"
  echo ""
  echo "$0 utiliza Base64 para estandarizar el contenido del mensaje, y posteriormente"
  echo "utiliza el algoritmo DICE para encriptar los datos"
  echo ""
}

print_clave_incorrecta() {
  echo "La clave configurada no es válida. Para configurar una clave válida"
  echo "utiliza: $0 -r [ARCHIVO]"
}

print_version() {
  echo "$0 v1.0.0"
  echo "Copyright (C) 2023 danuser2018"
  echo "Este software se adhiere a la licencia MIT <https://mit-license.org/>"
}	

mkdir -p ~/.dice
chmod 700 ~/.dice
if [[ ! -e ~/.dice/key ]]; then
  echo "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/" > ~/.dice/key
  chmod 700 ~/.dice/key
fi  

if [ $# -lt 1 ]; then
  print_uso
  exit 1
fi

if [ $# -gt 2 ]; then
  print_uso
  exit 1
fi

while getopts "edrhv" opcion; do
  case $opcion in
    e)
      if [ -z "$2" ]; then
	mensaje=$(base64 -w0)
      else
	mensaje=$(base64 -w0 "$2")
      fi	    
      
      codifica_mensaje "$mensaje"
      exit 0
      ;;
    d)
      if [ -z "$2" ]; then
        read mensaje
      else
        mensaje=$(cat "$2")
      fi

      decodifica_mensaje "$mensaje" | base64 -d 2>/dev/null
      exit 0
      ;;
    r)
      if [ -z "$2" ]; then
        key=$(genera_key)
      else	
        key=$(cat "$2")
      fi	
      verifica_key "$key"
      guarda_key "$key"
      echo "$key"
      exit 0
      ;;
    h)
      print_ayuda
      exit 0
      ;;
    v)  
      print_version
      exit 0
      ;;
    *)
      print_uso
      exit 1
      ;;
  esac
done
