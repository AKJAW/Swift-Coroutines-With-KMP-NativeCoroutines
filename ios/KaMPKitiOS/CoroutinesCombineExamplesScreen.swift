import Combine
import SwiftUI
import Foundation
import shared
import KMPNativeCoroutinesCombine

private let log = koin.loggerWithTag(tag: "CoroutinesExampleViewModel")

private class CoroutinesCombineExampleModel: ObservableObject {
    private let viewModel: CoroutinesExampleViewModel = KotlinDependencies.shared.getCoroutinesExampleViewModel()

    @Published
    var number: Int = -1

    @Published
    var result: ExampleResult

    var cancellables = [AnyCancellable]()

    init() {
        result = viewModel.exampleResult
        log.i(message_: "Combine init \(Unmanaged.passUnretained(self).toOpaque())")
    }

    deinit {
        log.i(message_: "Combine deinit \(Unmanaged.passUnretained(self).toOpaque())")
    }

    func activate() {
        createPublisher(for: viewModel.numberFlow)
            .sink { completion in
                log.i(message_: "Combine Number flow completion: \(completion)")
            } receiveValue: { [weak self] number in
                self?.number = number.intValue
            }
            .store(in: &cancellables)

        createPublisher(for: viewModel.exampleResultFlow)
            .sink { completion in
                log.i(message_: "Combine result: \(completion)")
            } receiveValue: { [weak self] result in
                log.i(message_: "Combine result: \(result)")
                self?.result = result
            }
            .store(in: &cancellables)
    }

    func cancel() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    func throwException() {
        let suspend = viewModel.throwException()
        log.i(message_: "Combine future exception start")
        createFuture(for: suspend)
            .sink { completion in
                log.i(message_: "Combine future exception completion \(completion)")
            } receiveValue: { value in
                log.i(message_: "Combine future exception recieveValue \(value)")
            }.store(in: &cancellables)

        createPublisher(for: viewModel.errorFlow)
            .sink { completion in
                log.i(message_: "Combine publisher exception completion \(completion)")
            } receiveValue: { number in
                log.i(message_: "Combine publisher exception recieveValue \(number)")
            }
            .store(in: &cancellables)
    }

    func generateResult() {
        viewModel.generateResult()
    }
}

struct CoroutinesCombineExampleScreen: View {

    @StateObject
    private var observableModel = CoroutinesCombineExampleModel()

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Number: \(observableModel.number)")
                Button("Cancel") {
                    observableModel.cancel()
                }
                Spacer()

                ResultView(result: observableModel.result, onClick: { observableModel.generateResult() })

                Spacer()
                Button("Throw Exception") {
                    observableModel.throwException()
                }
                Spacer()
                NavigationLink("Open in a new screen", destination: { CoroutinesCombineExampleScreen() })
                Spacer()
            }
        }.navigationViewStyle(StackNavigationViewStyle()) // Needed for deinit to work correclty...
            .onAppear(perform: {
                print("Combine onAppear \(observableModel)")
                observableModel.activate()
            })
            .onDisappear(perform: {
                print("Combine onDisappear")
                log.i(message_: "cancellables count: \(observableModel.cancellables.count)")
                // Only needed for root screen, the nested screens are cleared by AnyCancellable
//                 observableModel.cancel()
            })
    }
}

private struct ResultView: View {

    var result: ExampleResult
    var onClick: () -> Void

    var body: some View {
        switch result {
        case result as ExampleResult.Initial:
            Button("Generate result") {
                onClick()
            }
        case result as ExampleResult.Loading:
            Text("Loading...")
        case let success as ExampleResult.Success:
            Text("Success: \(success.value)")
        default:
            Button("Error, try again") {
                onClick()
            }
        }
    }
}
