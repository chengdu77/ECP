//
//  FlowChartViewController.m
//  JCDB
//
//  Created by WangJincai on 16/1/26.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import "FlowChartViewController.h"
#import "ASIWebPageRequest.h"
#import "ASIDownloadCache.h"

@interface FlowChartViewController ()<UIWebViewDelegate>{
    UIWebView *_webView;
}
@end

@implementation FlowChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"流程图";
    
    [MBProgressHUD showHUDAddedTo:ShareAppDelegate.window animated:YES];
//     NSString *processid=[[NSUserDefaults standardUserDefaults] objectForKey:kProcessid];
    
    
//    [webView loadRequest:request];
    
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,self.viewWidth,self.viewHeight-20)];
    [self.scrollView addSubview:_webView];
    
    NSString *serviceStr = [NSString stringWithFormat:@"%@/ext/LoginAction?action=Workflowgraph&processid=%@",self.serviceIPInfo,self.processid];
    
    
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:serviceStr]];
    [_webView loadRequest:req];
    return;
    
    NSHTTPCookieStorage *myCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [myCookie cookies]) {
//        NSLog(@"%@", cookie);
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie]; // 保存
    }
    
    // 寻找URL为HOST的相关cookie，不用担心，步骤2已经自动为cookie设置好了相关的URL信息
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:serviceStr]]; // 这里的HOST是你web服务器的域名地址
    // 比如你之前登录的网站地址是abc.com（当然前面要加http://，如果你服务器需要端口号也可以加上端口号），那么这里的HOST就是http://abc.com
    
    // 设置header，通过遍历cookies来一个一个的设置header
    for (NSHTTPCookie *cookie in cookies){
        
        // cookiesWithResponseHeaderFields方法，需要为URL设置一个cookie为NSDictionary类型的header，注意NSDictionary里面的forKey需要是@"Set-Cookie"
        NSArray *headeringCookie = [NSHTTPCookie cookiesWithResponseHeaderFields:
                                    [NSDictionary dictionaryWithObject:
                                     [[NSString alloc] initWithFormat:@"%@=%@",[cookie name],[cookie value]]
                                                                forKey:@"Set-Cookie"]
                                                                          forURL:[NSURL URLWithString:serviceStr]];
        
        // 通过setCookies方法，完成设置，这样只要一访问URL为HOST的网页时，会自动附带上设置好的header
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:headeringCookie
                                                           forURL:[NSURL URLWithString:serviceStr]
                                                  mainDocumentURL:nil];
    }
    
    NSURL *url = [NSURL URLWithString:serviceStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];

    [_webView loadRequest:request];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    
//    
//    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
//        NSLog(@"---%@", cookie);
//    }
    
//    NSLog(@"processid:%@ %@",processid,self.processid);
    
//     NSString *serviceStr = [NSString stringWithFormat:@"%@/ext/LoginAction?action=Workflowgraph&processid=%@",self.serviceIPInfo,self.processid];
//    NSURL *url = [NSURL URLWithString:serviceStr];
//    ASIWebPageRequest * request = [ASIWebPageRequest requestWithURL:url];
//    [request setDelegate:self];
//    [request setDidFailSelector:@selector(webPageFetchFailed:)];
//    [request setDidFinishSelector:@selector(webPageFetchSucceeded:)];
//    
//    // Tell the request to embed external resources directly in the page
//    [request setUrlReplacementMode:ASIReplaceExternalResourcesWithData];
//    
//    // It is strongly recommended you use a download cache with ASIWebPageRequest
//    // When using a cache, external resources are automatically stored in the cache
//    // and can be pulled from the cache on subsequent page loads
//    [request setDownloadCache:[ASIDownloadCache sharedCache]];
//    
//    // Ask the download cache for a place to store the cached data
//    // This is the most efficient way for an ASIWebPageRequest to store a web page
//    [request setDownloadDestinationPath:
//     [[ASIDownloadCache sharedCache] pathToStoreCachedResponseDataForRequest:request]];
//    
//    [request startAsynchronous];
  
}
- (void)webPageFetchFailed:(ASIHTTPRequest *)theRequest
{
    // Obviously you should handle the error properly...
    NSLog(@"%@",[theRequest error]);
}

//- (void)webPageFetchSucceeded:(ASIHTTPRequest *)theRequest
//{
//    NSString *response = [NSString stringWithContentsOfFile:
//                          [theRequest downloadDestinationPath] encoding:[theRequest responseEncoding] error:nil];
//    // Note we're setting the baseURL to the url of the page we downloaded. This is important!
//    [_webView loadHTMLString:response baseURL:[theRequest url]];
//}

- (void)webPageFetchSucceeded:(ASIHTTPRequest *)theRequest
{
    // The page has been downloaded with all external resources. Now, we'll load it into our UIWebView.
    // This time, we're telling our web view to load the file on disk directly.
    
//    NSString *response = [NSString stringWithContentsOfFile:
//                          [theRequest downloadDestinationPath] encoding:[theRequest responseEncoding] error:nil];
//    // Note we're setting the baseURL to the url of the page we downloaded. This is important!
//    [_webView loadHTMLString:response baseURL:[theRequest url]];
    
    [_webView loadRequest:
     [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[theRequest downloadDestinationPath]]]];
    
}

// We've set our controller to be the delegate of our web view
// When a user clicks on a link, we'll handle loading with ASIWebPageRequest
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)theRequest
 navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [_webView loadRequest:theRequest];
        return NO;
    }
    return YES;
}

//清除cookie
- (void)deleteCookie:(NSString *)_urlstr{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookieAry = [cookieJar cookiesForURL: [NSURL URLWithString: _urlstr]];
    for (cookie in cookieAry) {
        [cookieJar deleteCookie: cookie];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [MBProgressHUD hideAllHUDsForView:ShareAppDelegate.window animated:YES];
    [self scalingChange:webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"error:%@",error);
}

-(void)scalingChange:(UIWebView *)webView{
    //(initial-scale是初始缩放比,minimum-scale=1.0最小缩放比,maximum-scale=5.0最大缩放比,user-scalable=yes是否支持缩放)
    NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=self.view.frame.size.width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=5.0, user-scalable=yes\""];
    [webView stringByEvaluatingJavaScriptFromString:meta];
    
//    NSString* str1 =[NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%f%%'",Slide.value];
//    [_webView stringByEvaluatingJavaScriptFromString:str1];
}


@end
