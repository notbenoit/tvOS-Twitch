//
//  COLORAdController.h
//  COLORAdFramework
//
//  Created by Jordan Jasinski on 12.11.2015.
//  Copyright © 2015 Backflip Media Group Inc. All rights reserved.
//

@import UIKit;
@import JavaScriptCore;

#import <COLORAdFramework/COLORAdViewController.h>

#import <COLORAdFramework/COLORConstans.h>

@protocol COLORAdControllerJavaScript <JSExport>

+(instancetype _Null_unspecified)sharedAdController;

-(void)startWithAppIdentifier:(NSString* _Nonnull)appIdentifier;

-(void)prepareAdForPlacement:(NSString* _Nonnull)placement withCompletion:(JSValue* _Nonnull)completion andExpirationHandler:(JSValue* _Nonnull)expiration;

-(void)showLastAd;

-(void)setCurrentPlacement:(NSString* _Nonnull)placement;

-(void)registerThirdPartyUserId:(NSString* _Nonnull)userId withCompletionHandler:(JSValue* _Nonnull)completion;

-(JSValue* _Nonnull)userProfile;

@end

@protocol COLORAdControllerDelegate <NSObject>

@optional

-(void)didGetCurrency:(NSDictionary * _Null_unspecified)details;

@end

@interface COLORAdController : NSObject<COLORAdControllerJavaScript>

@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, assign) NSString* _Nonnull currentPlacement;

@property (nonatomic, weak) id<COLORAdControllerDelegate> _Nullable delegate;

-(void)monitorAdsForPlacements:(NSArray * _Nullable)placements;

-(BOOL)isAdReady;

-(COLORAdViewController * _Nullable)ad;

-(void)registerThirdPartyUserId:(NSString* _Nonnull)userId withCompletion:(COLORAdFrameworkRegisterThirdPartyUserIdCompletion _Nonnull)completion;

-(void)adViewControllerForPlacement:(NSString* _Nonnull)placement withCompletion:(COLORAdFrameworkAdRequestCompletion _Nonnull)completion __attribute__((deprecated("use adViewControllerForPlacement:withCompletion:expirationHandler: instead")));
-(void)adViewControllerForPlacement:(NSString* _Nonnull)placement withCompletion:(COLORAdFrameworkAdRequestCompletion _Nonnull)completion expirationHandler:(COLORAdFrameworkAdExpirationHandler _Nonnull)expirationHandler;

-(void)adViewControllerOfType:(COLORAdFrameworkAdType)type withCompletion:(COLORAdFrameworkAdRequestCompletion _Nonnull)completion __attribute__((deprecated("use adViewControllerOfType:withCompletion:expirationHandler: instead")));

-(void)adViewControllerOfType:(COLORAdFrameworkAdType)type withCompletion:(COLORAdFrameworkAdRequestCompletion _Nonnull)completion expirationHandler:(COLORAdFrameworkAdExpirationHandler _Nonnull)expirationHandler;

-(void)checkAvailableCurrencyAfterTimeInterval:(NSTimeInterval)timeInterval;

@end
