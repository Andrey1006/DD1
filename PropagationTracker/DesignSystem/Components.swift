import SwiftUI

struct Card<Content: View>: View {
    var padding: CGFloat = Spacing.md
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

extension View {
    func cardStyle(padding: CGFloat = Spacing.md) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

struct ProgressRing: View {
    var progress: Double
    var size: CGFloat = 64
    var lineWidth: CGFloat = 8
    var tint: Color = AppTheme.primary
    var icon: String? = nil
    var centerText: String? = nil

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.001, min(progress, 1)))
                .stroke(
                    AngularGradient(colors: [tint.opacity(0.7), tint], center: .center),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.5), value: progress)

            if let centerText {
                Text(centerText)
                    .font(.system(size: size * 0.26, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
            } else if let icon {
                Image(systemName: icon.isEmpty ? "leaf.fill" : icon)
                    .font(.system(size: size * 0.34, weight: .semibold))
                    .foregroundStyle(tint)
            }
        }
        .frame(width: size, height: size)
    }
}

struct StatusBadge: View {
    let status: BatchStatus
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: status.icon)
                .font(.system(size: compact ? 10 : 12, weight: .bold))
            if !compact {
                Text(status.title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
        }
        .foregroundStyle(status.tint)
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 5 : 6)
        .background(status.tint.opacity(0.14), in: Capsule())
    }
}

struct MethodChip: View {
    let method: PropagationMethod
    var selected: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: method.icon)
                .font(.system(size: 12, weight: .bold))
            Text(method.title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(selected ? .white : method.tint)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule().fill(selected ? AnyShapeStyle(method.tint) : AnyShapeStyle(method.tint.opacity(0.14)))
        )
    }
}

struct StatTile: View {
    let value: String
    let label: String
    let icon: String
    var tint: Color = AppTheme.primary

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Image(systemName: icon.isEmpty ? "leaf.fill" : icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

struct AppBackground: View {
    var body: some View {
        ZStack {
            AppTheme.background

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                glow(AppTheme.primary, 0.12)
                    .frame(width: 360, height: 360)
                    .position(x: w * 0.1, y: h * 0.06)

                glow(AppTheme.accent, 0.10)
                    .frame(width: 300, height: 300)
                    .position(x: w * 0.95, y: h * 0.32)

                glow(AppTheme.info, 0.10)
                    .frame(width: 320, height: 320)
                    .position(x: w * 0.2, y: h * 0.78)

                glow(AppTheme.gold, 0.08)
                    .frame(width: 240, height: 240)
                    .position(x: w * 0.85, y: h * 0.92)

                leaf(160, AppTheme.primary, 0.05, -22)
                    .position(x: w * 0.86, y: h * 0.12)
                leaf(120, AppTheme.primary, 0.04, 30)
                    .position(x: w * 0.08, y: h * 0.45)
                leaf(140, AppTheme.info, 0.04, 14)
                    .position(x: w * 0.95, y: h * 0.66)
            }
        }
        .ignoresSafeArea()
    }

    private func glow(_ color: Color, _ opacity: Double) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [color.opacity(opacity), color.opacity(0)],
                    center: .center,
                    startRadius: 0,
                    endRadius: 170
                )
            )
    }

    private func leaf(_ size: CGFloat, _ color: Color, _ opacity: Double, _ angle: Double) -> some View {
        Image(systemName: "leaf.fill")
            .font(.system(size: size))
            .foregroundStyle(color.opacity(opacity))
            .rotationEffect(.degrees(angle))
    }
}

struct AppTextField: View {
    var title: String? = nil
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var keyboard: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var multiline: Bool = false
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            if let title {
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            HStack(alignment: multiline ? .top : .center, spacing: 10) {
                if let icon {
                    Image(systemName: icon.isEmpty ? "pencil" : icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(focused ? AppTheme.primary : AppTheme.textSecondary)
                        .frame(width: 20)
                        .padding(.top, multiline ? 2 : 0)
                }
                Group {
                    if multiline {
                        TextField(placeholder, text: $text, axis: .vertical)
                            .lineLimit(3...6)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .focused($focused)
                .textInputAutocapitalization(autocapitalization)
                .keyboardType(keyboard)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, multiline ? 12 : 14)
            .background(AppTheme.surfaceAlt)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(focused ? AppTheme.primary : Color.clear, lineWidth: 1.5)
            )
            .animation(.easeOut(duration: 0.15), value: focused)
        }
    }
}

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.primary)
            }
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var tint: Color = AppTheme.primary
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(tint, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SoftButtonStyle: ButtonStyle {
    var tint: Color = AppTheme.primary
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(tint)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: icon.isEmpty ? "leaf.fill" : icon)
                .font(.system(size: 44, weight: .regular))
                .foregroundStyle(AppTheme.primary.opacity(0.7))
                .frame(width: 92, height: 92)
                .background(AppTheme.primary.opacity(0.1), in: Circle())
            Text(title)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
            Text(message)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(SoftButtonStyle())
                    .padding(.top, 4)
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity)
    }
}

enum Haptics {
    static func tap(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
