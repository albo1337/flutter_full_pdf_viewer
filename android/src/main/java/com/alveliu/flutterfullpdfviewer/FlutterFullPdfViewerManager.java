package com.alveliu.flutterfullpdfviewer;

import android.app.Activity;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.github.barteksc.pdfviewer.PDFView;
import com.github.barteksc.pdfviewer.listener.OnPageChangeListener;
import android.util.Log;

import java.io.File;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * FlutterFullPdfViewerManager
 */
class FlutterFullPdfViewerManager implements OnPageChangeListener {

    boolean closed = false;
    PDFView pdfView;
    Activity activity;
    String pdfFileName;
    Boolean testChange= true;
    Integer pageNumber = 0;

    FlutterFullPdfViewerManager (final Activity activity) {
        this.pdfView = new PDFView(activity, null);
        this.activity = activity;
    }

    @Override
    public void onPageChanged(int page, int pageCount) {
        this.pageNumber = page;
        this.activity.setTitle(String.format("%s %s / %s", pdfFileName, page + 1, pageCount));
    }

    void openPDF(String path) {
        Log.e("openPDF",path);

        File file = new File(path);
        this.pdfFileName = file.getName();

        pdfView.fromFile(file)
                .enableSwipe(true)
                .swipeHorizontal(false)
                .enableDoubletap(true)
                .onPageChange(this)
                .defaultPage(0)
                .load();
    }

    int getPageCount() {
        if (pdfView == null) {
            return 0;
        }
        return pdfView.getPageCount();
    }

    int setPage(int page){
        pdfView.jumpTo(page);
        pageNumber = page;
        Log.e("pageNumber",pageNumber.toString());
        return pageNumber;
    }

    int getPage(){
        return pdfView.getCurrentPage();
    }

    void resize(FrameLayout.LayoutParams params) {
        pdfView.setLayoutParams(params);
    }

    void close(MethodCall call, MethodChannel.Result result) {
        if (pdfView != null) {
            ViewGroup vg = (ViewGroup) (pdfView.getParent());
            vg.removeView(pdfView);
        }
        pdfView = null;
        if (result != null) {
            result.success(null);
        }

        closed = true;
        FlutterFullPdfViewerPlugin.channel.invokeMethod("onDestroy", null);
    }

    void close() {
        close(null, null);
    }
}