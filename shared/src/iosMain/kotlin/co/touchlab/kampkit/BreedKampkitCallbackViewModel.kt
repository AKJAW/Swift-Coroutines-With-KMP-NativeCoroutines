package co.touchlab.kampkit

import co.touchlab.kampkit.db.Breed
import co.touchlab.kampkit.models.BreedRepository
import co.touchlab.kampkit.models.BreedViewModel
import co.touchlab.kampkit.models.CallbackViewModel
import co.touchlab.kermit.Logger

@Suppress("Unused") // Members are called from Swift
class BreedKampkitCallbackViewModel(
    breedRepository: BreedRepository,
    log: Logger
) : CallbackViewModel() {

    override val viewModel = BreedViewModel(breedRepository, log)

    val breeds = viewModel.breedState.asCallbacks()

    suspend fun refreshBreeds(): Boolean =
        viewModel.refreshBreeds()

    fun updateBreedFavorite(breed: Breed) {
        viewModel.updateBreedFavorite(breed)
    }
}
