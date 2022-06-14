MODULE Main

!******************************
! PROGRAM for IRB 2600-20/1.65 Type B
! main module
!******************************


! ROBOT SPEED PARAMETERS
CONST speeddata s5:=[5,5,0,0];
CONST speeddata s10:=[10,10,0,0];
CONST speeddata s15:=[15,15,0,0];
CONST speeddata s20:=[20,20,0,0];
CONST speeddata s25:=[25,25,0,0];
CONST speeddata s30:=[30,30,0,0];
CONST speeddata s40:=[40,40,0,0];
CONST speeddata s50:=[50,50,0,0];
CONST speeddata s60:=[60,60,0,0];
CONST speeddata s70:=[70,70,0,0];
CONST speeddata s80:=[80,80,0,0];
CONST speeddata s90:=[90,90,0,0];
CONST speeddata s100:=[100,100,0,0];
CONST speeddata s150:=[150,150,0,0];
CONST speeddata s200:=[200,200,0,0];
CONST speeddata s250:=[250,250,0,0];
CONST speeddata s300:=[300,300,0,0];
CONST speeddata s400:=[400,400,0,0];
CONST speeddata s500:=[500,500,0,0];
CONST speeddata s600:=[600,600,0,0];
CONST speeddata s700:=[700,700,0,0];
CONST speeddata s800:=[800,800,0,0];
CONST speeddata s900:=[900,900,0,0];
CONST speeddata s1000:=[1000,1000,0,0];
CONST speeddata s2000:=[2000,2000,0,0];
CONST speeddata s3000:=[3000,3000,0,0];
CONST speeddata sMax:=[1200,800,1200,800];

! REGISTERS
VAR num answer:=0;
VAR num cycle_time:=0;
VAR num end_time:=0;
VAR num hour_perform:=0;
VAR num finished_detail:=0;
VAR bool detail_check:=TRUE;
VAR clock timer;

! MACHINE INTERRUPT
VAR intnum intnum5:=0;
VAR intnum intnum6:=0;
VAR bool times_up:=FALSE;
VAR bool stop_cycle:=FALSE;
VAR bool anomaly:=FALSE;

! CALIBRATION POSITION
CONST jointtarget calib_pos:=[[0,0,0,0,0,0],[9E+9,9E+9,9E+9,9E+9,9E+9,9E+9]];


!******************************
PROC main()
    P_Parameters;
    P_Interrupt;
    P_Initialization;
    X_DetailCompare;
    R_Home;
    T_RotateZ;
    T_Release;
    U_SelectMode;
    U_CheckTable;
    ClkStart timer;
    P_PickPlace;
ENDPROC

!******************************
PROC P_PickPlace()
    IF DI10_1=1 THEN
        TPErase;
        U_CheckPallet 1;
        R_Corner;
        finished_detail:=0;
        FOR y FROM 0 TO 2 DO
            pal1.oframe.trans.y:=y*distance_p1_y;
            FOR x FROM 0 TO 9 DO
                pal1.oframe.trans.x:=x*distance_p1_x;
                P_Pallet1;
            ENDFOR
        ENDFOR
        PulseDO\PLength:=0.2,DO10_55;
        R_Corner;
        PulseDO\PLength:=0.2,DO10_57;
        PulseDO\PLength:=0.2,DO10_1;
    ENDIF
    IF DI10_2=1 THEN
        TPErase;
        U_CheckPallet 2;
        R_Corner;
        finished_detail:=0;
        FOR y FROM 0 TO 2 DO
            pal2.oframe.trans.y:=y*distance_p2_y;
            FOR x FROM 0 TO 9 DO
                pal2.oframe.trans.x:=x*distance_p2_x;
                P_Pallet2;
            ENDFOR
        ENDFOR
        PulseDO\PLength:=0.2,DO10_56;
        R_Corner;
        PulseDO\PLength:=0.2,DO10_58;
        PulseDO\PLength:=0.2,DO10_2;
    ENDIF
    TPErase;
    MoveJ home,s300,z50,tool1;
ENDPROC

!******************************
PROC P_Pallet1()
    IF answer=1 THEN
        !! Warning! Engine starting
        S_Grinder2 "Start";
    ELSEIF answer=2 THEN
        !! Warning! Engine starting
        S_Grinder2 "Start";
    ENDIF
    R_Take1;
    R_Control "Take";
    IF detail_check=TRUE THEN
        IF answer=4 THEN
            R_Drop1;
        ELSE
            R_Home;
            IF answer=1 THEN
                P_Task1;
            ELSEIF answer=2 THEN
                P_Task1Short;
            ENDIF
            R_Home;
            R_Corner;
            R_Drop1;
        ENDIF
        R_Control "Drop";
    ENDIF
    U_PerfMetr;
ENDPROC

