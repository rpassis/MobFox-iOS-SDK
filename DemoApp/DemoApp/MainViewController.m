//
//  ViewController.m
//  DemoApp
//
//  Created by Shimi Sheetrit on 2/1/16.
//  Copyright © 2016 Matomy Media Group Ltd. All rights reserved.
//

#import "MainViewController.h"
#import "CollectionViewCell.h"
#import "SettingsViewController.h"
#import "NativeAdViewController.h"
#import "MPMobFoxNativeAdRenderer.h"
#import "MoPubNativeAdapterMobFox.h"


#define ADS_TYPE_NUM 4
#define AD_REFRESH 0


#define MOBFOX_HASH_BANNER @"fe96717d9875b9da4339ea5367eff1ec"
#define MOBFOX_HASH_INTER @"267d72ac3f77a3f447b32cf7ebf20673"
#define MOBFOX_HASH_NATIVE @"4c3ea57788c5858881dc42cfafe8c0ab"
#define MOBFOX_HASH_VIDEO @"80187188f458cfde788d961b6882fd53"


@interface MainViewController ()

@property (strong, nonatomic) MobFoxAd *mobfoxAd;
@property (strong, nonatomic) MobFoxInterstitialAd *mobfoxInterAd;
@property (strong, nonatomic) MobFoxNativeAd* mobfoxNativeAd;
@property (strong, nonatomic) MobFoxAd *mobfoxVideoAd;
@property (strong, nonatomic) NSURL *clickURL;
@property (strong, nonatomic) NSString *cellID;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *nativeAdView;
@property (weak, nonatomic) IBOutlet UIView *innerNativeAdView;

@property (weak, nonatomic) IBOutlet UIImageView *nativeAdIcon;
@property (weak, nonatomic) IBOutlet UILabel *nativeAdTitle;
@property (weak, nonatomic) IBOutlet UILabel *nativeAdDescription;

@property (nonatomic) CGRect videoAdRect;



@end

@implementation MainViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"response.json" ofType:nil];
    NSLog(@"plistPath %@", plistPath);
    
    self.cellID = @"cellID";
    self.nativeAdView.hidden = YES;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.innerNativeAdView addGestureRecognizer:recognizer];
    
    // Oreintation dependent in iOS 8 and later.
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    float bannerWidth = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 728.0 : 320.0;
    float bannerHeight = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 90.0 : 50.0;
    float videoWidth = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 500.0 : 300.0;
    float videoHeight = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 450.0 : 250.0;
    
    /*** Banner ***/
    CGRect adRect = CGRectMake((screenWidth-bannerWidth)/2, screenHeight-bannerHeight, bannerWidth, bannerHeight);
    self.mobfoxAd = [[MobFoxAd alloc] init:MOBFOX_HASH_BANNER withFrame:adRect];
    self.mobfoxAd.delegate = self;
    self.mobfoxAd.refresh = [NSNumber numberWithInt:AD_REFRESH];
    [self.view addSubview:self.mobfoxAd];
    
    /*** Interstitial ***/
    self.mobfoxInterAd = [[MobFoxInterstitialAd alloc] init:MOBFOX_HASH_INTER withRootViewController:self];
    //self.mobfoxInterAd.ad.type = @"video";
    self.mobfoxInterAd.delegate = self;
    
    /*** Native ***/
    self.mobfoxNativeAd = [[MobFoxNativeAd alloc] init:MOBFOX_HASH_NATIVE];
    self.mobfoxNativeAd.delegate = self;
    
    /*** Video ***/
    float videoTopMargin = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 200.0 : 80.0;
    self.videoAdRect = CGRectMake((screenWidth - videoWidth)/2, self.collectionView.frame.size.height + videoTopMargin, videoWidth, videoHeight);
    self.mobfoxVideoAd = [[MobFoxAd alloc] init:MOBFOX_HASH_VIDEO withFrame:self.videoAdRect];
    self.mobfoxVideoAd.delegate = self;
    self.mobfoxVideoAd.type = @"video";
    self.mobfoxVideoAd.auto_pilot = false;
    [self.view addSubview:self.mobfoxVideoAd];

    
}

