function trial_info= runTrial(imgName,img,w,p_key,q_key,...
    MEG,trial_type,trial_number,ioObj,Address,blockStart_trig,std_trig,tgt_trig,correct_trig, wrong_trig, stimulusDuration)
    
 stimulusOnset = drawstims(w,img,[]);
 %drawblank(w,'',[]);

 
% 不同刺激类型的MEG triggers
if trial_type(trial_number) == 1
   if MEG
       %sendTrigger(ioObj, Address, blockStart_trig + std_trig);
       io64(ioObj, Address, blockStart_trig + std_trig);
       WaitSecs(0.01);
       io64(ioObj, Address, 0);
   end
elseif trial_type(trial_number) == 5
  if MEG
       %sendTrigger(ioObj, Address, blockStart_trig + tgt_trig)
       io64(ioObj, Address, blockStart_trig + tgt_trig);
       WaitSecs(0.01);
       io64(ioObj, Address, 0);
  end
end
 
 % 记录反应
 [resp, keyonset] = waitForResKey(p_key,q_key,stimulusOnset, stimulusDuration);
 
 istgt=strncmp('tgt',imgName,3);
 
 % 记录反应是否正确
 
 if (resp=='p' && istgt) || (resp=='q' && ~istgt)
     isCorrect = 1;
     if MEG
         io64(ioObj, Address, correct_trig);
         WaitSecs(0.01);
         io64(ioObj, Address, 0);
     end
 else
     isCorrect = 0;
     if MEG
         io64(ioObj, Address, wrong_trig);
         WaitSecs(0.01);
         io64(ioObj, Address, 0);
     end
 end
 %Screen('Flip', w);
 %fixation(w);
 %WaitSecs(stimulusDuration - (GetSecs() - stimulusOnset));

 % 记录试次信息
 trial_info = struct( ...
    'response', resp, ...
    'correct', isCorrect, ...
    'keyontime',  keyonset, ...
    'imgname',  imgName, ...
    'onset', stimulusOnset, ...
    'rt', keyonset-stimulusOnset);
end