!******************************
PROC P_Pallet2()
    IF answer=1 THEN
        !! Warning! Engine starting
        S_Grinder2 "Start";
    ELSEIF answer=2 THEN
        !! Warning! Engine starting
        S_Grinder2 "Start";
    ENDIF
    R_Take2;
    R_Control "Take";
    IF detail_check=TRUE THEN
        IF answer=4 THEN
            R_Drop2;
        ELSE
            R_Home;
            IF answer=1 THEN
                P_Task1;
            ELSEIF answer=2 THEN
                P_Task1Short;
            ENDIF
            R_Home;
            R_Corner;
            R_Drop2;
        ENDIF
        R_Control "Drop";
    ENDIF
    U_PerfMetr;
ENDPROC

!******************************
PROC S_Alarm()
    Set DO10_38;
    Set DO10_36;
ENDPROC

!******************************
PROC S_Alarm1()
    TPErase;
    TPWrite "             **************";
    TPWrite "             * ATTENTION! *";
    TPWrite "             **************";
    TPWrite " ";
    TPWrite "Waiting time for the mode";
    TPWrite "selection has been exceeded";
    S_Alarm;
    EXIT;
ENDPROC

!******************************
PROC S_Alarm2()
    TPErase;
    TPWrite "             **************";
    TPWrite "             * ATTENTION! *";
    TPWrite "             **************";
    TPWrite " ";
    TPWrite "Waiting time for the pallet";
    TPWrite "selection has been exceeded";
    S_Alarm;
    EXIT;
ENDPROC

!******************************
PROC S_Alarm3()
    TPErase;
    TPWrite "             **************";
    TPWrite "             * ATTENTION! *";
    TPWrite "             **************";
    TPWrite " ";
    TPWrite "Waiting time for the pallet";
    TPWrite "move has been exceeded";
    S_Alarm;
    EXIT;
ENDPROC

!******************************
PROC P_Initialization()
    S_GrinderStop;
    times_up:=FALSE;
    stop_cycle:=FALSE;
    anomaly:=FALSE;
    loss_limit:=2;
    detail_check:=TRUE;
    PulseDO\PLength:=1,DO10_30;
    PulseDO\PLength:=1,DO10_1;
    PulseDO\PLength:=1,DO10_2;
    Reset DO10_36;
    Reset DO10_38;
    Reset DO10_5;
    Reset DO10_6;
ENDPROC

!******************************
PROC R_Corner()
    MoveJ corner,s800,z50,tool1;
ENDPROC

!******************************
PROC P_OffsetCalculation(num work_object)
    IF work_object=5 THEN
        IF count5>=count5_limit THEN
            count5:=0;
            S_GrinderStop;
            U_ReplaceWheel 5;
        ENDIF
        grinder5.oframe.trans.x:=count5*offs5_step;
        Incr count5;
    ELSEIF work_object=6 THEN
        IF count6>=count6_limit THEN
            count6:=0;
            S_GrinderStop;
            U_ReplaceWheel 6;
        ENDIF
        grinder6.oframe.trans.x:=count6*offs6_step;
        Incr count6;
    ENDIF
ENDPROC

!******************************
PROC P_Task1()
    X_DetailCounter "begin";
    R_Polish2;
    R_Polish3;
    R_Polish1;
    R_Polish4;
    R_Polish5;
    R_Polish6;
    S_GrinderStop;
    X_DetailCounter "end";
ENDPROC

!******************************
PROC P_Task1Short()
    X_DetailCounter "begin";
    R_Polish2;
    R_Polish3;
    R_Polish1;
    R_Polish4;
    R_Polish6;
    S_GrinderStop;
    X_DetailCounter "end";
ENDPROC

!******************************
PROC R_Control(string action)
    MoveL before,s500,z10,tool1;
    MoveL check,s200,fine,tool1;
    WaitTime 0.2;
    MoveL after,s500,z10,tool1;
    IF action="Take" AND DI10_29=0 THEN
        Decr loss_limit;
        MoveJ corner,s500,z5,tool1;
        T_Release;
        detail_check:=FALSE;
        S_GrinderStop;
        IF loss_limit=0 THEN
            TPErase;
            TPWrite "             **************";
            TPWrite "             * ATTENTION! *";
            TPWrite "             **************";
            TPWrite " ";
            TPWrite "Maximum details lost";
            MoveJ home,s300,z50,tool1;
            WaitTime 1;
            EXIT;
        ENDIF
        Stop;
    ELSEIF action="Drop" AND DI10_29=1 THEN
        MoveL corner,s300,z50,tool1;
        MoveL non_drop,s300,z50,tool1;
        Stop;
    ELSE
        detail_check:=TRUE;
        loss_limit:=2;
    ENDIF
ENDPROC

!******************************
PROC T_Grab()
    WaitTime 0.5;
    Set DO10_50;
    WaitTime 0.5;
