import SwiftUI

struct ErrorOverlayView: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            // Error card
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.red)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Error")
                            .font(.system(size: 16, weight: .semibold))
                        Text(message)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                            .lineLimit(3)
                    }

                    Spacer()
                }

                Button(action: onDismiss) {
                    Text("Dismiss")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .padding(16)
            .shadow(radius: 8)
        }
    }
}

#Preview {
    ErrorOverlayView(message: "Failed to save project: Connection error") {
        print("Dismissed")
    }
}
