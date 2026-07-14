package vn.ali.sa.sample

import android.app.Application
import android.util.Log
import dagger.hilt.android.HiltAndroidApp
import org.json.JSONObject
import vn.ali.sa.AliSASDK
import vn.ali.sa.AliSASDKConfig
import vn.ali.sa.AliSASDKDelegate
import vn.ali.sa.AliSASDKUserInfo
import vn.ali.sa.Environment
import vn.ali.sa.SdkConfig

@HiltAndroidApp
class SampleApplication : Application() {

    private val sdkDelegate = object : AliSASDKDelegate {
        override fun onRequestLogin() {
            Log.d(LOG_TAG, "MiniApp requested login; sample app should open login screen here")
        }

        override fun onJsonFromMiniApp(json: String, miniAppId: String) {
            val payload = runCatching { JSONObject(json) }.getOrNull()
            Log.d(LOG_TAG, "Received JSON from mini app $miniAppId: ${payload ?: json}")
        }

        override fun onDidOpenMiniApp(id: String) {
            Log.d(LOG_TAG, "Mini app opened: $id")
        }

        override fun onDidCloseMiniApp(id: String) {
            Log.d(LOG_TAG, "Mini app closed: $id")
        }
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(LOG_TAG, "Configuring AliSASDK facade for sample app...")

        val environment = Environment.SANDBOX

        AliSASDK.configure(
            context = this,
            config = AliSASDKConfig.builder()
                .sdkConfig(
                    SdkConfig(
                        environment = environment,
                        projectId = BuildConfig.SDK_PROJECT_ID,
                        subscriptionKey = BuildConfig.SDK_SUBSCRIPTION_KEY,
                    ),
                )
                .languageCode("vi")
                .autoCheckUpdates(true)
                .miniAppContextProvider {
                    startupUrlParams {
                        mapOf(
                            "eruda" to "1",
                        )
                    }
                    onInitParams { _ ->
                        mapOf(
                            "base_url" to BuildConfig.HOST_BASE_URL,
                            "company_id" to BuildConfig.COMPANY_ID,
                            "token" to "",
                        )
                    }
                }
                .build(),
        )

        AliSASDK.setUserInfo(
            AliSASDKUserInfo(
                userId = "123",
                phoneNumber = "0123456789",
            ),
        )

        AliSASDK.setDelegate(sdkDelegate)

        AliSASDK.initWhenReady(
            onReady = {
                Log.d(LOG_TAG, "AliSASDK runtime initialized successfully")
            },
            onFailure = { error ->
                Log.e(LOG_TAG, "AliSASDK runtime initialization failed: $error")
            },
        )

        SampleRuntimeInfo.environmentName = environment.name
        SampleRuntimeInfo.projectId = BuildConfig.SDK_PROJECT_ID
        SampleRuntimeInfo.companyId = BuildConfig.COMPANY_ID
        SampleRuntimeInfo.hostBaseUrl = BuildConfig.HOST_BASE_URL
        SampleRuntimeInfo.languageCode = "vi"

        Log.d(LOG_TAG, "AliSASDK configured successfully")
    }

    companion object {
        private const val LOG_TAG = "SampleApplication"
    }
}

object SampleRuntimeInfo {
    var environmentName: String = "SANDBOX"
    var projectId: String = ""
    var companyId: String = ""
    var hostBaseUrl: String = ""
    var languageCode: String = "vi"
}
