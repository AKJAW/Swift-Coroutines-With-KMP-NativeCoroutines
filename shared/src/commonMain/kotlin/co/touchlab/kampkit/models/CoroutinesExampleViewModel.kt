package co.touchlab.kampkit.models

import co.touchlab.kermit.Logger
import com.rickclephas.kmp.nativecoroutines.NativeCoroutines
import com.rickclephas.kmp.nativecoroutines.NativeCoroutinesState
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.cancel
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.cancel
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.onCompletion
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

class CoroutinesExampleViewModel(private val log: Logger) : ViewModel() {

    @NativeCoroutines
    val numberFlow: Flow<Int> = flow {
        var i = 0
        while (true) {
            emit(i++)
            delay(1000)
        }
    }.onEach { number ->
        log.i("numberFlow onEach: $number")
    }.onCompletion {throwable ->
        log.i("numberFlow onCompletion: $throwable")
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
    val exampleResult: MutableStateFlow<ExampleResult> =
        MutableStateFlow(ExampleResult.Initial)

    fun generateResult() {
        viewModelScope.launch {
            exampleResult.update { ExampleResult.Loading }
            delay(1000)
            repeat(3) { number ->
                exampleResult.update { ExampleResult.Success(number) }
                delay(1000)
            }
            exampleResult.update { ExampleResult.Error }
        }
    }

    @NativeCoroutines
    suspend fun throwException() {
        delay(1000)
        throw IllegalStateException()
    }
}

sealed class ExampleResult {

    object Initial : ExampleResult()

    object Loading : ExampleResult()

    data class Success(
        val value: Int
    ) : ExampleResult()

    object Error : ExampleResult()
}
