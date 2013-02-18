//
//  WOEditPicViewController.m
//  weorder
//
//  Created by Peter2 on 2/17/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WOEditPicViewController.h"
#import "WORecordStorePic.h"
#import "Utils.h"

#define KAlertviewSureToDel 1002

@interface WOEditPicViewController ()
<UIImagePickerControllerDelegate,UINavigationControllerDelegate,
UIActionSheetDelegate,
UIAlertViewDelegate>
{
    UIImagePickerController* imagePC;
   
}

@property (weak, nonatomic) IBOutlet UIImageView *imvPIc;
@property (weak, nonatomic) IBOutlet UITextField *tfDescription;
@property (weak, nonatomic) IBOutlet UILabel *lbDescription;

@property (weak, nonatomic) IBOutlet UIButton *btnAddPic;

@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnDel;

@end

@implementation WOEditPicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tfDescription.inputAccessoryView = [self accessoryView];
    self.tfDescription.clearButtonMode = UITextFieldViewModeAlways;
    
    self.lbDescription.text = kSharedModel.lang[@"picDescription"];
    [BRStyleSheet styleLabel:self.lbDescription withType:BRLabelTypeName];
    
    // prepare image picker
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		imagePC = [[UIImagePickerController alloc] init];
		imagePC.delegate = self;
		imagePC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePC.allowsEditing = YES;
	}

    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:self.lang[@"actionBack"] 
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:@selector(navigationBack:)];
    self.navigationItem.leftBarButtonItem = btnBack;
    if(nil !=  self.recordToEdit){
        
        NSString* cacheNamePath = [Utils filePathInCaches:self.recordToEdit.uniqueKey withSuffix:nil];
        BOOL isFileExist =  [[NSFileManager defaultManager] fileExistsAtPath:cacheNamePath];
        if (isFileExist) {
            self.imvPIc.image  =  [Utils readCacheImage:cacheNamePath];
        } 
        self.tfDescription.text = self.recordToEdit.description;
        [self.btnAddPic setBackgroundImage:nil forState:UIControlStateNormal];
    	
        self.title = kSharedModel.lang[@"titleEditStorePic"];
    } else {
        self.btnDel.hidden = YES;
        self.title = kSharedModel.lang[@"titleAddStorePic"];
        

    }
}

-(IBAction)_showChoosePicActionSheet:(id)sender {
    
	UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:kSharedModel.lang[@"choosePIc"] delegate:self cancelButtonTitle:kSharedModel.lang[@"actionCancel"] destructiveButtonTitle:nil otherButtonTitles:kSharedModel.lang[@"takeFromCamera"] , kSharedModel.lang[@"takeFromLibrary"] , nil];
    
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[popupQuery showInView:self.tabBarController.view];
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
    self.imvPIc.image = pickedImage;
    
    if(nil != self.recordToEdit){
        self.recordToEdit.isPicModified = YES;
    }
    
    [self.btnAddPic setBackgroundImage:nil forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:^(){
  
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:^(){
        
    }];
}
-(IBAction)save:(id)sender {
    
    if(nil == self.imvPIc.image){
        
        [self showMsg:kSharedModel.lang[@"pleaseChoosePIc"] type:msgLevelWarn];
        return;
    }
    
    if(self.tfDescription.text.length == 0){
        
        [self showMsg:kSharedModel.lang[@"pleaseFillDescription"] type:msgLevelWarn];
        return;
    }
    if(nil !=  self.recordToEdit){
    //update or delete pic
        NSString* uniqueKeyOld = self.recordToEdit.uniqueKey;
        self.recordToEdit.description = self.tfDescription.text;
        
        if(self.recordToEdit.isPicModified){
            
            UIImage* pickedImage = self.imvPIc.image;
            PRPLog(@"pickedImage: %@ \
                   -[%@ , %@]",
                   pickedImage,
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));
            

            
            [self showHud:YES];
            __block __weak WOEditPicViewController* weakSelf =(WOEditPicViewController*) self;
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
                NSString* uniqueFileName = res[@"uniqueFileName"];  
                PRPLog(@"uniqueFileName: %@ \
                       -[%@ , %@]",
                       uniqueFileName,
                       NSStringFromClass([self class]),
                       NSStringFromSelector(_cmd));
                weakSelf.recordToEdit.uniqueKey = uniqueFileName;
                [weakSelf _updStorePic:uniqueFileName description:self.recordToEdit.description _id:self.recordToEdit._id];
                
            }];

        } else {
               [self _updStorePic:uniqueKeyOld description:self.recordToEdit.description _id:self.recordToEdit._id];
            
        }
        
    } else {
    // add new pic
        UIImage* pickedImage = self.imvPIc.image;
        PRPLog(@"pickedImage: %@ \
               -[%@ , %@]",
               pickedImage,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
        
        [self showHud:YES];
        __block __weak WOEditPicViewController* weakSelf =(WOEditPicViewController*) self;
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
            
            [self _postStorePic:uniqueFileName description:self.tfDescription.text fbId:kSharedModel.fbId];
        }];

    }
}

