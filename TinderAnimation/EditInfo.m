//
//  EditInfo.m
//  TinderEditPhotos
//
//  Created by Gagandeep Kaur  on 19/09/15.
//  Copyright (c) 2015 Gagandeep Kaur . All rights reserved.
//

#import "EditInfo.h"

@interface EditInfo ()<buttonPressDelegate>

@end
#define LX_LIMITED_MOVEMENT 0

@implementation EditInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performSelectorInBackground:@selector(saveFilesInDocDirectory) withObject:nil];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        [myAlertView show];
    }
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startPaning:)];
    [self.collectionView addGestureRecognizer:longPress];
    longPress.cancelsTouchesInView = NO;
    
    LXReorderableCollectionViewFlowLayout *layout = [[LXReorderableCollectionViewFlowLayout alloc] init];
    [self.collectionView setCollectionViewLayout:layout];
//    [layout setUpGestureRecognizersOnCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void) viewWillDisappear:(BOOL)animated{
    
    NSError *error = nil;
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_myDirectory error:&error]) {
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", _myDirectory, file] error:&error];
        if (!success || error) {
            // it failed.
        }
    }
    
//    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_myDirectory error:NULL];
//    _arrCollectionView = [[NSMutableArray alloc] initWithArray:directoryContent];
    NSLog(@"%@",_arrCollectionView);
    
    for (int i = 0; i<_arrCollectionView.count; i++) {
        NSString *path = [_myDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[_arrCollectionView objectAtIndex:i]]];
        NSString *newPath = [_myDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",i]];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
        [self saveImageAtPath:newPath ImageData:data];
    }
}

- (void) saveFilesInDocDirectory{
    
    _paths = [[NSArray alloc] init];
    _paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _myDirectory = [[_paths objectAtIndex:0] stringByAppendingPathComponent:@"tinderImages"];
    NSError *error;
    
    //create directory if doesn't exist already
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_myDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:_myDirectory withIntermediateDirectories:NO attributes:nil error:&error];

     NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_myDirectory error:NULL];
    
    _arrCollectionView = [[NSMutableArray alloc] initWithArray:directoryContent];
    NSLog(@"%@",_arrCollectionView);
    
//    NSError *error;
//    [[NSFileManager defaultManager]removeItemAtPath:_myDirectory error:&error];

    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
   [_collectionView reloadData];
}

#pragma mark - collection view delegates and data sources

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return 6;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    
    cell.indexpath = indexPath;
    cell.delegate = self;
    cell.btnClose.layer.cornerRadius = cell.btnClose.frame.size.height/2;
    cell.btnClose.clipsToBounds = YES;
    
    if (indexPath.row >= _arrCollectionView.count) {
        
        cell.imgView.image = [UIImage imageNamed:@"placeholder"];

    }
    else{
    
        NSString *filePath = [_myDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[_arrCollectionView objectAtIndex:indexPath.row]]];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
        cell.imgView.image = [UIImage imageWithData:data];
    }
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    CollectionCell * cell = (CollectionCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    _selectedCellIndex = indexPath;
    NSData *data1 = UIImagePNGRepresentation(cell.imgView.image);
    NSData *data2 = UIImagePNGRepresentation([UIImage imageNamed:@"placeholder"]);
    if ([data1 isEqual:data2]) {
        UIActionSheet *actionSheetAddImage = [[UIActionSheet alloc]
                                      initWithTitle:nil delegate:self
                                      cancelButtonTitle:@"cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Choose Image",@"Take Image", nil];
        actionSheetAddImage.tag = 0;
        [actionSheetAddImage showInView:self.view];
    }
}


#pragma mark - Document directory functions
                             
-(void)saveImageAtPath:(NSString *)path ImageData:(NSData *)data
{
    NSData *file = data;
    [[NSFileManager defaultManager] createFileAtPath:path
                                            contents:file
                                          attributes:nil];
}
                             
-(NSData *)retrieveImageFromPath:(NSString *)path
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSData *file1 = [[NSData alloc] initWithContentsOfFile:path];
        if (file1)
        {
            return file1;
        }
    }
    else
    {
        NSLog(@"File does not exist");
         NSData *data2 = UIImagePNGRepresentation([UIImage imageNamed:@"placeholder"]);
        return data2;
    }
    return nil;
}


#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *file = [NSData dataWithData:UIImagePNGRepresentation(image)];
    
    NSString *path;
    path = [_myDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",(long)_selectedCellIndex.row]];
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    [self saveImageAtPath:path ImageData:file];
    
    CollectionCell *cell = (CollectionCell*)[self.collectionView cellForItemAtIndexPath:_selectedCellIndex];
    cell.imgView.image = image;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - cell custom delegates

- (void) closeButtonPressed:(NSIndexPath *)indexPath{
    
    _selectedCellIndex = indexPath;
    CollectionCell * cell = (CollectionCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    NSData *data1 = UIImagePNGRepresentation(cell.imgView.image);
    NSData *data2 = UIImagePNGRepresentation([UIImage imageNamed:@"placeholder"]);
    if (![data1 isEqual:data2]) {
        if (indexPath.row == 0) {
            UIActionSheet *actionSheetProfilePic = [[UIActionSheet alloc]
                                                    initWithTitle:nil delegate:self
                                                    cancelButtonTitle:@"cancel"
                                                    destructiveButtonTitle:@"Delete"
                                                    otherButtonTitles:nil];
            actionSheetProfilePic.tag = 1;
            [actionSheetProfilePic showInView:self.view];
        }
        else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil delegate:self
                                          cancelButtonTitle:@"cancel"
                                          destructiveButtonTitle:@"Delete"
                                          otherButtonTitles:@"Make Profile Pic", nil];
            actionSheet.tag = 2;
            [actionSheet showInView:self.view];
        }
    }
}

