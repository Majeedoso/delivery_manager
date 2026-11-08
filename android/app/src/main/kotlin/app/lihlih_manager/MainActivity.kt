package app.lihlih_manager

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import java.time.Duration
import java.time.Instant

class MainActivity : FlutterActivity() {
    // Android 12+ drops the animated splash at the app's first frame: let its second play out
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            splashScreen.setOnExitAnimationListener { view ->
                val end = view.iconAnimationStart?.plus(view.iconAnimationDuration ?: Duration.ZERO)
                val left = end?.let { Duration.between(Instant.now(), it).toMillis() } ?: 0L
                view.postDelayed({ view.remove() }, left.coerceAtLeast(0L))
            }
        }
    }
}
