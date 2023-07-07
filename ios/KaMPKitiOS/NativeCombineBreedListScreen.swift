import Combine
import SwiftUI
import Foundation
import shared
import KMPNativeCoroutinesCombine

private class NativeCombineBreedModel: ObservableObject {
    private var viewModel: BreedViewModel?

    @Published
    var loading = false

    @Published
    var breeds: [Breed]?

    @Published
    var error: String?

    private var cancellables = [AnyCancellable]()

    func activate() {
        let viewModel = KotlinDependencies.shared.getBreedViewModel()

        let nativeFlow = viewModel.nativeBreedStateFlow
        createPublisher(for: nativeFlow)
            // .receive(on: DispatchQueue.main) // Not needed with @NativeCoroutineScope
            .sink { completion in
                print("Combine Breeds completion: \(completion)")
            } receiveValue: { [weak self] dogsState in
                self?.loading = dogsState.isLoading
                self?.breeds = dogsState.breeds
                self?.error = dogsState.error

                if let breeds = dogsState.breeds {
                    print("Combine View updating with \(breeds.count) breeds")
                }
                if let errorMessage = dogsState.error {
                    print("Combine Displaying error: \(errorMessage)")
                }
            }
            .store(in: &cancellables)

        print("Combine cancellables count: \(self.cancellables.count)")
        self.viewModel = viewModel
    }

    func deactivate() {
        // Needed if activate is called in onAppear.
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        // Needed for init and favorite update
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
        let suspend = viewModel.nativeRefreshBreeds()
        createFuture(for: suspend)
            .sink { completion in
                print("Combine completion \(completion)")
            } receiveValue: { value in
                print("Combine recieveValue \(value)")
            }.store(in: &cancellables)
    }
}

struct NativeCombineBreedListScreen: View {
    @StateObject
    private var observableModel = NativeCombineBreedModel()

    var body: some View {
        BreedListContent(
            loading: observableModel.loading,
            breeds: observableModel.breeds,
            error: observableModel.error,
            onBreedFavorite: { observableModel.onBreedFavorite($0) },
            refresh: { observableModel.refresh() }
        )
        .onAppear(perform: {
            print("Combine onAppear")
            observableModel.activate()
        })
        .onDisappear(perform: {
            print("Combine onDisappear")
            observableModel.deactivate()
        })
    }
}
