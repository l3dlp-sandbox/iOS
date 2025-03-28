import Combine
import Foundation
import MEGADomain
import MEGAPresentation

@MainActor
final public class TermsAndPoliciesViewModel: ObservableObject {
    private let accountUseCase: any AccountUseCaseProtocol
    private let remoteFeatureFlagUseCase: any RemoteFeatureFlagUseCaseProtocol
    private let router: TermsAndPoliciesRouting
    
    let privacyUrl = URL(string: "https://mega.io/privacy") ?? URL(fileURLWithPath: "")
    let termsUrl = URL(string: "https://mega.io/terms") ?? URL(fileURLWithPath: "")
    @Published var cookieUrl = URL(fileURLWithPath: "")
    
    public init(
        accountUseCase: some AccountUseCaseProtocol,
        remoteFeatureFlagUseCase: any RemoteFeatureFlagUseCaseProtocol = DIContainer.remoteFeatureFlagUseCase,
        router: TermsAndPoliciesRouting
    ) {
        self.accountUseCase = accountUseCase
        self.remoteFeatureFlagUseCase = remoteFeatureFlagUseCase
        self.router = router
    }
    
    // MARK: - Cookie policy
    func setupCookiePolicyURL() async {
        guard let cookiePolicyURL = URL(string: "https://mega.nz/cookie") else { return }

        let isExternalAdsEnabled = remoteFeatureFlagUseCase.isFeatureFlagEnabled(for: .externalAds)
        guard isExternalAdsEnabled else {
            cookieUrl = cookiePolicyURL
            return
        }
        
        do {
            let cookiePath = cookiePolicyURL.lastPathComponent
            cookieUrl = try await accountUseCase.sessionTransferURL(path: cookiePath)
        } catch {
            cookieUrl = URL(fileURLWithPath: "")
        }
    }
    
    func dismiss() {
        router.dismiss()
    }
}
