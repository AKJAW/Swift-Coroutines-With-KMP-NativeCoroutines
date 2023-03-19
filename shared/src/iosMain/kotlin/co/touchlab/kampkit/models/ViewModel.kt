package co.touchlab.kampkit.models

import co.touchlab.kampkit.FlowAdapter
import com.rickclephas.kmp.nativecoroutines.NativeCoroutineScope
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.cancelChildren
import kotlinx.coroutines.flow.Flow

/**
 * Base class that provides a Kotlin/Native equivalent to the AndroidX `ViewModel`. In particular, this provides
 * a [CoroutineScope][kotlinx.coroutines.CoroutineScope] which uses [Dispatchers.Main][kotlinx.coroutines.Dispatchers.Main]
 * and can be tied into an arbitrary lifecycle by calling [clear] at the appropriate time.
 */
actual abstract class ViewModel {

    @NativeCoroutineScope
    actual val viewModelScope =
        MainScope()

    /**
     * Override this to do any cleanup immediately before the internal [CoroutineScope][kotlinx.coroutines.CoroutineScope]
     * is cancelled in [clear]
     */
    protected actual open fun onCleared() {
    }

    fun clear() {
        onCleared()
        viewModelScope.coroutineContext.cancelChildren()
    }
}
