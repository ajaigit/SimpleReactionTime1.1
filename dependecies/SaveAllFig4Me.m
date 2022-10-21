
% Function to save all generated figures in the specified locations
% This function will create a subfolder with name 'Plot' under parent
% folder
% The name of the all the matlab figures will be the title of the plots
% FigLoc is the location of the parent folder
% Created on '07-Feb-2022 17:30:05'
% Author Ajai Singh

function SaveAllFig4Me(FigLoc)

FolderName = 'Plots';
mkdir(fullfile(FigLoc,FolderName));
TL = fullfile(FigLoc,FolderName);

FigList = findobj(allchild(0),'flat','Type','figure');

for h = 1:length(FigList)
    FHndl = FigList(h);
    Axs = findobj(FHndl,'type','axes');
    FName = Axs.Title.String;
    savefig(FHndl,fullfile(TL,[FName,'.fig']));
end
disp('All Plots Saved!!')
end