function mailing_list=LHO_Mailing_List(IFO,Optics)

switch IFO
    case 'H1'
    switch Optics
        case 'ETMY'
            mailing_list={'vlhuillier@ligo.mit.edu';'bland_b@ligo-wa.caltech.edu';'Sadeski_t@ligo-wa.caltech.edu';'warner_j@ligo-wa.caltech.edu';'carrasco_c@ligo-wa.caltech.edu';'santini_t@ligo-wa.caltech.edu';...
                'izumi_k@ligo-wa.caltech.edu';'pele_a@ligo-wa.caltech.edu';'landry_m@ligo-wa.caltech.edu';'radkins_h@ligo-wa.caltech.edu';'jkissel@ligo.mit.edu';'fabrice@ligo.mit.edu';...
                'kawabe_k@ligo-wa.caltech.edu';'fauver_j@ligo-wa.caltech.edu';'bgateley@apollosm.com';'szymons@gmail.com';'dwyer_s@ligo-wa.caltech.edu';'rmss@conch.uoregon.edu'};
        case {'ITMY','TST','BS'}
            mailing_list={'vlhuillier@ligo.mit.edu';'bland_b@ligo-wa.caltech.edu';'Sadeski_t@ligo-wa.caltech.edu';'warner_j@ligo-wa.caltech.edu';'carrasco_c@ligo-wa.caltech.edu';'santini_t@ligo-wa.caltech.edu';...
               'dwyer_s@ligo-wa.caltech.edu';'izumi_k@ligo-wa.caltech.edu';'pele_a@ligo-wa.caltech.edu';...
              'landry_m@ligo-wa.caltech.edu';'radkins_h@ligo-wa.caltech.edu';'jkissel@ligo.mit.edu';'fabrice@ligo.mit.edu';'fauver_j@ligo-wa.caltech.edu';'bgateley@apollosm.com';'szymons@gmail.com';'pele_a@ligo-wa.caltech.edu'};
    end
end
