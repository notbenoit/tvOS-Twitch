//
//  COLORAdController.h
//  COLORAdFramework
//
//  Created by Jordan Jasinski on 12.11.2015.
//  Copyright © 2015 Backflip Media Group Inc. All rights reserved.
//

@import UIKit;

#import <COLORAdFramework/COLORAdViewController.h>

#import <COLORAdFramework/COLORConstans.h>

@protocol COLORAdControllerDelegate <NSObject>

@optional

-(void)didGetCurrency:(NSDictionary * _Null_unspecified)details;

@end

@interface COLORAdController : NSObject

@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, assign) NSString* _Nonnull currentPlacement;

@property (nonatomic, weak) id<COLORAdControllerDelegate> _Nullable delegate;

+(instancetype _Null_unspecified)sharedAdController;

-(void)startWithAppIdentifier:(NSString* _Nonnull)appIdentifier;

-(void)registerThirdPartyUserId:(NSString* _Nonnull)userId withCompletion:(COLORAdFrameworkRegisterThirdPartyUserIdCompletion _Nonnull)completion;

-(void)adViewControllerForPlacement:(NSString* _Nonnull)placenemt withCompletion:(COLORAdFrameworkAdRequestCompletion _Nonnull)completion;
-(void)adViewControllerOfType:(COLORAdFrameworkAdType)type withCompletion:(COLORAdFrameworkAdRequestCompletion _Nonnull)completion;

-(void)checkAvailableCurrencyAfterTimeInterval:(NSTimeInterval)timeInterval;

@end
