//
//  RPLTAdControllerLogger.h
//  RPLTAdFramework
//
//  Created by Jordan Jasinski on 22/12/15.
//  Copyright © 2015 Replay inc. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSInteger, COLORAdFrameworkDebugLevel) {
    COLORAdFrameworkDebugLevelInfo = 4,
    COLORAdFrameworkDebugLevelNotice = 3,
    COLORAdFrameworkDebugLevelWarning = 2,
    COLORAdFrameworkDebugLevelError = 1
};

@interface COLORAdFrameworkLogger : NSObject

+(void)setDebugLevel:(COLORAdFrameworkDebugLevel)level;

+(void)logInfoWithFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(1, 2);

+(void)logNoticeWithFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(1, 2);

+(void)logWarningWithFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(1, 2);

+(void)logErrorWithFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(1, 2);

@end
