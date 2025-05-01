function onset=drawblank(w,stim,when)
   oldSize = Screen('TextSize',w, 96);
   DrawFormattedText(w,stim,'center','center', [255 255 255]);
   onset=Screen('Flip', w,when);
   Screen('TextSize',w, oldSize);
   
end


