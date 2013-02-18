//
//  WOStoreBackenViewController.m
//  weorder
//
//  Created by Peter2 on 2/15/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WOStoreBackenViewController.h"
#import "WOEditPicViewController.h"
#import "WOCellStorePic.h"
#import "WORecordStorePic.h"
#import "Utils.h"
#import "AppDelegate.h"


#ifdef PRPDEBUG
@interface UIWindow (AutoLayoutDebug) 
+ (UIWindow *)keyWindow;
- (NSString *)_autolayoutTrace;
@end
#else

#endif

@interface WOStoreBackenViewController ()
<UITableViewDelegate, UITableViewDataSource,
UITextFieldDelegate, 
UITextViewDelegate>
{
    UIToolbar *_tbForKeyBoard;
}

@property (weak, nonatomic) IBOutlet UILabel *lbFbName;
@property (weak, nonatomic) IBOutlet UIImageView *imvFb;
@property (weak, nonatomic) IBOutlet UILabel *lbName;

@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UILabel *lbDescription;
@property (weak, nonatomic) IBOutlet UITextView *tvDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnSaveStoreInfo;

@property (weak, nonatomic) IBOutlet UIButton *btnAddStroePic;



@property (weak, nonatomic) IBOutlet UILabel *lbStorePics;
@property (weak, nonatomic) IBOutlet UITableView *tb;
@property(nonatomic, strong)NSMutableArray* docs;
@property(nonatomic, strong)NSIndexPath * indexPathTmp;
@end

@implementation WOStoreBackenViewController



-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if(self){
        self.title = kSharedModel.lang[@"titleMyStore"];
        self.navigationController.tabBarItem.title = kSharedModel.lang[@"titleMyStore"];
    }
    return self;
}

-(NSMutableArray*)docs{
    
    if(nil == _docs){
        _docs = [[NSMutableArray alloc] init];
    }
    return _docs;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
	self.tfName.inputAccessoryView = [self accessoryView];
    self.tfName.clearButtonMode = UITextFieldViewModeAlways;
    self.lbName.text = kSharedModel.lang[@"storeName"];
    [BRStyleSheet styleLabel:self.lbName withType:BRLabelTypeName];
    
    self.tvDescription.text = @"";
    self.tvDescription.inputAccessoryView = [self accessoryView];

    self.lbDescription.text = kSharedModel.lang[@"soreDescription"];    
    [BRStyleSheet styleLabel:self.lbDescription withType:BRLabelTypeName];
    
    self.lbStorePics.text = kSharedModel.lang[@"storePics"]; 
    [BRStyleSheet styleLabel:self.lbStorePics withType:BRLabelTypeName];
    
    
    CGAffineTransform rotateTable = CGAffineTransformMakeRotation(-M_PI_2);
	self.tb.transform = rotateTable;
//	self.tb.frame = CGRectMake(0, 500, self.tb.frame.size.width, self.tb.frame.size.height);
    UIImage* backgroundImage = [UIImage imageNamed:@"tool-bar-background.png"];
    self.tb.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    [self _setFbInfo];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleFacebookMeDidUpdate:) name:BRNotificationFacebookMeDidUpdate object:[BRDModel sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustForKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    
     
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
 
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BRNotificationFacebookMeDidUpdate object:[BRDModel sharedInstance]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    
#ifdef PRPDEBUG
    PRPLog(@"%@-[%@ , %@]",
           [[UIWindow keyWindow] _autolayoutTrace],
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
#else
    
#endif

}
- (void)didRotateFromInterfaceOrientation: (UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:
     fromInterfaceOrientation];
    

#ifdef PRPDEBUG
    PRPLog(@"%@-[%@ , %@]",
           [[UIWindow keyWindow] _autolayoutTrace],
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
#else
    
#endif
}

-(void)_setFbInfo{
    
    if(nil != kSharedModel.fbId 
       && nil ==  self.imvFb.image){
        self.imvFb.image = [UIImage imageNamed:kSharedModel.theme[@"placeholderPerson"]];
        NSString *urlFbThumb = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture", kSharedModel.fbId];
        [Utils showImageAsync:self.imvFb fromUrl:urlFbThumb cacheName:kSharedModel.fbId];
        self.lbFbName.text = [NSString stringWithFormat:@"store owner: %@", kSharedModel.fbName];
        self.lbStorePics.text = kSharedModel.lang[@"storePics"]; 
        [BRStyleSheet styleLabel:self.lbFbName withType:BRLabelTypeDaysUntilBirthdaySubText];
        
        self.btnSaveStoreInfo.hidden = NO;
        self.btnAddStroePic.hidden = NO;
        
    } else if (nil == kSharedModel.fbId ) {
        [kSharedModel fetchFacebookMe];
        self.btnSaveStoreInfo.hidden = YES;
        self.btnAddStroePic.hidden = YES;
    }
    [self _fetchStoreInfo];
}

-(void)_handleFacebookMeDidUpdate:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSString* error = userInfo[@"error"];
    if(nil != error){
        [self showMsg:error type:msgLevelWarn]; 
        //self.barBtnJoin.title = kSharedModel.lang[@"actionJoin"];
        //self.barBtnJoin.enabled = YES;
        return;
    }
    [self _setFbInfo];
    PRPLog(@"[BRDModel sharedInstance].fbName: %@-[%@ , %@]",
           [BRDModel sharedInstance].fbName,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));   
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BRNotificationFacebookMeDidUpdate object:[BRDModel sharedInstance]];
}

