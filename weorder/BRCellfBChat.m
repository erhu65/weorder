//
//  BRCellVideo.m
//  BirthdayReminder
//
//  Created by Peter2 on 12/18/12.
//  Copyright (c) 2012 Nick Kuh. All rights reserved.
//

#import "BRCellfBChat.h"
#import "BRRecordFbChat.h"
#import "BRStyleSheet.h"
#import "UIImageView+RemoteFile.h"
#import "Utils.h"

@implementation BRCellfBChat

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setRecord:(BRRecordFbChat *)record{
    
    self.lbFbUserName.text =  record.fbName;
    self.lbFbUserMsg.text = record.msg;
    
    NSString *formattedDateString = [self.dateFormatter stringFromDate:record.created_at];
    self.lbChatDatetime.text = formattedDateString;
    self.lbVideoName.text = @"";
    
    if([record.type isEqualToString:@"server"]){

        self.imvThumb.image = [UIImage imageNamed:kSharedModel.theme[@"Icon-72"]];
    } else if (record.dataImg == nil) {
        if ([record.strImgUrl length] > 0) {
            [self.imvThumb setImageWithFbThumb:record.fbId placeHolderImage:[UIImage imageNamed:kSharedModel.theme[@"Icon-72"]]];
        }
        else self.imvThumb.image = [UIImage imageNamed:kSharedModel.theme[@"Icon-72"]];
    } else {
        self.imvThumb.image = [UIImage imageWithData:record.dataImg];
    }
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = nil;
    
    if([record.type isEqualToString:@"chat"]){
        
        if(![record.uniquDataKey isEqualToString:@""]){
             self.accessoryView = [self _makeDetailDisclosureButton:record.uniquDataKey];
        }
    }
    
    if(nil == _record 
       || _record != record){
        _record = record;
    }
}

- (UIButton *) _makeDetailDisclosureButton:(NSString*)uniqueDataKey
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 50, 50)];
    
    NSString* localPathDir =  [Utils filePathInDocument:uniqueDataKey withSuffix:nil];
    BOOL isLocalPathExists = [Utils chkDataPathLocalExist:localPathDir];
    if(isLocalPathExists){
        NSString* imgBg = [NSString stringWithFormat:@"%@/bg.png", localPathDir];
        UIImage* img = [[UIImage alloc] initWithContentsOfFile:imgBg];
        UIImage* imgThumb = [Utils imageWithImage:img scaledToSize:CGSizeMake(50.0f, 50.0f)];
        [button setImage:imgThumb forState:UIControlStateNormal];
    }
    
    [button addTarget: self
               action: @selector(_accessoryButtonTapped:withEvent:)
     forControlEvents: UIControlEventTouchUpInside];
    return (button);
}
- (void) _accessoryButtonTapped: (UIControl *) button withEvent: (UIEvent *) event
{
    if([self.deletate respondsToSelector:@selector(BRCellfBChatDelegateCellTapped:)] 
       && nil != self.record){
        [self.deletate BRCellfBChatDelegateCellTapped:self.record];
    }
//    [self.tb.delegate tableView: self.tb accessoryButtonTappedForRowWithIndexPath:self.indexPath];
}



-(void) setLbFbUserName:(UILabel *)lbFbUserName
{
    _lbFbUserName = lbFbUserName;
    if (_lbFbUserName) {
        [BRStyleSheet styleLabel:_lbFbUserName withType:BRLabelTypeDaysUntilBirthdaySubText];
    }
}

-(void) setLbFbUserMsg:(UILabel *)lbFbUserMsg
{
    _lbFbUserMsg = lbFbUserMsg;
    if (_lbFbUserMsg) {
        [BRStyleSheet styleLabel:_lbFbUserMsg withType:BRLabelTypeLarge];
    }
}


-(void) setLbChatDatetime:(UILabel *)lbChatDatetime
{
    _lbChatDatetime = lbChatDatetime;
    if (_lbChatDatetime) {
        [BRStyleSheet styleLabel:_lbChatDatetime withType:BRLabelTypeDaysUntilBirthdaySubText];
    }
}

-(void)setLbVideoName:(UILabel *)lbVideoName{

    _lbVideoName = lbVideoName;
    if (_lbVideoName) {
        [BRStyleSheet styleLabel:_lbVideoName withType:BRLabelTypeDaysUntilBirthdaySubText];
    }
}

@end
