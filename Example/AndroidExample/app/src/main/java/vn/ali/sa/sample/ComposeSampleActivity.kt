package vn.ali.sa.sample

import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import dagger.hilt.android.AndroidEntryPoint
import org.json.JSONObject
import vn.ali.sa.AliSASDK
import vn.ali.sa.AliSASDKOptions
import vn.ali.sa.AliSASDKToolbarConfig
import vn.ali.sa.DispatchResult
import vn.ali.sa.EventParams
import vn.ali.sa.MiniAppOpenParams
import vn.ali.sa.MiniAppSessionController
import vn.ali.sa.MiniAppSessionLifecycleState

@AndroidEntryPoint
class ComposeSampleActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                ComposeIntegrationScreen(
                    showToast = { message ->
                        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
                    },
                )
            }
        }
    }
}

@Composable
private fun ComposeIntegrationScreen(showToast: (String) -> Unit) {
    var appId by remember { mutableStateOf("35763432-d4d9-11f0-aa6f-005056010315") }
    var queryInput by remember { mutableStateOf("mode=embedded&source=sample-app") }
    var showMiniApp by remember { mutableStateOf(false) }
    var controller by remember { mutableStateOf<MiniAppSessionController?>(null) }
    var lifecycleState by remember { mutableStateOf(MiniAppSessionLifecycleState.CLOSED) }
    var lastResult by remember { mutableStateOf("No result yet") }
    var eventDispatchLabel by remember { mutableStateOf("No event sent yet") }
    val backPressActionState: MutableState<(() -> Boolean)?> = remember {
        mutableStateOf(null)
    }
    val sendJsonToMiniAppState: MutableState<((String) -> Boolean)?> = remember {
        mutableStateOf(null)
    }

    LaunchedEffect(controller) {
        lifecycleState = controller?.state ?: MiniAppSessionLifecycleState.CLOSED
    }

    BackHandler(enabled = showMiniApp && backPressActionState.value != null) {
        backPressActionState.value?.invoke()
    }

    Scaffold(
        topBar = { TopBar(title = "Embedded MiniApp") },
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding),
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
                    .padding(20.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp),
            ) {
                Surface(
                    modifier = Modifier.fillMaxWidth(),
                    shape = MaterialTheme.shapes.large,
                    tonalElevation = 2.dp,
                    color = MaterialTheme.colorScheme.tertiaryContainer,
                ) {
                    Column(
                        modifier = Modifier.padding(20.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp),
                    ) {
                        Text(
                            text = "Compose render demo",
                            style = MaterialTheme.typography.titleLarge,
                            fontWeight = FontWeight.Bold,
                        )
                        Text(
                            text = "This screen uses RenderEmbeddedMiniApp(...) with MiniAppOpenParams(...), host callbacks, and the latest MiniAppSessionController actions.",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }

                Card(modifier = Modifier.fillMaxWidth()) {
                    Column(
                        modifier = Modifier.padding(20.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp),
                    ) {
                        OutlinedTextField(
                            value = appId,
                            onValueChange = { appId = it },
                            label = { Text("MiniApp ID") },
                            modifier = Modifier.fillMaxWidth(),
                            singleLine = true,
                            enabled = !showMiniApp,
                        )

                        OutlinedTextField(
                            value = queryInput,
                            onValueChange = { queryInput = it },
                            label = { Text("Open params query string") },
                            supportingText = {
                                Text("Passed through MiniAppOpenParams(queryParams = ...)")
                            },
                            modifier = Modifier.fillMaxWidth(),
                            enabled = !showMiniApp,
                            minLines = 2,
                        )

                        SessionStateCard(
                            lifecycleState = lifecycleState,
                            sessionId = controller?.sessionId ?: "Not created",
                            lastResult = lastResult,
                            eventDispatchLabel = eventDispatchLabel,
                        )

                        if (!showMiniApp) {
                            Button(
                                onClick = {
                                    lastResult = "Waiting for MiniApp result"
                                    eventDispatchLabel = "No event sent yet"
                                    showMiniApp = true
                                },
                                modifier = Modifier.fillMaxWidth(),
                            ) {
                                Text("Render embedded MiniApp")
                            }
                        } else {
                            ControllerActionPanel(
                                onGoHome = {
                                    val result = controller?.requestGoHome(shouldRefresh = true)
                                    eventDispatchLabel = formatDispatchResult("requestGoHome", result)
                                    lifecycleState = controller?.state ?: MiniAppSessionLifecycleState.CLOSED
                                },
                                onReload = {
                                    controller?.reload()
                                    lifecycleState = controller?.state ?: MiniAppSessionLifecycleState.CLOSED
                                    eventDispatchLabel = "reload() requested"
                                },
                                onSendEvent = {
                                    val result = controller?.sendEvent(
                                        name = "sampleHostEvent",
                                        params = EventParams.fromMap(
                                            mapOf(
                                                "source" to "sample-app",
                                                "timestamp" to System.currentTimeMillis(),
                                            ),
                                        ),
                                    )
                                    eventDispatchLabel = formatDispatchResult("sendEvent", result)
                                    lifecycleState = controller?.state ?: MiniAppSessionLifecycleState.CLOSED
                                },
                                onSendJson = {
                                    val payload = JSONObject().apply {
                                        put("action", "sampleJson")
                                        put("message", "hello from host compose demo")
                                    }
                                    val sent = sendJsonToMiniAppState.value?.invoke(
                                        payload.toString(),
                                    ) == true
                                    eventDispatchLabel = if (sent) {
                                        "JSON message sent through onSendJsonToMiniAppReady"
                                    } else {
                                        "JSON sender not ready yet"
                                    }
                                },
                                onClose = {
                                    controller?.close()
                                    lifecycleState = controller?.state ?: MiniAppSessionLifecycleState.CLOSED
                                    showMiniApp = false
                                },
                            )
                        }
                    }
                }
            }

            if (showMiniApp) {
                HorizontalDivider()

                AliSASDK.RenderEmbeddedMiniApp(
                    appId = appId.trim(),
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f),
                    options = AliSASDKOptions.forComposeRender(
                        showToolbar = true,
                        queryParams = AliSASDKOptions.parseQueryString(queryInput),
                        toolbarConfig = AliSASDKToolbarConfig(
                            title = "Embedded demo",
                            titleCenter = true,
                        ),
                        onOpenSettings = { miniAppId ->
                            showToast("Open settings requested by $miniAppId")
                        },
                        onCloseApp = {
                            showMiniApp = false
                            controller = null
                            lifecycleState = MiniAppSessionLifecycleState.CLOSED
                            backPressActionState.value = null
                            sendJsonToMiniAppState.value = null
                            showToast("MiniApp requested close")
                        },
                        onBackPressHandler = { tryGoBack ->
                            backPressActionState.value = tryGoBack
                        },
                        onAppReady = {
                            lifecycleState = controller?.state ?: MiniAppSessionLifecycleState.READY
                            showToast("MiniApp is ready")
                        },
                        onSendJsonToMiniAppReady = { sender ->
                            sendJsonToMiniAppState.value = sender
                        },
                    ),
                    params = MiniAppOpenParams(
                        queryParams = AliSASDKOptions.parseQueryString(queryInput),
                    ),
                    onControllerReady = { readyController ->
                        controller = readyController
                        lifecycleState = readyController.state
                    },
                    onResult = { result ->
                        Log.d("ComposeSample", "MiniApp result: $result")
                        lastResult = result.toString()
                        lifecycleState = controller?.state ?: MiniAppSessionLifecycleState.CLOSED
                        controller = null
                        backPressActionState.value = null
                        sendJsonToMiniAppState.value = null
                        showMiniApp = false
                    },
                )
            }
        }
    }
}

