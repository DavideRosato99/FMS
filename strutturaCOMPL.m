function [coeffCOMPL] = strutturaCOMPL(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_ccIPER,CCIPER,n_cc,CC,n_cd,CD,n_rtIPER,RTIPER,VELI,VELT)
    % le reazioni iperstatica anti-declassate
    % controllo che ci siano azione e reazione
    if (size(CCIPER,1)~=2) && (size(CCIPER,1)~=0)
        error('NON CISONO AZIONE REAZIONE DELL?IPERSTATICA, ricontrolla la matrice RTIPER');
    end
    if size(CCIPER,1) ~= 0
        MS(end+1,:) = [CCIPER(1,1) CCIPER(2,1) CCIPER(1,2)];
    end
    if size(RTIPER,1) ~= 0
        RT(end+1,:) = [RTIPER(1) RTIPER(2)];
    end
    [coeffCOMPL] = struttura0(n_nodi,NODI,n_aste,ASTE,n_rt,RT,n_ms,MS,n_cc,CC,n_cd,CD,VELI,VELT);
end