//
//  DBinding.m
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/12/4.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import "DBinding.h"
#import "DData.h"
#import "DMacro.h"
#import "DModuleCenter.h"

@interface BindingDelegate : NSObject
@property (nonatomic,weak) id object;
@property (nonatomic) SEL selector;
@property (nonatomic) int threadId;
@property (nonatomic) BOOL waitUntilDone;
- (BOOL)isEqualToDelegate:(BindingDelegate *)aDelegate;
- (BOOL)onChange:(id)aObject change:(NSDictionary*)change;
@end

/************************* BindingDelegate **************************/

@implementation BindingDelegate

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.threadId = KBingdingThreadWhatever;
        self.waitUntilDone = NO;
    }
    return self;
}

- (BOOL)isEqual:(id)anObject
{
    if(anObject == self)
        return YES;
    if(!anObject || ![anObject isKindOfClass:[self class]])
        return NO;
    
    return [self isEqualToDelegate:anObject];
}

- (BOOL)isEqualToDelegate:(BindingDelegate *)aDelegate
{
    if(!aDelegate)
        return NO;
    
    if( aDelegate == self || (aDelegate.object == self.object && aDelegate.selector == self.selector))
    {
        return YES;
    }
    
    return NO;
}

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

- (BOOL)onChange:(id)aObject change:(NSDictionary *)change
{
    __strong id strongObject = self.object;
    if(strongObject == nil)
        return NO;
    
    SuppressPerformSelectorLeakWarning(
         [[DThreadBus sharedInstance] callsafe:^{
        [strongObject performSelector:self.selector withObject:[change objectForKey:NSKeyValueChangeNewKey]];
    } inThread:self.threadId]);
    return YES;
}

@end

@interface BindingDelegateChanges : BindingDelegate
- (BOOL)onChange:(id)aObject change:(NSDictionary *)change;
@end

@implementation BindingDelegateChanges
- (BOOL)onChange:(id)aObject change:(NSDictionary *)change
{
    __strong id strongObject = self.object;
    if(strongObject == nil)
        return NO;
    
    SuppressPerformSelectorLeakWarning(
       [[DThreadBus sharedInstance] callsafe:^{
        [strongObject performSelector:self.selector withObject:change];
    } inThread:self.threadId];);
    return YES;
}
@end


@interface DBindingCenter : NSObject
{
    NSLock *_lock;
}
@property NSMutableDictionary *bindingDic;
+ (DBindingCenter*)dbc;
@end

@implementation DBindingCenter

- (instancetype)init
{
    if(self = [super init])
    {
        self.bindingDic = [[NSMutableDictionary alloc] init];
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (void)lock
{
    [_lock lock];
}

- (void)unlock
{
    [_lock unlock];
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)aObject change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context
{
    NSValue *key = [NSValue valueWithNonretainedObject:aObject];
    NSMutableDictionary* bindingDic = self.bindingDic;
    [self lock];
    NSMutableDictionary* objectBindingMap = [bindingDic objectForKey:key];
    [self unlock];
    if(objectBindingMap == nil)
    {
        assert(false);
        return;
    }
    [self lock];
    NSMutableArray* bindings = [objectBindingMap objectForKey:keyPath];
    [self unlock];
    
    if(bindings)
    {
        NSArray* toDispatchs = [[NSArray alloc] initWithArray:bindings];
        if(toDispatchs)
        {
            for(BindingDelegate* delegate in toDispatchs)
            {
                [delegate onChange:aObject change:change];
                //support weak reference
                if(delegate.object == nil)
                {
                    [self lock];
                    [bindings removeObject:delegate];
                    [self unlock];
                }
            }
        }
    }
    
    if(bindings.count == 0)
    {
        // remove observer
        @try {
            [aObject removeObserver:[DBindingCenter dbc] forKeyPath:keyPath context:NULL];
        } @catch (NSException *exception) {
        } @finally {
        }
    }
}

+ (DBindingCenter*)dbc
{
    static DBindingCenter* gdbc = nil;
    if(gdbc == nil)
    {
        gdbc = [[DBindingCenter alloc] init];
    }
    return gdbc;
}

@end


@implementation DBinding
+ (void)addBingdingX:(NSObject *)aObject
          forKeyPath:(NSString *)keyPath
             options:(NSKeyValueObservingOptions)options
            toTarget:(NSObject *)target
               onSel:(SEL)aSelector
{
    [self addBingdingX:aObject forKeyPath:keyPath options:options toTarget:target onSel:aSelector inThread:KBingdingThreadWhatever untilDone:NO];
}

+ (void)addBingdingX:(NSObject *)aObject forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options toTarget:(NSObject *)target onSel:(SEL)aSelector inThread:(int)thread untilDone:(BOOL)done
{
    NSValue *key = [NSValue valueWithNonretainedObject:aObject];
    [[DBindingCenter dbc] lock];
    NSMutableDictionary *bindingDic = [DBindingCenter dbc].bindingDic;
    NSMutableDictionary *objectBindingMap = [bindingDic objectForKey:key];
    if(objectBindingMap == nil)
    {
        objectBindingMap = [[NSMutableDictionary alloc] init];
        [bindingDic setObject:objectBindingMap forKey:key];
    }
    [[DBindingCenter dbc] unlock];
    
    [[DBindingCenter dbc] lock];
    NSMutableArray *bindings = [objectBindingMap objectForKey:keyPath];
    if(bindings == nil)
    {
        bindings = [[NSMutableArray alloc] init];
        [objectBindingMap setObject:bindings forKey:keyPath];
    }
    [[DBindingCenter dbc] unlock];
    
    
}









@end
