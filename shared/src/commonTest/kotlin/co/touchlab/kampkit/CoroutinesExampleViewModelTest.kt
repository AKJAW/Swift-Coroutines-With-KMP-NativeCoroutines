package co.touchlab.kampkit

import app.cash.turbine.test
import co.touchlab.kampkit.models.CoroutinesExampleViewModel
import co.touchlab.kampkit.models.ExampleResult
import co.touchlab.kermit.Logger
import co.touchlab.kermit.StaticConfig
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancelChildren
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals

class CoroutinesExampleViewModelTest {

    private lateinit var sut: CoroutinesExampleViewModel

    @BeforeTest
    fun setUp() {
        Dispatchers.setMain(UnconfinedTestDispatcher())
        sut = CoroutinesExampleViewModel(Logger(StaticConfig()))
    }

    @Test
    fun `The values are produced after cancelling`() = runTest {
        sut.generateResult()
        sut.exampleResult.test {
            assertEquals(ExampleResult.Loading, awaitItem())
            assertEquals(ExampleResult.Success(0), awaitItem())
            cancelAndIgnoreRemainingEvents()
        }

        sut.viewModelScope.coroutineContext.cancelChildren()

        sut.generateResult()
        sut.exampleResult.test {
            assertEquals(ExampleResult.Loading, awaitItem())
            assertEquals(ExampleResult.Success(0), awaitItem())
            cancelAndIgnoreRemainingEvents()
        }
    }
}