ENDPROC

!******************************
PROC T_Release()
    WaitTime 0.5;
    Reset DO10_50;
    WaitTime 0.5;
ENDPROC

!******************************
PROC T_RotateZ()
    WaitTime 1;
    PulseDO\PLength:=1,DO10_51;
    WaitTime 2;
ENDPROC

!******************************
PROC T_RotateX()
    WaitTime 1;
    PulseDO\PLength:=1,DO10_52;
    WaitTime 2;
ENDPROC

!******************************
PROC S_Grinder1(string action)
    IF action="Start" AND anomaly=FALSE THEN
        Reset DO10_12;
        Set DO10_11;
    ELSE
        Reset DO10_11;
    ENDIF
ENDPROC

!******************************
PROC S_Grinder2(string action)
    IF action="Start" AND anomaly=FALSE THEN
        Reset DO10_11;
        Set DO10_12;
    ELSE
        Reset DO10_12;
    ENDIF
ENDPROC

!******************************
PROC S_Grinder3(string action)
    IF action="Start" AND anomaly=FALSE THEN
        Reset DO10_14;
        Set DO10_13;
    ELSE
        Reset DO10_13;
    ENDIF
ENDPROC

!******************************
PROC S_Grinder4(string action)
    IF action="Start" AND anomaly=FALSE THEN
        Reset DO10_13;
        Set DO10_14;
    ELSE
        Reset DO10_14;
    ENDIF
ENDPROC

!******************************
PROC S_Grinder5(string action)
    IF action="Start" AND anomaly=FALSE THEN
        Reset DO10_16;
        Set DO10_15;
    ELSE
        Reset DO10_15;
    ENDIF
ENDPROC

!******************************
PROC S_Grinder6(string action)
    IF action="Start" AND anomaly=FALSE THEN
        Reset DO10_15;
        Set DO10_16;
    ELSE
        Reset DO10_16;
    ENDIF
ENDPROC

!******************************
PROC S_GrinderStop()
    Reset DO10_10;
    Reset DO10_11;
    Reset DO10_12;
    Reset DO10_13;
    Reset DO10_14;
    Reset DO10_15;
    Reset DO10_16;
    Reset DO10_41;
    Reset DO10_42;
    Reset DO10_43;
    Reset DO10_44;
    Reset DO10_45;
    Reset DO10_46;
    Reset DO10_47;
    Reset DO10_48;
ENDPROC

!******************************
PROC S_WaxRed()
    PulseDO\PLength:=0.5,DO10_43;
ENDPROC

!******************************
PROC S_WaxWhite()
    PulseDO\PLength:=0.5,DO10_44;
ENDPROC

!******************************
PROC R_Home()
    MoveJ home,s800,z50,tool1;
ENDPROC

!******************************
PROC P_Interrupt()
    IDelete intnum5;
    IDelete intnum6;
    CONNECT intnum5 WITH S_StopCycle;
    ISignalDI DI10_30,1,intnum5;
    CONNECT intnum6 WITH S_Anomaly;
    ISignalDI DI10_39,0,intnum6;
ENDPROC

!******************************
TRAP S_StopCycle
    stop_cycle:=TRUE;
    TPErase;
    TPWrite "             **************";
    TPWrite "             * ATTENTION! *";
    TPWrite "             **************";
    TPWrite " ";
    TPWrite "Stop cycle activated";
ENDTRAP

!******************************
TRAP S_Anomaly
    anomaly:=TRUE;
    S_Alarm;
    S_GrinderStop;
    PulseDO\PLength:=1,DO10_1;
    PulseDO\PLength:=1,DO10_2;
    TPErase;
    TPWrite "             **************";
    TPWrite "             *   ANOMALY  *";
    TPWrite "             **************";
ENDTRAP

!******************************
PROC U_SelectMode()
    VAR errnum errvar;

    answer:=0;
    TPErase;
    TPWrite " SELECT MODE:";
    TPWrite " ";
    TPWrite " STANDARD   - standard processing.";
    TPWrite " STANDARD-5 - standard without 5 wheel";
    TPWrite " TEST       - pallet testing.";
    TPReadFK answer,"","STANDARD","STANDARD-5","","TEST","SERVICE->"\MaxTime:=300\BreakFlag:=errvar;
    IF errvar=ERR_TP_MAXTIME S_Alarm1;
    TPErase;
    IF answer=5 U_ServiceMode;
ENDPROC

