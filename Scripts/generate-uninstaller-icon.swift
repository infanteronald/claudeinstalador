#!/usr/bin/env swift

// Generates an .icns app icon for Claude Code Nuclear Uninstaller
// Red/orange gradient with a trash symbol

import AppKit
import Foundation

func generateIcon() {
    let sizes: [(CGFloat, String)] = [
        (16, "icon_16x16"),
        (32, "icon_16x16@2x"),
        (32, "icon_32x32"),
        (64, "icon_32x32@2x"),
        (128, "icon_128x128"),
        (256, "icon_128x128@2x"),
        (256, "icon_256x256"),
        (512, "icon_256x256@2x"),
        (512, "icon_512x512"),
        (1024, "icon_512x512@2x"),
    ]

    let iconsetPath = "/tmp/UninstallerIcon.iconset"
    try? FileManager.default.removeItem(atPath: iconsetPath)
    try! FileManager.default.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

    for (size, name) in sizes {
        let image = drawIcon(size: size)
        let tiffData = image.tiffRepresentation!
        let bitmap = NSBitmapImageRep(data: tiffData)!
        let pngData = bitmap.representation(using: .png, properties: [:])!
        try! pngData.write(to: URL(fileURLWithPath: "\(iconsetPath)/\(name).png"))
    }

    let outputPath = CommandLine.arguments.count > 1
        ? CommandLine.arguments[1]
        : "UninstallerIcon.icns"

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
    process.arguments = ["-c", "icns", iconsetPath, "-o", outputPath]
    try! process.run()
    process.waitUntilExit()

    try? FileManager.default.removeItem(atPath: iconsetPath)
    print(process.terminationStatus == 0 ? "Icon generated: \(outputPath)" : "Error generating icon")
}

func drawIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let context = NSGraphicsContext.current!.cgContext

    let cornerRadius = size * 0.22
    let path = CGPath(roundedRect: rect.insetBy(dx: size * 0.02, dy: size * 0.02),
                      cornerWidth: cornerRadius, cornerHeight: cornerRadius,
                      transform: nil)
    context.addPath(path)
    context.clip()

    // Red/dark gradient
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        CGColor(red: 0.9, green: 0.15, blue: 0.1, alpha: 1.0),   // Red
        CGColor(red: 0.7, green: 0.1, blue: 0.1, alpha: 1.0),    // Dark red
        CGColor(red: 0.3, green: 0.05, blue: 0.05, alpha: 1.0),   // Very dark
    ] as CFArray
    let locations: [CGFloat] = [0.0, 0.5, 1.0]
    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations)!
    context.drawLinearGradient(gradient,
                               start: CGPoint(x: 0, y: size),
                               end: CGPoint(x: size, y: 0),
                               options: [])

    // Skull/nuke text
    let fontSize = size * 0.38
    let font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.white,
        .paragraphStyle: paragraphStyle,
    ]

    let text = "X"
    let textSize = text.size(withAttributes: attributes)
    let textRect = NSRect(
        x: (size - textSize.width) / 2,
        y: (size - textSize.height) / 2 - size * 0.02,
        width: textSize.width,
        height: textSize.height
    )

    context.setShadow(offset: CGSize(width: 0, height: -size * 0.02),
                      blur: size * 0.06,
                      color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.4))

    text.draw(in: textRect, withAttributes: attributes)

    image.unlockFocus()
    return image
}

generateIcon()