-(IBAction)_postStoreInfo:(id)sender{
    NSString* name = self.tfName.text;
    NSString* description = self.tvDescription.text;
    if(name.length == 0){
    
        [self showMsg:kSharedModel.lang[@"pleaseFillName"] type:msgLevelWarn];
        [self.tfName becomeFirstResponder];
        return;
    }
    if(description.length == 0){
        [self showMsg:kSharedModel.lang[@"pleaseFillDescription"] type:msgLevelWarn];
        [self.tvDescription becomeFirstResponder];
        return;
    }
    
    __block __weak WOStoreBackenViewController* weakSelf = (WOStoreBackenViewController*)self;
    double lat = 0.0f;
    double lng = 0.0f;
    if(nil != kAppDelegate.location){
        lat = kAppDelegate.location.coordinate.latitude;
        lng = kAppDelegate.location.coordinate.longitude;
    }
    [kSharedModel postStoreInfo:name 
                  description:description 
                  fbId:kSharedModel.fbId 
                  lat:lat lng:lng
                  withBlock:^(NSDictionary* res) {
                      
        NSString* error = res[@"error"];
        if(nil != error){
    
            [weakSelf showMsg:error type:msgLevelError];
            return;
        }
        
        NSString* msg = res[@"msg"];
        
        if(nil != msg){
            [weakSelf showMsg:msg type:msgLevelInfo];
            
            
            NSDictionary* doc = res[@"doc"];
            weakSelf.tfName.text = doc[@"name"];
            weakSelf.tvDescription.text = doc[@"description"];

            return;
        }

        
    }];
}

-(void)_fetchStoreInfo{
    
    if(nil == kSharedModel.fbId) return;
    
    __block __weak WOStoreBackenViewController* weakSelf = (WOStoreBackenViewController*)self;
    [kSharedModel fetchStoreInfoByFbId:kSharedModel.fbId 
                      withBlock:^(NSDictionary* res) {
                          
                          NSString* error = res[@"error"];
                          if(nil != error){
                               
                              [weakSelf showMsg:error type:msgLevelError];
                              return;
                          }
                          
                          NSString* msg = res[@"msg"];
                          if(nil !=  msg){
                              
                              NSString* msgLocal = kSharedModel.lang[msg];
                              [weakSelf showMsg:msgLocal type:msgLevelInfo];
                           
                          }
                          
                          NSDictionary* doc = res[@"doc"];
                         
                          if(nil != doc){
                              [weakSelf _fetchStorePics];
                              weakSelf.tfName.text = doc[@"name"];
                              weakSelf.tvDescription.text = doc[@"description"];
                              return;
                          }
                          
                          
                      }];
}

