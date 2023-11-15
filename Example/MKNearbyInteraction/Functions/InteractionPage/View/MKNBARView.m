//
//  MKNBARView.m
//  MKNearbyInteraction_Example
//
//  Created by aa on 2023/11/13.
//  Copyright © 2023 lovexiaoxia. All rights reserved.
//

#import "MKNBARView.h"

#import <ARKit/ARKit.h>
#import <RealityKit/RealityKit.h>

#import "Masonry.h"

#import "MKMacroDefines.h"

@interface MKNBARView ()<ARSessionDelegate>

// The AR Session to be shared with all devices, to enable camera assistance
@property (nonatomic, strong)ARSCNView *arView;
@property (nonatomic, strong)ARWorldTrackingConfiguration *arConfig;
@property (nonatomic, strong)ARAnchor *anchor;
@property (nonatomic, strong)SCNSphere *pinShape;
@property (nonatomic, strong)SCNMaterial *material;
@property (nonatomic, strong)ARSession *arSession;
@property (nonatomic, strong)SCNNode *modelNode;
@property (nonatomic, strong)SCNScene *scene;

@end

@implementation MKNBARView

- (void)dealloc {
    NSLog(@"MKNBARView销毁");
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.arView];
    }
    return self;
}

#pragma mark - super method
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.arView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

#pragma mark - ARSessionDelegate
- (BOOL)sessionShouldAttemptRelocalization:(ARSession *)session {
    return NO;
}

#pragma mark - public method
- (ARSession *)arSession {
    return self.arView.session;
}

- (void)createARObject {
    // Add modelNode as a child node of the anchor
    self.arView.scene = [SCNScene scene];
    [self.arView.scene.rootNode addChildNode:self.modelNode];
}

- (void)updateMatrix:(SCNMatrix4)matrix {
    self.modelNode.transform = matrix;
}

- (void)start {
    [self.arView.session runWithConfiguration:self.arConfig];
}

- (void)pause {
    [self.arView.session pause];
}

#pragma mark - getter
- (ARSCNView *)arView {
    if (!_arView) {
        _arView = [[ARSCNView alloc] init];
        _arView.session = [[ARSession alloc] init];
        _arView.session.delegate = self;
        [_arView.session addAnchor:self.anchor];
        [_arView.scene.rootNode addChildNode:self.modelNode];
    }
    return _arView;
}

- (ARWorldTrackingConfiguration *)arConfig {
    if (!_arConfig) {
        _arConfig = [[ARWorldTrackingConfiguration alloc] init];
        _arConfig.worldAlignment = ARWorldAlignmentGravity;
        _arConfig.collaborationEnabled = NO;
        _arConfig.userFaceTrackingEnabled = NO;
        _arConfig.initialWorldMap = nil;
    }
    return _arConfig;
}

- (ARAnchor *)anchor {
    if (!_anchor) {
        _anchor = [[ARAnchor alloc] initWithTransform:matrix_identity_float4x4];
    }
    return _anchor;
}

- (SCNSphere *)pinShape {
    if (!_pinShape) {
        _pinShape = [SCNSphere sphereWithRadius:0.03];
    }
    return _pinShape;
}

- (SCNMaterial *)material {
    if (!_material) {
        _material = [SCNMaterial material];
        _material.diffuse.contents = [UIColor yellowColor];
        _material.metalness.contents = @NO;
        _material.roughness.contents = @0.2; // 光滑度设置为 0.5
    }
    return _material;
}

- (SCNNode *)modelNode {
    if (!_modelNode) {
        _modelNode = [SCNNode nodeWithGeometry:self.pinShape];
        _modelNode.geometry.firstMaterial = self.material;
        _modelNode.position = SCNVector3Make(0, 0, 100);
        //        _modelNode.scale = SCNVector3Make(0.1, 0.1, 0.1); // 调整缩放比例
//        _modelNode.light = [SCNLight light];
//        _modelNode.light.type = SCNLightTypeOmni; // 或者 SCNLightTypeDirectional
//        _modelNode.light.color = [UIColor darkGrayColor];
    }
    return _modelNode;
}

- (SCNScene *)scene {
    if (!_scene) {
        _scene = [SCNScene sceneNamed:@"3d_arrow.usdz"];
        _scene.rootNode.light = [SCNLight new];
        _scene.rootNode.light.type = SCNLightTypeAmbient;
        _scene.rootNode.light.color = [UIColor darkGrayColor];
    }
    return _scene;
}

@end
