//
//  ViewController.m
//  双击放大和长按操作
//
//  Created by Kenfor-YF on 16/5/9.
//  Copyright © 2016年 Kenfor-YF. All rights reserved.
//

#import "ViewController.h"
#define XMWidth [UIScreen mainScreen].bounds.size.width
#define XMHeight [UIScreen mainScreen].bounds.size.height
#define Duration 0.2
@interface ViewController ()<UIGestureRecognizerDelegate>
@property(nonatomic,weak)UIScrollView *srollView;
@property(nonatomic,assign)BOOL funScreen;
@property(nonatomic,assign)CGRect oldRect;
@property(nonatomic,strong)UIButton *selectedBtn;
@property(nonatomic,strong)UIView *lastView;
@property(nonatomic,assign)CGPoint startPoint;
@property(nonatomic,assign)CGPoint originPoint;
@property(nonatomic,assign)BOOL contain;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setScrollView];
    [self addDisplayView];
    [self onTapOnce:5];
    _funScreen = NO;
}
-(void)setScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 20, XMWidth, 319)];
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.layer.borderColor = [UIColor greenColor].CGColor;
    scrollView.layer.borderWidth = 1;
    scrollView.bounces = NO;
    [self.view addSubview:scrollView];
    self.srollView = scrollView;
}

-(void)addDisplayView
{
    CGFloat width = (XMWidth - 3)/2;
    CGFloat height = (319 - 1)/2;

    for (int i=0; i<4; i++) {
        UIView *view = [[UIView alloc]init];
        view.frame = CGRectMake((i%2)*(1+width)+1, (i/2)*(1+width)+1, width, height);
        view.layer.borderColor = [UIColor whiteColor].CGColor;
        view.backgroundColor = [UIColor blackColor];
        view.layer.borderWidth = 1;
        view.tag = i;
        view.userInteractionEnabled = YES;
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
        addBtn.frame = CGRectMake(0, 0, 30, 30);
        addBtn.tintColor = [UIColor grayColor];
        addBtn.tag = i;
        if (i == 0) {
            addBtn.tag = 5;
            view.tag = 5;
        }
        addBtn.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
        [addBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:addBtn];
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap1:)];
        [view addGestureRecognizer:tap1];
        tap1.numberOfTapsRequired = 1;
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap2:)];
        [view addGestureRecognizer:tap2];
        tap2.delegate = self;
        tap2.numberOfTapsRequired = 2;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
        [view addGestureRecognizer:longPress];
        [tap1 requireGestureRecognizerToFail:longPress];
        [self.srollView addSubview:view];
    }
}
-(void)drawPlayView:(CGRect)rect byTag:(int)tag
{
    UIView *playView = [self.view viewWithTag:tag];
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    addBtn.frame = CGRectMake(0, 0, 30, 30);
    addBtn.tintColor = [UIColor grayColor];
    addBtn.center = CGPointMake(rect.size.width/2, rect.size.height/2);
    [playView addSubview:addBtn];
}
-(void)tap1:(UIGestureRecognizer *)gesture
{
    int num = (int)gesture.view.tag;
    [self onTapOnce:num];
}
-(void)onTapOnce:(int)num
{
    //改变选中框的颜色和状态.
    self.selectedBtn.tintColor = [UIColor whiteColor];
    self.lastView.layer.borderColor = [UIColor whiteColor].CGColor;
    UIView *view = [self.view viewWithTag:num];
    self.selectedBtn = view.subviews[0];
    self.lastView = view;
    self.selectedBtn.tintColor = [UIColor greenColor];
    view.layer.borderColor = [UIColor greenColor].CGColor;
    [view reloadInputViews];
}
-(void)tap2:(UIGestureRecognizer *)gesture
{
    UIView *playView = gesture.view;
    CGFloat width = XMWidth - 2;
    CGFloat height = 317;
    if (!self.funScreen) {//非全屏状态,双击放大.
        self.srollView.contentOffset = CGPointZero;
        
        _funScreen = YES;
        _oldRect = playView.frame;
        playView.frame = CGRectMake(1,1,width,height);
        //放在父控件的最前面
        self.selectedBtn.center = CGPointMake(playView.frame.size.width/2, playView.frame.size.height/2);
        
        [self.srollView bringSubviewToFront:playView];
    }else{//全屏状态.双击缩小
        self.srollView.contentSize = CGSizeZero;
        self.srollView.contentOffset = CGPointZero;
        playView.frame = self.oldRect;
        self.selectedBtn.center = CGPointMake(playView.frame.size.width/2, playView.frame.size.height/2);
        _funScreen = NO;
        //放在父控件的最后面
        [self.srollView sendSubviewToBack:playView];
    }
}
-(void)longPressAction:(UILongPressGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    //长按开始
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _startPoint = [gesture locationInView:gesture.view];
        _originPoint = view.center;
        [UIView animateWithDuration:Duration animations:^{
            view.transform = CGAffineTransformMakeScale(0.9, 0.9);
            view.alpha = 0.7;
        }];
    }
    //正在拖动
    else if (gesture.state == UIGestureRecognizerStateChanged){
        CGPoint newPoint = [gesture locationInView:gesture.view];
        CGFloat detalX = newPoint.x - self.startPoint.x;
        CGFloat detalY = newPoint.y - self.startPoint.y;
        view.center = CGPointMake(view.center.x + detalX, view.center.y + detalY);
        NSInteger index = [self getPoint:view.center withView:view];
        if (index<0) {//没有移动过
            _contain = NO;
        }else{
            [UIView animateWithDuration:Duration animations:^{
                CGPoint temp = CGPointZero;
                UIView *playView = [self.view viewWithTag:index];
                temp = playView.center;
                view.center = temp;
                playView.center = self.originPoint;
                self.originPoint = view.center;
                _contain = YES;
            }];
        }
    }
    //结束拖动
    else if (gesture.state == UIGestureRecognizerStateEnded){
        [UIView animateWithDuration:Duration animations:^{
            //恢复原来的样子.
            view.transform = CGAffineTransformIdentity;
            view.alpha = 1.0;
            if (!self.contain) {
                view.center = self.originPoint;
            }
        }];
    }
}
-(NSInteger)getPoint:(CGPoint)point withView:(UIView *)view
{
    for (int i=0; i<4; i++) {
        UIView *playView;
        if (i == 0) {
           playView = [self.view viewWithTag:5];
        }else{
           playView = [self.view viewWithTag:(int)i];
        }
        if (view != playView) {
            if (CGRectContainsPoint(playView.frame, point)) {
                if (i == 0) {
                    i = 5;
                }
                return i;
            }
        }
    }
    return -1;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}
-(void)btnClick:(UIButton *)button
{
    [self onTapOnce:(int)button.tag];
    //执行点击事件和其它操作
}
















@end
