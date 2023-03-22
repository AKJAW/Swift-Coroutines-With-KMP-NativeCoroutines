package co.touchlab.kampkit.models

import co.touchlab.kermit.Logger
import com.rickclephas.kmp.nativecoroutines.NativeCoroutines
import com.rickclephas.kmp.nativecoroutines.NativeCoroutinesState
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.flow.stateIn

class CoroutinesExampleViewModel(private val log: Logger) : ViewModel() {

    @NativeCoroutines
    val numberFlow: Flow<Int> = flow {
        var i = 0
        while (true) {
            emit(i++)
            delay(100)
        }
    }.onEach { number ->
        log.i("numberFlow onEach: $number")
    }

    @NativeCoroutines
    val errorFlow: Flow<Int> = flow {
        repeat(3) { number ->
            emit(number)
            delay(1000)
        }
        throw IllegalStateException()
    }

    @NativeCoroutinesState
    val exampleResult: StateFlow<ExampleResult> =
        flow {
            emit(ExampleResult.Loading)
            delay(1000)
            repeat(3) { number ->
                emit(ExampleResult.Success(number))
                delay(1000)
            }
            emit(ExampleResult.Error)
        }.stateIn(viewModelScope, SharingStarted.Lazily, ExampleResult.Initial)

    // TODO something with a passed in scope?  : ViewModel()

    @NativeCoroutines
    suspend fun throwException() {
        delay(1000)
        throw IllegalStateException()
    }
}

sealed class ExampleResult {

    object Initial : ExampleResult()

    object Loading : ExampleResult()

    data class Success(val value: Int) : ExampleResult()

    object Error : ExampleResult()
}
