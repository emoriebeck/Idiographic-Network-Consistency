%Datamatrix to textfile
function []=Data_to_txt(location,object)
%e.g. 'C:\Users\u0073672\Documents\ONDERZOEK\10. Mplus\Granularity\namefile.txt'

data=fopen(location,'wt');

for i=1:size(object,1)
    fprintf(data,strcat(repmat('%6.6f,',1,size(object,2)-1),'%6.6f'),object(i,:));
    fprintf(data,'\n');
end;

fclose('all')