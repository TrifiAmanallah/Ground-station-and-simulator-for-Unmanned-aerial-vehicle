
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Initialization du Horizon Display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global Display	
hold on,
set(gca,'Xtick',[])
set(gca,'Ytick',[])
set(gca,'Position',[0 0 1 1])	%Repère orthonormé et placé sur la feuille
%Ordonnee=ylabel({'\bfTAS\rm';'m/s'})
%set(Ordonnee,'Rotation',0)


% Paramètres étalon de l'affichage
Display.Hauteur=1;
Display.Largeur=Display.Hauteur;	%Le repère doit être orthonormé pour avoir l'angle de gîte réel
	%Rayon de la Rosasse de l'angle de gîte
	r1=3*Display.Largeur/10;
	r2=r1+Display.Largeur/30;
   r3=r1+Display.Largeur/20;
   
  	%Pas d'affichage de l'angle d'assiette
	Display.PasAssiette=r1*180/(pi*25);
   
   axis([-Display.Largeur/2 Display.Largeur/2 -Display.Hauteur/2 Display.Hauteur/2])
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Initialisation Horizon
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
Display.Ciel=patch([-1;-1;1;1]*Display.Largeur/2,[-1;1;1;-1]*Display.Largeur/2,'b');
%set(Display.Ciel,'FaceColor',[0 0.8 1])
set(Display.Ciel,'FaceColor',[0.3 0.6 1])

Display.Terre=patch([-1;-1;1;1]*Display.Largeur/2,[0;-1;-1;0]*Display.Largeur/2,'r');
%set(Display.Terre,'FaceColor',[1 0.8 0.4])
set(Display.Terre,'FaceColor',[0.8 0.6 0.4])

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%        Pitch bar
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
petitebarre=(1/2)*Display.Largeur/10;
moyennebarre=Display.Largeur/10;
grandebarre=2*Display.Largeur/10;
RefTerreX=[petitebarre moyennebarre petitebarre grandebarre moyennebarre moyennebarre]/2;
RefTerreX=[-RefTerreX;RefTerreX];
RefTerreX=[RefTerreX RefTerreX];
RefTerreY=[2.5:2.5:10 15 20]*Display.PasAssiette*pi/180;
RefTerreY=[RefTerreY;RefTerreY];
RefTerreY=[RefTerreY -RefTerreY];
Display.PitchBar=line(RefTerreX,RefTerreY);
set(Display.PitchBar,'Color','w')
set(Display.PitchBar,'LineWidth',2)
TextX=[1.1 1.1 -1.45 -1.45]*grandebarre/2;
TextY=[1 -1 1 -1]*10*pi/180*Display.PasAssiette;
TextT={'10';'10';'10';'10'};
Display.PitchBartext=text(TextX,TextY,TextT);
set(Display.PitchBartext,'Color','w')
clear petitebarre & moyennebarre & grandebarre & RefTerreX & RefTerreY & TextX & TextY & TextT



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Rosase d'angle de gîte
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%r1=3*Display.Largeur/10;
%r2=r1+Display.Largeur/30;
%r3=r1+Display.Largeur/20;
RoseX=[r1*cos(pi/6) r1*cos(pi/4) r1*cos(pi/3) r1*cos(7*pi/18) r1*cos(4*pi/9);
		 r3*cos(pi/6) r2*cos(pi/4) r3*cos(pi/3) r2*cos(7*pi/18) r2*cos(4*pi/9)];
RoseY=[r1*sin(pi/6) r1*sin(pi/4) r1*sin(pi/3) r1*sin(7*pi/18) r1*sin(4*pi/9);
		 r3*sin(pi/6) r2*sin(pi/4) r3*sin(pi/3) r2*sin(7*pi/18) r2*sin(4*pi/9)];
RoseX=[RoseX [0;0] -RoseX];
RoseY=[RoseY [r1;r3] RoseY];
Display.Rosasse=line(RoseX,RoseY)
set(Display.Rosasse,'Color','w')
set(Display.Rosasse,'LineWidth',2)
% Flèche tournante
LargeurF=(1/3)*(Display.Largeur/10);
Display.RosasseFleche=patch([0 1 -1]*LargeurF/2,r1-LargeurF*sin(60*pi/180)*[0 1 1],'w');
set(Display.RosasseFleche,'EdgeColor','w')
Display.RefRosasseFleche=[get(Display.RosasseFleche,'Xdata')';get(Display.RosasseFleche,'Ydata')'];
%Flèche fixe
Display.RosasseFlecheFixe=patch([0 1 -1]*LargeurF/2,r1+LargeurF*sin(60*pi/180)*[0 1 1],'w');
set(Display.RosasseFlecheFixe,'EdgeColor','w')
clear RoseX & RoseY
clear r1 & r2 & r3 & LargeurF



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     Box de la vitesse
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
Display.VitesseBox=patch([0;Display.Largeur/10;Display.Largeur/10;0]-Display.Largeur/2,[1;1;-1;-1]*Display.Largeur/40,'k')
Display.VitesseValue=text(-Display.Largeur/2+5*Display.Largeur/1000,-25*Display.Largeur/10000,'000')
set(Display.VitesseValue,'Color','w')
set(Display.VitesseValue,'Fontsize',12)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%      Box de l'altitude
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Display.AltitudeBox=patch(-[0;1.6*Display.Largeur/10;1.6*Display.Largeur/10;0]+Display.Largeur/2,[1;1;-1;-1]*Display.Largeur/40,'k')
Display.AltitudeValue=text(-1.6*Display.Largeur/10+Display.Largeur/2+5*Display.Largeur/1000,-25*Display.Largeur/10000,'00000')
set(Display.AltitudeValue,'Color','w')
set(Display.AltitudeValue,'Fontsize',12)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Initialisation ligne d'aile avion
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Display.AileDroite=line([Display.Largeur/10 Display.Largeur/10 2*Display.Largeur/10],[-0.5*Display.Hauteur/10 0 0]);
Display.AileGauche=line([-Display.Largeur/10 -Display.Largeur/10 -2*Display.Largeur/10],[-0.5*Display.Hauteur/10 0 0]);
Display.Cockpit=line([-0.1*Display.Largeur/10 0.1*Display.Largeur/10],[0 0])




