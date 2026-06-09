import QtQuick
import Victron.VenusOS

Page {
	id: root

	// All data comes from Global.system, Global.tanks, Global.solarInputs,
	// Global.acInputs, Global.dcInputs, and Global.evChargers. These are
	// always present (even barebones mock). Tiles gracefully hide or show
	// "No data" based on what hardware is connected.

	property string systemUid: Global.system ? Global.system.serviceUid : ""

	function fmtPower(w) {
		if (isNaN(w)) return "--"
		return Math.abs(Math.round(w)) + " W"
	}
	function fmtVolts(v) {
		if (isNaN(v)) return "--"
		return v.toFixed(1) + " V"
	}
	function fmtAmps(a) {
		if (isNaN(a)) return "--"
		return a.toFixed(1) + " A"
	}
	function fmtPercent(p) {
		if (isNaN(p)) return "--"
		return Math.round(p) + "%"
	}

	Flickable {
		anchors.fill: parent
		anchors.margins: 8
		contentHeight: grid.height
		clip: true

		Grid {
			id: grid
			width: parent.width
			columns: 2
			spacing: 8

			// ── Battery ──────────────────────────────────────────────────
			Rectangle {
				width: (grid.width - grid.spacing) / 2
				height: 140
				radius: 8
				color: Theme.color_darkOk_background || "#1a2744"
				border.color: Theme.color_listItem_border || "#334466"

				Column {
					anchors.fill: parent
					anchors.margins: 10
					spacing: 4

					Text {
						text: "BATTERY"
						color: Theme.color_font_secondary || "#88aacc"
						font.pixelSize: 11
						font.bold: true
					}

					Text {
						text: fmtPercent(Global.system.battery.stateOfCharge)
						color: {
							var soc = Global.system.battery.stateOfCharge
							if (isNaN(soc)) return Theme.color_font_primary
							if (soc <= 15) return "#e74c3c"
							if (soc <= 30) return "#f39c12"
							return "#2ecc71"
						}
						font.pixelSize: 36
						font.bold: true
					}

					Row {
						spacing: 16
						Text {
							text: fmtVolts(Global.system.battery.voltage)
							color: Theme.color_font_primary || "#ccddee"
							font.pixelSize: 13
						}
						Text {
							text: fmtAmps(Global.system.battery.current)
							color: {
								var c = Global.system.battery.current
								if (isNaN(c)) return Theme.color_font_primary
								return c < 0 ? "#2ecc71" : "#e74c3c"
							}
							font.pixelSize: 13
						}
					}

					Text {
						text: {
							var p = Global.system.battery.power
							if (isNaN(p)) return "No battery"
							return (p < 0 ? "Charging " : "Discharging ") + fmtPower(p)
						}
						color: Theme.color_font_secondary || "#88aacc"
						font.pixelSize: 11
					}

					Text {
						visible: !isNaN(Global.system.battery.temperature)
						text: !isNaN(Global.system.battery.temperature)
							? Math.round(Global.system.battery.temperature) + " °C"
							: ""
						color: Theme.color_font_secondary || "#88aacc"
						font.pixelSize: 11
					}
				}
			}

			// ── Solar ────────────────────────────────────────────────────
			Rectangle {
				width: (grid.width - grid.spacing) / 2
				height: 140
				radius: 8
				color: Theme.color_darkOk_background || "#1a2744"
				border.color: Theme.color_listItem_border || "#334466"

				Column {
					anchors.fill: parent
					anchors.margins: 10
					spacing: 4

					Text {
						text: "SOLAR"
						color: Theme.color_font_secondary || "#88aacc"
						font.pixelSize: 11
						font.bold: true
					}

					Text {
						text: {
							var p = Global.system.solar.power
							return isNaN(p) ? "No PV" : fmtPower(p)
						}
						color: {
							var p = Global.system.solar.power
							if (isNaN(p) || p === 0) return Theme.color_font_primary
							return "#f1c40f"
						}
						font.pixelSize: 36
						font.bold: true
					}

					Text {
						text: {
							var count = Global.solarInputs ? Global.solarInputs.inputCount : 0
							if (count === 0) return "No chargers connected"
							return count + " charger" + (count > 1 ? "s" : "")
						}
						color: Theme.color_font_secondary || "#88aacc"
						font.pixelSize: 12
					}
				}
			}

			// ── AC Input ─────────────────────────────────────────────────
			Rectangle {
				width: (grid.width - grid.spacing) / 2
				height: 140
				radius: 8
				color: Theme.color_darkOk_background || "#1a2744"
				border.color: Theme.color_listItem_border || "#334466"

				VeQuickItem {
					id: acIn0Power
					uid: root.systemUid ? root.systemUid + "/Ac/ActiveIn/L1/P" : ""
				}
				VeQuickItem {
					id: acIn0Source
					uid: root.systemUid ? root.systemUid + "/Ac/ActiveIn/Source" : ""
				}

				Column {
					anchors.fill: parent
					anchors.margins: 10
					spacing: 4

					Text {
						text: {
							var src = acIn0Source.value
							if (src === 1) return "GRID"
							if (src === 2) return "GENERATOR"
							if (src === 3) return "SHORE"
							return "AC INPUT"
						}
						color: Theme.color_font_secondary || "#88aacc"
						font.pixelSize: 11
						font.bold: true
					}

					Text {
						text: {
							var input = Global.acInputs ? Global.acInputs.input1 : null
							if (!input) return "No AC"
							var p = input.power
							return isNaN(p) ? "Connected" : fmtPower(p)
						}
						color: Theme.color_font_primary || "white"
						font.pixelSize: 36
						font.bold: true
					}

					Text {
						text: {
							var input = Global.acInputs ? Global.acInputs.input1 : null
							if (!input) return "Not connected"
							return input.connected ? "Active" : "Standby"
						}
						color: Theme.color_font_secondary || "#88aacc"
						font.pixelSize: 12
					}
				}
			}

			// ── DC Loads ─────────────────────────────────────────────────
			Rectangle {
				width: (grid.width - grid.spacing) / 2
				height: 140
				radius: 8
				color: Theme.color_darkOk_background || "#1a2744"
				border.color: Theme.color_listItem_border || "#334466"

				Column {
					anchors.fill: parent
					anchors.margins: 10
					spacing: 4

					Text {
						text: "DC LOADS"
						color: Theme.color_font_secondary || "#88aacc"
						font.pixelSize: 11
						font.bold: true
					}

					Text {
						text: {
							var dc = Global.system.dc
							if (!dc || !dc.hasPower) return "None"
							return fmtPower(dc.power)
						}
						color: Theme.color_font_primary || "white"
						font.pixelSize: 36
						font.bold: true
					}

					Text {
						visible: Global.system.dc && Global.system.dc.hasPower
						text: fmtVolts(Global.system.dc ? Global.system.dc.voltage : NaN)
						color: Theme.color_font_secondary || "#88aacc"
						font.pixelSize: 13
					}

					Text {
						text: {
							var dc = Global.system.dc
							if (!dc || !dc.hasPower) return "No DC system"
							return dc.currentValid ? fmtAmps(dc.current) : ""
						}
						color: Theme.color_font_secondary || "#88aacc"
						font.pixelSize: 12
					}
				}
			}

			// ── Tanks ────────────────────────────────────────────────────
			Rectangle {
				width: (grid.width - grid.spacing) / 2
				height: 140
				radius: 8
				color: Theme.color_darkOk_background || "#1a2744"
				border.color: Theme.color_listItem_border || "#334466"

				Column {
					anchors.fill: parent
					anchors.margins: 10
					spacing: 4

					Text {
						text: "TANKS"
						color: Theme.color_font_secondary || "#88aacc"
						font.pixelSize: 11
						font.bold: true
					}

					Text {
						text: {
							var count = Global.tanks ? Global.tanks.totalTankCount : 0
							return count > 0 ? count + " tank" + (count > 1 ? "s" : "") : "None"
						}
						color: Theme.color_font_primary || "white"
						font.pixelSize: 22
						font.bold: true
					}

					Repeater {
						model: Global.tanks ? Global.tanks.allTankModels : []
						delegate: Text {
							required property var modelData
							visible: modelData.count > 0
							text: {
								var name = Global.tanks.tankTypeLabel(modelData.type)
								return name + ": " + modelData.count
							}
							color: Theme.color_font_secondary || "#88aacc"
							font.pixelSize: 12
						}
					}
				}
			}

			// ── EV Chargers ──────────────────────────────────────────────
			Rectangle {
				width: (grid.width - grid.spacing) / 2
				height: 140
				radius: 8
				color: Theme.color_darkOk_background || "#1a2744"
				border.color: Theme.color_listItem_border || "#334466"

				Column {
					anchors.fill: parent
					anchors.margins: 10
					spacing: 4

					Text {
						text: "EV CHARGERS"
						color: Theme.color_font_secondary || "#88aacc"
						font.pixelSize: 11
						font.bold: true
					}

					Text {
						text: {
							var count = Global.evChargers ? Global.evChargers.model.count : 0
							if (count === 0) return "None"
							return count + " charger" + (count > 1 ? "s" : "")
						}
						color: Theme.color_font_primary || "white"
						font.pixelSize: 22
						font.bold: true
					}

					Text {
						visible: Global.evChargers && Global.evChargers.model.count > 0
						text: "See Overview for details"
						color: Theme.color_font_secondary || "#88aacc"
						font.pixelSize: 12
					}
				}
			}

			// ── DC Inputs ────────────────────────────────────────────────
			Rectangle {
				width: (grid.width - grid.spacing) / 2
				height: 140
				radius: 8
				color: Theme.color_darkOk_background || "#1a2744"
				border.color: Theme.color_listItem_border || "#334466"

				Column {
					anchors.fill: parent
					anchors.margins: 10
					spacing: 4

					Text {
						text: "DC INPUTS"
						color: Theme.color_font_secondary || "#88aacc"
						font.pixelSize: 11
						font.bold: true
					}

					Text {
						text: {
							var count = Global.dcInputs ? Global.dcInputs.model.count : 0
							if (count === 0) return "None"
							return count + " source" + (count > 1 ? "s" : "")
						}
						color: Theme.color_font_primary || "white"
						font.pixelSize: 22
						font.bold: true
					}

					Text {
						text: {
							var count = Global.dcInputs ? Global.dcInputs.model.count : 0
							if (count === 0) return "No alternator, wind, genset"
							return "Alternator / Wind / DC genset"
						}
						color: Theme.color_font_secondary || "#88aacc"
						font.pixelSize: 12
					}
				}
			}

			// ── System Info ──────────────────────────────────────────────
			Rectangle {
				width: (grid.width - grid.spacing) / 2
				height: 140
				radius: 8
				color: Theme.color_darkOk_background || "#1a2744"
				border.color: Theme.color_listItem_border || "#334466"

				VeQuickItem {
					id: systemState
					uid: root.systemUid ? root.systemUid + "/SystemState/State" : ""
				}
				VeQuickItem {
					id: systemType
					uid: root.systemUid ? root.systemUid + "/SystemType" : ""
				}

				Column {
					anchors.fill: parent
					anchors.margins: 10
					spacing: 4

					Text {
						text: "SYSTEM"
						color: Theme.color_font_secondary || "#88aacc"
						font.pixelSize: 11
						font.bold: true
					}

					Text {
						text: {
							var s = systemState.value
							if (s === undefined || s === null) return "Unknown"
							if (s === 0) return "Off"
							if (s === 1) return "Low power"
							if (s === 2) return "VE.Bus Fault"
							if (s === 3) return "Bulk"
							if (s === 4) return "Absorption"
							if (s === 5) return "Float"
							if (s === 6) return "Storage"
							if (s === 7) return "Equalize"
							if (s === 8) return "Passthrough"
							if (s === 9) return "Inverting"
							if (s === 10) return "Assisting"
							if (s === 252) return "ESS"
							if (s === 256) return "Discharging"
							if (s === 259) return "Sustain"
							return "State " + s
						}
						color: Theme.color_font_primary || "white"
						font.pixelSize: 22
						font.bold: true
					}

					Text {
						text: systemType.value || "---"
						color: Theme.color_font_secondary || "#88aacc"
						font.pixelSize: 14
					}

					Text {
						text: {
							var items = []
							if (Global.notifications && Global.notifications.activeModel.count > 0)
								items.push(Global.notifications.activeModel.count + " alert" + (Global.notifications.activeModel.count > 1 ? "s" : ""))
							return items.length > 0 ? items.join(", ") : "No alerts"
						}
						color: {
							if (Global.notifications && Global.notifications.activeModel.count > 0)
								return "#e74c3c"
							return "#2ecc71"
						}
						font.pixelSize: 12
					}
				}
			}
		}
	}
}
