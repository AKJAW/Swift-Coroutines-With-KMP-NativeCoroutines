import Combine
import SwiftUI
import Foundation
import shared

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

//        doPublish(viewModel.breeds) { [weak self] dogsState in
//            self?.loading = dogsState.isLoading
//            self?.breeds = dogsState.breeds
//            self?.error = dogsState.error
//
//            if let breeds = dogsState.breeds {
//                log.d(message: {"View updating with \(breeds.count) breeds"})
//            }
//            if let errorMessage = dogsState.error {
//                log.e(message: {"Displaying error: \(errorMessage)"})
//            }
//        }.store(in: &cancellables)

        viewModel.breeds.subscribe(
            onEach: { [weak self] dogsState in
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
            onComplete: { print("Subscription end") },
            onThrow: { error in  print("Subscription error: \(error)") }
        )

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
//        let adapter = viewModel.refreshBreeds()
//        createFuture(suspendAdapter: adapter)
//            .sink { completion in
//                print("completion \(completion)")
//            } receiveValue: { value in
//                print("recieveValue \(value)")
//            }.store(in: &cancellables)

        viewModel.refreshBreeds().subscribe(
            onSuccess: { value in
                print("completion \(value)")
            },
            onThrow: { error in
                print("error \(error)")
            }
        )
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
