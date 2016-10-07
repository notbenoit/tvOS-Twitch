//
//  RPLTAdViewController.h
//  RPLTAdFramework
//
//  Created by Jordan Jasinski on 15/12/15.
//  Copyright © 2015 Replay Inc. All rights reserved.
//

@import UIKit;

typedef void(^COLORPreloadedAdViewControllerCompletion)(NSError * _Nullable error);

@protocol COLORPreloadedAdViewController <NSObject>

-(void)preloadAdElementsWithCompletion:(COLORPreloadedAdViewControllerCompletion _Nonnull)completion;

@end

@class COLORAdItem;
@class COLORAdServerAPI;

typedef void(^COLORAdViewControllerDidCompleteAd)(BOOL watched);

@interface COLORAdViewController : UIViewController

@property (nonatomic, weak) COLORAdServerAPI * _Nullable api;
@property (nonatomic, copy) COLORAdViewControllerDidCompleteAd _Nullable adCompleted __attribute__((deprecated("use addCompletionHandler: instead")));

@property (nonatomic, readonly) BOOL expired;

-(void)closeAd:(BOOL)watched;

//-(void)addCompletionHandler:(void (^ _Nonnull)(BOOL watched))completion;
-(void)addCompletionHandler:(COLORAdViewControllerDidCompleteAd _Nonnull)completion;

@end
