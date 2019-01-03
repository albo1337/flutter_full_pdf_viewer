@import UIKit;

#import "FlutterFullPdfViewerPlugin.h"

@interface FlutterFullPdfViewerPlugin ()
@end

@implementation FlutterFullPdfViewerPlugin{
    FlutterResult _result;
    UIViewController *_viewController;
    UIWebView *_webView;
    int pageNumber = 0;
    int pageCount = 0;
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
        
        if (_webView == nil){
            _webView = [[UIWebView alloc] initWithFrame:rc];
            _webView.scalesPageToFit = true;
            
            NSURL *targetURL = [NSURL fileURLWithPath:path];
            NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
            [_webView loadRequest:request];
            
            [_viewController.view addSubview:_webView];
            self.pdfPageCount = (int)CGPDFDocumentGetNumberOfPages(pdf);
        }
        
    } else if ([@"getPageCount" isEqualToString:call.method]) {
        if (_webView != nil) {
            [self getPageCount];
        }
        result(nil);
    } else if ([@"getPage" isEqualToString:call.method]) {
        if (_webView != nil) {
            [self getPage];
        }
        result(nil);
    } else if ([@"setPage" isEqualToString:call.method]) {
        if (_webView != nil) {
            NSDictionary *rect = call.arguments[@"rect"];
            int page =[[rect valueForKey:@"page"] doubleValue]
            page = [self getPage:page];
        }
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

#pragma UIScrollViewDelegate
– (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // if pdfPageHeight is -1 it needs to be calculated
    if(self.pdfPageHeight == –1)
    {
        // the page height is calculated by taking the overall size of the UIWebView scrollView content size
        // then dividing it by the number of pages Core Graphics reported for the PDF file being shown
        CGFloat contentHeight = self.webView.scrollView.contentSize.height;
        self.pdfPageHeight = contentHeight / self.pdfPageCount;
        // also calculate what half the screen height is. no sense in doing this multiple times.
        self.halfScreenHeight = (self.webView.frame.size.height / 2);
    }
    // to calculate the page number, first get how far the user has scrolled
    float verticalContentOffset = self.webView.scrollView.contentOffset.y;
    // next add the halfScreenHeight then divide the result by the guesstimated pdfPageHeight
    self.pageNumber = ceilf((verticalContentOffset + self.halfScreenHeight) / self.pdfPageHeight);
    // finally set the text of the page counter label
    self.pageLabel.text = [NSString stringWithFormat:@”%d of %d”, self.pageNumber, self.pdfPageCount];
}

-(int)setPage:(int *)page {
    if (page/*which page? u want to go ?*/ < 170/*how many pages?*/)
    {
        float y =  self.pdfPageHeight/*page Hight*/ * page++;
        
        if (isIOSAbove4)
        {
            [[_webView scrollView] setContentOffset:CGPointMake(0,y) animated:YES];
        }
        else
        {
            [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.scrollTo(0.0, %f)", y]];
        }
    }
    self.pageNumber = page;
    return self.pageNumber;
}

- (int)getPage {
    return self.pageNumber;
}

- (int)getPageCount {
    return self.pageCount;
}

- (void)closeWebView {
    if (_webView != nil) {
        [_webView stopLoading];
        [_webView removeFromSuperview];
        _webView = nil;
    }
}


@end
