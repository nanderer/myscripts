#!/bin/bash

# Überprüfe, ob die Anzahl der übergebenen Argumente korrekt ist
if [ $# -ne 1 ] || ! [[ $1 =~ ^[0-9]+$ ]]; then
  echo "Verwendung: $0 <Anzahl der zu zwischenspeichernden Zeilen (ganze Zahl)>"
  exit 1
fi

# Anzahl der zu zwischenspeichernden Zeilen
x=$1

# Array zum Speichern der zwischengespeicherten Zeilen
declare -a lines

# Schleife zum Einlesen und Filtern der Zeilen
while read -r line; do
  # Überprüfe, ob die aktuelle Zeile bereits im Array existiert
  if [[ ! " ${lines[@]} " =~ " $line " ]]; then
    echo "$line" | grep -v 'm 0 0 l ' | grep -v 'm 224' 
    lines+=("$line")

    # Wenn das Array die gewünschte Anzahl von Zeilen erreicht hat, entferne die älteste Zeile
    if [ ${#lines[@]} -gt $x ]; then
      unset 'lines[0]'
      lines=("${lines[@]}")
    fi
  fi
done
