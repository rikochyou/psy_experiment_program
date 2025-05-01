function drawTxt(w,txt, waitTime)
 %% display text
 txtColor=[255 255 255]; % rgb: black
 DrawFormattedText(w, txt, 'center','center', txtColor);
 % "flip" what we've drawn onto the display
 Screen('Flip', w);
 % wait 1 second, then advance after keypress
 WaitSecs(waitTime);
end
