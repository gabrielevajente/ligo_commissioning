% SS=Pack_Filters_ZPK2SS(Filter_zpk_Form)
% December 19, 2012 - VL - initial rev: 6569
% Pack_Filters_zpk2SS transforms a digital filters saved in the zpk form to
% a structure containing the state space domain

function SS=Pack_Filters_ZPK2SS(Filter_zpk_Form)
    [SS.A,SS.B,SS.C,SS.D,SS.Ts] =  ssdata(Filter_zpk_Form);
end
