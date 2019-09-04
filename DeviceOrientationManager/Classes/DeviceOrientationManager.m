
#import "DeviceOrientationManager.h"

@interface DeviceOrientationManager()
@property(nonatomic, assign) BOOL hasBackUp;
@property(nonatomic, assign) BOOL forbitOrientation;
@property(nonatomic, assign) UIDeviceOrientation lastOrientation;
//禁止旋转时的方向
@property(nonatomic, assign) UIDeviceOrientation backupForbitOrientation;
@property(nonatomic, assign) ScreenDirectionSupport backupDirectionSupport;
@property(nonatomic, assign) UIDeviceOrientation backupOrientation;
@end

@implementation DeviceOrientationManager

+(instancetype) shareInstance
{
    static DeviceOrientationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DeviceOrientationManager alloc] init];
        
        [manager registerForNotifications];
    });
    
    return manager;
}

-(void) dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//恢复屏幕支持方向
-(void) recoveryDeviceSupport
{
    if(!self.hasBackUp)
        return;
    
    self.hasBackUp = NO;
    _currentScreenSupport = self.backupDirectionSupport;
    
    if(self.backupOrientation != 0){
        //变换为竖屏
        NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:self.backupOrientation];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        
        self.backupOrientation = 0;
    }
    
}

//把屏幕强制转化成当前方向
-(void) updateOrientation
{
    if(self.lastOrientation != 0){
        //变换为竖屏
        NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:self.lastOrientation];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    }
}


-(void) backupDeviceSupport{
    self.hasBackUp = YES;
    self.backupDirectionSupport = _currentScreenSupport;
    self.backupOrientation = self.lastOrientation;
    [self onlyPortraitSupport];
}

//重置屏幕支持方向，竖屏
-(void) resetDeviceSupport
{
    [self onlyPortraitSupport];
    self.forbitOrientation = NO;
    self.hasBackUp = NO;
    self.delegate = nil;
    self.backupDirectionSupport = VerticalSupportOnly;
}

//返回是否为横屏
-(BOOL) isLandscape
{
    if(self.lastOrientation == UIDeviceOrientationLandscapeRight || self.lastOrientation == UIDeviceOrientationLandscapeLeft){
        return YES;
    }
    
    return NO;
}

//强制禁止旋转屏，可能是竖屏，也可能是横屏
-(void) forbitOrientationSupport
{
    self.forbitOrientation = YES;
    self.backupForbitOrientation = self.lastOrientation;
    
    //恢复成只支持竖屏
    if(self.lastOrientation == UIDeviceOrientationLandscapeRight || self.lastOrientation == UIInterfaceOrientationLandscapeRight){
        _currentScreenSupport = CrossSupportOnly;
    }
    else{
        _currentScreenSupport = VerticalSupportOnly;
    }
}

-(void) onlyPortraitSupport
{
    //变换为竖屏
    NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
    
    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    
    //恢复成只支持竖屏
    _currentScreenSupport = VerticalSupportOnly;
}

-(void) onlyLandscapeSupport
{
    //强制旋转成横屏
    NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
    
    if(self.lastOrientation == UIDeviceOrientationLandscapeRight){
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    }
    else{
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    }
    
    //恢复成只支持竖屏
    _currentScreenSupport = CrossSupportOnly;
}

-(void) threeOrientationSupport
{
    //恢复成只支持竖屏
    _currentScreenSupport = TreeDirectionSupport;
    //禁止旋转放开时，旋转一下屏幕
    if(self.forbitOrientation)
    {
        self.forbitOrientation = NO;
//        NSNumber *orientationTarget = [NSNumber numberWithInt:self.backupForbitOrientation];
//        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        
        [self updateOrientation];
    }

    /*
    
    if(self.lastOrientation == UIDeviceOrientationLandscapeRight){
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    }
    else if(self.lastOrientation == UIDeviceOrientationLandscapeLeft){
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    }
    else{
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    }

     */
}


//响应设备方向转换事件
- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIDeviceOrientation dorientation = [[UIDevice currentDevice] orientation];
    
//    DLog(@"屏幕方向监听 === 方向为 = %ld",(long)dorientation);
    if (dorientation == UIDeviceOrientationPortrait || dorientation == UIDeviceOrientationLandscapeLeft || dorientation == UIDeviceOrientationLandscapeRight)
    {
//        if (self.lastOrientation != dorientation)
        {
            self.lastOrientation = dorientation;
            [self UpdateViewsWithOrientation:dorientation];
        }
    }
}


//注册设置方向转换事件
- (void)registerForNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(deviceOrientationDidChange:)
               name:UIDeviceOrientationDidChangeNotification object:nil];
    
    //这句话很重要，没有这句会有bug
    NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
    
    UIDeviceOrientation dorientation = [[UIDevice currentDevice] orientation];
    if (dorientation == UIDeviceOrientationPortrait || dorientation == UIDeviceOrientationLandscapeLeft || dorientation == UIDeviceOrientationLandscapeRight)
    {
        self.lastOrientation = dorientation;
    }
    else{
        self.lastOrientation = UIDeviceOrientationPortrait;
    }
    
    [self UpdateViewsWithOrientation:dorientation];
}

//根据设备方向对视图做相应调整,现在有这个类
-(void) UpdateViewsWithOrientation:(UIDeviceOrientation)dorientation
{
    if(self.forbitOrientation)
        return;
    
    [self.delegate UpdateViewsWithOrientation:dorientation];
}

@end
