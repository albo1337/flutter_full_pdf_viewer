@import UIKit;

#import "FlutterFullPdfViewerPlugin.h"

@interface FlutterFullPdfViewerPlugin ()
@end

@implementation FlutterFullPdfViewerPlugin{
    FlutterResult _result;
    UIViewController *_viewController;
    UIWebView *_webView;
    int _pdfPageHeight;
    int _halfScreenHeight;
    int _pageNumber;
    int _pageCount;
    #define isIOSAbove4 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_full_pdf_viewer"
                                     binaryMessenger:[registrar messenger]];
    
    UIViewController *viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    
    FlutterFullPdfViewerPlugin *instance = [[FlutterFullPdfViewerPlugin alloc] initWithViewController:viewController];
    
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
    }
    return self;
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

        NSLog( @"launch: Page: '%i'", _pageNumber );
        
        if (_webView == nil){
            _webView = [[UIWebView alloc] initWithFrame:rc];
            _webView.scalesPageToFit = true;
            _pdfPageHeight = -1;
            
            NSURL *targetURL = [NSURL fileURLWithPath:path];
            CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL((__bridge CFURLRef)targetURL);
            NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
            [_webView loadRequest:request];
            
            [_viewController.view addSubview:_webView];
            _pageCount = (int)CGPDFDocumentGetNumberOfPages(pdfDocument);
            // [self setPage:10];
        }
    } else if ([@"getPageCount" isEqualToString:call.method]) {
        if (_webView != nil) {
            result([@"" stringByAppendingString:[NSString stringWithFormat:@"%i", [self getPageCount]]]);
        } else
        result(nil);
    } else if ([@"getPage" isEqualToString:call.method]) {
        if (_webView != nil) {
            result([@"" stringByAppendingString:[NSString stringWithFormat:@"%i", [self getPage]+1]]);
        } else
        result(nil); 
    } else if ([@"setPage" isEqualToString:call.method]) {
        if (_webView != nil) {
            NSDictionary *rect = call.arguments[@"rect"];
            int page =[[rect valueForKey:@"page"] doubleValue];
            page = [self setPage:page];
            result([@"" stringByAppendingString:[NSString stringWithFormat:@"%i", [self getPage]+1]]); 
        } else
        result(nil);    
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



-(int)setPage:(int)page {
    if(_pdfPageHeight == -1)
    {
        // the page height is calculated by taking the overall size of the UIWebView scrollView content size
        // then dividing it by the number of pages Core Graphics reported for the PDF file being shown
        CGFloat contentHeight = _webView.scrollView.contentSize.height;
        _pdfPageHeight = contentHeight / _pageCount;
        // also calculate what half the screen height is. no sense in doing this multiple times.
        _halfScreenHeight = (_webView.frame.size.height / 2);
    }
    /*which page? u want to go ?*/  /*how many pages?*/
    if (page< _pageCount)
    {
        float y =  _pdfPageHeight/*page Hight*/ * page++;

        if (isIOSAbove4)
        {
            [[_webView scrollView] setContentOffset:CGPointMake(0,y) animated:YES];
        }
        else
        {
            [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.scrollTo(0.0, %f)", y]];
        }
    }
    _pageNumber = page-1;
    NSLog( @"setPage: '%i'", _pageNumber );

    return _pageNumber;
}

- (int)getPage {
    return _pageNumber;
}

- (int)getPageCount {
    return _pageCount;
}

- (void)closeWebView {
    if (_webView != nil) {
        [_webView stopLoading];
        [_webView removeFromSuperview];
        _webView = nil;
    }
}


@end
