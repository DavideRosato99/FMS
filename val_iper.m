function [R] = val_iper(coeff0,coeffIPER,coeffCOMPL,n_aste)
    R_vec = [];
    % ciclo sulle aste
    for i1 = 1:n_aste
        % ciclo su N,T,M, controllo dei soli valori di grado 0 (c0)
        for i2 = 1:3
            if coeffIPER(i1,i2,1) ~= 0
                R_ip = round((coeffCOMPL(i1,i2,1) - coeff0(i1,i2,1))/coeffIPER(i1,i2,1),5);
                if R_ip ~= 0
                    R_vec = [R_vec;R_ip];
                end
            end
        end
    end
    format rat
    % controllo che tutte le ipotetiche R siano uguali
    valore = R_vec(1);
    for i = 2:size(R_vec,1)
        if R_vec(i) ~= valore
            error('incoerenza tra i risultati di R');
        end
    end
    R = valore;
end