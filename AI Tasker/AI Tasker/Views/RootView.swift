import SwiftUI

struct RootView: View {
    @State var appState: AppState

    var body: some View {
        ZStack {
            Group {
                switch appState.currentFlow {
                case .onboarding:
                    OnboardingViewWrapper(appState: appState)
                case .home:
                    HomeView(appState: appState)
                case .questionForm:
                    QuestionFormView(appState: appState)
                case .taskReview:
                    TaskReviewView(appState: appState)
                case .projectDashboard:
                    ProjectDashboardView(appState: appState)
                }
            }

            // Error Overlay
            if let errorMessage = appState.errorMessage {
                ErrorOverlayView(message: errorMessage, onDismiss: {
                    appState.clearError()
                })
            }
        }
        .environment(appState)
    }
}

// Wrapper to handle onboarding completion
struct OnboardingViewWrapper: View {
    @Environment(\.dismiss) var dismiss
    var appState: AppState

    var body: some View {
        OnboardingView()
            .environment(appState)
            .onDisappear {
                // Mark onboarding as complete when dismissed
                appState.hasCompletedOnboarding = true
                appState.currentFlow = .home
            }
    }
}

#Preview {
    RootView(appState: AppState())
}
