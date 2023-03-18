package co.touchlab.kampkit

import co.touchlab.kampkit.db.Breed
import co.touchlab.kampkit.models.BreedRepository
import co.touchlab.kampkit.models.BreedViewModel
import co.touchlab.kampkit.models.BreedViewState
import co.touchlab.kermit.Logger

@Suppress("Unused") // Members are called from Swift
class AdapterBreedViewModel(
    breedRepository: BreedRepository,
    log: Logger
) {

    val viewModel = BreedViewModel(breedRepository, log)

    val breeds: FlowAdapter<BreedViewState> =
        FlowAdapter(viewModel.viewModelScope, viewModel.breedState)

    // Suspend wrapper
    fun refreshBreeds(): SuspendAdapter<Boolean> =
        SuspendAdapter(viewModel.viewModelScope) {
            viewModel.refreshBreeds()
        }

    fun updateBreedFavorite(breed: Breed) {
        viewModel.updateBreedFavorite(breed)
    }

    fun clear() {
        viewModel.clear()
    }
}
