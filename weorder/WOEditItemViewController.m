//
//  WOEditItemViewController.m
//  weorder
//
//  Created by Peter2 on 2/19/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WOEditItemViewController.h"
#import "WORecordItem.h"

@interface WOEditItemViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnBack;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbPrice;
@property (weak, nonatomic) IBOutlet UILabel *lbDesc;
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UITextField *tfPrice;
@property (weak, nonatomic) IBOutlet UITextView *tvDesc;

@end

@implementation WOEditItemViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.noticeChildViewController.view.hidden = YES;
    self.barBtnBack.title = kSharedModel.lang[@"actionBack"];
    
    self.lbName.text = kSharedModel.lang[@"name"]; 
    [BRStyleSheet styleLabel:self.lbName withType:BRLabelTypeName];
    self.tfName.inputAccessoryView = [self accessoryView];
    self.tfName.clearButtonMode = UITextFieldViewModeAlways;

    
    self.lbPrice.text = kSharedModel.lang[@"price"]; 
    [BRStyleSheet styleLabel:self.lbPrice withType:BRLabelTypeName];
    self.tfPrice.keyboardType = UIKeyboardTypeNumberPad;
    self.tfPrice.inputAccessoryView = [self accessoryView];
    self.tfPrice.clearButtonMode = UITextFieldViewModeAlways;
    
    self.tfPrice.clearButtonMode = UITextFieldViewModeAlways;
    
    self.lbDesc.text = kSharedModel.lang[@"desc"]; 
    [BRStyleSheet styleLabel:self.lbDesc withType:BRLabelTypeName];
    self.tvDesc.text = @"";
    self.tvDesc.inputAccessoryView = [self accessoryView];
    

	// Do any additional setup after loading the view.
    if(nil != self.recordToEdit){
        
        self.navBar.topItem.title = kSharedModel.lang[@"eidtItem"];
    } else {
        
        self.navBar.topItem.title = kSharedModel.lang[@"addItem"];
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    self.noticeChildViewController.view.hidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    self.noticeChildViewController.view.hidden = YES;
    
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    self.noticeChildViewController.view.hidden = NO;
    
}


- (IBAction)_back:(id)sender {
    
    self.complectionBlock(nil);
    
}


@end
