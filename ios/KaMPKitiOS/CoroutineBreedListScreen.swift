import Combine
import SwiftUI
import Foundation
import shared

// https://www.slideshare.net/ChristianMelchior/coroutines-for-kotlin-multiplatform-in-practise
class Collector<T>: Kotlinx_coroutines_coreFlowCollector {
    private let callback: (T) -> Void

    init(callback: @escaping (T) -> Void) {
        self.callback = callback
    }

    func emit(value: Any?, completionHandler: @escaping (Error?) -> Void) {
        // swiftlint:disable force_cast
        callback(value as! T)
        // swiftlint:enable force_cast
        completionHandler(nil)
    }
}

private class CoroutineBreedModel: ObservableObject {
    private var viewModel: BreedViewModel?
    private var refreshJob: Kotlinx_coroutines_coreJob?

    @Published
    var loading = false

    @Published
    var breeds: [Breed]?

    @Published
    var error: String?

    func activate() {
        let viewModel = KotlinDependencies.shared.getBreedViewModel()

viewModel.breedState.collect(
    collector: Collector<BreedViewState> { [weak self] dogsState in
        self?.loading = dogsState.isLoading
        self?.breeds = dogsState.breeds
        self?.error = dogsState.error

        if let breeds = dogsState.breeds {
            print("View updating with \(breeds.count) breeds")
        }
        if let errorMessage = dogsState.error {
            print("Displaying error: \(errorMessage)")
        }
    },
    completionHandler: { error in
        print("breed collection completion error: \(error)")
    }
)

        self.viewModel = viewModel
    }

    func deactivate() {
        refreshJob?.cancel(cause: nil)
    }

    func onBreedFavorite(_ breed: Breed) {
        viewModel?.updateBreedFavorite(breed: breed)
    }

    func refresh() {
        viewModel?.refreshBreeds { wasRefreshed, error in
            print("refreshed: \(wasRefreshed), error: \(error)")
        }
    }
}

struct CoroutinesBreedListScreen: View {
    @StateObject
    private var observableModel = CoroutineBreedModel()

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
