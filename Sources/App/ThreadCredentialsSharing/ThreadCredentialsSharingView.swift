import Shared
import SwiftUI

@available(iOS 16.4, *)
struct ThreadCredentialsSharingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ThreadCredentialsSharingViewModel

    init(viewModel: ThreadCredentialsSharingViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            if viewModel.showImportSuccess {
                successView
                    .onAppear {
                        Haptics.shared.play(.medium)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            dismiss()
                        }
                    }
            } else {
                progressView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5))
        .alert(alertTitle, isPresented: $viewModel.showAlert) {
            alertActions
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            Task {
                await viewModel.retrieveAllCredentials()
            }
        }
    }

    private var successView: some View {
        Image(systemName: "checkmark.circle.fill")
            .resizable()
            .frame(width: 65, height: 65)
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
    }

    private var alertTitle: String {
        switch viewModel.alertType {
        case let .empty(title, _):
            return title
        case let .error(title, _):
            return title
        case .none:
            return ""
        }
    }

    private var alertMessage: String {
        switch viewModel.alertType {
        case let .empty(_, message):
            return message
        case let .error(_, message):
            return message
        default:
            return ""
        }
    }

    private var doneButton: some View {
        Button {
            dismiss()
        } label: {
            Text(L10n.doneLabel)
        }
    }

    private var retryButton: some View {
        Button {
            Task {
                await viewModel.retrieveAllCredentials()
            }
        } label: {
            Text(L10n.retryLabel)
        }
    }

    @ViewBuilder
    private var alertActions: some View {
        switch viewModel.alertType {
        case .error, .empty:
            doneButton
            retryButton
        default:
            EmptyView()
        }
    }

    private var progressView: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .scaleEffect(CGSize(width: 2, height: 2))
            .tint(.white)
    }
}
