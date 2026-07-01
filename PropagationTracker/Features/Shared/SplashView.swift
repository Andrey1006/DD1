import SwiftUI

struct SplashView: View {
    @State private var appear = false
    @State private var pulse = false
    @State private var ringPhase = false
    @State private var leafGrow = false
    @State private var shimmer = false
    @State private var rotate = false

    var body: some View {
        ZStack {
            backgroundLayer

            ForEach(0..<3, id: \.self) { index in
                ExpandingRing(delay: Double(index) * 0.6)
            }

            orbitingParticles

            leafMark
        }
        .ignoresSafeArea()
        .onAppear { startAnimations() }
    }

    private var backgroundLayer: some View {
        ZStack {
            AppTheme.heroGradient

            RadialGradient(
                colors: [AppTheme.gold.opacity(0.28), .clear],
                center: .center,
                startRadius: 10,
                endRadius: 320
            )
            .scaleEffect(pulse ? 1.15 : 0.85)
            .opacity(pulse ? 0.9 : 0.5)

            LinearGradient(
                colors: [.white.opacity(shimmer ? 0.10 : 0.0), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var leafMark: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.12))
                .frame(width: 168, height: 168)
                .scaleEffect(pulse ? 1.08 : 0.92)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.95), AppTheme.gold.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 118, height: 118)
                .shadow(color: AppTheme.primaryDeep.opacity(0.35), radius: 24, y: 10)

            Image(systemName: "leaf.fill")
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(AppTheme.heroGradient)
                .rotationEffect(.degrees(leafGrow ? 0 : -18))
                .scaleEffect(leafGrow ? 1 : 0.3)
                .opacity(leafGrow ? 1 : 0)
        }
        .scaleEffect(appear ? 1 : 0.6)
        .opacity(appear ? 1 : 0)
    }

    private var orbitingParticles: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(AppTheme.gold.opacity(0.9))
                    .frame(width: 8, height: 8)
                    .offset(y: -120)
                    .rotationEffect(.degrees(Double(index) / 6 * 360))
                    .scaleEffect(appear ? 1 : 0)
            }
            .rotationEffect(.degrees(rotate ? 360 : 0))
            .opacity(0.8)
        }
    }

    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            appear = true
        }
        withAnimation(.spring(response: 1.0, dampingFraction: 0.55).delay(0.25)) {
            leafGrow = true
        }
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
            pulse = true
        }
        withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
            shimmer = true
        }
        withAnimation(.linear(duration: 14).repeatForever(autoreverses: false)) {
            rotate = true
        }
    }
}

private struct ExpandingRing: View {
    let delay: Double
    @State private var animate = false

    var body: some View {
        Circle()
            .stroke(
                LinearGradient(
                    colors: [.white.opacity(0.55), AppTheme.gold.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 1.5
            )
            .frame(width: 160, height: 160)
            .scaleEffect(animate ? 2.6 : 0.6)
            .opacity(animate ? 0 : 0.7)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 2.4)
                        .repeatForever(autoreverses: false)
                        .delay(delay)
                ) {
                    animate = true
                }
            }
    }
}

#Preview {
    SplashView()
}
