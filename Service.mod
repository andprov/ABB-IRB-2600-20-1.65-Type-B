MODULE Service

!******************************
! This program module for call service procs.
!******************************


!******************************
PROC Z_Calib()
    answer:=0;
    TPErase;
    TPWrite " ";
    TPWrite " CALIBRATION POSE";
    TPWrite " ";
    TPWrite " Go To Calibration Pose?";
    TPReadFK answer,"","<-RETURN","GO","","","";
    TPErase;
    IF answer=1 THEN
        U_ServiceMode;
    ELSEIF answer=2 THEN
        MoveJ home,s100,z50,tool1;
        MoveAbsJ calib_pos,s100,fine,tool1;
    ENDIF
    EXIT;
ENDPROC

!******************************
PROC Z_DetailCounterReset()
    answer:=0;
    TPErase;
    TPWrite " ";
    TPWrite " COUNTER RESET";
    TPWrite " ";
    TPWrite " Reset The Detail Counter?";
    TPWrite " This procedure cannot be undone!";
    TPWrite " Detail counter";
    TPWrite " will be reset to 0.";
    TPWrite " ";
    TPReadFK answer,"","<-RETURN","YES","","","";
    IF answer=2 THEN
        collect:=-1;
        put:=-1;
        total:=0;
        made:=0;
        lost:=0;
        start_data:=Cdate();
    ELSEIF answer=1 THEN
        U_ServiceMode;
    ENDIF
    EXIT;
ENDPROC

!******************************
PROC Z_GrinderOffsetReset()
    answer:=0;
    TPErase;
    TPWrite " ";
    TPWrite " OFFSET RESET";
    TPWrite " ";
    TPWrite " Select Grinder For Offset Reset";
    TPWrite " This procedure cannot be undone!";
    TPWrite " Offset for the selected grinder";
    TPWrite " will be reset to 0.";
    TPWrite " ";
    TPReadFK answer,"","<-RETURN","GRINDER 5","GRINDER 6","ALL","";
    TEST answer
    CASE 1:
        U_ServiceMode;
    CASE 2:
        count5:=0;
        grinder5.oframe.trans.x:=0;
    CASE 3:
        count6:=0;
        grinder6.oframe.trans.x:=0;
    CASE 4:
        count5:=0;
        count6:=0;
        grinder5.oframe.trans.x:=0;
        grinder6.oframe.trans.x:=0;
    ENDTEST
    Z_CheckWheel "external call";
ENDPROC

!******************************
PROC Z_CheckWheel(string call)
    VAR num wheel;

    answer:=0;
    TPErase;
    TPWrite " ";
    TPWrite " CHECK WHEEL";
    TPWrite " ";
    TPWrite " This procedure must be performed";
    TPWrite " after replacing the polishing wheels";
    TPReadFK answer,"","<-RETURN","GO WHEEL 5","GO WHEEL 6","","";
    TPErase;
    TEST answer
    CASE 1:
        IF call="internal call" U_ServiceMode;
        IF call="external call" Z_GrinderOffsetReset;
    CASE 2:
        grinder5.oframe.trans.x:=count5*offs5_step;
        MoveL wheel5,s100,z0,tool1\WObj:=grinder5;
        wheel:=5;
    CASE 3:
        grinder6.oframe.trans.x:=count6*offs6_step;
        MoveL wheel6,s100,z0,tool1\WObj:=grinder6;
        wheel:=6;
    ENDTEST
    answer:=0;
    TPErase;
    TPWrite " If necessary, select 'CHANGE POSITION'";
    TPWRite " to change grinder position.";
    TPReadFK answer,"","<-RETURN","CHANGE POSITION","","","";
    IF answer=2 THEN
        IF wheel=5 grinder5.uframe.trans.y:=Z_ChangeGrinderPos(grinder5.uframe.trans.y);
        IF wheel=6 grinder6.uframe.trans.y:=Z_ChangeGrinderPos(grinder6.uframe.trans.y);
    ENDIF
    IF call="internal call" Z_CheckWheel "internal call";
    IF call="external call" Z_CheckWheel "external call";
ENDPROC

!******************************
FUNC num Z_ChangeGrinderPos(num init_value)
    VAR num y_value;

    y_value:=UINumTune(
        \Header:="CHANGE POSITION"
        \Message:="Set Grinder Position"
        \Icon:=0,
        init_value,
        1,
        \MinValue:=980
        \MaxValue:=1040);
    RETURN y_value;
ENDFUNC

ENDMODULE