@Composable
private fun SessionStateCard(
    lifecycleState: MiniAppSessionLifecycleState,
    sessionId: String,
    lastResult: String,
    eventDispatchLabel: String,
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.large,
        tonalElevation = 1.dp,
        color = MaterialTheme.colorScheme.surfaceVariant,
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            Text(
                text = "Session status",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold,
            )
            Text("State: ${lifecycleState.name}")
            Text("Session ID: $sessionId", style = MaterialTheme.typography.bodySmall)
            Text("Last action: $eventDispatchLabel", style = MaterialTheme.typography.bodySmall)
            Text("Result: $lastResult", style = MaterialTheme.typography.bodySmall)
        }
    }
}

@Composable
private fun ControllerActionPanel(
    onGoHome: () -> Unit,
    onReload: () -> Unit,
    onSendEvent: () -> Unit,
    onSendJson: () -> Unit,
    onClose: () -> Unit,
) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text(
            text = "Controller actions",
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold,
        )
        FlowRow(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            FilterChip(selected = false, onClick = onGoHome, label = { Text("requestGoHome") })
            FilterChip(selected = false, onClick = onReload, label = { Text("reload") })
            FilterChip(selected = false, onClick = onSendEvent, label = { Text("sendEvent") })
            FilterChip(selected = false, onClick = onSendJson, label = { Text("send JSON") })
        }
        OutlinedButton(
            onClick = onClose,
            modifier = Modifier.fillMaxWidth(),
        ) {
            Text("Close embedded MiniApp")
        }
    }
}

private fun formatDispatchResult(label: String, result: DispatchResult?): String {
    return when (result) {
        DispatchResult.Delivered -> "$label delivered"
        DispatchResult.Queued -> "$label queued"
        is DispatchResult.Failed -> "$label failed: ${result.reason}"
        null -> "$label unavailable"
    }
}
