 
function res = visodd(varargin)

%% 清除之前所有东西
clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 设置工作目录
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('E:\vis_oddball');
addpath('E:\vis_oddball\logs');
addpath('E:\vis_oddball\mats');
addpath('E:\vis_oddball\images');
cd('E:\vis_oddball');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 选择是否使用MEG  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MEG    = input('MEG recording: Yes (1) or No (0) ? :');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 被试信息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

prompt = {'被试序号','姓名[汉字]','性别[1=男,2=女]','出生日期[19920309]'};  %定义需要填写的项目
dlg_title = '被试信息'; %定义需要填写的项目
num_lines = 1; %定义显示的行数
defaultanswer = {'1','','',''}; %定义默认的数值
subinfo = inputdlg(prompt,dlg_title,num_lines,defaultanswer);%创建输入用户信息的对话框，prompt为提示字符串，dlg_title为对话框名称，num_lines为显示的行数，defaultanswer为默认的数值
subID = [subinfo{1}]; %提取用户信息的第1行，转换为数值变量后赋值给subID，记录被试序号
name= [subinfo{2}]; %提取用户信息的第2行，记录被试姓名
gender = str2num([subinfo{3}]); %提取用户信息的第3行，记录被试性别
birthyear = str2num([subinfo{4}]); %提取用户信息的第4行，记录被试出生日期

input('Press ENTER to continue');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 设置被试信息存储矩阵和日志输出
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nowstr = datestr(datevec(now),'yyyymmddHHMMSS');
savename=[ subID '_' nowstr ];
logfile=fullfile('logs',[savename,'.txt']);
matfile=fullfile('mats',[savename,'.mat']);

diary(logfile)
fprintf('starting task for %s\n',subID); % 日志

result  = struct; % 设置结果存储结构

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 按键设置
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
targetKey   = '1!';
MEGKey      = '=+';
KbName('UnifyKeyNames');
targetKey   = KbName(targetKey);
MEGKey      = KbName(MEGKey);
escape      = KbName('ESCAPE');
p_key = KbName('p');
q_key = KbName('q');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MEG 设置
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  并口设置
if MEG
    ioObj = io64;
    status = io64(ioObj);
    if status ~= 0
        error('并行端口驱动初始化失败');
    end
    Address = hex2dec('4FF8');  % 并行端口地址，通常是 0x378 或 0x3BC
else
    ioObj = 0;
    Address = 0;
end

%% Trigger 设置
expStart_trig   = 1001;
blockStart_trig = 1010;
blockEnd_trig   = 1020;
expEnd_trig     = 1255;

% 图片刺激类型
tgt_trig       = 1005;
std_trig       = 1002;


% Key press trig
press_p_trig      = 1050;
press_q_trig = 1070;
no_press_trig = 1090;

% 反应是否正确
correct_trig = 1040;
wrong_trig = 1050;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 设置屏幕
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% []代表全屏, 其他值： [topx,topy,width,height]

screenRes   = [0 0 800 600]; 
% screenRes   = []; 全屏显示，如需要可取消注释，并注释掉上一行
w           = PTBsetup(screenRes);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 设置刺激图片
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

std = imread('cat.jpg');
tgt = imread('mountain.png');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 指导语
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s = double('欢迎参加实验！');

drawAndKey(w,s);
s1 = double('在这个实验中，你会看到不同的图片。\n实验过程中，用双手做出反应。\n当你看到山的图片时，用右手食指按"p"。\n当你看到猫的图片时，用左手食指按“q”。');

drawAndKey(w,s1);

% End of instructions
s2 = double('做好准备！\n准备开始了！');
drawTxt(w,s2,0.7);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 实验设置
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TrialInter = 1; % 试次间隔时间，秒为单位
BlockNum = 2; % Block的数量，可修改
BlockInter = 2; % 上一个Block结束到下一个Block之间的间隔，秒为单位
stimulusDuration = 0.5; % 刺激持续时间，秒为单位

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 设置结果输出和Block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


result.subInfo = [{'subID'},{'Name'},{'Sex'},{'Age'};...
    {subID},{name},{gender},{birthyear}];