#pragma mark UIAlertViewDelegate 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if(alertView.tag == KAlertviewSureToDel){
        
        if([title isEqualToString:kSharedModel.lang[@"actionOK"]]){
            
            [self _delStorePic:self.recordToEdit._id];
            
        }
    } 
}
-(IBAction)_confirmToDel:(id)sender{
    
    UIAlertView* av = [[UIAlertView alloc] initWithTitle:kSharedModel.lang[@"warn"] 
                           message:kSharedModel.lang[@"areYouSureToDelete"] delegate:self cancelButtonTitle:kSharedModel.lang[@"actionOK"] otherButtonTitles:kSharedModel.lang[@"actionCancel"], nil];
    av.tag = KAlertviewSureToDel;
    [av show];
}

-(void)_postStorePic:(NSString*)uniqueKey
    description:(NSString*)description
    fbId:(NSString*)fbId
{
    __block __weak WOEditPicViewController* weakSelf = (WOEditPicViewController*)self;        
    [kSharedModel postStorePic:uniqueKey 
                    description:description 
                           fbId:fbId 
                      withBlock:^(NSDictionary* res) {
                          
                          NSString* error = res[@"error"];
                          if(nil != error){
                              
                              [weakSelf showMsg:error type:msgLevelError];
                              return;
                          }
                          weakSelf.complectionBlock(res[@"doc"]);

            }];
}
-(void)_updStorePic:(NSString*)uniqueKey
         description:(NSString*)description
                _id:(NSString*)_id
{
    __block __weak WOEditPicViewController* weakSelf = (WOEditPicViewController*)self;        
    [kSharedModel updStorePic:_id 
                    uniqueKey:uniqueKey 
                  description:description 
                    withBlock:^(NSDictionary* res) {
                         
                         NSString* error = res[@"error"];
                         if(nil != error){
                             
                             [weakSelf showMsg:error type:msgLevelError];
                             return;
                         }
                         weakSelf.complectionBlock(res[@"doc"]);
                     }];
}

-(void)_delStorePic:(NSString*)_id
{    
    NSString* uniqueKeyOld = self.recordToEdit.uniqueKey;
    __block __weak WOEditPicViewController* weakSelf = (WOEditPicViewController*)self;        
    [kSharedModel delAwsS3Img:uniqueKeyOld
                    withBlock:^(NSDictionary* resByDel) {
                        
        NSString* cacheNamePath = [Utils filePathInCaches:uniqueKeyOld withSuffix:nil];
        [[NSFileManager defaultManager] removeItemAtPath:cacheNamePath error:nil]; 
        
        [kSharedModel delStorePic:_id  
                        withBlock:^(NSDictionary* res) {
                            
                            NSString* error = res[@"error"];
                            if(nil != error){
                                
                                [weakSelf showMsg:error type:msgLevelError];
                                return;
                            }
                            weakSelf.complectionBlock(nil);
                        }];

    }];          
    
}



@end
