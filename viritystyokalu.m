
function [Kc, tauI, tauD] = viritystyokalu()
% VIRITYSTYOKALU Laskee PI/PID- säätimelle viritysparametreja
% SIMC-viritysmetodin mukaan
%    
%   Parametrit annetaan säätimen kaskadinotaatiolle
%
%   Ohjelma antaa ohjeita käytön aikana
%   Viritystyökalulle ei tarvitse antaa parametreja
%   Palauttaa kolme parametria;
%       Vahvistuksen Kc
%       Integraattorin aikavakion Ti
%       Derivaattorin aikavakion Td
%
%   Oletuksena viritysparametri tau_c = theta. Voidaan vaihtaa 


    % Viritysparametrit mit� lasketaan
    Kc = 0;
    tauI = 0;
    tauD = 0;
        
    % Tarkistusarvot
    tarkistus2 = false;
    
    kyssari = 'Sy�t� prosessin viiveen suuruus (Jos viivettä ei ole, syötä 0): ';
    theta0 = input(kyssari);

    kyssari = 'Sy�t� prosessin DC-vahvistus: ';
    k = input(kyssari);
    
    kyssari = 'Onko j�rjestelm� integroiva? (Y/N) ';
    int = input(kyssari, 's');
    int = upper(int);
    
    if int == 'Y' 
        
        kyssari = 'Montako integraattioria j�rjestelm�ss� on? ';
        int_lkm = input(kyssari);
        
        if int_lkm == 1
            
            kyssari = 'Onko j�rjestelm�ss� napaa? (Y/N) ';
            intnapa = input(kyssari, 's');
            intnapa = upper(intnapa);

            
            if intnapa == 'Y' 
                tauc = theta0;
                
                while tarkistus2 == false 
                    
                    kyssari = 'Sy�t� navan aikavakio: ';
                    tau2 = input(kyssari);
                    
                    if tau2 <= 0 
                       error('Siirtofunktio epästabiili, ei voida laskea viritysparametrejä'); 
                    end
                    
                    [Kc, tauI, tauD] = intnapasimc(theta0, tau2, k, tauc);
                    fprintf('Viritysparametrilla tau_c = %d saatiin viritysparametreiksi: \n', tauc);
                    fprintf('Kc = %d \n', Kc);
                    fprintf('tauI = %d \n', tauI);
                    fprintf('tauD = %d \n', tauD);

                    [tauc, tarkistus2] = tarkistus(tauc, theta0);
                    
                end
                return;
            else
                
                tauc = theta0;
                while tarkistus2 == false 
                    
                    [Kc, tauI] = intsimc(theta0, k, tauc);
                    fprintf('Viritysparametrilla tau_c = %d saatiin viritysparametreiksi: \n', tauc);
                    fprintf('Kc = %d \n', Kc);
                    fprintf('tauI = %d \n', tauI);

                    [tauc, tarkistus2] = tarkistus(tauc, theta0);
                
                end
                return;
            end
            
        elseif int_lkm == 2

            tauc = theta0;
            while tarkistus2 == false 

                [Kc, tauI, tauD] = doupintsimc(theta0, k, tauc);
                fprintf('Viritysparametrilla tau_c = %d saatiin viritysparametreiksi: \n', tauc);
                fprintf('Kc = %d \n', Kc);
                fprintf('tauI = %d \n', tauI);
                fprintf('tauD = %d \n', tauD);

                [tauc, tarkistus2] = tarkistus(tauc, theta0);

            end
            return;
            
        else
            disp('Valitettavasti t�lle mallille ei voida laskea viritysparametrej�');
            return;
        end
    else
        [Kc, tauI] = cleardelay(theta0, k);
        fprintf('SIMC-virityksell� viritysparametreiksi saatiin: ');
        fprintf('Kc = %d \n', Kc);
        fprintf('tauI = %d \n', tauI);
        return;
    end

    % Ohjelma kysyy k�ytt�j�lt� prosessin navat ja nollat
    kyssari = 'Sy�t� prosessin napojen aikavakiot vektorina: ';
    navat = input(kyssari);
    
    for aikavakio = navat
        if aikavakio <= 0
            error('Siirtofunktio epästabiili, viritysparametrejä ei voida laskea');
        end
    end
    
    kyssari = 'Sy�t� prosessin nollien aikavakiot vektorina: ';
    nollat = input(kyssari);

    tarkistus1 = false;
    tarkistus2 = false;

    % Tarkastus sille, onko kyseess� aito tai vahvasti aito siirtofunktio (onko napoja enemm�n
    % tai yht�paljon kuin nollia)
    if length(navat) < length(nollat)
        error('Siirtofunktio on epäaito, viritysparametrejä ei voida laskea');
    end

    % J�rjest�� vektorit suurimmasta pienimp��n 
    navat = sort(navat, 'descend');
    nollat = sort(nollat, 'descend');
    
    

    while tarkistus1 == false
        kyssari = 'Haluatko virityksen PI vai PID säätimelle? (PI/PID) ';
        saadin = input(kyssari, 's');
        saadin = upper(saadin);
        disp(saadin);
        tau1 = 0;
        tau2 = 0;
        theta = 0;

        if strcmp('PI', saadin) == 1

            % PI viritys
            % Approksimaatio ensimm�iseen kertaluokkaan
            [tau1, theta] = piapp(navat, nollat, theta0);

            % Valitaan oletusarvo viritysparametrille tauc
            tauc = theta;

            while tarkistus2 == false

                Kc = 1/k*tau1/(tauc+theta);
                tauI = min(tau1, 4*(tauc+theta));
                tauD = 0;

                fprintf('Viritysparametrilla tau_c = %d saatiin viritysparametreiksi: \n', tauc);
                fprintf('Kc = %d \n', Kc);
                fprintf('tauI = %d \n', tauI);

                [tauc, tarkistus2] = tarkistus(tauc, theta0);
            end

            tarkistus1 = true;

        elseif strcmp('PID', saadin) == 1
            % PID viritys

            [tau1, tau2, theta] = pidapp(navat, nollat, theta0);

            while tarkistus2 == false

                Kc = 1/k*tau1/(tauc+theta);
                tauI = min(tau1, 4*(tauc+theta));
                tauD = tau2;

                fprintf('Viritysparametrilla tau_c = %d saatiin viritysparametreiksi: \n', tauc);
                fprintf('Kc = %d \n', Kc);
                fprintf('tauI = %d \n', tauI);
                fprintf('tauD = %d \n', tauD);

                [tauc, tarkistus2] = tarkistus(tauc, theta0);
            end

            tarkistus1 = true;

        else
            disp('Sy�tt�isitk� jommankumman tarjotuista vaihtoehdoista? (PI/PID) ');
        end
    end
    
