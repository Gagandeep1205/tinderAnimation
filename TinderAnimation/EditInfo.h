//
//  EditInfo.h
//  TinderEditPhotos
//
//  Created by Gagandeep Kaur  on 19/09/15.
//  Copyright (c) 2015 Gagandeep Kaur . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionCell.h"
//#import "CustomLayout.h"
#import "LXReorderableCollectionViewFlowLayout.h"

@protocol changeProfilePic <NSObject>

@required

- (void) newData : (UIImage *)image;

@end

@interface EditInfo : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate,
        UICollectionViewDelegateFlowLayout, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (nonatomic, weak) id<changeProfilePic> delegate;
//@property (weak, nonatomic) IBOutlet CustomLayout *customLayout;
@property UIImage *profileImage;
@property UIImageView *movingCell;
@property NSMutableArray *arrCollectionView;
@property NSArray *paths;
@property NSIndexPath *selectedCellIndex;
@property NSIndexPath *indexPathMovingCell;
@property NSIndexPath *indexPathInBetween;
@property NSIndexPath *indexPathWhereCellStopped;
@property NSString *myDirectory;
@property CGPoint startingPoint;
@property CGPoint endingPoint;

- (IBAction)actionBtnDone:(id)sender;

@end
