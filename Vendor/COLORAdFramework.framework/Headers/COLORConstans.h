//
//  RPLTConstans.h
//  COLORAdFramework
//
//  Created by Jordan Jasinski on 16/12/15.
//  Copyright © 2015 Backflip Media Group Inc. All rights reserved.
//

@import Foundation;

#import <COLORAdFramework/COLORAdFrameworkLogger.h>
#import <COLORAdFramework/COLORUserProfile.h>

#pragma mark Notifications
extern NSString * _Nonnull const COLORAdFrameworkNotificationDidGetCurrency;

#pragma mark General
extern NSString * _Nonnull const COLORAdFrameworkName;
extern NSString * _Nonnull const COLORAdFrameworkVersion;
extern NSString * _Nonnull const COLORAdFrameworkApiBaseURL;
extern NSString * _Nonnull const COLORAdFrameworkBundleIdentifier;
extern NSString * _Nonnull const COLORAdFrameworkApiBaseURL;


#pragma mark App Placement
extern NSString * _Nonnull const COLORAdFrameworkPlacementAppLaunch;
extern NSString * _Nonnull const COLORAdFrameworkPlacementAppResume;
extern NSString * _Nonnull const COLORAdFrameworkPlacementAppClose;
extern NSString * _Nonnull const COLORAdFrameworkPlacementMainMenu;
extern NSString * _Nonnull const COLORAdFrameworkPlacementPause;
extern NSString * _Nonnull const COLORAdFrameworkPlacementStageOpen;
extern NSString * _Nonnull const COLORAdFrameworkPlacementStageComplete;
extern NSString * _Nonnull const COLORAdFrameworkPlacementStageFailed;
extern NSString * _Nonnull const COLORAdFrameworkPlacementLevelUp;
extern NSString * _Nonnull const COLORAdFrameworkPlacementBetweenLevels;
extern NSString * _Nonnull const COLORAdFrameworkPlacementStoreOpen;
extern NSString * _Nonnull const COLORAdFrameworkPlacementInAppPurchase;
extern NSString * _Nonnull const COLORAdFrameworkPlacementInAppPurchaseAbandoned;
extern NSString * _Nonnull const COLORAdFrameworkPlacementVirtualGoodPurchase;
extern NSString * _Nonnull const COLORAdFrameworkPlacementUserHighScore;
extern NSString * _Nonnull const COLORAdFrameworkPlacementOutOfGoods;
extern NSString * _Nonnull const COLORAdFrameworkPlacementOutOfEnergy;
extern NSString * _Nonnull const COLORAdFrameworkPlacementInsufficientCurrency;
extern NSString * _Nonnull const COLORAdFrameworkPlacementFinishedTutorial;

#pragma mark User Preferences
extern NSString * _Nonnull const COLORAdFrameworkPreferencesEmailAddress;
extern NSString * _Nonnull const COLORAdFrameworkPreferencesPhoneNumber;

#pragma handlers
@class COLORAdViewController;
typedef void(^COLORAdFrameworkAdRequestCompletion)(COLORAdViewController * _Nullable vc, NSError * _Nullable error);
typedef void(^COLORAdFrameworkRegisterThirdPartyUserIdCompletion)(NSError * _Nullable error);

#pragma types
typedef NS_ENUM(NSUInteger, COLORAdFrameworkAdType) {
    COLORAdFrameworkAdTypeAny = 0,
    COLORAdFrameworkAdTypeAppWall = 1,
    COLORAdFrameworkAdTypeAppGrid = 2,
    COLORAdFrameworkAdTypeAppSingle = 3,
    COLORAdFrameworkAdTypeVideo = 4,
    COLORAdFrameworkAdTypeFeaturedItem = 5,
    COLORAdFrameworkAdTypeFullscreen = 6,
    COLORAdFrameworkAdTypeVideoRecommendation = 7
};

