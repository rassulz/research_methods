#!/usr/bin/env bash
# Собирает poster.html в PDF формата A1 (594 x 841 мм).
# Запуск:  bash poster/make-pdf.sh
# Результат: Aktobe_Poster_A1.pdf в корне репозитория.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(dirname "$here")"
html="$here/poster.html"
out="$repo/Aktobe_Poster_A1.pdf"

find_browser() {
  for p in \
    "/c/Program Files/Google/Chrome/Application/chrome.exe" \
    "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe" \
    "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    "$(command -v google-chrome || true)" \
    "$(command -v chromium || true)" \
    "$(command -v chromium-browser || true)"
  do
    [ -n "$p" ] && [ -x "$p" ] && { echo "$p"; return; }
  done
  return 1
}

browser="$(find_browser)" || { echo "Не найден Chrome / Chromium / Edge." >&2; exit 1; }
echo "Браузер: $browser"

# В Git Bash / MSYS пути вида /c/Users/... Chrome не понимает — переводим в C:/Users/...
if command -v cygpath >/dev/null 2>&1; then
  url_path="$(cygpath -m "$html")"
  out_path="$(cygpath -w "$out")"
else
  url_path="$html"
  out_path="$out"
fi

"$browser" --headless=new --disable-gpu --no-sandbox --no-pdf-header-footer \
           --print-to-pdf="$out_path" "file:///$url_path" >/dev/null 2>&1

if [ -f "$out" ]; then
  echo "Готово: $out ($(du -h "$out" | cut -f1))"
  echo "Проверь размер страницы — должно быть 594 x 841 мм."
else
  echo "PDF не создан." >&2; exit 1
fi
