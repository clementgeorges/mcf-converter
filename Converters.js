.pragma library

// ---------- parsing / formatting ----------
function num(s) {
  if (s === undefined || s === null) return NaN
  var t = String(s).replace(/\s/g, "")
  if (t.indexOf(".") === -1) t = t.replace(",", ".")
  if (t === "" || t === "-" || t === ".") return NaN
  return Number(t)
}

function fmt(n) {
  if (n === null || n === undefined || isNaN(n) || !isFinite(n)) return "—"
  if (n === 0) return "0"
  var a = Math.abs(n)
  if (a >= 1e12 || a < 1e-6) return n.toExponential(4)
  return parseFloat(n.toFixed(a >= 1 ? 4 : 6)).toString()
}

function r4(n) { return parseFloat(n.toFixed(4)).toString() }

function money(n) {
  if (isNaN(n) || !isFinite(n)) return "—"
  var parts = n.toFixed(n !== 0 && Math.abs(n) < 1 ? 4 : 2).split(".")
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, " ")
  return parts.join(".")
}

// ---------- fluid typography (same maths as royalfig's calculator) ----------
function fluid(minVp, maxVp, minFs, maxFs, root, unit, remOut) {
  if ([minVp, maxVp, minFs, maxFs, root].some(function (v) { return isNaN(v) }))
    return { ok: false, error: "Fill in every field with a number." }
  if (root <= 0) return { ok: false, error: "Root font size must be above 0." }
  if (maxVp === minVp) return { ok: false, error: "Min and max viewport must be different." }

  var slope = (maxFs - minFs) / (maxVp - minVp)       // px per px of viewport
  var intercept = minFs - slope * minVp                // px at viewport 0
  var lo = Math.min(minFs, maxFs)
  var hi = Math.max(minFs, maxFs)
  function len(px) { return remOut ? r4(px / root) + "rem" : r4(px) + "px" }

  var preferred
  if (slope === 0) preferred = len(minFs)
  else if (intercept === 0) preferred = r4(slope * 100) + unit
  else preferred = len(intercept) + (slope >= 0 ? " + " : " - ") + r4(Math.abs(slope * 100)) + unit

  return {
    ok: true,
    css: slope === 0 ? len(minFs) : "clamp(" + len(lo) + ", " + preferred + ", " + len(hi) + ")",
    preferred: preferred,
    sizeAt: function (vp) { return Math.min(hi, Math.max(lo, intercept + slope * vp)) }
  }
}

// ---------- measurement units ----------
// f = factor to the category's base unit. Temperature is handled separately.
var categories = [
  { key: "length", label: "Length", def: "cm", units: [
    { id: "mm", label: "Millimetres", f: 0.001 },
    { id: "cm", label: "Centimetres", f: 0.01 },
    { id: "m", label: "Metres", f: 1 },
    { id: "km", label: "Kilometres", f: 1000 },
    { id: "in", label: "Inches", f: 0.0254 },
    { id: "ft", label: "Feet", f: 0.3048 },
    { id: "yd", label: "Yards", f: 0.9144 },
    { id: "mi", label: "Miles", f: 1609.344 } ] },
  { key: "volume", label: "Volume", def: "l", units: [
    { id: "ml", label: "Millilitres", f: 0.001 },
    { id: "cl", label: "Centilitres", f: 0.01 },
    { id: "l", label: "Litres", f: 1 },
    { id: "m3", label: "Cubic metres", f: 1000 },
    { id: "tsp", label: "Teaspoons (US)", f: 0.00492892 },
    { id: "tbsp", label: "Tablespoons (US)", f: 0.0147868 },
    { id: "floz", label: "Fluid ounces (US)", f: 0.0295735 },
    { id: "cup", label: "Cups (US)", f: 0.236588 },
    { id: "pt", label: "Pints (US)", f: 0.473176 },
    { id: "gal", label: "Gallons (US)", f: 3.78541 } ] },
  { key: "mass", label: "Weight", def: "kg", units: [
    { id: "mg", label: "Milligrams", f: 0.001 },
    { id: "g", label: "Grams", f: 1 },
    { id: "kg", label: "Kilograms", f: 1000 },
    { id: "t", label: "Tonnes", f: 1000000 },
    { id: "oz", label: "Ounces", f: 28.349523 },
    { id: "lb", label: "Pounds", f: 453.59237 } ] },
  { key: "temp", label: "Temperature", def: "c", units: [
    { id: "c", label: "Celsius" },
    { id: "f", label: "Fahrenheit" },
    { id: "k", label: "Kelvin" } ] },
  { key: "data", label: "Data", def: "mb", units: [
    { id: "b", label: "Bytes", f: 1 },
    { id: "kb", label: "Kilobytes (KB)", f: 1e3 },
    { id: "mb", label: "Megabytes (MB)", f: 1e6 },
    { id: "gb", label: "Gigabytes (GB)", f: 1e9 },
    { id: "kib", label: "Kibibytes (KiB)", f: 1024 },
    { id: "mib", label: "Mebibytes (MiB)", f: 1048576 },
    { id: "gib", label: "Gibibytes (GiB)", f: 1073741824 } ] }
]

function unitOf(cat, id) {
  var u = categories[cat].units
  for (var i = 0; i < u.length; i++) if (u[i].id === id) return u[i]
  return null
}

function convert(cat, value, fromId, toId) {
  if (isNaN(value)) return NaN
  if (categories[cat].key === "temp") {
    var c = fromId === "f" ? (value - 32) * 5 / 9 : fromId === "k" ? value - 273.15 : value
    return toId === "f" ? c * 9 / 5 + 32 : toId === "k" ? c + 273.15 : c
  }
  var a = unitOf(cat, fromId), b = unitOf(cat, toId)
  if (!a || !b) return NaN
  return value * a.f / b.f
}

// ---------- currency ----------
var currencies = ["USD", "EUR", "GBP", "ZAR", "JPY", "CNY", "INR", "AUD",
                  "CAD", "CHF", "NZD", "SGD", "AED", "BRL", "NGN", "KES"]
