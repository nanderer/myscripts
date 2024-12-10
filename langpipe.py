#!/usr/bin/env python3
import sys
import getopt
from langdetect import detect, LangDetectException

def filter_lines(target_language, verbose):
    for line in sys.stdin:
        line = line.strip()  # Entfernt führende und nachfolgende Leerzeichen
        if not line:
            continue  # Leere Zeilen überspringen
        try:
            detected_language = detect(line)
            if detected_language == target_language:
                print(line)  # Ausgabe der Zeile, wenn die Sprache übereinstimmt
            elif verbose:  # Wenn -v gesetzt ist, auch unsichere Zeilen ausgeben
                print(f"[uncertain] {line}")
        except LangDetectException:
            if verbose:
                print(f"[detection failed] {line}")

def main():
    # Initialisieren der Variablen
    target_language = None
    verbose = False

    try:
        opts, args = getopt.getopt(sys.argv[1:], "vl:", ["verbose", "language="])
    except getopt.GetoptError as err:
        print(str(err))
        sys.exit(2)

    # Argumente auswerten
    for opt, arg in opts:
        if opt in ("-v", "--verbose"):
            verbose = True
        elif opt in ("-l", "--language"):
            target_language = arg

    if not target_language:
        print("Usage: langpipe.py -l <language> [-v]")
        sys.exit(2)

    filter_lines(target_language, verbose)

if __name__ == '__main__':
    main()

