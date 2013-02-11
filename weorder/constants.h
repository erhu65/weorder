//
//  constants.h
//  we tube
//
//  Created by Huang Peter on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


//


#if TARGET_IPHONE_SIMULATOR

#define BASE_URL          @"http://localhost:3000"

#else

#define BASE_URL          @"http://protected-harbor-4547.herokuapp.com"

#endif
//#define BASE_URL          @"http://localhost:3000"
//#define BASE_URL          @"http://radiant-hollows-7509.herokuapp.com"

#define AWS_S3_ACCESS_KEY_ID          @"AKIAJC63EYWOJ72VK7PA"
#define AWS_S3_SECRET_KEY             @"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"
#define AWS_S3_ZIP_BUCKET         @"wework-bucket"


#define BRNotificationInAppDidUpdate           @"BRNotificationInAppDidUpdate"

#define KUserDefaultFbId @"fbId"
#define KUserDefaultFbName @"fbName"
#define KUserDefaultToken @"token"

#define KUserDefaultNotice @"KUserDefaultNotice"
#define KUserDefaultLang @"KUserDefaultLang"


#define KFacebookKey @"161217940695125"//

#define KSyncImagesDone @"syncImagesDone"
#define KUploadDone @"uploadDone"
#define KUploadFail @"uploadFalil"
#define KNoticeComing @"KNoticeComing"
#define KNoticeId @"KNoticeId"
#define KPasswordComing @"KPasswordComing"

#define kPagerLimit  @"10"

#define kCustomRowHeight    60.0
#define kCustomRowCount     7

#define app_logo @"http://erhu65.phpfogapp.com/public/images/icon_tagsale_57.png"

#define kAppDelegate ((AppDelegate *) [[UIApplication sharedApplication] delegate])
#define kSharedModel ((BRDModel *) [BRDModel sharedInstance])

#define isiPhone ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPHONE			(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] 
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define BR_STYLE_COLOR [UIColor colorWithRed:87.0f/255.0f green:47.0f/255.0f blue:13.0f/255.0f alpha:0.5f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)
#define RESIZABLE(_VIEW_) [_VIEW_ setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth]

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

#define kSections      2
#define kSection1Rows  2
#define kSection2Rows  3

#define kPopoverWidth  320
#define kPopoverHeight 700

#define kSelectKey      @"selection"
#define kDescriptKey    @"description"
#define kControllerKey  @"viewController"
#define kCellIdentifier @"MasterViewCell"
#define kInset               10
#define kSelectLabelWidth    100
#define kDescriptLabelWidth  160
#define kSelectLabelTag      1
#define kDescriptLabelTag    2

#define kMasterViewWidth 320 
#define kStatusBarHeight 20 
#define kMasterViewWidth 320 
#define kStatusBarHeight 20 

#define kAirportViewHeight 420
#define kToolbarHeight     44
#define kLeftMargin        16
#define kSegControlHeight  30
#define kImageSize         190
#define kImageIndent       6

#define kState  @"LastState.state"
#define kUseStoredDataPreference @"useStoredDataPreference"

#define kTableMarginiPad       300
#define kTableMarginiPhone    100


#define KMainPart1 1
#define KMainPart2 2
#define KMainPart3 3
#define KMainPart4 4

#define KMovesRangeModeByDay 8001
#define KMovesRangeModeByWeek 8002
#define KMovesRangeModeByMonth 8003

#define KImgTypeInCellNo1 9881
#define KImgTypeInCellNo2 9882

#define KUserPassword  @"password"
#define KUserTheme  @"theme"
#define KUserLang  @"lang"
#define KUserCurrency  @"currency"
#define KUserCurrency_str  @"currency_str"
#define KUserFbId @"fbId"
#define KUserSyncType @"syncType"
#define KUserSyncTypeAuto @"syncTypeAuto"
#define KUserSyncTypeManual @"syncTypeManual"

#define KMobileUDID @"UDID"


#define k_api_key @"CodeGOAIWeb"


#define k_bottomY_heigher    387.0
#define k_bottomY_lower    433.0



typedef enum regenerate_barcode_type {
    regenerate_barcode_type_manual = 9001,
    regenerate_barcode_type_scan = 9002
} regenerate_barcode_type;


typedef enum btnKind {
    k_btn_back = 2001,
    k_yes = 2002,
    k_no = 2003,
    k_btn_addCard = 2004,
    k_btn_EditCard = 2005
    
} btnKind;


