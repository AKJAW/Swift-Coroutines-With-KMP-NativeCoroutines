import Combine
import SwiftUI
import Foundation
import shared

private let log = koin.loggerWithTag(tag: "KampkitBreedModel")

private class KampkitBreedModel: ObservableObject {
    private var viewModel: BreedKampkitCallbackViewModel?

    @Published
    var loading = false

    @Published
    var breeds: [Breed]?

    @Published
    var error: String?

    private var cancellables = [AnyCancellable]()

    func activate() {
        let viewModel = KotlinDependencies.shared.getBreedKampkitCallbackViewModel()

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
        // TODO add wrapper for suspend fun?
        // TODO something about error handling? - Probably the wrapper will have a try catch?
        viewModel?.refreshBreeds { wasRefreshed, error in
            log.i(message: {"refreshBreeds completed, wasRefreshed: \(wasRefreshed?.boolValue), error: \(error)"})
        }
    }
}

struct KampkitCombineBreedListScreen: View {
    @StateObject
    private var observableModel = KampkitBreedModel()

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
