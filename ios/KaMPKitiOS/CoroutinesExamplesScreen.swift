import Combine
import SwiftUI
import Foundation
import shared
import KMPNativeCoroutinesCombine

private let log = koin.loggerWithTag(tag: "CoroutinesExampleViewModel")

private class CoroutinesExampleModel: ObservableObject {
    // TODO something with cancelling / nulling out? - This block de-init?
    private let viewModel: CoroutinesExampleViewModel = KotlinDependencies.shared.getCoroutinesExampleViewModel()

    @Published
    var number: Int = -1

    private var cancellables = [AnyCancellable]()

    func activate() {
        createPublisher(for: viewModel.numberFlow)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                log.i(message_: "Number flow completion: \(completion)")
            } receiveValue: { [weak self] number in
                self?.number = number.intValue
            }
            .store(in: &cancellables)

        // TODO needeD?
        log.i(message_: "cancellables count: \(self.cancellables.count)")
    }

    deinit {
        log.i(message_: "deinit")
    }

    func cancel() {
        log.i(message_: "cancelling")
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    func throwException() {
        createFuture(for: viewModel.throwException())
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
        }
        .onAppear(perform: {
            print("onAppear \(observableModel)")
            observableModel.activate()
        })
        // Not cancelled on navigate back...
        .onDisappear(perform: {
            print("onDisappear")
            observableModel.cancel()
        })
    }
}
