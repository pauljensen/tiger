

load ~/Dropbox/work/models/ecoli/iaf1260.mat
load ~/Dropbox/work/models/pao/pao.mat
load ~/Dropbox/work/models/yeast/ind750.mat
load ~/Dropbox/work/models/lmajor/lmajor12182009.mat
load ~/Dropbox/work/models/chlamy/chlamyDa.mat
load ~/Dropbox/work/models/human/duarte.mat

%set(0,'RecursionLimit',1000)

clear models
models(6) = struct();
models(1).name = 'E. coli iAF1260';
models(1).model = iaf1260;
models(2).name = 'P. aeruginosa iMO1086';
models(2).model = pao_cobra;
models(3).name = 'S. cerevisiae iND750';
models(3).model = ind750;
models(4).name = 'L. major iAC560';
models(4).model = lmajor;
models(5).name = 'C. reinhardtii iRC1086';
models(5).model = chlamyDa;
models(6).name = 'H. sapiens Recon1';
models(6).model = humanDefault;

for i = 2 : length(models)
    tic;
    v13 = cobra_to_tiger(models(i).model,'add_gpr','v1.3');
    models(i).t13 = toc;
    models(i).size13 = size(v13.A);
    tic;
    v14 = cobra_to_tiger(models(i).model);
    models(i).t14 = toc;
    models(i).size14 = size(v14.A);
    i
end

%%

worked = 2:5;

ncols = zeros(length(worked),3);
nrows = zeros(length(worked),3);
times = zeros(length(worked),2);

for i = worked
    ncols(i,:) = [size(models(i).model.S,2), ...
                  models(i).size13(2), ...
                  models(i).size14(2)];
    nrows(i,:) = [size(models(i).model.S,1), ...
                  models(i).size13(1), ...
                  models(i).size14(1)];
    times(i,:) = [models(i).t13,models(i).t14];
end

subplot(1,3,1);
bar(nrows(2:end,:));
title('# Rows');
subplot(1,3,2);
bar(ncols(2:end,:));
title('# Columns');
subplot(1,3,3);
bar(times(2:end,:));
title('Runtime [seconds]');

