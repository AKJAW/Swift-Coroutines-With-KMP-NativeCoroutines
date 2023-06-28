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

    @MainActor
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

    @MainActor
    func activate2() async throws {
        let viewModel = KotlinDependencies.shared.getBreedViewModel()

        let nativeFlow = viewModel.nativeBreedStateFlow

        self.viewModel = viewModel

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
            print("Async Success: \(value)")
        } catch {
            print("Async Failed with error: \(error)")
        }
    }

    func refresh2() async {
        guard let viewModel = self.viewModel else {
            return
        }
        let suspend = viewModel.nativeRefreshBreeds()
        let result = await asyncResult(for: suspend)
        switch result {
        case .success(let value):
            print("Async Success: \(value)")
        case .failure(let error):
            print("Async Failed with error: \(error)")
        }
    }

    func refresh3() async {
        guard let viewModel = self.viewModel else {
            return
        }
        let suspend = viewModel.nativeRefreshBreeds()
        let result = await asyncResult(for: suspend)
        if case .success(let value) = result {
            print("Async Success: \(value)")
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
                    await observableModel.refresh3()
                }
            }
        )
        .task {
            try? await observableModel.activate2()
        }
        .onDisappear(perform: {
            observableModel.deactivate()
        })
    }
}
