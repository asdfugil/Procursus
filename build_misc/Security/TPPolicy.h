#import <Foundation/Foundation.h>
#include <TrustedPeers/TPPolicyVersion.h>

NS_ASSUME_NONNULL_BEGIN

@interface TPPolicy : NSObject <NSSecureCoding> {

	BOOL _unknownRedactions;
	TPPolicyVersion* _version;
	NSArray* _modelToCategory;
	NSDictionary* _categoriesByView;
	NSDictionary* _introducersByCategory;
	NSArray* _keyViewMapping;
	NSSet* _userControllableViewList;
	NSSet* _piggybackViews;
	NSSet* _priorityViews;
	NSSet* _inheritedExcludedViews;
}
@property (nonatomic,retain) TPPolicyVersion * version;                         //@synthesize version=_version - In the implementation block
@property (nonatomic,retain) NSArray * modelToCategory;                         //@synthesize modelToCategory=_modelToCategory - In the implementation block
@property (nonatomic,retain) NSDictionary * categoriesByView;                   //@synthesize categoriesByView=_categoriesByView - In the implementation block
@property (nonatomic,retain) NSDictionary * introducersByCategory;              //@synthesize introducersByCategory=_introducersByCategory - In the implementation block
@property (nonatomic,retain) NSArray * keyViewMapping;                          //@synthesize keyViewMapping=_keyViewMapping - In the implementation block
@property (nonatomic,retain) NSSet * userControllableViewList;                  //@synthesize userControllableViewList=_userControllableViewList - In the implementation block
@property (nonatomic,retain) NSSet * piggybackViews;                            //@synthesize piggybackViews=_piggybackViews - In the implementation block
@property (nonatomic,retain) NSSet * priorityViews;                             //@synthesize priorityViews=_priorityViews - In the implementation block
@property (nonatomic,retain) NSSet * inheritedExcludedViews;                    //@synthesize inheritedExcludedViews=_inheritedExcludedViews - In the implementation block
@property (assign) BOOL unknownRedactions;                                      //@synthesize unknownRedactions=_unknownRedactions - In the implementation block
+(BOOL)supportsSecureCoding;
+(id)policyWithModelToCategory:(id)arg1 categoriesByView:(id)arg2 introducersByCategory:(id)arg3 keyViewMapping:(id)arg4 unknownRedactions:(BOOL)arg5 userControllableViewList:(id)arg6 piggybackViews:(id)arg7 priorityViews:(id)arg8 inheritedExcludedViews:(id)arg9 version:(id)arg10 ;
-(void)setPiggybackViews:(NSSet *)arg1 ;
-(void)setKeyViewMapping:(NSArray *)arg1 ;
-(void)encodeWithCoder:(id)arg1 ;
-(NSArray *)keyViewMapping;
-(NSSet *)piggybackViews;
-(NSDictionary *)categoriesByView;
-(TPPolicyVersion *)version;
-(void)setPriorityViews:(NSSet *)arg1 ;
-(id)viewsForModel:(id)arg1 error:(id*)arg2 ;
-(void)setModelToCategory:(NSArray *)arg1 ;
-(void)setVersion:(TPPolicyVersion *)arg1 ;
-(id)description;
-(id)syncingPolicyForModel:(id)arg1 syncUserControllableViews:(int)arg2 isInheritedAccount:(BOOL)arg3 error:(id*)arg4 ;
-(BOOL)isEqualToPolicy:(id)arg1 ;
-(void)setIntroducersByCategory:(NSDictionary *)arg1 ;
-(BOOL)unknownRedactions;
-(void)setUnknownRedactions:(BOOL)arg1 ;
-(void)setInheritedExcludedViews:(NSSet *)arg1 ;
-(BOOL)isEqual:(id)arg1 ;
-(id)initWithCoder:(id)arg1 ;
-(void)setUserControllableViewList:(NSSet *)arg1 ;
-(void)setCategoriesByView:(NSDictionary *)arg1 ;
-(NSDictionary *)introducersByCategory;
-(NSSet *)inheritedExcludedViews;
-(id)categoryForModel:(id)arg1 ;
-(BOOL)peerInCategory:(id)arg1 canAccessView:(id)arg2 ;
-(NSSet *)userControllableViewList;
-(NSArray *)modelToCategory;
-(NSSet *)priorityViews;
-(BOOL)trustedPeerInCategory:(id)arg1 canIntroduceCategory:(id)arg2 ;
@end

NS_ASSUME_NONNULL_END