typedef enum mainBtnKind {
    k_btn_discount_brand_recreation = 1001,
    k_btn_discount_brand_foot = 1002,
    k_btn_discount_brand_spa = 1003,
    k_btn_my_code = 1004,
    k_btn_vip = 1005,
    k_btn_instruction = 1006 
    
} mainBtnKind;


typedef enum tabKind {
    tabKindMainCategoryAll = 0,
    tabKindMainCategoryFavorite = 1,
    tabKindVideoFavorite = 2,
    tabKindSetting = 3,    
} tabKind;

typedef enum tabKindImg {
    k_tabImg_main = 30010,
    k_tabImg_bonus = 30020,
    k_tabImg_my_code = 30030,
    k_tabImg_vip = 30040,
    k_tabImg_Instruction = 30050,
    
} tabKindImg;


typedef enum titleType {
    k_title_memberLogin = 4001,   
    k_title_forgetPasswd = 4002, 
    k_title_memberRegister = 4003,
    k_title_bonusExchange = 4004,
    k_title_bonusExchangeDetail = 40041,
    k_title_myCodeList = 4005,
    k_title_myCodeDetailRefundConsent = 4006,
    k_title_myCodeDetailRefundConfirm = 4007,
    k_title_myCodeDetailTransferConsent = 4008,
    k_title_myCodeDetailTransferConfirm = 4009,
    k_title_myCodeSetting = 4010,
    k_title_myCodeSettingChange = 40101,
    k_title_myCodeSettingNotice = 40102,
    k_title_myCodeSettingAbout = 40103,
    k_title_vip = 4011,
    k_title_vip_member_card_scan = 4012,
    k_title_shoppingCard = 4013,
} titleType;

#define k_segue_tabViewController @"tabViewController"

#define k_segue_fbShare @"fbShare"
 

#define k_segue_discountBrand @"discountBrand"
#define k_segue_discount @"discount"
#define k_segue_brand @"brand"
#define k_segue_itemDetail @"itemDetail"
#define k_segue_storeItems @"storeItems"
#define k_segue_storeDetails @"storeDetails"
#define k_segue_storeBranch @"storeBranch"
#define k_segue_storeMap @"storeMap"
#define k_segue_shoppingCard @"shoppingCard"
#define k_segue_memberLogin @"memberlogin"
#define k_segue_forgetPasswd @"forgetPasswd"
#define k_segue_memberRegister @"memberRegister"
#define k_segue_bonusExchange @"bonusExchange"
#define k_segue_bonusExchangeDetail @"bonusExchangeDetail"
#define k_segue_myCodeList @"myCodeList"
#define k_segue_myCodeDetail @"myCodeDetail"
#define k_segue_QRCode @"QRCode"
#define k_segue_myCodeDetailRefundConsent @"myCodeDetailRefundConsent"
#define k_segue_myCodeDetailRefundConfirm @"myCodeDetailRefundConfirm"
#define k_segue_myCodeDetailTransferConsent @"myCodeDetailTransferConsent"
#define k_segue_myCodeDetailTransferConfirm @"myCodeDetailTransferConfirm"

#define k_segue_myCodeSetting @"myCodeSetting"
#define k_segue_myCodeSettingChange @"myCodeSettingChange"
#define k_segue_myCodeSettingNotice @"myCodeSettingNotice"
#define k_segue_myCodeSettingAbout @"myCodeSettingAbout"

#define k_segue_vip @"vip"
#define k_segue_vipDetail @"vipDetail"
#define k_segue_vipMemberCard @"vipMemberCard"
#define k_segue_vipMemberCardEdit @"vipMemberCardEdit"

#define k_segue_vipMemberCardEditByManual1 @"vipMemberCardEditByManual1"
#define k_segue_vipMemberCardEditByManual2 @"vipMemberCardEditByManual2"
#define k_segue_vipMemberCardEditByScan @"vipMemberCardEditByScan"
#define k_segue_vipExclusiveDiscount @"vipExclusiveDiscount"

#define k_info @"訊息"
#define k_warning @"警告"
//何服器異常
#define k_network_connection_problem @"網路連線緩慢，請稍後再試"
#define k_network_connection_problem2 @"網路連線問題"


#define ShowNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = NO

typedef enum testType {
    k_testType_noNeedLogin = 1,
    k_testType_needLogin_doCache = 2,
    k_testType_needLogin_noDoCache_for_testing_user_timeout = 3,
} testType;
#define testType 1
