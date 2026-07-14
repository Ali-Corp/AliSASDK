package vn.ali.sa.sample

import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import dagger.hilt.android.AndroidEntryPoint
import vn.ali.sa.AliSASDK
import vn.ali.sa.AliSASDKOptions
import vn.ali.sa.AliSASDKToolbarConfig

@AndroidEntryPoint
class ActivitySampleActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                ActivityIntegrationScreen(
                    onOpenMiniApp = { appId, queryInput, forceUpdate, showToolbar ->
                        val queryParams = AliSASDKOptions.parseQueryString(queryInput)
                        AliSASDK.openMiniApp(
                            context = this,
                            appId = appId,
                            options = AliSASDKOptions.forActivityLaunch(
                                queryParams = queryParams,
                                forceUpdate = forceUpdate,
                                showLoadingIndicator = true,
                                showToolbar = showToolbar,
                                toolbarConfig = AliSASDKToolbarConfig(
                                    title = "Standalone demo",
                                    background = Color(0xFF1E3A8A),
                                    foreground = Color(0xFFFFFFFF),
                                    titleCenter = true,
                                ),
                            ),
                        )
                        Toast.makeText(
                            this,
                            "Launching MiniApp with ${queryParams.size} query params",
                            Toast.LENGTH_SHORT,
                        ).show()
                    },
                )
            }
        }
    }
}

@Composable
private fun ActivityIntegrationScreen(
    onOpenMiniApp: (appId: String, queryInput: String, forceUpdate: Boolean, showToolbar: Boolean) -> Unit,
) {
    var appId by remember { mutableStateOf("35763432-d4d9-11f0-aa6f-005056010315") }
    var queryInput by remember { mutableStateOf("source=sample-app&screen=standalone") }
    var forceUpdate by remember { mutableStateOf(false) }
    var showToolbar by remember { mutableStateOf(true) }

    Scaffold(
        topBar = { TopBar(title = "Standalone MiniApp") },
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            Surface(
                modifier = Modifier.fillMaxWidth(),
                shape = MaterialTheme.shapes.large,
                tonalElevation = 2.dp,
                color = MaterialTheme.colorScheme.secondaryContainer,
            ) {
                Column(
                    modifier = Modifier.padding(20.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    Text(
                        text = "Activity launch demo",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                    )
                    Text(
                        text = "This screen shows the latest standalone launch API. Enter an app id, add a simple query string, and the sample will parse it into AliSASDKOptions.forActivityLaunch(...).",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }

            Card(modifier = Modifier.fillMaxWidth()) {
                Column(
                    modifier = Modifier.padding(20.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp),
                ) {
                    OutlinedTextField(
                        value = appId,
                        onValueChange = { appId = it },
                        label = { Text("MiniApp ID") },
                        modifier = Modifier.fillMaxWidth(),
                        singleLine = true,
                    )

                    OutlinedTextField(
                        value = queryInput,
                        onValueChange = { queryInput = it },
                        label = { Text("Query string") },
                        supportingText = {
                            Text("Example: source=sample-app&screen=standalone")
                        },
                        modifier = Modifier.fillMaxWidth(),
                        minLines = 2,
                    )

                    ToggleRow(
                        label = "Force update",
                        checked = forceUpdate,
                        onCheckedChange = { forceUpdate = it },
                    )

                    ToggleRow(
                        label = "Show toolbar",
                        checked = showToolbar,
                        onCheckedChange = { showToolbar = it },
                    )

                    Button(
                        onClick = {
                            onOpenMiniApp(appId.trim(), queryInput.trim(), forceUpdate, showToolbar)
                        },
                        modifier = Modifier.fillMaxWidth(),
                    ) {
                        Text("Open standalone MiniApp")
                    }
                }
            }

            Surface(
                modifier = Modifier.fillMaxWidth(),
                shape = MaterialTheme.shapes.large,
                tonalElevation = 1.dp,
            ) {
                Column(
                    modifier = Modifier.padding(20.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    Text(
                        text = "What this launch includes",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold,
                    )
                    Text("• AliSASDK.openMiniApp(context, appId, options = ...)")
                    Text("• AliSASDKOptions.forActivityLaunch(...) with parsed query params")
                    Text("• Toolbar title, centered title, and colors")
                    Text("• No legacy host session lookup or old lifecycle polling")
                }
            }
        }
    }
}

@Composable
private fun ToggleRow(
    label: String,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit,
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(text = label, style = MaterialTheme.typography.bodyLarge)
        }
        Switch(checked = checked, onCheckedChange = onCheckedChange)
    }
}
