//
//  WOEditItemPicOptioinalViewController.m
//  weorder
//
//  Created by Peter2 on 2/20/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WOEditItemPicOptioinalViewController.h"
#import "WORecordItem.h"
#import "WORecordItemPicOptional.h"
#import "Utils.h"

#define KAlertviewSureToDel 1003


@interface WOEditItemPicOptioinalViewController ()
<UIImagePickerControllerDelegate,UINavigationControllerDelegate,
UIActionSheetDelegate,
UIAlertViewDelegate>
{
    UIImagePickerController* imagePC;
}
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnBack;
@property (weak, nonatomic) IBOutlet UILabel *lbDesc;
@property (weak, nonatomic) IBOutlet UITextView *tvDesc;

@property (weak, nonatomic) IBOutlet UILabel *lbItemPIc;
@property (weak, nonatomic) IBOutlet UIImageView *imvItemPIc;
@property (weak, nonatomic) IBOutlet UIButton *btnItemPic;

@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnDel;

@end

@implementation WOEditItemPicOptioinalViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.noticeChildViewController.view.hidden = YES;
    self.barBtnBack.title = kSharedModel.lang[@"actionBack"];
        
    self.lbDesc.text = kSharedModel.lang[@"desc"]; 
    [BRStyleSheet styleLabel:self.lbDesc withType:BRLabelTypeName];
    self.tvDesc.text = @"";
    self.tvDesc.inputAccessoryView = [self accessoryView];
    
    self.lbItemPIc.text = kSharedModel.lang[@"ItemPicNeed"];
    [BRStyleSheet styleLabel:self.lbItemPIc withType:BRLabelTypeName];
    
    // prepare image picker
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		imagePC = [[UIImagePickerController alloc] init];
		imagePC.delegate = self;
		imagePC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePC.allowsEditing = YES;
	}
    
    if(nil != self.recordToEdit){
        
        NSString* cacheNamePath = [Utils filePathInCaches:self.recordToEdit.picKey withSuffix:nil];
        BOOL isFileExist =  [[NSFileManager defaultManager] fileExistsAtPath:cacheNamePath];
        if (isFileExist) {
            self.imvItemPIc.image  =  [Utils readCacheImage:cacheNamePath];
        } 
        self.tvDesc.text = self.recordToEdit.desc;
        [self.btnItemPic setBackgroundImage:nil forState:UIControlStateNormal];
        
        self.navBar.topItem.title = kSharedModel.lang[@"editItemPic"];
    } else {
        
        self.navBar.topItem.title = kSharedModel.lang[@"addItemPic"];
        self.btnDel.hidden = YES;
        self.btnDel.enabled = NO;
       
        [BRStyleSheet styleLabel:self.lbItemPIc withType:BRLabelTypeName];
        
        [self.btnItemPic setBackgroundImage:[UIImage imageNamed:kSharedModel.theme[@"placeHorderGeneral"]] forState:UIControlStateNormal];
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

- (IBAction)_showChoosePicActionSheet:(id)sender {    
	UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:kSharedModel.lang[@"choosePIc"] delegate:self cancelButtonTitle:kSharedModel.lang[@"actionCancel"] destructiveButtonTitle:nil otherButtonTitles:kSharedModel.lang[@"takeFromCamera"] , kSharedModel.lang[@"takeFromLibrary"] , nil];
    
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}

#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString* btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
	if ([btnTitle isEqualToString:kSharedModel.lang[@"takeFromCamera"]]) {
        imagePC.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:imagePC animated:YES completion:^() {
            
        }];
	} else if ([btnTitle isEqualToString:kSharedModel.lang[@"takeFromLibrary"]]) {
        imagePC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePC animated:YES completion:^() {
            
        }];
    } 
}

#pragma mark UIImagePickerControllerDelegate
-(void) imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    
    UIImage* imgOriginal = [info valueForKey:@"UIImagePickerControllerEditedImage"];
    
    PRPLog(@"info: %@ \
           -[%@ , %@]",
           info,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
    
    
    UIImage* pickedImage = [Utils imageWithImage:imgOriginal scaledToSize:CGSizeMake(250.0f, 250.0f)];
    self.imvItemPIc.image = pickedImage;
    
    if(nil != self.recordToEdit){
        self.recordToEdit.isPicModified = YES;
    }
    
    [self.btnItemPic setBackgroundImage:nil forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:^(){
        
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:^(){
        
    }];
}


#pragma mark UIAlertViewDelegate 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if(alertView.tag == KAlertviewSureToDel){
        
        if([title isEqualToString:kSharedModel.lang[@"actionOK"]]){
            
            [self _delItemPicOptioinal:self.recordToEdit];
            
        }
    } 
}
- (IBAction)_confirmToDel:(id)sender {
    UIAlertView* av = [[UIAlertView alloc] initWithTitle:kSharedModel.lang[@"warn"] 
                                                 message:kSharedModel.lang[@"areYouSureToDelete"] delegate:self cancelButtonTitle:kSharedModel.lang[@"actionOK"] otherButtonTitles:kSharedModel.lang[@"actionCancel"], nil];
    av.tag = KAlertviewSureToDel;
    [av show];
}

