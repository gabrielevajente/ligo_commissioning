% ZPK=Unpack_Filters_SS2ZPK(Filter_zpk_Form)
% December 19, 2012 - VL - initial rev: 6569
% Pack_Filters_zpk2SS transforms a digital filters saved in the state space domain to zpk form

function ZPK=Unpack_Filters_SS2ZPK(Filter_SS_Form)
    A=Filter_SS_Form.SS.A;
    B=Filter_SS_Form.SS.B;
    C=Filter_SS_Form.SS.C;
    D=Filter_SS_Form.SS.D;
    Ts=Filter_SS_Form.SS.Ts;
    ZPK=zpk(ss(A,B,C,D,Ts));
end
