import SwiftUI

struct BatchThumbnail: View {
    let batch: PropagationBatch
    var size: CGFloat = 56

    var body: some View {
        Group {
            if let data = batch.photo, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    batch.method.tint.opacity(0.16)
                    Image(systemName: batch.method.icon)
                        .font(.system(size: size * 0.4, weight: .semibold))
                        .foregroundStyle(batch.method.tint)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct BatchRowCard: View {
    let batch: PropagationBatch

    var body: some View {
        HStack(spacing: Spacing.md) {
            BatchThumbnail(batch: batch)

            VStack(alignment: .leading, spacing: 5) {
                Text(batch.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                Text(batch.species)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    StatusBadge(status: batch.status, compact: false)
                    Text("\(batch.survivingCount)/\(batch.initialCount)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            Spacer()

            ProgressRing(
                progress: batch.progress,
                size: 46,
                lineWidth: 6,
                tint: batch.status.tint,
                centerText: "\(Int(batch.progress * 100))"
            )
        }
        .cardStyle()
    }
}

struct InfoPill: View {
    let icon: String
    let label: String
    let value: String
    var tint: Color = AppTheme.primary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: icon.isEmpty ? "circle.fill" : icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(tint)
                Text(label)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppTheme.surfaceAlt)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

extension Date {
    func relativeShort() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    func mediumString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}
