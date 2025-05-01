function [key,RT] = waitForResKey(p_key,q_key,start,timeout)
  fastestResponseTime=.06;
  WaitSecs(fastestResponseTime);
 
  key=0;
  RT=-Inf;
  % continue until we get a keypress we like
  % or we run out of time
  while(RT<=0 && GetSecs() - start < timeout )
      [keyPressed, thisRT, keyCode] = KbCheck;
      if keyPressed
          if keyCode(KbName('ESCAPE'))
              sca;
              return;
          elseif keyCode(p_key) || keyCode(q_key)
              RT = thisRT;
              key = KbName(keyCode);
          end
      end
  end
