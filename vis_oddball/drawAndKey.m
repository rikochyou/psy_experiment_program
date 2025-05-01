function drawAndKey(w,txt)
 %% display text
 txtColor=[255 255 255]; % rgb: white
 txt=[txt double('\n\n按任意键继续')];
 DrawFormattedText(w, txt, 'center','center', txtColor);
 % "flip" what we've drawn onto the display
 Screen('Flip', w);
 % wait 300 seconds, then advance after keypress
 WaitSecs(.3);
 KbPressWait();
end