#pragma mark - action sheet delegates

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag == 0) {
        
        if (buttonIndex ==0) {
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController:picker animated:YES completion:NULL];
            
        }
        
        else if (buttonIndex ==1){
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
    }
    else{
        CollectionCell *cell = (CollectionCell*)[self.collectionView cellForItemAtIndexPath:_selectedCellIndex];
        CollectionCell *profileCell = (CollectionCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        if (buttonIndex == 0) {
            NSString *path;
            path = [_myDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",(long)_selectedCellIndex.row]];
            cell.imgView.image = [UIImage imageNamed:@"placeholder"];
            NSError *error;
            [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
        }
        
        if(buttonIndex == 1){

            UIImage *imgTemp = profileCell.imgView.image;
            NSString *strTemp = [_arrCollectionView objectAtIndex:0];
            
            profileCell.imgView.image = cell.imgView.image;
            cell.imgView.image = imgTemp;
            
            [_arrCollectionView replaceObjectAtIndex:0 withObject:[_arrCollectionView objectAtIndex:_selectedCellIndex.row]];
            [_arrCollectionView replaceObjectAtIndex:_selectedCellIndex.row withObject:strTemp];
        }
    }
}


#pragma mark - button actions

- (IBAction)actionBtnDone:(id)sender {
    
    
    NSString *filePath = [_myDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[_arrCollectionView objectAtIndex:0]]];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
    UIImage *img = [UIImage imageWithData:data];
    
    [self.delegate newData:img];
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


#pragma mark long press gesture recogniser 

- (void)startPaning : (UILongPressGestureRecognizer *)longPress {
    
    CGPoint locationPoint = [longPress locationInView:self.collectionView];
//    CollectionCell *cellProfile = (CollectionCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        
        _startingPoint = [longPress locationInView:self.collectionView];
        _indexPathMovingCell = [self.collectionView indexPathForItemAtPoint:_startingPoint];
//        CollectionCell *cellBegin = (CollectionCell*)[self.collectionView cellForItemAtIndexPath:_indexPathMovingCell];
//        
//        UIGraphicsBeginImageContext(cellBegin.bounds.size);
//        [cellBegin.layer renderInContext:UIGraphicsGetCurrentContext()];
//        UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        [cellBegin setHidden:YES];
//        self.movingCell = [[UIImageView alloc] initWithImage:cellImage];
//        [self popCell:0.1 :self.movingCell];
//        [self.movingCell setCenter:locationPoint];
//        [self.collectionView addSubview:self.movingCell];
        
    }
    
    if (longPress.state == UIGestureRecognizerStateChanged) {
        [self.movingCell setCenter:locationPoint];
        _indexPathInBetween = [self.collectionView indexPathForItemAtPoint:locationPoint];
//        CollectionCell *cellTemp = (CollectionCell*)[self.collectionView cellForItemAtIndexPath:_indexPathInBetween];
    }
    
    if (longPress.state == UIGestureRecognizerStateEnded) {
//        _endingPoint = [longPress locationInView:self.collectionView];
//        CollectionCell *cellBegin = (CollectionCell*)[self.collectionView cellForItemAtIndexPath:_indexPathMovingCell];
//        [cellBegin setHidden:NO];
//        [self.movingCell removeFromSuperview];
//        CGPoint endingPoint = [longPress locationInView:self.collectionView];
//        _indexPathWhereCellStopped = [self.collectionView indexPathForItemAtPoint:endingPoint];
//        NSLog(@"%@",_indexPathWhereCellStopped);
//        _indexPathMovingCell = [self.collectionView indexPathForItemAtPoint:_startingPoint];
//        NSString *strTemp = [_arrCollectionView objectAtIndex:_indexPathMovingCell.row];
//        
////        CGRect profileRect = cellProfile.frame;
////        if (CGRectContainsPoint(profileRect, locationPoint)) {
//        
//            [_arrCollectionView insertObject:strTemp atIndex:_indexPathWhereCellStopped.row];
//            [_arrCollectionView removeObjectAtIndex:_indexPathMovingCell.row+1];
//            [_collectionView reloadData];
//            NSLog(@"%@",_arrCollectionView);
//        }
    }
}

#pragma mark - animations

- (void) popCell:(float)secs : (UIImageView*)image{
    
    image.transform = CGAffineTransformMakeScale(1.4, 1.4);
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        image.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        image.transform = CGAffineTransformMakeScale(1, 1);
    }];}


#pragma mark - LXReorderableCollectionViewDelegateFlowLayout methods

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"will begin drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did begin drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"will end drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did end drag");
}


#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    NSString *strTemp = [_arrCollectionView objectAtIndex:fromIndexPath.item];
    
    [self.arrCollectionView removeObjectAtIndex:fromIndexPath.item];
    [self.arrCollectionView insertObject:strTemp atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
//    PlayingCard *playingCard = self.deck[indexPath.item];
//    
//    switch (playingCard.suit) {
//        case PlayingCardSuitSpade:
//        case PlayingCardSuitClub: {
//            return YES;
//        } break;
//        default: {
//            return NO;
//        } break;
//    }
//#else
    return YES;
//#endif
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
//#if LX_LIMITED_MOVEMENT == 1
//    PlayingCard *fromPlayingCard = self.deck[fromIndexPath.item];
//    PlayingCard *toPlayingCard = self.deck[toIndexPath.item];
//    
//    switch (toPlayingCard.suit) {
//        case PlayingCardSuitSpade:
//        case PlayingCardSuitClub: {
//            return fromPlayingCard.rank == toPlayingCard.rank;
//        } break;
//        default: {
//            return NO;
//        } break;
//    }
//#else
    return YES;
//#endif
}

@end
