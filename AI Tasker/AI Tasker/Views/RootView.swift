import SwiftUI

struct RootView: View {
    @State var appState: AppState

    var body: some View {
        ZStack {
            Group {
                switch appState.currentFlow {
                case .onboarding:
                    OnboardingView()
                        .environment(appState)
                        .onDisappear {
                            // Mark onboarding as complete when dismissed
                            appState.hasCompletedOnboarding = true
                            appState.currentFlow = .home
                        }
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

#Preview {
    RootView(appState: AppState())
}
