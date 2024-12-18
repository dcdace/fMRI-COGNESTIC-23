% ======================================================================
% dace.apsvalka@mrc-cbu.cam.ac.uk (2023)
%
% After preprocessing, create outputs of motion-correction (realignment)
% parameters. 
%
% Creates .png images for each subject displaying realignment parameters
% for each run. 
% And creates 2 group aggregated .csv files: max_mm and max_dg. The
% tables show, for each subject (rows) and each run (columns) the maximum
% amount of movement in that run. 
%
% ======================================================================

% Add path to SPM12 
addpath('/imaging/local/software/spm_cbu_svn/releases/spm12_latest/')

% Location of the preprocessed data
datadir = '/imaging/correia/da05/workshops/2023-09-COGNESTIC/demo/FaceRecognition/data/bids/derivatives/SPM12';

task = 'tnt';

% Get all sujbjects
subs = cellstr(spm_select('List',datadir, 'dir','^sub-'));
nsub = numel(subs);

% Loop through subjects
for s = 1:nsub
    sub = subs{s};
    
    disp(['---subject ' sub ' -----']);

    rp_files = cellstr(spm_select('FPList', fullfile(datadir, sub, 'func'), ['^.*task-' task '_.*\.txt$']));
    saveMovement = fullfile(datadir, 'movement');
    if ~exist(saveMovement,'dir')
        mkdir(saveMovement);
    end
    motname = fullfile(saveMovement, [sub '_task-' task '_' date '.png']);
    plotNr = 0;
    printfig = figure(1);
    set(gcf, 'Position', get(0, 'Screensize'));
    set(printfig, 'Name', ['Motion parameters: subject ' sub], 'Visible', 'on');
        
    nruns = length(rp_files);
    for i = 1:nruns
        b = rp_files{i};
        loadmot = load(b);
        
        % Max mm
        Max_mm{s,1}      = sub;
        Max_mm(s,i+1)    = {max(max(abs(loadmot(:,1:3))))};        
        % Max degrees
        Max_dg{s,1}      = sub;
        Max_dg(s,i+1)    = {max(max(abs(loadmot(:,4:6)*180/pi)))};
                
        % mm
        plotNr = plotNr + 1;                
        subplot(nruns,2,plotNr);
        plot(loadmot(:,1:3));
        set(gca,'FontSize',6);
        grid on;
        title([sub ':run' num2str(i) ', mm'], 'interpreter', 'none');
        % degrees
        plotNr = plotNr + 1;        
        subplot(nruns,2,plotNr);
        plot(loadmot(:,4:6)*180/pi);
        set(gca,'FontSize',6);
        grid on;
        title([sub ':run' num2str(i) ', degrees'], 'interpreter', 'none');
    end
    print(printfig, '-dpng', '-noui', motname);
    close(printfig)
   
end
% Save max movements to .csv files
fname = fullfile(saveMovement, ['task-' task '_max_mm.csv']);
T_mm = cell2table(Max_mm);
writetable(T_mm, fname, 'WriteVariableNames', false)

fname = fullfile(saveMovement, ['task-' task '_max_dg.csv']);
T_dg = cell2table(Max_dg);
writetable(T_dg, fname, 'WriteVariableNames', false)
