// Draws the Demucs Splitter app icon (1024x1024 PNG): four coloured waveform rows, one per stem.
import AppKit

let size: CGFloat = 1024
let outPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon-1024.png"

let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size),
                           bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                           colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let ctx = NSGraphicsContext.current!.cgContext

// macOS icon grid: 824pt rounded square centred on a 1024 canvas, with a soft drop shadow.
let tile = CGRect(x: 100, y: 100, width: 824, height: 824)
let tilePath = CGPath(roundedRect: tile, cornerWidth: 185, cornerHeight: 185, transform: nil)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 28, color: NSColor.black.withAlphaComponent(0.35).cgColor)
ctx.addPath(tilePath)
ctx.setFillColor(NSColor.black.cgColor)
ctx.fillPath()
ctx.restoreGState()

ctx.saveGState()
ctx.addPath(tilePath)
ctx.clip()
let bg = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                    colors: [NSColor(red: 0.16, green: 0.12, blue: 0.32, alpha: 1).cgColor,
                             NSColor(red: 0.05, green: 0.04, blue: 0.12, alpha: 1).cgColor] as CFArray,
                    locations: [0, 1])!
ctx.drawLinearGradient(bg, start: CGPoint(x: 512, y: 924), end: CGPoint(x: 512, y: 100), options: [])

// Four stem rows (top to bottom): vocals, drums, bass, other.
let stems: [(NSColor, Double)] = [
    (NSColor(red: 1.00, green: 0.36, blue: 0.58, alpha: 1), 1.7),
    (NSColor(red: 1.00, green: 0.66, blue: 0.22, alpha: 1), 3.1),
    (NSColor(red: 0.30, green: 0.62, blue: 1.00, alpha: 1), 0.9),
    (NSColor(red: 0.30, green: 0.88, blue: 0.62, alpha: 1), 2.3),
]
let barCount = 15
let barWidth: CGFloat = 26
let left: CGFloat = 200, right: CGFloat = 824
let step = (right - left - barWidth) / CGFloat(barCount - 1)
let rowGap: CGFloat = 158
let firstRowY: CGFloat = 512 + rowGap * 1.5

for (row, stem) in stems.enumerated() {
    let cy = firstRowY - CGFloat(row) * rowGap
    ctx.setFillColor(stem.0.cgColor)
    for i in 0..<barCount {
        let t = Double(i) / Double(barCount - 1)
        let envelope = sin(t * .pi) * 0.75 + 0.25
        let wobble = abs(sin(t * 7.0 * stem.1 + Double(row))) * 0.6 + 0.4
        let h = CGFloat(envelope * wobble) * 118 + 16
        let x = left + CGFloat(i) * step
        let bar = CGRect(x: x, y: cy - h / 2, width: barWidth, height: h)
        ctx.addPath(CGPath(roundedRect: bar, cornerWidth: barWidth / 2, cornerHeight: barWidth / 2, transform: nil))
        ctx.fillPath()
    }
}

// Subtle top highlight for depth.
let shine = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                       colors: [NSColor.white.withAlphaComponent(0.10).cgColor, NSColor.white.withAlphaComponent(0).cgColor] as CFArray,
                       locations: [0, 1])!
ctx.drawLinearGradient(shine, start: CGPoint(x: 512, y: 924), end: CGPoint(x: 512, y: 560), options: [])
ctx.restoreGState()

NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: outPath))
print("wrote \(outPath)")
