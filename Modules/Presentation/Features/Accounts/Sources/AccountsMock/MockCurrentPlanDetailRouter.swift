import Accounts
import SwiftUI

public class MockCancelAccountPlanRouter: CancelAccountPlanRouting {
    public var dismiss_calledTimes = 0
    public var showCancellationSteps_calledTimes = 0
    
    public init() {}
    
    public func build() -> UIViewController {
        UIViewController()
    }
    public func start() {}
    
    public func dismiss() {
        dismiss_calledTimes += 1
    }
    
    public func showCancellationSteps() {
        showCancellationSteps_calledTimes += 1
    }
}