for block_number = 1:BlockNum
    result.data(block_number).block  = block_number;
    trial_type                       = zeros(1,100);
    
    %% 序列生成
    % 定义序列长度
    sequenceLength = 10;
    
    % 生成随机概率
    randomProbabilities = rand(1, sequenceLength); % 生成0到1之间的随机数
    
    % 根据概率生成序列
    sequence = cell(1, sequenceLength); % 初始化序列
    for i = 1:sequenceLength
        if randomProbabilities(i) <= 0.2
            sequence{i} = 'tgt'; % 20% 概率选择 'tgt'
        else
            sequence{i} = 'std'; % 80% 概率选择 'std'
        end
    end

    for i = 1:length(sequence)
        if isequal(sequence{i},'std')
            trial_type(i) = 1;
        elseif isequal(sequence{i},'tgt')
            trial_type(i) = 5;
        end
    end
    
    %% block开始提示
    block_info = sprintf('Start Block %d',block_number);
    drawTxt(w, block_info, 1);
    Screen(w,'Flip');
    MEGStartTime = GetSecs();
    %[~,MEGStartTime]=waitForKey(MEGKey,start_time,Inf);
    fprintf('MEGStart\t%.02f\n',MEGStartTime);
    
    % 注视点
    fixation(w,[]);    
    WaitSecs(1);

    %% 实验开始trigger
    if MEG
        %sendTrigger(ioObj, Address, expStart_trig)
        io64(ioObj, Address, expStart_trig);
        WaitSecs(0.01);
        io64(ioObj, Address, 0);
    end
    result.MEGStart = MEGStartTime;
    
    result.data(block_number).BlockStart    = GetSecs();
    
    %% Block开始trigger
    if MEG
        %sendTrigger(ioObj, Address,blockStart_trig)
        io64(ioObj, Address, blockStart_trig);
        WaitSecs(0.01);
        io64(ioObj, Address, 0);
    end

    %% 循环trials
    for trial_number = 1:length(sequence)

       imgName         = sequence{trial_number};

       if trial_type(trial_number) == 1
           img     = std;
       elseif trial_type(trial_number) == 5
           img     = tgt;
       end

       %% 任务开始
       
       trial_info   = runTrial(imgName,img,w,p_key,q_key,...
           MEG,trial_type,trial_number,ioObj,Address,blockStart_trig,std_trig,tgt_trig, correct_trig, wrong_trig, stimulusDuration);
       
       
       %% 按键MEG Trigger
       if MEG
           if trial_info.response == 'p'
                %sendTrigger(ioObj, Address, blockStart_trig + press_p_trig);
                io64(ioObj, Address, blockStart_trig + press_p_trig);
                WaitSecs(0.01);
                io64(ioObj, Address, 0);
           elseif trial_info.response == 'q'
               %sendTrigger(ioObj, Address, blockStart_trig + press_q_trig);
               io64(ioObj, Address, blockStart_trig + press_q_trig);
               WaitSecs(0.01);
               io64(ioObj, Address, 0);
           else
               %sendTrigger(ioObj, Address, blockStart_trig + no_press_trig);
               io64(ioObj, Address, blockStart_trig + no_press_trig);
               WaitSecs(0.01);
               io64(ioObj, Address, 0);
           end
       end
       
       % 打印日志
       fprintf('trial %02d\tpushed %d\tscore %d\tRT %.02f\timgon %.02f\timg %s\n',...
         trial_number, trial_info.response, ...
         trial_info.correct, trial_info.rt,...
         trial_info.onset-MEGStartTime,trial_info.imgname);
       
        result.data(block_number).timing(trial_number) = trial_info;
       fixation(w,[]);
       WaitSecs(TrialInter);
    end

    %% Block结束trigger %%
    if MEG
        sendTrigger(ioObj, Address, blockEnd_trig);
    end
    
    %% Block 结束
    finishBlock = GetSecs();
    fprintf('Finished Block %02d\t%.02f\n',block_number,finishBlock);
    result.data(block_number).endBlock = finishBlock;
    blockEndIns = double('block结束');
    %drawTxt(w,blockEndIns,BlockInter);   
    drawAndKey(w,blockEndIns);
    %% Block结束后保存结果
    save(matfile,'result');  
   
end
%% 实验结束trigger
if MEG
    sendTrigger(ioObj, Address, expEnd_trig);
end
%% 实验结束
finishTime=GetSecs();
fprintf('Finished Main Loop\t%.02f\n',finishTime);
WaitSecs(1);
result.finishtime= finishTime;
save(matfile,'result','subID')
end_inst = double('实验结束！\n感谢您的参与！');
DrawFormattedText(w,end_inst,'center','center');
Screen(w,'Flip');
WaitSecs(3);
cleanup;
end