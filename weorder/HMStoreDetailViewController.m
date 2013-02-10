//
//  HMStoreDetailViewController.m
//  Hangman
//
//  Created by Ray Wenderlich on 7/12/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import "HMStoreDetailViewController.h"
#import "IAPProduct.h"
#import "IAPProductInfo.h"
#import <StoreKit/StoreKit.h>
#import "HMIAPHelper.h"
#import "UIImageView+RemoteFile.h"
#import "BackgroundLayer.h"


@interface HMStoreDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imvBg;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *resumeButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@end

@implementation HMStoreDetailViewController {
    NSNumberFormatter * _priceFormatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
     
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter
     setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter
     setNumberStyle:NSNumberFormatterCurrencyStyle];

    [self.view insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_sand.png"]] atIndex:0];
    
}
- (void)refresh {
    
    if ([_product.info.icon length] > 0) {
        
        NSString* picUrl = [NSString stringWithFormat:@"%@/%@", BASE_URL, _product.info.icon];
        [self.imvBg setImageWithRemoteFileURL:picUrl placeHolderImage:[UIImage imageNamed:kSharedModel.theme[@"Icon"]]];
    } else self.imvBg.image = [UIImage imageNamed:kSharedModel.theme[@"Icon"]];
    
    self.title = _product.skProduct.localizedTitle;
    self.titleLabel.text = _product.skProduct.localizedTitle;
    self.descriptionTextView.text =
    _product.skProduct.localizedDescription;
    [_priceFormatter setLocale:_product.skProduct.priceLocale];
    self.priceLabel.text = [_priceFormatter
                            stringFromNumber:_product.skProduct.price];
    self.versionLabel.text = @"Version 1.0";
    
    if (_product.allowedToPurchase) {
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Buy"
                                         style:UIBarButtonItemStyleBordered target:self
                                        action:@selector(buyTapped:)];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    self.pauseButton.hidden = YES;
    self.resumeButton.hidden = YES;
    self.cancelButton.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.statusLabel.hidden = YES;
    [self refresh];
    [self.product addObserver:self
                   forKeyPath:@"purchaseInProgress" options:0 context:nil];
    [self.product addObserver:self
                   forKeyPath:@"purchase" options:0 context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.product removeObserver:self
                      forKeyPath:@"purchaseInProgress" context:nil];
    [self.product removeObserver:self
                      forKeyPath:@"purchase" context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    [self refresh];
}


#pragma mark - Callbacks
 
- (void)buyTapped:(id)sender {
    NSLog(@"Buy tapped!");
    [[HMIAPHelper sharedInstance] buyProduct:self.product];
}

- (IBAction)pauseTapped:(id)sender {
}

- (IBAction)resumeTapped:(id)sender {
}

- (IBAction)cancelTapped:(id)sender {
}

@end