-(void)_fetchStorePics{
    
    [self showHud:YES];
    
    __block __weak WOStoreBackenViewController* weakSelf = (WOStoreBackenViewController*)self;  
    [kSharedModel fetchStorePicByFbId: kSharedModel.fbId 
                              withBlock:^(NSDictionary* res){
                                  NSString* errMsg = res[@"error"];
                                  if(nil != errMsg){
                                      [weakSelf showMsg:errMsg type:msgLevelError];
                                      return;
                                  } else  {
                                      NSMutableArray* docs = (NSMutableArray*)res[@"docs"];
                                      NSRange range = NSMakeRange(0, docs.count); 
                                      NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:range];
                                      [weakSelf.docs removeAllObjects];
                                      [weakSelf.docs insertObjects:docs atIndexes:indexes];
                                      if(weakSelf.docs.count > 0){
                                          [weakSelf.tb reloadData];
                                          if(nil == weakSelf.indexPathTmp){
                                              weakSelf.indexPathTmp = [NSIndexPath indexPathForRow:0 inSection:0];
                                          } 
                                          
                                          [weakSelf.tb scrollToRowAtIndexPath:self.indexPathTmp atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                                          
                                      }
                                      weakSelf.indexPathTmp = nil;
                                      [weakSelf hideHud:YES];
                                  }     
                                  
                              }];
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.docs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"WOCellStorePic";
    
	WOCellStorePic *cell = (WOCellStorePic*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];    
    
    WORecordStorePic *record = self.docs[indexPath.row];
    cell.indexPath = indexPath;
    cell.record = record;
        
    return cell;
}

CGRect CGRectShrinkHeight(CGRect rect, CGFloat amount)
{
	return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - amount);
}
- (void) adjustForKeyboard: (NSNotification *) notification
{
    
	// Retrieve the keyboard bounds via the notification userInfo dictionary
	CGRect kbounds;
	NSDictionary *userInfo = [notification userInfo];
	[(NSValue *)[userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"] getValue:&kbounds];
    
	// Shrink the textview frame -- comment this out to see the default behavior
//    CGRect destRect = CGRectShrinkHeight(self.view.bounds, kbounds.size.height);
//	self.tvDescription.frame = destRect;
}
- (void) keyboardWillHide: (NSNotification *) notification
{
	// return to previous text view size
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WORecordStorePic *record = self.docs[indexPath.row];
    self.indexPathTmp = indexPath;
    [self performSegueWithIdentifier:@"segueEditPIc" sender:record];
}


#pragma mark UITextFieldDelegate
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    if (textField == self.tfName) {
//        [textField resignFirstResponder];
//    }
//    return NO;
//}
//
#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text
{
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    //	if ([identifier isEqualToString:@"DoneEdit"])
    //	{
    //		if ([self.textField.text length] > 0)
    //		{
    //			int value = [self.textField.text intValue];
    //			if (value >= 0 && value <= 100)
    //				return YES;
    //		}
    //        
    //		[[[UIAlertView alloc]
    //          initWithTitle:nil
    //          message:@"Value must be between 0 and 100."
    //          delegate:nil
    //          cancelButtonTitle:@"OK"
    //          otherButtonTitles:nil]
    //         show];
    //		return NO;
    //	}
	return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     NSString *identifier = segue.identifier;
    __block __weak WOStoreBackenViewController* weakSelf = (WOStoreBackenViewController*)self;  
    if ([identifier isEqualToString:@"segueAddPIc"]) {
        
      
        WOEditPicViewController *destinationVC = (WOEditPicViewController *) segue.destinationViewController;
        destinationVC.fbId = kSharedModel.fbId;
        destinationVC.complectionBlock = ^(NSDictionary* res){ 
                        
            PRPLog(@"after upload new pic res: %@-[%@ , %@]",
                   res,
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));
            [weakSelf _fetchStorePics];
            [weakSelf.navigationController popViewControllerAnimated:YES];

        };        
    } else if([identifier isEqualToString:@"segueEditPIc"]) {
        
        WORecordStorePic *record = (WORecordStorePic *)sender;
        WOEditPicViewController *destinationVC = (WOEditPicViewController *) segue.destinationViewController;
        destinationVC.recordToEdit = record;
        
        destinationVC.complectionBlock = ^(NSDictionary* res){ 
            
            [weakSelf _fetchStorePics];
            
            PRPLog(@"after remove old and upload new pic res: %@-[%@ , %@]",
                   res,
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));
            
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };        
    }

}


@end
