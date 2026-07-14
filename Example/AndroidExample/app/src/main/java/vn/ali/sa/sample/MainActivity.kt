package vn.ali.sa.sample

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                MainScreen()
            }
        }
    }
}

@Composable
private fun MainScreen() {
    val context = LocalContext.current

    Scaffold(
        topBar = {
            TopBar(title = "Alisa SDK Sample")
        },
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            HeroCard()

            ConfigSummaryCard()

            DemoCard(
                title = "Standalone activity launch",
                body = "Opens a MiniApp in the SDK-managed activity flow using AliSASDK.openMiniApp(...) and AliSASDKOptions.forActivityLaunch(...).",
                buttonLabel = "Open standalone demo",
                onClick = {
                    context.startActivity(Intent(context, ActivitySampleActivity::class.java))
                },
            )

            DemoCard(
                title = "Embedded Compose render",
                body = "Renders a MiniApp directly inside the host screen with RenderEmbeddedMiniApp(...), MiniAppOpenParams(...), and live controller actions.",
                buttonLabel = "Open embedded demo",
                onClick = {
                    context.startActivity(Intent(context, ComposeSampleActivity::class.java))
                },
            )

            FlowReferenceCard(hostPackage = context.packageName)
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
internal fun TopBar(title: String) {
    TopAppBar(title = { Text(title) })
}

@Composable
private fun HeroCard() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer),
    ) {
        Column(
            modifier = Modifier.padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            Box(
                modifier = Modifier
                    .background(
                        color = MaterialTheme.colorScheme.primary.copy(alpha = 0.12f),
                        shape = RoundedCornerShape(999.dp),
                    )
                    .padding(horizontal = 12.dp, vertical = 6.dp),
            ) {
                Text(
                    text = "Latest public SDK API demo",
                    style = MaterialTheme.typography.labelLarge,
                    color = MaterialTheme.colorScheme.primary,
                )
            }

            Text(
                text = "Choose how you want to open the MiniApp",
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Bold,
            )

            Text(
                text = "This sample keeps the setup visible, makes the two integration paths easier to compare, and uses the current Alisa SDK facade APIs only.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

@Composable
private fun ConfigSummaryCard() {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        tonalElevation = 2.dp,
        color = MaterialTheme.colorScheme.surfaceVariant,
    ) {
        Column(
            modifier = Modifier.padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Text(
                text = "Current sample configuration",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold,
            )
            ConfigRow("Environment", SampleRuntimeInfo.environmentName)
            ConfigRow("Project ID", SampleRuntimeInfo.projectId)
            ConfigRow("Company ID", SampleRuntimeInfo.companyId)
            ConfigRow("Base URL", SampleRuntimeInfo.hostBaseUrl)
            ConfigRow("Language", SampleRuntimeInfo.languageCode)
        }
    }
}

@Composable
private fun DemoCard(
    title: String,
    body: String,
    buttonLabel: String,
    onClick: () -> Unit,
) {
    Card(modifier = Modifier.fillMaxWidth()) {
        Column(
            modifier = Modifier.padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.SemiBold,
            )
            Text(
                text = body,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Button(
                onClick = onClick,
                modifier = Modifier.fillMaxWidth(),
            ) {
                Text(buttonLabel)
            }
        }
    }
}

@Composable
private fun FlowReferenceCard(hostPackage: String) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        tonalElevation = 1.dp,
    ) {
        Column(
            modifier = Modifier.padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            Text(
                text = "API reference used in this sample",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold,
            )
            ConfigRow("Configure", "AliSASDK.configure(context, AliSASDKConfig.builder()...build())")
            ConfigRow("Standalone", "AliSASDK.openMiniApp(context, appId, options = AliSASDKOptions.forActivityLaunch(...))")
            ConfigRow("Embedded", "AliSASDK.RenderEmbeddedMiniApp(appId, modifier, options, params, onControllerReady, onResult)")
            ConfigRow("Controller", "state / requestGoHome() / reload() / close() / sendEvent()")
            HorizontalDivider(modifier = Modifier.padding(vertical = 2.dp))
            ConfigRow("Host package", hostPackage)
        }
    }
}

@Composable
private fun ConfigRow(label: String, value: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Text(
            text = label,
            modifier = Modifier.weight(0.32f),
            style = MaterialTheme.typography.bodySmall,
            fontWeight = FontWeight.Medium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        Text(
            text = value,
            modifier = Modifier.weight(0.68f),
            style = MaterialTheme.typography.bodySmall.copy(
                fontFamily = FontFamily.Monospace,
                fontSize = 11.sp,
            ),
        )
    }
}
