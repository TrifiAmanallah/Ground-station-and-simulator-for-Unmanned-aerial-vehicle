%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Ramène les angles entre + ou - pi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   AngleRADpi=functionRameneAnglepi(AngleRAD);

Anglepi=AngleRAD;
% Si la mesure de phi comprend plusieurs tours.
% on se ramène à + ou - 2*pi
I=find(abs(AngleRAD/(2*pi))>1);
   tamp=AngleRAD(I)-fix(AngleRAD(I)/(2*pi))*2*pi;
   Anglepi(I)=tamp;

% On se ramène mainteant à + ou - pi
Ipi=find(AngleRAD>pi);
   Anglepi(Ipi)=-(2*pi-AngleRAD(Ipi));
Ipii=find(AngleRAD<=-pi);
   Anglepi(Ipii)=2*pi+AngleRAD(Ipii);

if(~isempty(find(AngleRAD>pi + AngleRAD<-pi))==1)
   errordlg({'Erreur conversion des angles'})
end

AngleRADpi=Anglepi;