!******************************
PROC U_ServiceMode()
    VAR errnum errvar;
    VAR num s_answer;

    TPErase;
    TPReadFK s_answer,"SERVICE MODE:","OFFSET  RESET","CHECK  WHEEL","COUNTER RESET","CALIBRATION POSE","EXIT"\MaxTime:=300\BreakFlag:=errvar;
    IF errvar=ERR_TP_MAXTIME S_Alarm1;
    TPErase;
    TEST s_answer
    CASE 1:
        Z_GrinderOffsetReset;
    CASE 2:
        Z_CheckWheel "internal call";
    CASE 3:
        Z_DetailCounterReset;
    CASE 4:
        Z_Calib;
    CASE 5:
        EXIT;
    ENDTEST
ENDPROC

!******************************
PROC U_CheckTable()
    IF DI10_1=0 AND DI10_2=0 THEN
        TPErase;
        TPWrite "             **************";
        TPWrite "             * ATTENTION! *";
        TPWrite "             **************";
        TPWrite " ";
        TPWrite " Work table not selected.";
        TPWrite " ";
        TPWrite " 1. Press button on the table.";
        TPWrite " 2. Press START on FlexPendant.";
        WaitUntil DI10_1=1 OR DI10_2=1\MaxTime:=300\TimeFlag:=times_up;
        IF times_up S_Alarm2;
        Stop;
        TPErase;
    ENDIF
ENDPROC

!******************************
PROC U_CheckPallet(num pallet)
    IF (pallet=1 AND DI10_5=0) OR (pallet=2 AND DI10_6=0) THEN
        TPErase;
        TPWrite "             **************";
        TPWrite "             * ATTENTION! *";
        TPWrite "             **************";
        TPWrite " ";
        TPWrite " Pallet "+ValToStr(pallet)+" is not in work position.";
        TPWrite " ";
        TPWrite " 1. Press PALLET MOVE button.";
        TPWrite " 2. Press START on FlexPendant.";
        WaitUntil(pallet=1 AND DI10_5=1) OR (pallet=2 AND DI10_6=1)\MaxTime:=300\TimeFlag:=times_up;
        IF times_up S_Alarm3;
        Stop;
        TPErase;
    ENDIF
ENDPROC

!******************************
PROC U_PerfMetr()
    ClkStop timer;
    Incr finished_detail;
    cycle_time:=Round(ClkRead(timer));
    end_time:=cycle_time*(30-finished_detail);
    IF cycle_time=0 cycle_time:=1;
    hour_perform:=Trunc(3600/cycle_time);
    TPErase;
    TPWrite " CYCLE TIME: "+X_SecToTime(cycle_time);
    TPWrite " PRODUCTION IN HOUR: "\Num:=hour_perform;
    TPWrite " FINISHED DETAIL: "\Num:=finished_detail;
    TPWrite " PALLET END TIME: "+X_SecToTime(end_time);
    TPWrite " ";
    TPWrite " TOTAL DETAIL: "\Num:=total;
    TPWrite " MADE DETAIL:  "\Num:=made;
    TPWrite " LOST DETAIL:  "\Num:=lost;
    TPWrite " CALCULATION START DATE: "+start_data;
    TPWrite " REPLACE 5 WHEEL: "\Num:=(count5_limit-count5);
    TPWrite " REPLACE 6 WHEEL: "\Num:=(count6_limit-count6);
    ClkReset timer;
    ClkStart timer;
ENDPROC

!******************************
PROC U_ReplaceWheel(num work_object)
    VAR num continue;

    TPErase;
    TPWrite "             **************";
    TPWrite "             * ATTENTION! *";
    TPWrite "             **************";
    TPWrite " ";
    TPWrite " The offset will be reset to 0!!!";
    TPWrite " ";
    TPWrite " Replace the polishing wheel # "\Num:=work_object;
    TPWrite " then press CONTINUE.";
    TPReadFK continue,"","CONTINUE","","","",""\MaxTime:=300;
    IF work_object=5 AND continue=1 THEN
        S_Grinder5 "Start";
    ELSEIF work_object=6 AND continue=1 THEN
        S_Grinder6 "Start";
    ENDIF
    WaitTime 5;
ENDPROC

!******************************
PROC X_DetailCompare()
    IF collect<>put THEN
        Incr lost;
    ENDIF
    put:=collect;
ENDPROC

!******************************
PROC X_DetailCounter(string point)
    IF point="begin" THEN
        Incr total;
        collect:=collect*(-1);
    ELSE
        Incr made;
        put:=put*(-1);
    ENDIF
ENDPROC

!******************************
FUNC string X_SecToTime(num time)
    VAR string hh;
    VAR string mm;
    VAR string ss;

    hh:=ValToStr(time DIV 3600 DIV 10)+ValToStr(time DIV 3600 MOD 10);
    mm:=ValToStr(time MOD 3600 DIV 60 DIV 10)+ValToStr(time MOD 3600 DIV 60 MOD 10);
    ss:=ValToStr(time MOD 60 DIV 10)+ValToStr(time MOD 60 MOD 10);
    RETURN hh+":"+mm+":"+ss;
ENDFUNC

ENDMODULE