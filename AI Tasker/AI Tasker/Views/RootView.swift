import SwiftUI

struct RootView: View {
    @State var appState: AppState

    var body: some View {
        ZStack {
            Group {
                switch appState.currentFlow {
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
