//
//  ViewController.m
//  iOS录音和wav转amr
//
//  Created by uplooking on 16/7/14.
//  Copyright © 2016年 MHKJ_TQY. All rights reserved.
//  测试修改

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VoiceConverter.h"


#define wav_record_path       @"wav_record"       //wav录音文件保存的文件名
#define amrTOwav_record_path  @"amrTOwav_record"  //amr转wav文件名
#define wavTOamr_record_path  @"wavTOamr_record"  //wav转amr文件名

@interface ViewController ()
{
    NSString *wavStr; //苹果录制wav文件路径
    NSString *wav_amr; //要保存的amr文件路径
    NSString *amr_wav; //amr转到wav的保存路径
}
/** 录音器 */
@property (nonatomic,strong) AVAudioRecorder   *    recorder;
/** 播放器 */
@property (nonatomic,strong) AVAudioPlayer     *    player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化 按钮控件
    [self initControl];
    //初始化 录音器和播放器
    [self initAVAudio];
    
    
/*******************************************************************************/
    //1、进入程序后点击  开始录音 -> 结束录音 -> 播放录音 -> wav转amr -> amr转wav -> 屏幕下方打印frame = 时 证明amr转wav 成功 -> 点击amr转wav播放 -> 成功播放声音 (点击播放录音按钮 也播放声音)
    //2、在 xcode -> window -> Devices 然后左侧自己的手机 -> 安装的这个程序 -> 最下角的设置按钮 -> Download container -> 然后右键显示包内容 -> AppData -> Documents下 能看到3个文件 可以amr文件发送到Android手机上 能正常播放
/*******************************************************************************/
    
}
//初始化 录音器和播放器
- (void)initAVAudio
{
    //初始化播放器
    self.player = [[AVAudioPlayer alloc]init];
    
    //初始化录音
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    
    //设置文件名和录音路径
    wavStr = [self getPathByFileName:wav_record_path ofType:@"wav"];
    //amrStr = [self getPathByFileName:@"amr_record" ofType:@"amr"];
    NSURL *url = [NSURL fileURLWithPath:wavStr];
    _recorder = [[AVAudioRecorder alloc]initWithURL:url settings:[self getAudioRecorderSettingDict] error:NULL];
    
    // 准备
    [_recorder prepareToRecord];
}
//初始化按钮控件
- (void)initControl
{
    //录音开始
    UIButton * startRecord = [[UIButton alloc] initWithFrame:CGRectMake(50, 100, 100, 50)];
    [startRecord setTitle:@"开始录音" forState:UIControlStateNormal];
    startRecord.backgroundColor = [UIColor redColor];
    [self.view addSubview:startRecord];
    [startRecord addTarget:self action:@selector(startRecordClick) forControlEvents:UIControlEventTouchUpInside];
    //录音结束
    UIButton * stopRecord = [[UIButton alloc] initWithFrame:CGRectMake(200, 100, 100, 50)];
    stopRecord.backgroundColor = [UIColor redColor];
    [stopRecord setTitle:@"停止录音" forState:UIControlStateNormal];
    [self.view addSubview:stopRecord];
    [stopRecord addTarget:self action:@selector(stopRecordClick) forControlEvents:UIControlEventTouchUpInside];
    
    //播放
    UIButton * playRecord = [[UIButton alloc] initWithFrame:CGRectMake(50, 200, 100, 50)];
    playRecord.backgroundColor = [UIColor redColor];
    [playRecord setTitle:@"播放录音" forState:UIControlStateNormal];
    [self.view addSubview:playRecord];
    [playRecord addTarget:self action:@selector(playRecordClick) forControlEvents:UIControlEventTouchUpInside];
    
    //wav转amr
    UIButton * wavRecord = [[UIButton alloc] initWithFrame:CGRectMake(50, 300, 100, 50)];
    wavRecord.backgroundColor = [UIColor redColor];
    [wavRecord setTitle:@"wav转amr" forState:UIControlStateNormal];
    [self.view addSubview:wavRecord];
    [wavRecord addTarget:self action:@selector(wavRecordClick) forControlEvents:UIControlEventTouchUpInside];
    
    //amr转wav
    UIButton * amrRecord = [[UIButton alloc] initWithFrame:CGRectMake(200, 300, 100, 50)];
    amrRecord.backgroundColor = [UIColor redColor];
    [amrRecord setTitle:@"amr转wav" forState:UIControlStateNormal];
    [self.view addSubview:amrRecord];
    [amrRecord addTarget:self action:@selector(amrRecordClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    //播放amr转wav的录音
    UIButton * amrTOwavRecord = [[UIButton alloc] initWithFrame:CGRectMake(200, 400, 120, 50)];
    amrTOwavRecord.backgroundColor = [UIColor redColor];
    [amrTOwavRecord setTitle:@"amr转wav播放" forState:UIControlStateNormal];
    [self.view addSubview:amrTOwavRecord];
    [amrTOwavRecord addTarget:self action:@selector(amrTOwavRecordClick) forControlEvents:UIControlEventTouchUpInside];
    
}
// 开始录音
- (void)startRecordClick
{
    [_recorder record];
}
// 停止录音
- (void)stopRecordClick
{
    [_recorder stop];
}
//播放声音
- (void)playRecordClick
{
    _player = [_player initWithContentsOfURL:[NSURL URLWithString:wavStr] error:nil];
    [_player play];
    

}
//wav 转 amr 点击事件
- (void)wavRecordClick
{
    //amr文件保存路径
    amr_wav = [self getPathByFileName:amrTOwav_record_path ofType:@"amr"];
    //wav转amr
    [VoiceConverter ConvertWavToAmr:wavStr amrSavePath:amr_wav];
}
//amr 转 wav 点击事件
- (void)amrRecordClick
{
    //wav文件保存路径
    wav_amr = [self getPathByFileName:wavTOamr_record_path ofType:@"wav"];
    //amr 转 wav
    [VoiceConverter ConvertAmrToWav:amr_wav wavSavePath:wav_amr];
}
//amr 转 wav 播放
- (void)amrTOwavRecordClick
{
    _player = [_player initWithContentsOfURL:[NSURL URLWithString:wav_amr] error:nil];
    [_player play];
}

/**
	生成文件路径
	@param _fileName 文件名
	@param _type 文件类型
	@returns 文件路径
 */
- (NSString *)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type
{
    NSString* fileDirectory = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:_fileName]stringByAppendingPathExtension:_type];
    return fileDirectory;
}

/**
	获取录音设置
	@returns 录音设置
 */
- (NSDictionary *)getAudioRecorderSettingDict
{
    // 录音设置的字典
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                   nil];
    
    
    
    return recordSetting;
}

@end
