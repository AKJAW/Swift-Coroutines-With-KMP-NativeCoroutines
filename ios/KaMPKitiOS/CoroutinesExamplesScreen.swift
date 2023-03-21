import Combine
import SwiftUI
import Foundation
import shared
import KMPNativeCoroutinesCombine

private let log = koin.loggerWithTag(tag: "CoroutinesExampleViewModel")

private class CoroutinesExampleModel: ObservableObject {
    private let viewModel: CoroutinesExampleViewModel = KotlinDependencies.shared.getCoroutinesExampleViewModel()

    @Published
    var number: Int = -1

    var cancellables = [AnyCancellable]()

    init() {
        log.i(message_: "init \(Unmanaged.passUnretained(self).toOpaque())")
    }

    deinit {
        log.i(message_: "deinit \(Unmanaged.passUnretained(self).toOpaque())")
    }

    func activate() {
        createPublisher(for: viewModel.numberFlow)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                log.i(message_: "Number flow completion: \(completion)")
            } receiveValue: { [weak self] number in
                self?.number = number.intValue
            }
            .store(in: &cancellables)
    }

    func cancel() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    func throwException() {
        let suspend = viewModel.throwException()
        log.i(message_: "future exception start")
        createFuture(for: suspend)
            .sink { completion in
                log.i(message_: "future exception completion \(completion)")
            } receiveValue: { value in
                log.i(message_: "future exception recieveValue \(value)")
            }.store(in: &cancellables)

        createPublisher(for: viewModel.errorFlow)
            .sink { completion in
                log.i(message_: "publisher exception completion \(completion)")
            } receiveValue: { number in
                log.i(message_: "publisher exception recieveValue \(number)")
            }
            .store(in: &cancellables)
    }
}

struct CoroutinesExampleScreen: View {
    @StateObject
    private var observableModel = CoroutinesExampleModel()

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Number: \(observableModel.number)")
                Spacer()
                Button("Cancel") {
                    observableModel.cancel()
                }
                Spacer()
                Button("Throw Exception") {
                    observableModel.throwException()
                }
                Spacer()
                NavigationLink("Open in a new screen", destination: { CoroutinesExampleScreen() })
                Spacer()
            }
        }.navigationViewStyle(StackNavigationViewStyle()) // Needed for deinit to work correclty...
        .onAppear(perform: {
            print("onAppear \(observableModel)")
            observableModel.activate()
        })
        .onDisappear(perform: {
            print("onDisappear")
            log.i(message_: "cancellables count: \(observableModel.cancellables.count)")
            // Not needed with StackNavigationViewStyle
            // observableModel.cancel()
        })
    }
}
