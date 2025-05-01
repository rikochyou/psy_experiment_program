function onset=drawstims(w,stim,when)
   textureIndex = Screen('MakeTexture', w, stim);
   Screen('DrawTexture', w, textureIndex);
   onset=Screen('Flip', w,when);
end


