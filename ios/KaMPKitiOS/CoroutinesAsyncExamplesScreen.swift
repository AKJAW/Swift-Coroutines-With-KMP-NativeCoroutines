import Combine
import SwiftUI
import Foundation
import shared
import KMPNativeCoroutinesAsync

private let log = koin.loggerWithTag(tag: "CoroutinesExampleViewModel")

@MainActor
private class CoroutinesAsyncExampleModel: ObservableObject {
    private let viewModel: CoroutinesExampleViewModel = KotlinDependencies.shared.getCoroutinesExampleViewModel()

    @Published
    var number: Int = -1

    @Published
    var result: ExampleResult

    var numberTask: Task<(), Never>?

    init() {
        result = viewModel.exampleResult
        log.i(message_: "init \(Unmanaged.passUnretained(self).toOpaque())")
    }

    deinit {
        log.i(message_: "deinit \(Unmanaged.passUnretained(self).toOpaque())")
    }

    func listenToNumbers() async {
        if numberTask != nil {
            return
        }

        numberTask = Task {
            do {
                let sequence = asyncSequence(for: viewModel.numberFlow)
                for try await number in sequence {
                    self.number = number.intValue
                }
            } catch {
                print("Async numberFlow Failed with error: \(error)")
            }
            print("Async numberFlow completed")
        }
    }

    func listenToResults() async throws {
        let sequence = asyncSequence(for: viewModel.exampleResultFlow)
        for try await result in sequence {
            log.i(message_: "result: \(result)")
            self.result = result
        }
    }

    func cancel() {
        numberTask?.cancel()
        numberTask = nil
    }

    func throwException() async {
        let suspend = viewModel.throwException()
        log.i(message_: "async function exception start")
        let result = await asyncResult(for: suspend)
        switch result {
        case .success(let value):
            log.i(message_: "async function exception success \(value)")
        case .failure(let error):
            log.i(message_: "async function exception failure \(error)")
        }
        log.i(message_: "async function exception end")

        log.i(message_: "async sequence exception start")
        do {
            let sequence = asyncSequence(for: viewModel.errorFlow)
            for try await number in sequence {
                log.i(message_: "async sequence exception number: \(number)")
            }
        } catch {
            print("async sequence exception error: \(error)")
        }
        log.i(message_: "async sequence exception end")
    }

    func generateResult() {
        viewModel.generateResult()
    }
}

struct CoroutinesAsyncExampleScreen: View {

    @StateObject
    private var observableModel = CoroutinesAsyncExampleModel()

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
                    Task {
                        await observableModel.throwException()
                    }
                }
                Spacer()
                NavigationLink("Open in a new screen", destination: { CoroutinesCombineExampleScreen() })
                Spacer()
            }
        }.navigationViewStyle(StackNavigationViewStyle()) // Needed for deinit to work correclty...
            .task {
                print("onAppear \(observableModel)")
                await observableModel.listenToNumbers()
            }
            .task {
                try? await observableModel.listenToResults()
            }
            .onDisappear(perform: {
                print("onDisappear")
                log.i(message_: "numberTask: \(String(describing: observableModel.numberTask))")
                // Only needed for root screen, the nested screens are cleared by the UI
//                observableModel.cancel()
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
