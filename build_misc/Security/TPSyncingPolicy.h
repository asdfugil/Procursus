#import <Foundation/Foundation.h>

@class NSString, TPPolicyVersion, NSArray, NSSet;

@interface TPSyncingPolicy : NSObject <NSSecureCoding> {

	BOOL _isInheritedAccount;
	int _syncUserControllableViews;
	NSString* _model;
	TPPolicyVersion* _version;
	NSArray* _keyViewMapping;
	NSSet* _viewList;
	NSSet* _priorityViews;
	NSSet* _viewsToPiggybackTLKs;
	NSSet* _userControllableViews;
}
@property (readonly) NSString * model;                           //@synthesize model=_model - In the implementation block
@property (readonly) TPPolicyVersion * version;                  //@synthesize version=_version - In the implementation block
@property (readonly) NSArray * keyViewMapping;                   //@synthesize keyViewMapping=_keyViewMapping - In the implementation block
@property (readonly) NSSet * viewList;                           //@synthesize viewList=_viewList - In the implementation block
@property (readonly) NSSet * priorityViews;                      //@synthesize priorityViews=_priorityViews - In the implementation block
@property (readonly) NSSet * viewsToPiggybackTLKs;               //@synthesize viewsToPiggybackTLKs=_viewsToPiggybackTLKs - In the implementation block
@property (readonly) NSSet * userControllableViews;              //@synthesize userControllableViews=_userControllableViews - In the implementation block
@property (assign) BOOL isInheritedAccount;                      //@synthesize isInheritedAccount=_isInheritedAccount - In the implementation block
@property (readonly) int syncUserControllableViews;              //@synthesize syncUserControllableViews=_syncUserControllableViews - In the implementation block
+(BOOL)supportsSecureCoding;
-(void)encodeWithCoder:(id)arg1 ;
-(NSArray *)keyViewMapping;
-(TPPolicyVersion *)version;
-(NSSet *)viewList;
-(NSSet *)userControllableViews;
-(id)description;
-(id)initWithModel:(id)arg1 version:(id)arg2 viewList:(id)arg3 priorityViews:(id)arg4 userControllableViews:(id)arg5 syncUserControllableViews:(int)arg6 viewsToPiggybackTLKs:(id)arg7 keyViewMapping:(id)arg8 isInheritedAccount:(BOOL)arg9 ;
-(NSSet *)viewsToPiggybackTLKs;
-(NSString *)model;
-(void)setIsInheritedAccount:(BOOL)arg1 ;
-(BOOL)isInheritedAccount;
-(int)syncUserControllableViews;
-(id)initWithCoder:(id)arg1 ;
-(BOOL)syncUserControllableViewsAsBoolean;
-(BOOL)isSyncingEnabledForView:(id)arg1 ;
-(id)mapDictionaryToView:(id)arg1 ;
-(NSSet *)priorityViews;
@end
