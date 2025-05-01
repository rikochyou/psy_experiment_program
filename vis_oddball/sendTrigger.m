function sendTrigger(ioObj, Address,trigger)
    io64(ioObj, Address, trigger);
    WaitSecs(0.01);
    io64(ioObj, Address, 0);
end
