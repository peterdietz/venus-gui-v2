#!/bin/bash
set -e

PLUGIN_NAME="NavigationExample"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

RCC_BIN=$(command -v rcc 2>/dev/null \
    || find /opt/qt -name rcc -type f 2>/dev/null | head -1 \
    || find /opt/victronenergy -name rcc -type f 2>/dev/null | head -1 \
    || echo "")

if [ -z "$RCC_BIN" ]; then
    echo "ERROR: rcc not found. Install Qt 6 or run on a Venus OS Large image."
    exit 1
fi

cat > "${PLUGIN_NAME}.qrc" << EOF
<RCC>
<qresource prefix="/${PLUGIN_NAME}">
<file>${PLUGIN_NAME}_Page.qml</file>
<file>icon_brick.svg</file>
</qresource>
</RCC>
EOF

"$RCC_BIN" -binary -o "${PLUGIN_NAME}.rcc" "${PLUGIN_NAME}.qrc"
RESOURCE_B64=$( (base64 -i "${PLUGIN_NAME}.rcc" 2>/dev/null \
    || base64 "${PLUGIN_NAME}.rcc") | tr -d '\n')

cat > "${PLUGIN_NAME}.json" << JSONEOF
{
    "name": "${PLUGIN_NAME}",
    "version": "1.0",
    "minRequiredVersion": "",
    "maxRequiredVersion": "",
    "translations": [],
    "integrations": [
        {
            "type": 3,
            "title": "Example",
            "icon": "qrc:/${PLUGIN_NAME}/icon_brick.svg",
            "url": "qrc:/${PLUGIN_NAME}/${PLUGIN_NAME}_Page.qml"
        }
    ],
    "resource": "${RESOURCE_B64}"
}
JSONEOF

rm -f "${PLUGIN_NAME}.qrc" "${PLUGIN_NAME}.rcc"
echo "Built ${PLUGIN_NAME}.json ($(wc -c < "${PLUGIN_NAME}.json") bytes)"
