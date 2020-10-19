@import UIKit;
@import WebKit;

#import "FlutterFullPdfViewerPlugin.h"

@interface FlutterFullPdfViewerPlugin ()
@end

@implementation FlutterFullPdfViewerPlugin{
    FlutterResult _result;
    WKWebView *_webView;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_full_pdf_viewer"
                                     binaryMessenger:[registrar messenger]];
    
    FlutterFullPdfViewerPlugin *instance = [[FlutterFullPdfViewerPlugin alloc] init];
    
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (CGRect)parseRect:(NSDictionary *)rect {
    return CGRectMake([[rect valueForKey:@"left"] doubleValue],
                      [[rect valueForKey:@"top"] doubleValue],
                      [[rect valueForKey:@"width"] doubleValue],
                      [[rect valueForKey:@"height"] doubleValue]);
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (_result) {
        _result([FlutterError errorWithCode:@"multiple_request"
                                    message:@"Cancelled by a second request"
                                    details:nil]);
        _result = nil;
    }
    
    
    if ([@"launch" isEqualToString:call.method]) {
        
        NSDictionary *rect = call.arguments[@"rect"];
        NSString *path = call.arguments[@"path"];
        
        CGRect rc = [self parseRect:rect];
        
        if (_webView == nil){
            _webView = [[WKWebView alloc] initWithFrame:rc];
            
            NSURL *targetURL = [NSURL fileURLWithPath:path];

            if (@available(iOS 9.0, *)) {
                [_webView loadFileURL:targetURL allowingReadAccessToURL:targetURL];
            } else {
                // untested.
                // _webView.scalesPageToFit = true;
                NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
                [_webView loadRequest:request];
            }

            // Fix iOS 13 get KeyWindow's way & delay get rootViewController to avoid not initialize
            UIViewController *viewController = nil;
            if (@available(iOS 13.0, *)) {
                UIWindow        *foundWindow = nil;
                NSArray         *windows = [[UIApplication sharedApplication] windows];
                for (UIWindow   *window in windows) {
                    if (window.isKeyWindow) {
                        foundWindow = window;
                        break;
                    }
                }
                viewController = foundWindow.rootViewController;
            } else {
                viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
            }
            
            [viewController.view addSubview:_webView];
        }
        
    } else if ([@"resize" isEqualToString:call.method]) {
        if (_webView != nil) {
            NSDictionary *rect = call.arguments[@"rect"];
            CGRect rc = [self parseRect:rect];
            _webView.frame = rc;
        }
    } else if ([@"close" isEqualToString:call.method]) {
        [self closeWebView];
        result(nil);
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)closeWebView {
    if (_webView != nil) {
        [_webView stopLoading];
        [_webView removeFromSuperview];
        _webView = nil;
    }
}


@end
