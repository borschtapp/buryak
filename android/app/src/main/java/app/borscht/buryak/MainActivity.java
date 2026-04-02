package app.borscht.buryak;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;

import androidx.core.content.FileProvider;

import java.io.File;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final int REQUEST_INSTALL_PERMISSION = 1001;

    private MethodChannel.Result pendingResult;
    private String pendingApkPath;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "app.borscht.buryak/installer")
            .setMethodCallHandler((call, result) -> {
                if (!call.method.equals("install")) {
                    result.notImplemented();
                    return;
                }
                String path = call.arguments();
                if (path == null) {
                    result.error("INVALID_ARG", "APK path is required", null);
                    return;
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
                        && !getPackageManager().canRequestPackageInstalls()) {
                    pendingResult = result;
                    pendingApkPath = path;
                    Intent intent = new Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES)
                        .setData(Uri.parse("package:" + getPackageName()));
                    startActivityForResult(intent, REQUEST_INSTALL_PERMISSION);
                } else {
                    performInstall(path, result);
                }
            });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode != REQUEST_INSTALL_PERMISSION) return;

        if (pendingResult == null || pendingApkPath == null) return;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
                && getPackageManager().canRequestPackageInstalls()) {
            performInstall(pendingApkPath, pendingResult);
        } else {
            pendingResult.error("PERMISSION_DENIED", "Install unknown apps permission was not granted", null);
        }
        pendingResult = null;
        pendingApkPath = null;
    }

    private void performInstall(String path, MethodChannel.Result result) {
        try {
            File file = new File(path);
            Uri uri = FileProvider.getUriForFile(
                this,
                getApplicationContext().getPackageName() + ".provider",
                file
            );
            Intent intent = new Intent(Intent.ACTION_INSTALL_PACKAGE);
            intent.setDataAndType(uri, "application/vnd.android.package-archive");
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
            result.success(null);
        } catch (Exception e) {
            result.error("INSTALL_FAILED", e.getMessage(), null);
        }
    }
}
