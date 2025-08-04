#!/bin/bash

LAST_HASH=""

echo "[INFO] Clipwatcher gestartet..."

while true; do
    # Versuche, Text aus Zwischenablage zu holen
    TEXT=$(xclip -selection clipboard -o 2>/dev/null)

    if [[ -n "$TEXT" ]]; then
        HASH=$(echo "$TEXT" | sha256sum | awk '{print $1}')
        if [ "$HASH" != "$LAST_HASH" ]; then
            LAST_HASH="$HASH"
            echo "[TEXT] $TEXT"
            CLEAN=$(echo "$TEXT" | tr '[:upper:]' '[:lower:]')
            espeak "$CLEAN"
        fi
    else
        # Kein Text? Dann prüfen, ob Bild vorhanden ist
        if xclip -selection clipboard -t image/png -o > /tmp/clipwatch_img.png 2>/dev/null; then
            HASH=$(sha256sum /tmp/clipwatch_img.png | awk '{print $1}')
            if [ "$HASH" != "$LAST_HASH" ]; then
                LAST_HASH="$HASH"
                echo "[INFO] OCR läuft..."
                OCRTEXT=$(tesseract /tmp/clipwatch_img.png stdout -l deu 2>/dev/null)
                echo "[OCR] $OCRTEXT"
                CLEAN=$(echo "$OCRTEXT" | tr '[:upper:]' '[:lower:]')
                espeak "$CLEAN"
            fi
        fi
    fi

    sleep 2
done

