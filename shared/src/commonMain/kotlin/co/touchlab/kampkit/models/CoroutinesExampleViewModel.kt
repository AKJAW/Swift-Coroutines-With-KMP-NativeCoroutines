package co.touchlab.kampkit.models

import co.touchlab.kermit.Logger
import com.rickclephas.kmp.nativecoroutines.NativeCoroutines
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.onEach

class CoroutinesExampleViewModel(private val log: Logger) {

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
            delay(100)
        }
        throw IllegalStateException()
    }

    // TODO something with a passed in scope?  : ViewModel()

    @NativeCoroutines
    suspend fun throwException() {
        throw IllegalStateException()
    }
}