end

function [tauc, tarkistus1] = tarkistus(tauc, theta)

    kyssari = ('Oletko tyytyv�inen tuloksiin? (Y/N) ');
    vast = input(kyssari, 's');
    vast = upper(vast);
    if vast == 'Y'
        tarkistus1 = true;
        tauc = tauc;

    elseif vast == 'N'
        kyssari = ('Sy�t� uusi tau_c (oltava suurempi/yhtäsuuri kuin theta): ');
        tauc_new = input(kyssari);
        while tauc_new < theta
            kyssari = ('Syötä uusi tau_c (oltava suurempi/yhtäsuuri kuin theta): ');
            tauc_new = input(kyssari);
        end
        tauc = tauc_new;
        tarkistus1 = false;
    end

end

    
function [tau1, theta] = piapp(navat, nollat, theta0)

    for i = 1:length(navat)
        % mit� navoille tehd��n
        if i == 1
            tau1 = navat(i);
            theta = theta0;
        elseif i == 2
            tau1 = tau1 + navat(i)/2;
            theta = theta + navat(i)/2;
        else
            theta = theta + navat(i);
        end
    end

    for i = 1:length(nollat)
        % mit� nollille tehd��n
        if nollat(i) < 0
            % negatiiviset nollat
            theta = theta + abs(nollat(i));

        elseif nollat(i) > 0
            % positiiviset nollat

            if nollat(i) > theta/2
                tau1 = tau1 - nollat(i);
            else
                theta = theta - nollat(i);
            end

        else 
            error('Nollat eivät voi olla arvoa nolla, viritysparametreja ei voida laskea');
            
        end
    end

end

function [tau1, tau2, theta] = pidapp(navat, nollat, theta0) 
    for i = 1:length(navat)
        % mit� navoille tehd��n
        if i == 1
            tau1 = navat(i);
            theta = theta0;
        elseif i == 2
            tau2 = navat(i);
        elseif i == 3
            tau2 = tau2 + navat(i)/2;
            theta = theta + navat(i)/2;
        else
            theta = theta + navat(i);
        end
    end

    for i = 1:length(nollat)
        % mit� nollille tehd��n
        if nollat(i) < 0
            % negatiiviset nollat
            theta = theta + abs(nollat(i));

        elseif nollat(i) > 0
            % positiiviset nollat

            if nollat(i) > theta/2
                tau1 = tau1 - nollat(i);
            else
                theta = theta - nollat(i);
            end

        else 
            error('Nollat eivät voi olla arvoa nolla, viritysparametrejä ei voida laskea');
        end
    end
end

function[Kc, tauI] = cleardelay(theta, k)
    tauI = 0.08*theta;
    Kc = 0.5/k*tauI/theta;
end

function [Kc, tauI] = intsimc(theta, k, tauc)
    Kc = 1/k*1/(tauc + theta);
    tauI = 4*(tauc + theta);
end

function [Kc, tauI, tauD] = doupintsimc(theta, k, tauc)
    Kc = 1/k*1/(4*(tauc + theta)^2);
    tauI = 4*(tauc + theta);
    tauD = 4*(tauc + theta);
end

function [Kc, tauI, tauD] = intnapasimc(theta, k, tau2, tauc)
    Kc = 1/k*1/(tauc + theta);
    tauI = 4*(tauc + theta);
    tauD = tau2;
end