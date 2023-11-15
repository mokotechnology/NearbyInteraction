//
//  MKNBSceneView.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/13.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "MKNBSceneView.h"

#import <SceneKit/SceneKit.h>

#import "Masonry.h"

#import "MKMacroDefines.h"

@interface MKNBSceneView ()

@property (nonatomic, assign)BOOL arrowEnabled;

@property (nonatomic, strong)SCNView *sceneView;

@property (nonatomic, strong)SCNScene *scene;

// Auxiliary variables to handle the 3D arrow
@property (nonatomic, assign)NSInteger curAzimuth;

@property (nonatomic, assign)NSInteger curElevation;

@property (nonatomic, assign)NSInteger curSpin;

@end

@implementation MKNBSceneView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _arrowEnabled = YES;
        [self addSubview:self.sceneView];
        [self initArrowPosition];
        [self switchArrowImgView];
    }
    return self;
}

#pragma mark - super method
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.sceneView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

// MARK: - Arrow methods
- (void)switchArrowImgView {
    if (self.arrowEnabled) {
        self.sceneView.autoenablesDefaultLighting = YES;
        self.scene.rootNode.light.color = [UIColor darkGrayColor];
    }
    else {
        self.sceneView.autoenablesDefaultLighting = NO;
        self.scene.rootNode.light.color = [UIColor blackColor];
    }
}

- (void)initArrowPosition {
    CGFloat degree = 1.0 * M_PI / 180.0;
    
    self.scene.rootNode.eulerAngles = SCNVector3Make(-90 * degree, 0, 0);
    
    self.curAzimuth = 0;
    self.curElevation = 0;
    self.curSpin = 0;
}

- (void)setArrowAngleWithNewElevation:(NSInteger)newElevation newAzimuth:(NSInteger)newAzimuth {
    CGFloat oneDegree = 1.0 * M_PI / 180.0;
    NSInteger deltaX, deltaY, deltaZ;
    
    if (self.arrowEnabled) {
        deltaX = newElevation - self.curElevation;
        deltaY = newAzimuth - self.curAzimuth;
        deltaZ = 0 - self.curSpin;
        
        self.curElevation = newElevation;
        self.curAzimuth = newAzimuth;
        self.curSpin = 0;
    } else {
        deltaX = 90 - self.curElevation;
        deltaY = 0 - self.curAzimuth;
        deltaZ = newAzimuth - self.curSpin;
        
        self.curElevation = 90;
        self.curAzimuth = 0;
        self.curSpin = newAzimuth;
    }
    
    self.scene.rootNode.eulerAngles = SCNVector3Make(self.scene.rootNode.eulerAngles.x + deltaX * oneDegree,
                                                     self.scene.rootNode.eulerAngles.y - deltaY * oneDegree,
                                                     self.scene.rootNode.eulerAngles.z - deltaZ * oneDegree);
}

#pragma mark - getter
- (SCNScene *)scene {
    if (!_scene) {
        _scene = [SCNScene sceneNamed:@"3d_arrow.usdz"];
        _scene.rootNode.light = [SCNLight new];
        _scene.rootNode.light.type = SCNLightTypeAmbient;
        _scene.rootNode.light.color = [UIColor darkGrayColor];
    }
    return _scene;
}

- (SCNView *)sceneView {
    if (!_sceneView) {
        _sceneView = [[SCNView alloc] init];
        _sceneView.autoenablesDefaultLighting = YES;
        _sceneView.allowsCameraControl = NO;
        _sceneView.backgroundColor = [UIColor whiteColor];
        _sceneView.scene = self.scene;
    }
    return _sceneView;
}

@end
