//
//  HMStoreListViewController.m
//  Hangman
//
//  Created by Ray Wenderlich on 7/12/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import "HMStoreListViewController.h"
#import "HMStoreListViewCell.h"
#import "HMIAPHelper.h"
#import "IAPProduct.h"
#import <StoreKit/StoreKit.h>
#import "HMStoreDetailViewController.h"
#import "IAPProductInfo.h"
#import "IAPProductPurchase.h"
#import "UIImageView+RemoteFile.h"

//#import "UIImageView+AFNetworking.h"

@interface HMStoreListViewController() <UIAlertViewDelegate>
@end

@implementation HMStoreListViewController {
    NSArray * _products;
    NSNumberFormatter * _priceFormatter;
    BOOL _observing;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:kSharedModel.lang[@"actionBack"] style:UIBarButtonItemStyleBordered target:self action:@selector(doneTapped:)];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStyleBordered target:self action:@selector(restoreTapped:)];

    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter
     setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload)
                  forControlEvents:UIControlEventValueChanged];
    [self reload];
    [self.refreshControl beginRefreshing];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_sand.png"]]];}

- (void)reload {
    
    [self setProducts:nil];
    [self.tableView reloadData];
    [[HMIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            [self setProducts:products];
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addObservers];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeObservers];
}

#pragma mark - KVO

- (void)addObservers {
    if (_observing || _products == nil) return;
    _observing = TRUE;
    for (IAPProduct * product in _products) {
        [product addObserver:self
                  forKeyPath:@"purchaseInProgress" options:0 context:nil];
        [product addObserver:self forKeyPath:@"purchase" options:0
                     context:nil];
    }
}

- (void)removeObservers {
    if (!_observing) return;
    _observing = FALSE;
    for (IAPProduct * product in _products) {
        [product removeObserver:self
                     forKeyPath:@"purchaseInProgress" context:nil];
        [product removeObserver:self forKeyPath:@"purchase"
                        context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    IAPProduct * product = (IAPProduct *)object;
    int row = [_products indexOfObject:product];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row
                                                 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setProducts:(NSArray *)products {    
    [self removeObservers];
    _products = products;
    [self addObservers];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return _products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    HMStoreListViewCell *cell = [tableView
                                 dequeueReusableCellWithIdentifier:CellIdentifier];
    
    IAPProduct *product = _products[indexPath.row];
    
    cell.titleLabel.text = product.skProduct.localizedTitle;
    cell.descriptionLabel.text =
    product.skProduct.localizedDescription;
    [_priceFormatter setLocale:product.skProduct.priceLocale];
    if (!product.purchase.consumable && product.purchase) {
        cell.priceLabel.text = @"Installed";
    } else {
        cell.priceLabel.text = [_priceFormatter
                                stringFromNumber:product.skProduct.price];
    }
    if ([product.info.icon length] > 0) {
        NSString* picUrl = [NSString stringWithFormat:@"%@/%@", BASE_URL, product.info.icon];
        [cell.iconImageView setImageWithRemoteFileURL:picUrl placeHolderImage:[UIImage imageNamed:kSharedModel.theme[@"Icon"]]];
    }  else cell.iconImageView.image = [UIImage imageNamed:kSharedModel.theme[@"Icon"]];

    
    return cell;
}

#pragma mark - Callbacks

- (void)doneTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)restoreTapped:(id)sender {
    NSLog(@"Restore tapped!");
    UIAlertView * alertView = [[UIAlertView alloc]
                               initWithTitle:@"Restore Content"
                               message:@"Would you like to check for and restore any previous purchases?"
                               delegate:self
                               cancelButtonTitle:@"Cancel"
                               otherButtonTitles:@"OK", nil];
    alertView.delegate = self;
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [[HMIAPHelper sharedInstance] 
         restoreCompletedTransactions];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"PushDetail"
                              sender:indexPath];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushDetail"]) {
        HMStoreDetailViewController * detailViewController =
        (HMStoreDetailViewController *)
        segue.destinationViewController;
        NSIndexPath * indexPath = (NSIndexPath *)sender;
        IAPProduct *product = _products[indexPath.row];
        detailViewController.product = product;
    }
}

@end
