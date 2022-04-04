load('weight.mat')

tbl = table(InitialWeight,Program,Subject,Week,y);
tbl.Subject = nominal(tbl.Subject);
tbl.Program = nominal(tbl.Program);

lme = fitlme(tbl,'y ~ InitialWeight + Program*Week + (Week|Subject)')