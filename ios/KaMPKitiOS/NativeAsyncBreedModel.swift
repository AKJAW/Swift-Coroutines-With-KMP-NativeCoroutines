import Combine
import SwiftUI
import Foundation
import shared
import KMPNativeCoroutinesAsync

private class NativeAsyncBreedModel: ObservableObject {
    private var viewModel: BreedViewModel?

    @Published
    var loading = false

    @Published
    var breeds: [Breed]?

    @Published
    var error: String?

    @MainActor // TODO needed even with NativeCoroutinesState?
    func activate() async {
        let viewModel = KotlinDependencies.shared.getBreedViewModel()

        let nativeFlow = viewModel.nativeBreedStateFlow

        self.viewModel = viewModel

        do {
            let sequence = asyncSequence(for: nativeFlow)
            for try await dogsState in sequence {
                self.loading = dogsState.isLoading
                self.breeds = dogsState.breeds
                self.error = dogsState.error

                if let breeds = dogsState.breeds {
                    print("Async View updating with \(breeds.count) breeds")
                }
                if let errorMessage = dogsState.error {
                    print("Async Displaying error: \(errorMessage)")
                }
            }
        } catch {
            print("Async Failed with error: \(error)")
        }
    }

    func deactivate() {
        // Needed for init and favorite update
        viewModel?.clear()
        viewModel = nil
    }

    func onBreedFavorite(_ breed: Breed) {
        viewModel?.updateBreedFavorite(breed: breed)
    }

    func refresh() async {
        guard let viewModel = self.viewModel else {
            return
        }
        let suspend = viewModel.nativeRefreshBreeds()
        do {
            let value = try await asyncFunction(for: suspend)
            print("Async Got value \(value)")
        } catch {
            print("Async Failed with error: \(error)")
        }
    }
}

struct NativeAsyncBreedListScreen: View {
    @StateObject
    private var observableModel = NativeAsyncBreedModel()

    var body: some View {
        BreedListContent(
            loading: observableModel.loading,
            breeds: observableModel.breeds,
            error: observableModel.error,
            onBreedFavorite: { observableModel.onBreedFavorite($0) },
            refresh: {
                Task {
                    await observableModel.refresh()
                }
            }
        )
        .task {
            await observableModel.activate()
        }
        .onDisappear(perform: {
            observableModel.deactivate()
        })
    }
}
