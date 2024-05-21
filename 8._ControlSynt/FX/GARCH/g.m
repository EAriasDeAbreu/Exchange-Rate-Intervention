clc;
clear all;

tcest = readtable("tcs_est.xlsx", "UseExcel",false);

tc = table2array(tcest(2:5286,2:22));

tcn = tcest.Properties.VariableNames;
tcn = tcn(1,2:22);


fecha = table2array(tcest(2:5286,1));

figure
subplot(2,2,1)
plot(fecha, tc(:,2))
title("Depreciación Colombia")
subplot(2,2,2)
plot(fecha, tc(:,1))
title("Depreciación Brasil")
subplot(2,2,3)
plot(fecha, tc(:,20))
title("Depreciación Mexico")
subplot(2,2,4)
plot(fecha, tc(:,21))
title("Depreciación Australia")

%GARCH

vols = NaN(5285,22);
%vols(:,1) =fecha;
BIC = NaN(6,4);


for j = 1:21
for p = 1:6
    for q = 1:4

serie = fillmissing(tc(:,j), "linear");
na = isnan(tc(:,j));
na = 1-na;

mod = garch(p,q);
[~,~,LL] = estimate(mod, serie);

[~,BIC(p, q)] = aicbic(LL,p+q+1,5285);
    end
end

vmin = min(BIC);
[pe,qu] = find(BIC==vmin);

mod = garch(pe(1,1), qu(1,1));
[est,~,LL] = estimate(mod, serie);


vol = infer(est, serie);
vol = na.*vol;
for i = 1:5285
    if vol(i) == 0 
        vol(i) = NaN(1,1);
    end
end
vols(:,j+1) = vol;
end

figure
subplot(2,1,1)
plot(fecha, tc(:,2))
title("Depreciación estandarizada Colombia")
subplot(2,1,2)
plot(fecha, vols(:,3))
title("Varianza Condicional depreciación")

vols = array2table(vols);
vols(:,1) = fecha;
%%
writetable(vols, "vol.xlsx")





