FolderName = [pwd,'\FigsExercise'];
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
FigHandle = FigList(iFig);
saveas(FigHandle, ['Fig',num2str(FigHandle.Number)], 'png');    %<---- 'Brackets'
end
movefile('*.png',['./FigsExercise/']);