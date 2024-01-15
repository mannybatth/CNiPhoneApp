//
//  WebViewController.m
//  CNApp
//
//  Created by Manpreet Singh on 7/5/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate>
{
    NSURL *url;
    UIActivityIndicatorView *firstSpinner;
}

@property (strong, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation WebViewController

- (id)initWithURL:(NSURL *)urlObj
{
    self = [super init];
    if (self) {
        
        url = urlObj;
        
    }
    return self;
}

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        
        url = [NSURL URLWithString:path];
        if (url == nil) url = [NSURL fileURLWithPath:path];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webview.delegate = self;
    
    firstSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    firstSpinner.center = CGPointMake(self.view.bounds.size.width/2, 200);
    firstSpinner.hidesWhenStopped = YES;
    [self.view addSubview:firstSpinner];
    [firstSpinner startAnimating];
    
    if (url) {
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        [self.webview loadRequest:urlRequest];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setTitleView:nil];
    [self.navigationItem setRightBarButtonItem:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [firstSpinner stopAnimating];
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self.navigationItem setTitle:title];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
