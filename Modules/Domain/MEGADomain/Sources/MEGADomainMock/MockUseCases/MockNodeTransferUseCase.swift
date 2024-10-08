import MEGADomain
import MEGASwift

public struct MockNodeTransferUseCase: NodeTransferUseCaseProtocol {
    private let stream: AsyncStream<TransferEntity>
    private let continuation: AsyncStream<TransferEntity>.Continuation
    
    public var nodeTransferCompletionUpdates: AnyAsyncSequence<TransferEntity> {
        stream.eraseToAnyAsyncSequence()
    }
    
    public init() {
        (stream, continuation) = AsyncStream<TransferEntity>.makeStream()
    }
    
    public func yield(_ transferEntity: TransferEntity) {
        continuation.yield(transferEntity)
    }
}
