import Foundation
import MEGAAppPresentation
import MEGADomain

enum PasteImagePreviewAction: ActionType {
    case didClickSend
    case didClickCancel

}

protocol PasteImagePreviewRouting: Routing {
    func dismiss()
}

final class PasteImagePreviewViewModel: ViewModelType {
    enum Command: CommandType, Equatable {     
    }
    
    // MARK: - Private properties
    private let router: any PasteImagePreviewRouting
    private let chatRoom: ChatRoomEntity
    private let chatUploader: any ChatUploaderProtocol
    
    // MARK: - Internel properties
    var invokeCommand: ((Command) -> Void)?
    
    // MARK: - Init
    init(
        router: some PasteImagePreviewRouting,
        chatRoom: ChatRoomEntity,
        chatUploader: some ChatUploaderProtocol = ChatUploader.sharedInstance
    ) {
        self.router = router
        self.chatRoom = chatRoom
        self.chatUploader = chatUploader
    }
    
    // MARK: - Dispatch action
    func dispatch(_ action: PasteImagePreviewAction) {
        switch action {
        case .didClickCancel:
            router.dismiss()
        case .didClickSend:
            didClickSend()
        }
    }
    
    private func didClickSend() {
        router.dismiss()
        guard let image = UIPasteboard.general.loadImage() else {
            return
        }
        Task {
            await chatUploader.upload(image: image, chatRoomId: chatRoom.chatId)
        }
    }
}