- (UIViewController *)viewControllerForPresentingModalView {
    
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    NSLog(@"viewWillDisappear");
    
    [super viewWillDisappear:animated];
    [self.mobfoxVideoAd pause];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return ADS_TYPE_NUM;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{

    CollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:self.cellID forIndexPath:indexPath];
    cell.title.text = [self adTitle:indexPath];
    cell.image.image = [self adImage:indexPath];
    
    if (cell.selected) {
        cell.backgroundColor = [UIColor lightGrayColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor]; // Default color
    }
    
    return cell;
}

#pragma mark Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UICollectionViewCell* cell = [collectionView  cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    
    
    switch (indexPath.item) {
        case 0:
            [self hideAds:indexPath];
            [self.mobfoxVideoAd pause];
            self.mobfoxAd.invh = self.invh.length > 0 ? self.invh: MOBFOX_HASH_BANNER;
            [self.mobfoxAd loadAd];
            
            break;
            
        case 1:
            
            [self hideAds:indexPath];
            [self.mobfoxVideoAd pause];
            self.mobfoxInterAd.ad.invh = self.invh.length > 0 ? self.invh: MOBFOX_HASH_INTER;
            [self.mobfoxInterAd loadAd];
            break;
            
        case 2:
            [self hideAds:indexPath];
            [self.mobfoxVideoAd pause];
            self.mobfoxNativeAd.invh = self.invh.length > 0 ? self.invh: MOBFOX_HASH_NATIVE;
            [self.mobfoxNativeAd loadAd];
            
            break;
            
        case 3:
            
            [self hideAds:indexPath];
            [self.mobfoxVideoAd pause];

            self.mobfoxVideoAd.invh = self.invh.length > 0 ? self.invh: MOBFOX_HASH_VIDEO;
            [self.mobfoxVideoAd loadAd];

            break;
            
        default:
            break;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* cell = [collectionView  cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}



#pragma mark MobFox Ad Delegate

//called when ad is displayed
- (void)MobFoxAdDidLoad:(MobFoxAd *)banner {
    
    NSLog(@"MobFoxAdDidLoad:");
}

//called when an ad cannot be displayed
- (void)MobFoxAdDidFailToReceiveAdWithError:(NSError *)error {
    
    NSLog(@"MobFoxAdDidFailToReceiveAdWithError: %@", [error description]);
}

//called when ad is closed/skipped
- (void)MobFoxAdClosed {
    NSLog(@"MobFoxAdClosed:");

}

//called when ad is clicked
- (void)MobFoxAdClicked {
    NSLog(@"MobFoxAdClicked:");

}

#pragma mark MobFox Interstitial Ad Delegate

//best to show after delegate informs an ad was loaded
- (void)MobFoxInterstitialAdDidLoad:(MobFoxInterstitialAd *)interstitial {
    
    NSLog(@"MobFoxInterstitialAdDidLoad:");
    
    if(self.mobfoxInterAd.ready){
        [self.mobfoxInterAd show];
    }

}

- (void)MobFoxInterstitialAdDidFailToReceiveAdWithError:(NSError *)error {
    
    NSLog(@"MobFoxInterstitialAdDidFailToReceiveAdWithError: %@", [error description]);
    
}

- (void)MobFoxInterstitialAdClosed {
    
    NSLog(@"MobFoxInterstitialAdClosed");
    
}

- (void)MobFoxInterstitialAdClicked {
    
    NSLog(@"MobFoxInterstitialAdClicked");
    
}

- (void)MobFoxInterstitialAdFinished {
    
    NSLog(@"MobFoxInterstitialAdFinished");
    
}

#pragma mark MobFox Native Ad Delegate

//called when ad response is returned
- (void)MobFoxNativeAdDidLoad:(MobFoxNativeAd *)ad withAdData:(MobFoxNativeData *)adData {
    
    self.nativeAdIcon.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:adData.icon.url]];
    self.nativeAdTitle.text = adData.assetHeadline;
    self.nativeAdDescription.text = adData.assetDescription;
    self.clickURL = [adData.clickURL absoluteURL];
    
    //adData.callToActionText
    NSLog(@"adData.assetHeadline: %@", adData.assetHeadline);
    NSLog(@"adData.assetDescription: %@", adData.assetDescription);
    NSLog(@"adData.callToActionText: %@", adData.callToActionText);
    
    for (MobFoxNativeTracker *tracker in adData.trackersArray) {
        
        NSLog(@"tracker: %@", tracker);
        NSLog(@"tracker.url: %@", tracker.url);

        if ([tracker.url absoluteString].length > 0)
        {
            
            // Fire tracking pixel
            UIWebView* wv = [[UIWebView alloc] initWithFrame:CGRectZero];
            NSString* userAgent = [wv stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
            NSLog(@"userAgent: %@", userAgent);
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
    
}

//called when ad response cannot be returned
- (void)MobFoxNativeAdDidFailToReceiveAdWithError:(NSError *)error {
    
    NSLog(@"MobFoxNativeAdDidFailToReceiveAdWithError: %@", [error description]);
    
}

#pragma mark Private Methods

- (void)hideAds:(NSIndexPath *)indexPath {
    
    switch (indexPath.item) {
        case 0:
            self.mobfoxAd.hidden= NO;
            self.mobfoxInterAd.ad.hidden = YES;
            self.nativeAdView.hidden = YES;
            self.mobfoxVideoAd.hidden = YES;
            
            break;
            
        case 1:
            self.mobfoxAd.hidden= YES;
            self.mobfoxInterAd.ad.hidden = NO;
            self.nativeAdView.hidden = YES;
            self.mobfoxVideoAd.hidden = YES;
            
            break;
            
        case 2:
            self.mobfoxAd.hidden= YES;
            self.mobfoxInterAd.ad.hidden = YES;
            self.nativeAdView.hidden = NO;
            self.mobfoxVideoAd.hidden = YES;
            
            break;
            
        case 3:
            self.mobfoxAd.hidden= YES;
            self.mobfoxInterAd.ad.hidden = YES;
            self.nativeAdView.hidden = YES;
            self.mobfoxVideoAd.hidden = NO;
            
            break;
            
        default:
            break;
    }
    
}

- (NSString *)adTitle:(NSIndexPath *)indexPath {
    
    switch (indexPath.item) {
        case 0:
            return @"Banner";
            break;
        case 1:
            return @"Interstitial";
            break;
        case 2:
            return @"Native";
            break;
        case 3:
            return @"Video";
            break;
            
        default:
            return @"";
            break;
    }
}

- (UIImage *)adImage:(NSIndexPath *)indexPath {
    
    switch (indexPath.item) {
        case 0:
            return [UIImage imageNamed:@"test_banner.png"];
            break;
        case 1:
            return [UIImage imageNamed:@"test_interstitial.png"];
            break;
        case 2:
            return [UIImage imageNamed:@"test_native.png"];
            break;
        case 3:
            return [UIImage imageNamed:@"test_video.png"];
            break;
            
        default:
            return nil;
            break;
    }
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    
    [[UIApplication sharedApplication] openURL:self.clickURL];
    
}

- (void)presentViewController {
    
    NativeAdViewController *nativeVC = [[NativeAdViewController alloc] init];
    [self presentViewController:nativeVC animated:YES completion:nil];
    
}

-(void)nativeAdWillPresentModalForCollectionViewAdPlacer:(MPCollectionViewAdPlacer *)placer{
    NSLog(@">> first");
}


-(void)nativeAdDidDismissModalForCollectionViewAdPlacer:(MPCollectionViewAdPlacer *)placer{
    NSLog(@">> second");
}


-(void)nativeAdWillLeaveApplicationFromCollectionViewAdPlacer:(MPCollectionViewAdPlacer *)placer{
    NSLog(@">> third");
}

@end



