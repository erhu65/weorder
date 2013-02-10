
@class Item;

typedef void (^DetailViewControllerCompletionBlock)(BOOL success);

@interface DetailViewController : UIViewController

@property (nonatomic, copy) DetailViewControllerCompletionBlock completionBlock;
@property (nonatomic, strong) Item *itemToEdit;

@end
