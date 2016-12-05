//
//  DBinding.h
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/12/4.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DThreadBus.h"

//Thread Invoke Id
const static int KBingdingThreadWhatever = ThreadWhatEver;
const static int KBingdingThreadMain = ThreadMain;
const static int KBingdingThreadBackground = ThreadBack;

//Not Thread Safe
//Support weak reference

@interface DBinding : NSObject

+ (void)addBingdingX:(NSObject*)aObject forKeyPath:(NSString*)keyPath options:(NSKeyValueObservingOptions)options toTarget:(NSObject*)target onSel:(SEL)sel;

+ (void)addBingdingX:(NSObject*)aObject forKeyPath:(NSString*)keyPath options:(NSKeyValueObservingOptions)options toTarget:(NSObject*)target onSel:(SEL)sel inThread:(int)thread untilDone:(BOOL)done;

+ (void)addBinding:(int)src forKeyPath:(NSString*)keyPath options:(NSKeyValueObservingOptions)options toTarget:(NSObject*)target onSel:(SEL)sel;
+ (void)addBinding:(int)src forKeyPath:(NSString*)keyPath toTarget:(NSObject*)target onSel:(SEL)sel;

+ (void)addArrayBindingX:(NSObject*)src forKeyPath:(NSString*)keyPath options:(NSKeyValueObservingOptions)options toTarget:(NSObject*)target onSel:(SEL)sel;
+ (void)addArrayBindingX:(NSObject*)aObject forKeyPath:(NSString*)keyPath options:(NSKeyValueObservingOptions)options toTarget:(NSObject*)aTarget onSel:(SEL)aSelector inThread:(int)thread untilDone:(BOOL)done;

+ (void)addArrayBinding:(int)src forKeyPath:(NSString*)keyPath options:(NSKeyValueObservingOptions)options toTarget:(NSObject*)target onSel:(SEL)sel;

+ (void)addArrayBinding:(int)src forKeyPath:(NSString*)keyPath toTarget:(NSObject*)target onSel:(SEL)sel;



+ (void)removeBinding:(int)src forKeyPath:(NSString*)keyPath toTarget:(NSObject*)target onSel:(SEL)sel;
+ (void)removeBindingX:(NSObject*)aObject forKeyPath:(NSString*)keyPath toTarget:(NSObject*)target onSel:(SEL)sel;

+ (void)clearBindingX:(NSObject*)aObject forKeyPath:(NSString*)keyPath;
+ (void)clearBinding:(int)src forKeyPath:(NSString*)keyPath;

+ (void)clearBindingX:(NSObject*)aObject;

@end

// auto remove all dbindings
@interface DKvoSource : NSObject

@end


//not thread safe
@interface KvoBinder : NSObject
@property(weak) id target;

- (BOOL)singleBindTo:(NSObject*)source withName:(NSString*)name forKeyPaths:(NSArray*)keys onSels:(SEL*)sels;
- (BOOL)singleBindTo:(NSObject*)source withName:(NSString*)name forKeyPaths:(NSArray*)keys onSels:(SEL*)sels inOptions:(NSKeyValueObservingOptions)options;
- (void)clearKvoConnection:(NSString*)name;
- (void)clearAllKvoConnection;

@end



