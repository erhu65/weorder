//
//  WOStoreBackenViewController.m
//  weorder
//
//  Created by Peter2 on 2/15/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WOStoreBackenViewController.h"
#import "WOCellStorePic.h"


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
@property (weak, nonatomic) IBOutlet UIImageView *fbImg;
@property (weak, nonatomic) IBOutlet UILabel *lbName;

@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UILabel *lbDescription;
@property (weak, nonatomic) IBOutlet UITextView *tvDescription;

@property (weak, nonatomic) IBOutlet UILabel *lbStorePics;

@property (weak, nonatomic) IBOutlet UITableView *tb;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.tfName.inputAccessoryView = [self accessoryView];
    
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
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustForKeyboard:) name:UIKeyboardDidShowNotification object:nil];

}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
 
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



#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"WOCellStorePic";
    
	WOCellStorePic *cell = (WOCellStorePic*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];    
    
    cell.lbPicDesc.text =  @"description..";
    cell.imvPic.image = [UIImage imageNamed:@"Icon.png"];
    
    return cell;
}


- (UIToolbar *) accessoryView
{
	_tbForKeyBoard = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
	_tbForKeyBoard.tintColor = [UIColor darkGrayColor];
	
	NSMutableArray *items = [NSMutableArray array];
	//[items addObject:BARBUTTON(@"Clear", @selector(clearText))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	[items addObject:BARBUTTON(@"Done", @selector(leaveKeyboardMode))];
	_tbForKeyBoard.items = items;	
	
	return _tbForKeyBoard;
}
//- (void) clearText
//{
//	[self.tfName setText:@""];
//}

- (void) leaveKeyboardMode
{
	[super findAndResignFirstResponder:self.view];
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
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    //BRRecordVideo *record = [BRDModel sharedInstance].videos[indexPath.row];
//}


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
    //segueFbChatRoom
	if ([segue.identifier isEqualToString:@"segueFbChatRoom"])
	{

		//self.daysViewController.records = _records;
	} else if ([segue.identifier isEqualToString:@"segueFbMsgBoard"]) {
   
    }
    
}


@end
