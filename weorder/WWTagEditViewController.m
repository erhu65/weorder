//
//  WWTagEditViewController.m
//  wework
//
//  Created by Peter2 on 2/5/13.
//  Copyright (c) 2013 Peter2. All rights reserved.
//

#import "WWTagEditViewController.h"
#import "WWRecordTag.h"

@interface WWTagEditViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tfTagName;

@end

@implementation WWTagEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.type == tagEditTypeEdit){
       self.title = kSharedModel.lang[@"titleEditTag"];
    } else if(self.type == tagEditTypeAdd) {
      self.title = kSharedModel.lang[@"titleAddTag"];
    }
    
	// Do any additional setup after loading the view.
    [self.tfTagName becomeFirstResponder];
    if(self.type == tagEditTypeEdit
       && [self.recordEdit.tagName length] > 0){
    
        self.tfTagName.text = self.recordEdit.tagName;
    }
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:kSharedModel.theme[@"bg_sand"]]];
    self.view.backgroundColor  = background;
    self.tfTagName.clearButtonMode = UITextFieldViewModeAlways;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self.tfTagName resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if([self isViewLoaded] && self.view.window == nil){
        //self.imvThumb = nil;
    }
}


-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if(self){
        
     
        
    }
    
    return self;
}


#pragma mark Segues
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
	if ([identifier isEqualToString:@"unwindSegueBackToWWTagViewControllerSave"])
	{
        self.recordEdit.tagName = self.tfTagName.text;
        if([self.tfTagName.text length] == 0){
        
            [self showMsg:kSharedModel.lang[@"warnEmptyText"] type:msgLevelWarn];
            return NO;
        } 
	}
	return YES;
}
@end
