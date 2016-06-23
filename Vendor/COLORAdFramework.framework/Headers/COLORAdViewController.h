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

@interface COLORAdViewController : UIViewController

@property (nonatomic, weak) COLORAdServerAPI * _Nullable api;
@property (nonatomic, copy) void (^_Nullable adCompleted)();

-(void)closeAd;

@end
