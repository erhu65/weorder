
#import "BRCoreViewController.h"

@interface BRFBFriendListViewController : BRCoreViewController
@property(nonatomic, strong)NSString* myRoomId;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *importButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//Keeps track of selected rows
@property (nonatomic, strong) NSMutableDictionary *selectedIndexPathToBirthday;

@end