//
//  DProtocol.h
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/12/5.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDef.h"
#import "NetDelegate.h"
#import <MapKit/MapKit.h>


/****************** GagaProtocol convenience macro ********************/
typedef void(^GagaNetTimeOutBlock)(GagaProtocol *proto);
typedef void(^GagaNetRespondBlock)(GagaProtocol *proto);

/****************** app protocol ********************/
@protocol AppProtocol <NSObject>
@required
- (void)quit;
- (void)checkAppStateWithCompletionBlock:(GagaNetRespondBlock)respond andTimeOutBlock:(GagaNetTimeOutBlock)timeOut;
@end

/******************* net module protocol *************************/
@protocol NetProtocol <NSObject>
@required
- (void)sendProto:(GagaProtocol*)proto;
- (void)dispatchProto:(GagaProtocol*)proto;

@end



/************************* d module protocol ***************************/
@interface DProtocol : NSObject

@end
