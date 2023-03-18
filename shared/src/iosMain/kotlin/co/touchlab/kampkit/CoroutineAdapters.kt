package co.touchlab.kampkit

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onCompletion
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.launch

class FlowAdapter<T : Any>(
    private val scope: CoroutineScope,
    private val flow: Flow<T>
) {
    fun subscribe(
        onEach: (item: T) -> Unit,
        onComplete: () -> Unit,
        onThrow: (error: Throwable) -> Unit
    ): Canceller = JobCanceller(
        flow.onEach { onEach(it) }
            .catch { onThrow(it) }
            .onCompletion { onComplete() }
            .launchIn(scope)
    )
}

interface Canceller {
    fun cancel()
}

private class JobCanceller(private val job: Job) : Canceller {
    override fun cancel() {
        job.cancel()
    }
}

// https://dev.to/touchlab/kotlin-coroutines-and-swift-revisited-j5h
class SuspendAdapter<T : Any>(
    private val scope: CoroutineScope,
    private val suspender: suspend () -> T
) {

    fun subscribe(
        onSuccess: (item: T) -> Unit,
        onThrow: (error: Throwable) -> Unit
    ) = scope.launch {
        try {
            onSuccess(suspender())
        } catch (error: Throwable) {
            onThrow(error)
        }
    }
}
