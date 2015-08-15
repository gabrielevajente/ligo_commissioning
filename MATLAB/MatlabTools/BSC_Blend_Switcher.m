function BSC_Blend_Switcher(Optics)

Optics = upper(Optics)

%Script to automate the switching of the BSC blends to the Ryan/LLO
%configuration. Not very smart and takes several minutes to run. First
%turns off all blends on St1 and St2. Then turns on the LLO blends, and
%puts unused DOFs in T750 blend. Relies on chamber being in same blend filter
%arrangement as ITMX.

%Turn everything off
% t1=gps_now

    for NN=1:10;
         system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_X_CPS_CUR FM' num2str(NN) ' OFF']);
        system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_X_T240_CUR FM' num2str(NN) ' OFF']);
        system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_X_L4C_CUR FM' num2str(NN) ' OFF']);
        
       system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_Y_CPS_CUR FM' num2str(NN) ' OFF']);
        system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_Y_T240_CUR FM' num2str(NN) ' OFF']);
        system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_Y_L4C_CUR FM' num2str(NN) ' OFF']);
        
        system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_Z_CPS_CUR FM' num2str(NN) ' OFF']);
        system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_Z_T240_CUR FM' num2str(NN) ' OFF']);
        system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_Z_L4C_CUR FM' num2str(NN) ' OFF']);
        
        system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RX_CPS_CUR FM' num2str(NN) ' OFF']);
        system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RX_T240_CUR FM' num2str(NN) ' OFF']);
        system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RX_L4C_CUR FM' num2str(NN) ' OFF']);
        
        system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RY_CPS_CUR FM' num2str(NN) ' OFF']);
        system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RY_T240_CUR FM' num2str(NN) ' OFF']);
        system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RY_L4C_CUR FM' num2str(NN) ' OFF']);
        
        system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RZ_CPS_CUR FM' num2str(NN) ' OFF']);
        system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RZ_T240_CUR FM' num2str(NN) ' OFF']);
        system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RZ_L4C_CUR FM' num2str(NN) ' OFF']);
                
        system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_X_CPS_CUR FM' num2str(NN) ' OFF']);
        system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_X_GS13_CUR FM' num2str(NN) ' OFF']);
        
         system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_Y_CPS_CUR FM' num2str(NN) ' OFF']);
        system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_Y_GS13_CUR FM' num2str(NN) ' OFF']);
        
        system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_Z_CPS_CUR FM' num2str(NN) ' OFF']);
        system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_Z_GS13_CUR FM' num2str(NN) ' OFF']);
        
        system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_RX_CPS_CUR FM' num2str(NN) ' OFF']);
        system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_RX_GS13_CUR FM' num2str(NN) ' OFF']);
        
        system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_RX_CPS_CUR FM' num2str(NN) ' OFF']);
        system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_RX_GS13_CUR FM' num2str(NN) ' OFF']);
        
        system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_RY_CPS_CUR FM' num2str(NN) ' OFF']);
        system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_RY_GS13_CUR FM' num2str(NN) ' OFF']);
        
        system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_RZ_CPS_CUR FM' num2str(NN) ' OFF']);
        system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_RZ_GS13_CUR FM' num2str(NN) ' OFF']);
    end

%Turn on the LLO blends, needs the blends to all be in the same
%configuration as installed at ITMX, turns unused DOFS to T750


system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_X_CPS_CUR FM9 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_X_T240_CUR FM9 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_X_L4C_CUR FM9 ON']);

system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_Y_CPS_CUR FM9 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_Y_T240_CUR FM9 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_Y_L4C_CUR FM9 ON']);

system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_Z_CPS_CUR FM9 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_Z_T240_CUR FM9 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_Z_L4C_CUR FM9 ON']);

system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RX_CPS_CUR FM9 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RX_CPS_CUR FM10 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RX_T240_CUR FM9 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RX_T240_CUR FM10 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RX_L4C_CUR FM9 ON']);

system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RY_CPS_CUR FM9 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RY_CPS_CUR FM10 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RY_T240_CUR FM9 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RY_T240_CUR FM10 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RY_L4C_CUR FM9 ON']);

system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RZ_CPS_CUR FM2 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RZ_T240_CUR FM2 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST1_BLND_RZ_L4C_CUR FM2 ON']);




system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_X_CPS_CUR FM9 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_X_GS13_CUR FM9 ON']);


system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_Y_CPS_CUR FM9 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_Y_GS13_CUR FM9 ON']);

system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_Z_CPS_CUR FM2 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_Z_GS13_CUR FM2 ON']);

system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_RX_CPS_CUR FM2 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_RX_GS13_CUR FM2 ON']);

system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_RY_CPS_CUR FM2 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_RY_GS13_CUR FM2 ON']);

system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_RZ_CPS_CUR FM2 ON']);
system(['ezcaswitch H1:ISI-' Optics '_ST2_BLND_RZ_GS13_CUR FM2 ON']);

% t2= gps_now

% runtime=t2-t1

end



