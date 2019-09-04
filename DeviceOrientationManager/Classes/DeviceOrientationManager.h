
#import <Foundation/Foundation.h>

/**
 屏幕旋转申请

 - VerticalSupportOnly: 竖屏
 - CrossSupportOnly: 横屏
 - TreeDirectionSupport: 可以旋转
 */
typedef NS_OPTIONS(NSUInteger, ScreenDirectionSupport) {
    VerticalSupportOnly = 1 << 0,
    CrossSupportOnly = 1 << 1,
    TreeDirectionSupport = 1 << 2,
};

/**
 旋转代理
 */
@protocol DeviceOrientationDelegate<NSObject>

/**
 更新屏幕旋转状态
 */
-(void) UpdateViewsWithOrientation:(UIDeviceOrientation)dorientation;

@end

/**
 屏幕旋转管理
 */
@interface DeviceOrientationManager : NSObject

@property(nonatomic, weak) id<DeviceOrientationDelegate> delegate;

    
/**
 需要 -(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
 根据该状态返回不同的屏幕支持
 */
@property (nonatomic, assign, readonly) ScreenDirectionSupport currentScreenSupport;
    
/**
 单例
 */
+(instancetype) shareInstance;
  
/**
 恢复屏幕支持方向
 */
-(void) recoveryDeviceSupport;

/**
 重置屏幕支持方向，竖屏
 */
-(void) resetDeviceSupport;
 
/**
 备份屏幕支持方向
 */
-(void) backupDeviceSupport;
 
/**
 强制旋转成竖屏
 */
-(void) onlyPortraitSupport;
 
/**
 强制旋转成横屏
 */
-(void) onlyLandscapeSupport;
 
/**
 强制支持旋转
 */
-(void) threeOrientationSupport;

/**
 强制禁止旋转屏，可能是竖屏，也可能是横屏
 */
-(void) forbitOrientationSupport;

/**
 返回是否为横屏
 */
-(BOOL) isLandscape;
  
/**
 把屏幕强制转化成当前方向，前提是必须支持此种旋转
 */
-(void) updateOrientation;

@end
