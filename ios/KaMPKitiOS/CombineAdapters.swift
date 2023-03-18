import Combine
import shared

/// Create a Combine publisher from the supplied `FlowAdapter`. Use this in contexts where more transformation will be
/// done on the Swift side before the value is bound to UI
func createPublisher<T>(_ flowAdapter: FlowAdapter<T>) -> AnyPublisher<T, KotlinError> {
    return Deferred<Publishers.HandleEvents<PassthroughSubject<T, KotlinError>>> {
        let subject = PassthroughSubject<T, KotlinError>()
        let canceller = flowAdapter.subscribe(
            onEach: { item in subject.send(item) },
            onComplete: { subject.send(completion: .finished) },
            onThrow: { error in subject.send(completion: .failure(KotlinError(error))) }
        )
        return subject.handleEvents(receiveCancel: { canceller.cancel() })
    }.eraseToAnyPublisher()
}

/// Prepare the supplied `FlowAdapter` to be bound to UI. The `onEach` callback will be called from `DispatchQueue.main`
/// on every new emission.
///
/// Note that this calls `assertNoFailure()` internally so you should handle errors upstream to avoid crashes.
func doPublish<T>(_ flowAdapter: FlowAdapter<T>, onEach: @escaping (T) -> Void) -> Cancellable {
    return createPublisher(flowAdapter)
        .assertNoFailure()
        .compactMap { $0 }
        .receive(on: DispatchQueue.main)
        .sink { onEach($0) }
}

/// Wraps a `KotlinThrowable` in a `LocalizedError` which can be used as  a Combine error type
class KotlinError: LocalizedError {
    let throwable: KotlinThrowable

    init(_ throwable: KotlinThrowable) {
        self.throwable = throwable
    }
    var errorDescription: String? {
        throwable.message
    }
}

// https://dev.to/touchlab/kotlin-coroutines-and-swift-revisited-j5h
func createFuture<T>(
    suspendAdapter: SuspendAdapter<T>
) -> AnyPublisher<T, KotlinError> {
    return Deferred<Publishers.HandleEvents<Future<T, KotlinError>>> {
        var job: Kotlinx_coroutines_coreJob? = nil
        return Future { promise in
            job = suspendAdapter.subscribe(
                onSuccess: { item in promise(.success(item)) },
                onThrow: { error in promise(.failure(KotlinError(error))) }
            )
        }.handleEvents(receiveCancel: {
            job?.cancel(cause: nil)
        })
    }
    .eraseToAnyPublisher()
}
