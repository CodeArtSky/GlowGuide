import SwiftUI

struct ColorSwatchView: View {
    let spec: ColorSpec
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(spec.color)
                .frame(width: 50, height: 50)
                .shadow(color: spec.color.opacity(0.3), radius: 4, y: 2)

            VStack(spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Text(spec.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Large Color Swatch (for detail views)

struct LargeColorSwatchView: View {
    let spec: ColorSpec
    let label: String

    var body: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 16)
                .fill(spec.color)
                .frame(height: 80)
                .shadow(color: spec.color.opacity(0.3), radius: 8, y: 4)

            VStack(spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(spec.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                if let detail = spec.detail {
                    Text(detail)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Color Palette Grid

struct ColorPaletteGrid: View {
    let palette: ColorPalette

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                LargeColorSwatchView(spec: palette.eyeshadow, label: "Eyeshadow")
                LargeColorSwatchView(spec: palette.lips, label: "Lips")
            }

            HStack(spacing: 16) {
                LargeColorSwatchView(spec: palette.blush, label: "Blush")
                LargeColorSwatchView(spec: palette.brows, label: "Brows")
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        HStack {
            ColorSwatchView(
                spec: ColorSpec(hexColor: "C4956A", name: "Warm Bronze", detail: "shimmer"),
                label: "Eyes"
            )
            ColorSwatchView(
                spec: ColorSpec(hexColor: "B85C5C", name: "Dusty Rose", detail: "satin"),
                label: "Lips"
            )
            ColorSwatchView(
                spec: ColorSpec(hexColor: "E8A090", name: "Peach Glow", detail: "apples"),
                label: "Blush"
            )
        }
        .padding()

        ColorPaletteGrid(palette: MakeupLook.sample.colorPalette)
            .padding()
    }
}
