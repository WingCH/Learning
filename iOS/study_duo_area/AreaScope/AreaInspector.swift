import SwiftUI

struct AreaInspector: View {
    var body: some View {
        // The outer reader occupies the safe area. The inner reader spans the window.
        GeometryReader { content in
            GeometryReader { window in
                let origin = window.frame(in: .global).origin
                let safe = content.frame(in: .global).offsetBy(dx: -origin.x, dy: -origin.y)
                let occlusions = window.reservedRegions(kind: .occlusion, options: .includeInactive,
                                                        layoutDirectionBehavior: .fixed)
                let divisions = window.reservedRegions(kind: .division, options: .includeInactive,
                                                       layoutDirectionBehavior: .fixed)
                ZStack(alignment: .bottomLeading) {
                    RegionPlot(safe: safe, occlusions: occlusions, divisions: divisions)
                    legend(size: window.size, safe: safe, occlusions: occlusions, divisions: divisions)
                        .padding(.horizontal, 18)
                        .padding(.bottom, 18)
                        .frame(maxWidth: safe.width, maxHeight: safe.height, alignment: .bottomLeading)
                        .position(x: safe.midX, y: safe.midY)
                }
            }
            .ignoresSafeArea(.container, edges: .all)
        }
    }

    private func legend(size: CGSize, safe: CGRect, occlusions: [ReservedRegion],
                        divisions: [ReservedRegion]) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Label("螢幕區域 · Screen Regions", systemImage: "viewfinder")
                .font(.headline)
            Text("視窗 Window · \(dimensions(size)) pt")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
            Divider()
            row("安全區 Safe Area", RegionPlot.safeColor, dimensions(safe.size) + " pt")
            regions("遮擋區 Occlusion", occlusions, RegionPlot.occlusionColor)
            regions("摺疊區 Fold", divisions, RegionPlot.divisionColor)
        }
        .padding(14)
        .fixedSize(horizontal: false, vertical: true)
        .frame(idealWidth: 320, maxWidth: 320)
        .background(Color(red: 0.055, green: 0.105, blue: 0.13), in: RoundedRectangle(cornerRadius: 14))
        .overlay { RoundedRectangle(cornerRadius: 14).strokeBorder(.white.opacity(0.22)) }
    }

    @ViewBuilder
    private func regions(_ title: String, _ regions: [ReservedRegion], _ color: Color) -> some View {
        if regions.isEmpty {
            row(title, color, "未偵測到 Not detected")
        } else {
            ForEach(regions) { region in
                let state = region.isActive ? "使用中 Active" : "未啟用 Inactive"
                row(title, color, dimensions(region.frame.size) + " pt\n" + state, inactive: !region.isActive)
            }
        }
    }

    private func row(_ title: String, _ color: Color, _ value: String, inactive: Bool = false) -> some View {
        HStack(spacing: 8) {
            Rectangle()
                .strokeBorder(color, style: StrokeStyle(lineWidth: 2, dash: inactive ? [3, 2] : []))
                .frame(width: 17, height: 12)
            Text(verbatim: title)
            Spacer(minLength: 4)
            Text(verbatim: value)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.secondary)
        }
        .font(.subheadline.monospacedDigit())
        .accessibilityElement(children: .combine)
    }

    private func dimensions(_ size: CGSize) -> String {
        "\(Double(size.width).formatted(.number.precision(.fractionLength(0...2)))) × \(Double(size.height).formatted(.number.precision(.fractionLength(0...2))))"
    }
}

private struct RegionPlot: View {
    let safe: CGRect
    let occlusions: [ReservedRegion]
    let divisions: [ReservedRegion]

    static let safeColor = Color(red: 0.34, green: 0.94, blue: 0.76)
    static let occlusionColor = Color(red: 1, green: 0.68, blue: 0.26)
    static let divisionColor = Color(red: 0.78, green: 0.65, blue: 1)

    var body: some View {
        Canvas { context, size in
            let bounds = CGRect(origin: .zero, size: size)
            context.fill(Path(bounds), with: .color(Color(red: 0.04, green: 0.085, blue: 0.11)))
            var grid = Path()
            for x in stride(from: 0, to: size.width, by: 32) {
                grid.move(to: CGPoint(x: x, y: 0))
                grid.addLine(to: CGPoint(x: x, y: size.height))
            }
            for y in stride(from: 0, to: size.height, by: 32) {
                grid.move(to: CGPoint(x: 0, y: y))
                grid.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(grid, with: .color(.white.opacity(0.09)), lineWidth: 0.6)
            context.stroke(Path(safe.insetBy(dx: 1, dy: 1)), with: .color(Self.safeColor), lineWidth: 2)
            for region in divisions { draw(region, color: Self.divisionColor, in: context) }
            for region in occlusions {
                draw(region, color: Self.occlusionColor, in: context)
                // System chrome can cover the exact outline of a nested camera region.
                if occlusions.contains(where: { $0.id != region.id && $0.frame.contains(region.frame) }) {
                    drawOuterCorners(around: region.frame, in: context)
                }
            }
        }
        .accessibilityHidden(true)
    }

    private func drawOuterCorners(around frame: CGRect, in context: GraphicsContext) {
        let box = frame.insetBy(dx: -12, dy: -12)
        var marks = Path()
        for x in [box.minX, box.maxX] {
            for y in [box.minY, box.maxY] {
                let dx: CGFloat = x == box.minX ? 8 : -8
                let dy: CGFloat = y == box.minY ? 8 : -8
                marks.move(to: CGPoint(x: x + dx, y: y))
                marks.addLine(to: CGPoint(x: x, y: y))
                marks.addLine(to: CGPoint(x: x, y: y + dy))
            }
        }
        context.stroke(marks, with: .color(Self.occlusionColor), lineWidth: 2)
    }

    private func draw(_ region: ReservedRegion, color: Color, in context: GraphicsContext) {
        let box = Path(region.frame)
        context.fill(box, with: .color(color.opacity(region.isActive ? 0.22 : 0.10)))
        context.stroke(box, with: .color(color),
                       style: StrokeStyle(lineWidth: 2, dash: region.isActive ? [] : [6, 4]))
    }
}