- (IBAction)_save:(id)sender {
    
    NSString* desc = self.tvDesc.text;
    if(desc.length == 0){
        
        [self showMsg:kSharedModel.lang[@"pleaseFillDescription"] type:msgLevelWarn];
        return;
    }
    if(nil == self.imvItemPIc.image){
        
        [self showMsg:kSharedModel.lang[@"pleaseChoolseAItemPic"] type:msgLevelWarn];
        return;
    }
    [self showHud:YES];
    if(nil !=  self.recordToEdit){
        //update  item
        NSString* uniqueKeyOld = self.recordToEdit.picKey;
        self.recordToEdit.desc = self.tvDesc.text;
        
        if(self.recordToEdit.isPicModified){
            
            UIImage* pickedImage = self.imvItemPIc.image;
            PRPLog(@"pickedImage: %@ \
                   -[%@ , %@]",
                   pickedImage,
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));
            [self showHud:YES];
            __block __weak WOEditItemPicOptioinalViewController* weakSelf =(WOEditItemPicOptioinalViewController*) self;
            [kSharedModel delAwsS3Img:uniqueKeyOld withBlock:^(NSDictionary* resByDel) {
                NSString* cacheNamePath = [Utils filePathInCaches:uniqueKeyOld withSuffix:nil];
                [[NSFileManager defaultManager] removeItemAtPath:cacheNamePath error:nil];     
            }];
            
            [kSharedModel saveImageAndUploadToAWS:pickedImage withBlock:^(NSDictionary* res) {
                
                NSString* error = res[@"error"];
                if(nil != error) {
                    
                    [weakSelf showMsg:error type:msgLevelError];
                    return;
                }
                
                NSString* action = res[@"action"];  
                if(nil != action){
                    if([action isEqualToString:@"hideHUD"]){
                        [weakSelf hideHud:YES];
                    }
                }
                NSString* uniqueKeyNew = res[@"uniqueFileName"];  
                PRPLog(@"uniqueKeyNew: %@ \
                       -[%@ , %@]",
                       uniqueKeyNew,
                       NSStringFromClass([self class]),
                       NSStringFromSelector(_cmd));
                weakSelf.recordToEdit.picKey = uniqueKeyNew;
                
                [weakSelf _updItemPicOptioinal:weakSelf.recordToEdit];
                
            }];
            
        } else {
            [self _updItemPicOptioinal:self.recordToEdit];
            
        }
        
    } else {
        // add new item
        UIImage* pickedImage = self.imvItemPIc.image;
        PRPLog(@"pickedImage: %@ \
               -[%@ , %@]",
               pickedImage,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
        
        [self showHud:YES];
        __block __weak WOEditItemPicOptioinalViewController* weakSelf =(WOEditItemPicOptioinalViewController*) self;
        
        [kSharedModel saveImageAndUploadToAWS:pickedImage withBlock:^(NSDictionary* res) { 
            
            NSString* error = res[@"error"];
            if(nil != error) {
                
                [weakSelf showMsg:error type:msgLevelError];
                return;
            }
            
            NSString* action = res[@"action"];  
            if(nil != action){
                if([action isEqualToString:@"hideHUD"]){
                    [weakSelf hideHud:YES];
                }
            }
            NSString* uniqueFileName = res[@"uniqueFileName"];  
            PRPLog(@"uniqueFileName: %@ \
                   -[%@ , %@]",
                   uniqueFileName,
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));
            
            NSDictionary* docToAdd = @{@"desc": desc, @"picKey": uniqueFileName, @"itemId": self.item._id};
            
            WORecordItemPicOptional* reocrdToAdd = [[WORecordItemPicOptional alloc] initWithJsonDic:docToAdd];
            
            [self _postItemPicOptional:reocrdToAdd];
        }];
        
    }
}

- (void)_postItemPicOptional:(WORecordItemPicOptional*)reocrd{
    [self showHud:YES];
    __block __weak WOEditItemPicOptioinalViewController* weakSelf = (WOEditItemPicOptioinalViewController*)self;
    [kSharedModel postItemPicOptional:reocrd 
                            withBlock:^(NSDictionary* res) { 
        
        NSString* error  = res[@"error"];
        if(nil != error){
            
            [weakSelf showMsg:error type:msgLevelError];
            return;
        }
        
        [weakSelf hideHud:YES];
        self.complectionBlock(res);
        
    }];
    
}


- (void)_updItemPicOptioinal:(WORecordItemPicOptional*)reocrd{
    [self showHud:YES];
    __block __weak WOEditItemPicOptioinalViewController* weakSelf = (WOEditItemPicOptioinalViewController*)self;
    [kSharedModel updItemPicOptional:reocrd withBlock:^(NSDictionary* res){ 
        
        NSString* error  = res[@"error"];
        if(nil != error){
            
            [weakSelf showMsg:error type:msgLevelError];
            return;
        }
        [weakSelf hideHud:YES];
        self.complectionBlock(res);
        
    }];
    
}

- (void)_delItemPicOptioinal:(WORecordItemPicOptional*)reocrd{
    
    [self showHud:YES];
    __block __weak WOEditItemPicOptioinalViewController* weakSelf = (WOEditItemPicOptioinalViewController*)self;
    NSString* uniqueKeyOld = self.recordToEdit.picKey;
    [kSharedModel delAwsS3Img:uniqueKeyOld
                    withBlock:^(NSDictionary* resByDel) {
                        
                        NSString* cacheNamePath = [Utils filePathInCaches:uniqueKeyOld withSuffix:nil];
                        [[NSFileManager defaultManager] removeItemAtPath:cacheNamePath error:nil]; 
                        
                        [kSharedModel delItemPicOptional:reocrd
                                    withBlock:^(NSDictionary* res) {
                                        
                                        NSString* error = res[@"error"];
                                        if(nil != error){
                                            
                                            [weakSelf showMsg:error type:msgLevelError];
                                            return;
                                        }
                                        NSDictionary* resDel = @{@"type": @"del"};
                                        [weakSelf hideHud:YES];
                                        weakSelf.complectionBlock(resDel);
                                    }];
                        
                    }];          
    
}

@end
