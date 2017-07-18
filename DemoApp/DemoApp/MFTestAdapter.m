//
//  MFTestAdapter.m
//  DemoApp
//
//  Created by Shimi Sheetrit on 12/20/16.
//  Copyright © 2016 Matomy Media Group Ltd. All rights reserved.
//

#import "MFTestAdapter.h"


@interface MFTestAdapter()

@property (strong, nonatomic) NSURL *nativeClickURL;

@property (weak, nonatomic) IBOutlet UIView *nativeAdView;
@property (weak, nonatomic) IBOutlet UIView *innerNativeAdView;

@property (weak, nonatomic) IBOutlet UIImageView *nativeAdIcon;
@property (weak, nonatomic) IBOutlet UILabel *nativeAdTitle;
@property (weak, nonatomic) IBOutlet UILabel *nativeAdDescription;
@property (weak, nonatomic) IBOutlet UITextField *invhInput;

@property float bannerWidth;
@property float bannerHeight;


@end

@implementation MFTestAdapter


- (id)init {
    
    NSLog(@"MFTestAdapter >> init");
    
    
    //_bannerWidth = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 728.0 : 320.0;
    //_bannerHeight = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 90.0 : 50.0;
    
    self = [super init];
    if (self)
    {}
    return self;
}

/*** banner request ***/
- (void)requestAdWithFrame:(CGRect)rect networkID:(NSString*)nid customEventInfo:(NSDictionary *)info {
    
    NSLog(@"MFTestAdapter >> requestAdWithSize:");

    //CGRect rect = CGRectMake((SCREEN_WIDTH - _bannerWidth)/2, SCREEN_HEIGHT - _bannerHeight, size.width, size.height);
    self.bannerAd = [[MobFoxAd alloc] init:nid withFrame:rect];
    self.bannerAd.delegate = self;
        
    UIView *parentVC = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    [parentVC addSubview:self.bannerAd];
    [self.bannerAd loadAd];
}

/*** interstitial request ***/
- (void)requestInterstitialAdWithFrame:(CGRect)rect networkID:(NSString*)nid customEventInfo:(NSDictionary *)info {
    
    NSLog(@"MFTestAdapter >> requestInterstitialAdWithSize:");
    
    UIViewController *rootController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];

    self.interstitialAd = [[MobFoxInterstitialAd alloc] init:nid withRootViewController:rootController];
    self.interstitialAd.delegate = self;
                           
    [self.interstitialAd loadAd];
}

/*** native request ***/
- (void)requestNativeAdWithFrame:(CGRect)rect networkID:(NSString*)nid customEventInfo:(NSDictionary *)info {
    
    NSLog(@"MFTestAdapter >> requestNativeAdWithSize:");
    
    self.nativeAd = [[MobFoxNativeAd alloc] init:nid];
    self.nativeAd.delegate = self;
    
    [self.nativeAd loadAd];
}


#pragma mark MobFox Ad Delegate

//called when ad is displayed
- (void)MobFoxAdDidLoad:(MobFoxAd *)banner{
    NSLog(@"MFTestAdapter >> MobFoxAdDidLoad:");
    
    [self.delegate MFTestAdapterBaseAdDidLoad:banner];

}

//called when an ad cannot be displayed
- (void)MobFoxAdDidFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"MFTestAdapter >> MobFoxAdDidFailToReceiveAdWithError: %@", [error description]);
    
    [self.delegate MFTestAdapterBaseAdDidFailToReceiveAdWithError:error];
}

//called when ad is closed/skipped
- (void)MobFoxAdClosed {
    NSLog(@"MFTestAdapter >> MobFoxAdClosed");
    
    [self.delegate MFTestAdapterBaseAdClosed];
    
}

#pragma mark MobFox Interstitial Ad Delegate

//best to show after delegate informs an ad was loaded
- (void)MobFoxInterstitialAdDidLoad:(MobFoxInterstitialAd *)interstitial {
    
    NSLog(@"MFTestAdapter >> MobFoxInterstitialAdDidLoad:");
    
    if(self.interstitialAd.ready){
        [interstitial show];
        
        [self.delegate MFTestAdapterInterstitialAdapterBaseAdDidLoad:nil];
        
    }
  
}

- (void)MobFoxInterstitialAdDidFailToReceiveAdWithError:(NSError *)error {
    
    NSLog(@"MFTestAdapter >> MobFoxInterstitialAdDidFailToReceiveAdWithError: %@", [error description]);
    
    [self.delegate MFTestAdapterInterstitialAdapterBaseAdDidFailToReceiveAdWithError:error];
}

#pragma mark MobFox Native Ad Delegate

//called when ad response is returned
- (void)MobFoxNativeAdDidLoad:(MobFoxNativeAd *)ad withAdData:(MobFoxNativeData *)adData {
    
    self.nativeAdIcon.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:adData.icon.url]];
    self.nativeAdTitle.text = adData.assetHeadline;
    self.nativeAdDescription.text = adData.assetDescription;
    self.nativeClickURL = [adData.clickURL absoluteURL];
    
    NSLog(@"MFTestAdapter >> adData.assetHeadline: %@", adData.assetHeadline);
    NSLog(@"MFTestAdapter >> adData.assetDescription: %@", adData.assetDescription);
    NSLog(@"MFTestAdapter >> adData.callToActionText: %@", adData.callToActionText);
    
    for (MobFoxNativeTracker *tracker in adData.trackersArray) {
        
        //NSLog(@"tracker: %@", tracker);
        //NSLog(@"tracker.url: %@", tracker.url);
        
        if ([tracker.url absoluteString].length > 0)
        {
            
            // Fire tracking pixel
            UIWebView* wv = [[UIWebView alloc] initWithFrame:CGRectZero];
            NSString* userAgent = [wv stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
            NSURLSessionConfiguration* conf = [NSURLSessionConfiguration defaultSessionConfiguration];
            conf.HTTPAdditionalHeaders = @{ @"User-Agent" : userAgent };
            NSURLSession* session = [NSURLSession sessionWithConfiguration:conf];
            NSURLSessionDataTask* task = [session dataTaskWithURL:tracker.url completionHandler:
                                          ^(NSData *data,NSURLResponse *response, NSError *error){
                                              
                                              if(error) NSLog(@"err %@",[error description]);
                                              
                                          }];
            [task resume];
            
        }
        
    }
    [self.delegate MFTestAdapterNativeAdapterBaseAdDidLoad:adData];
    
    
}

//called when ad response cannot be returned
- (void)MobFoxNativeAdDidFailToReceiveAdWithError:(NSError *)error {
    
    NSLog(@"MFTestAdapter >> MobFoxNativeAdDidFailToReceiveAdWithError: %@", [error description]);
    
    [self.delegate MFTestAdapterNativeAdapterBaseAdDidFailToReceiveAdWithError:error];
    
}




@end
