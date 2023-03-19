import Combine
import SwiftUI
import Foundation
import shared

private let log = koin.loggerWithTag(tag: "AdapterBreedModel")

private class AdapterBreedModel: ObservableObject {
    private var viewModel: AdapterBreedViewModel?

    @Published
    var loading = false

    @Published
    var breeds: [Breed]?

    @Published
    var error: String?

    private var cancellables = [AnyCancellable]()

    func activate() {
        let viewModel = KotlinDependencies.shared.getAdapterBreedViewModel()

        doPublish(viewModel.breeds) { [weak self] dogsState in
            self?.loading = dogsState.isLoading
            self?.breeds = dogsState.breeds
            self?.error = dogsState.error

            if let breeds = dogsState.breeds {
                log.d(message: {"View updating with \(breeds.count) breeds"})
            }
            if let errorMessage = dogsState.error {
                log.e(message: {"Displaying error: \(errorMessage)"})
            }
        }.store(in: &cancellables)

        self.viewModel = viewModel
    }

    func deactivate() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()

        viewModel?.clear()
        viewModel = nil
    }

    func onBreedFavorite(_ breed: Breed) {
        viewModel?.updateBreedFavorite(breed: breed)
    }

    func refresh() {
        guard let viewModel = self.viewModel else {
            return
        }
        createFuture(suspendAdapter: viewModel.refreshBreeds()).sink { completion in
            log.d(message: { "refreshBreeds completion \(completion)" })
        } receiveValue: { value in
            log.d(message: { "refreshBreeds recieveValue \(value.boolValue)" })
        }.store(in: &cancellables)

    }
}

struct AdapterBreedListScreen: View {
    @StateObject
    private var observableModel = AdapterBreedModel()

    var body: some View {
        BreedListContent(
            loading: observableModel.loading,
            breeds: observableModel.breeds,
            error: observableModel.error,
            onBreedFavorite: { observableModel.onBreedFavorite($0) },
            refresh: { observableModel.refresh() }
        )
        .onAppear(perform: {
            observableModel.activate()
        })
        .onDisappear(perform: {
            observableModel.deactivate()
        })
    }
}
