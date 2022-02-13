package com.alveliu.flutterfullpdfviewer;

import android.app.Activity;
import android.content.Context;
import android.graphics.Point;
import android.view.Display;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterFullPdfViewerPlugin
 */
public class FlutterFullPdfViewerPlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {
    static MethodChannel channel;
    private Activity activity;
    private FlutterFullPdfViewerManager flutterFullPdfViewerManager;
    private Context applicationContext;

    private void setActivity(Activity activity) {
        this.activity = activity;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "launch":
                openPDF(call, result);
                break;
            case "resize":
                resize(call, result);
                break;
            case "close":
                close(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void openPDF(MethodCall call, MethodChannel.Result result) {
        String path = call.argument("path");
        if (flutterFullPdfViewerManager == null || flutterFullPdfViewerManager.closed) {
            flutterFullPdfViewerManager = new FlutterFullPdfViewerManager(applicationContext);
        }
        FrameLayout.LayoutParams params = buildLayoutParams(call);
        activity.addContentView(flutterFullPdfViewerManager.pdfView, params);
        flutterFullPdfViewerManager.openPDF(path);
        result.success(null);
    }

    private void resize(MethodCall call, final MethodChannel.Result result) {
        if (flutterFullPdfViewerManager != null) {
            FrameLayout.LayoutParams params = buildLayoutParams(call);
            flutterFullPdfViewerManager.resize(params);
        }
        result.success(null);
    }

    private void close(MethodCall call, MethodChannel.Result result) {
        if (flutterFullPdfViewerManager != null) {
            flutterFullPdfViewerManager.close(call, result);
            flutterFullPdfViewerManager = null;
        }
    }

    private FrameLayout.LayoutParams buildLayoutParams(MethodCall call) {
        Map<String, Number> rc = call.argument("rect");
        FrameLayout.LayoutParams params;
        if (rc != null) {
            params = new FrameLayout.LayoutParams(dp2px(applicationContext, rc.get("width").intValue()), dp2px(applicationContext, rc.get("height").intValue()));
            params.setMargins(dp2px(applicationContext, rc.get("left").intValue()), dp2px(applicationContext, rc.get("top").intValue()), 0, 0);
        } else {
            Display display = activity.getWindowManager().getDefaultDisplay();
            Point size = new Point();
            display.getSize(size);
            int width = size.x;
            int height = size.y;
            params = new FrameLayout.LayoutParams(width, height);
        }
        return params;
    }

    private int dp2px(Context context, float dp) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dp * scale + 0.5f);
    }

    private void onAttachedToEngine(Context context, BinaryMessenger binaryMessenger) {
        this.applicationContext = context;
        channel = new MethodChannel(binaryMessenger, "flutter_full_pdf_viewer");
        channel.setMethodCallHandler(this);
    }

    @SuppressWarnings("deprecation")
    public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
        FlutterFullPdfViewerPlugin plugin = new FlutterFullPdfViewerPlugin();
        plugin.setActivity(registrar.activity());
        plugin.onAttachedToEngine(registrar.context(), registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        this.onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
    }
}
