!! PROGRAM WRITTEN TO CONVERT PSEUDOPOTENTIAL FROM HGH/NLCC TO  UPF format
!! USED IN Quantum Espresso 
!! Written by Santanu Saha, University of Basel, April 2014
!! Under the supervision S.Goedecker
!! Parts of the Program were used from the Conversion Program obtained from QE Group
program hgh2qe
 implicit real*8 (a-h,o-z)
 parameter ( lmx=5, lpmx= 4, nsmx=2 )
 allocatable rr(:),rab(:),pot_loc(:),pot_nlcc(:),pot_Dij(:,:),rhoatom(:)
 dimension r_l(4),gpot(4),gcore(4),psppar(6,4,2),hsep(6,4,2),lproj(12),&
    nproj(4)
 character(100)::author,time,functional,forline
 character(3)::func,psname
 character(14)::filename
 character(2)::elname
 character(len=2), parameter :: symbol_(94)=(/' H','He',        &
         'Li','Be',' B',' C',' N',' O',' F','Ne',   &
         'Na','Mg','Al','Si',' P',' S','Cl','Ar',   &
         ' K','Ca','Sc','Ti',' V','Cr','Mn','Fe','Co','Ni',&
              'Cu','Zn','Ga','Ge','As','Se','Br','Kr',     &
         'Rb','Sr',' Y','Zr','Nb','Mo','Tc','Ru','Rh','Pd',&
              'Ag','Cd','In','Sn','Sb','Te',' I','Xe',     &
         'Cs','Ba','La','Ce','Pr','Nd','Pm','Sm','Eu','Gd',&
                             'Tb','Dy','Ho','Er','Tm','Yb',&
                   'Lu','Hf','Ta',' W','Re','Os','Ir','Pt',&
              'Au','Hg','Tl','Pb','Bi','Po','At','Rn',     &
         'Fr','Ra','Ac','Th','Pa',' U','Np','Pu'/)




 !! READ HGH pseudopotential
 nproj=0
 lproj=-1
 call readpsp (lpx,r_l,gpot,gcore,psppar,rcore,nloc,rloc,znuc,zion,ixc, &
      ipspcod,lproj,nproj,nkbeta)
 if (ixc==-101130.or.ixc==11)func='pbe'
 if (ixc==-20.or.ixc==1)func='lda'
 !psname='hgh'
 !elname=symbol_(int(znuc))
 !if ( elname(1).eqv." ") then
 ! write(filename,'(a1,a1,a3,a1,a3,a4)')elname(2),'.',func,'-',psname,'.UPF'
 !else
 ! write(filename,'(a2,a1,a3,a1,a3,a4)')elname,'.',func,'-',psname,'.UPF'
 !end if
 !open (unit=6,file=filename)

 !! PSP INFO !!
 write(6,'(a)')'<UPF version="2.0.1">'
 write(6,'(a)')'  <PP_INFO>'
 write(6,'(a)')'    Generated in analytical, separable form'
 if (ipspcod==2.or.ipspcod==3) then
   write(author,'(a34)')'Goedecker/Hartwigsen/Hutter/Teter"'
   write(6,'(a)')'    Author: Goedecker/Hartwigsen/Hutter/Teter'
   write(time,'(a43)')'Phys.Rev.B58, 3641 (1998);B54, 1703 (1996)"'
   write(6,'(a)')'    Generation date: Phys.Rev.B58, 3641 (1998); &
                        B54, 1703 (1996)'
 else if (ipspcod==10) then
   write(author,'(a40)')'Krack/Goedecker/Hartwigsen/Hutter/Teter"'
   write(6,'(a)')'    Author: Krack/Goedecker/Hartwigsen/Hutter/Teter'
   write(time,'(a35)')'Theor. Chem. Acc(2005) 114:145-152"'
   write(6,'(a)')'    Generation date: Theor. Chem. Acc(2005) 114:145-152'
 else if (ipspcod==12) then
   write(author,'(a50)')'Willand/Goedecker/Genovese/Deutsch/Sadeghi/Deb/Mayagoitia/Kvashnin"'
   write(6,'(a)')'    Author:Willand/Goedecker/Genovese/Deutsch/Sadeghi/Deb/ &
                        Mayagoitia/Kvashnin'
   write(time,'(a34)')'J. Chem. Phys. 138, 104109 (2013)"'
   write(6,'(a)')'    Generation date: J. Chem. Phys. 138, 104109 (2013)'
 end if

 
 write(6,'(a)')'    Pseudopotential type: NC'
 if (int(znuc) <= 0 .or.int(znuc) > 94) then
    stop "Wrong zatom value"
 end if
 write(6,'(a13,a2)')'    Element: ',symbol_(int(znuc))
 if (ixc==-20) then
   write(6,'(a)')'    Functional: SLA-PZ-NOGX-NOGC'
   write(functional,'(a17)')'SLA-PZ-NOGX-NOGC"'
 else if (ixc==-101130) then
   write(functional,'(a15)')'SLA-PW-PBX-PBC"'
   write(6,'(a)')'    Functional: SLA-PW-PBX-PBC'
 end if
 write(6,*)
 write(6,'(a)')'    Suggested minimum cutoff for wavefunctions:   0. Ry'
 write(6,'(a)')'    Suggested minimum cutoff for charge density:   0. Ry'
 write(6,'(a)')'    The Pseudo was generated with a Non-Relativistic Calculation'
 write(6,'(a)')'    Local Potential: unknown format, L component and cutoff &
                radius: -3   0.0000'
 write(6,*)
 write(6,'(a)')'    Valence configuration:' 
 write(6,'(a)')'    nl pn  l   occ       Rcut    Rcut US       E pseu'
 write(6,*)
 write(6,'(a)')'    Generation configuration: not available.'
 write(6,'(a)')'    Converted from CPMD format using cpmd2upf v.5.0.1 - &
                     PG 10Jul2012'
 write(6,'(a)')'    Contains atomic orbitals generated by ld1.x - use with care'
 write(6,'(a)')'  </PP_INFO>'  !! END OF PSP INFO
 write(6,'(a)')'  <!--                               -->'
 write(6,'(a)')'  <!-- END OF HUMAN READABLE SECTION -->'
 write(6,'(a)')'  <!--                               -->'
 write(6,'(a)')'  <PP_HEADER generated="Generated in analytical, separable form"'
 write(6,'(a21,a)')'             author="',author
 write(6,'(a19,a)')'             date="',time
 write(6,'(a)')'             comment="Contains atomic orbitals generated by ld1.x - use with care"'
 write(6,'(a22,a2,a1)')'             element="',symbol_(int(znuc)),'"'
 write(6,'(a)')'             pseudo_type="NC"'
 write(6,'(a)')'             relativistic="no"'
 write(6,'(a)')'             is_ultrasoft="F"'
 write(6,'(a)')'             is_paw="F"'
 write(6,'(a)')'             is_coulomb="F"'
 write(6,'(a)')'             has_so="F"'
 write(6,'(a)')'             has_wfc="F"'
 write(6,'(a)')'             has_gipaw="F"'
 write(6,'(a)')'             paw_as_gipaw="F"'
 if (ipspcod==12) then
   write(6,'(a)')'             core_correction="T"'
 else
   write(6,'(a)')'             core_correction="F"'
 end if
 write(6,'(a25,a)')'             functional="',functional
 write(6,'(a24,1pe22.15e3,a)')'             z_valence="',zion,'"'
 write(6,'(a)')'             total_psenergy="0.000000000000000E+000"'
 write(6,'(a)')'             wfc_cutoff="0.000000000000000E+000"'
 write(6,'(a)')'             rho_cutoff="0.000000000000000E+000"'
 if((lpx-1).ge.0)write(6,'(a20,i1,a)')'             l_max="',lpx-1,'"'
 if((lpx-1).lt.0)write(6,'(a20,i2,a)')'             l_max="',lpx-1,'"'
 write(6,'(a)')'             l_max_rho="0"'
 write(6,'(a)')'             l_local="-3"'



 !! SETTING UP RADIAL GRID
 z=znuc
 fact=1.d0
 xmin = -7.0d0
 amesh=0.0125d0*fact  !! Modify this value to increase the no of grid points
 rmax =100.0d0
 mesh = 1 + (log(z*rmax)-xmin)/amesh
 mesh = (mesh/2)*2+1 ! mesh is odd (for historical reasons?)
 allocate (rr(mesh),rab(mesh),pot_loc(mesh),pot_nlcc(mesh),pot_Dij(nkbeta,nkbeta),&
           rhoatom(mesh))
 do i=1, mesh
   rr(i) = exp (xmin+(i-1)*amesh)/z
   !!r(i)=exp[(i-1)*amesh]*r(1)
   rab(i)= rr(i)*amesh
 end do

 if(mesh.lt.1000)write(6,'(a24,i3,a1)')'             mesh_size="',mesh,'"'
 if((mesh.ge.1000).and.(mesh.lt.10000))write(6,'(a24,i4,a1)')'             mesh_size="',mesh,'"'
 if(mesh.ge.10000)write(6,'(a24,i5,a1)')'             mesh_size="',mesh,'"'
 write(6,'(a)')'             number_of_wfc=" 0"'
 if(nkbeta.lt.10)write(6,'(a29,i1,a3)')'             number_of_proj="',nkbeta,'"/>'
 if(nkbeta.ge.10)write(6,'(a29,i2,a3)')'             number_of_proj="',nkbeta,'"/>'


 rmax=rr(mesh)
 xmin=log(z*rr(1))
 if(mesh.lt.1000) then
   50 format (a15,1pe22.15e3,a8,i3,a8,1pe23.15e3,a8,1pe22.15e3,a1)
   write(6,50)'  <PP_MESH dx="',amesh,'" mesh="',mesh,'" xmin="',xmin,'" rmax="',rmax,'"'
   write(6,'(a7,1pe22.15e3,a2)')'zmesh="',z,'">'
   write(6,'(a28,i3,a)')'   <PP_R type="real" size="',mesh,'" columns="4">'
   write(6,'(4(1x,1pe22.15e3,1x))')rr
   write(6,'(a)')'    </PP_R>'
   write(6,'(a30,i3,a)')'    <PP_RAB type="real" size="',mesh,'" columns="4">'
 else if((mesh.ge.1000).and.(mesh.lt.10000)) then
   51 format (a15,1pe22.15e3,a8,i4,a8,1pe23.15e3,a8,1pe22.15e3,a1)
   write(6,51)'  <PP_MESH dx="',amesh,'" mesh="',mesh,'" xmin="',xmin,'" rmax="',rmax,'"'
   write(6,'(a7,1pe22.15e3,a2)')'zmesh="',z,'">'
   write(6,'(a28,i4,a)')'   <PP_R type="real" size="',mesh,'" columns="4">'
   write(6,'(4(1x,1pe22.15e3,1x))')rr
   write(6,'(a)')'    </PP_R>'
   write(6,'(a30,i4,a)')'    <PP_RAB type="real" size="',mesh,'" columns="4">'
 else if(mesh.ge.10000) then
   52 format (a15,1pe22.15e3,a8,i5,a8,1pe23.15e3,a8,1pe22.15e3,a1)
   write(6,52)'  <PP_MESH dx="',amesh,'"mesh="',mesh,'" xmin="',xmin,'" rmax="',rmax,'"'
   write(6,'(a7,1pe22.15e3,a2)')'zmesh="',z,'">'
   write(6,'(a28,i5,a)')'   <PP_R type="real" size="',mesh,'" columns="4">'
   write(6,'(4(1x,1pe22.15e3,1x))')rr
   write(6,'(a)')'    </PP_R>'
   write(6,'(a30,i5,a)')'    <PP_RAB type="real" size="',mesh,'" columns="4">'
 end if

 write(6,'(4(1x,1pe22.15e3,1x))')rab
 write(6,'(a)')'    </PP_RAB>'
 write(6,'(a)')'  </PP_MESH>'
 !! END of setting up and writing Radial Grid and Radial Weights



 call vloc (mesh,nloc,rloc,zion,rr,gpot,pot_loc) !! Local Potential
 if (ipspcod==12)call vnlcc (mesh,znuc,zion,rcore,gcore,rr,pot_nlcc)  !! NLCC
 !! Non-Local Potential
 call vnonloc (mesh,nkbeta,ipspcod,lpx,psppar,r_l,rr,pot_Dij,lproj,nproj)
 write(6,'(a)')'  <PP_PSWFC>'
 write(6,'(a)')'  </PP_PSWFC>'
 
! fourpi=16.d0*datan(1.d0)
! totrho=0.d0
! rcov=1.304d0 
! do imesh=1,mesh
!  r=rr(imesh)
!  rhoatom(imesh)=fourpi*r**2*r**(3.d0/2.d0)*exp(-0.5d0*((r-0.52*rcov)/rcov)**2)
!  totrho=totrho+rhoatom(imesh)*rab(imesh)
! end do
! anorm=zion/totrho
! rhoatom=anorm*rhoatom
! !write(21,*)'totrho,anorm,anorm1,zion',totrho,anorm,anorm1,zion
! !write(21,*)'diff',abs(totrho-totrho1)
! !write(21,'(4e25.17)')rhoatom
! !testrho=0.d0
! !do imesh=1,mesh
! !  testrho=testrho+rhoatom(imesh)*rab(imesh)
! !end do
! !write(21,*)'testrho',testrho

 call interpolate(znuc,mesh,amesh,rr,rhoatom)
  
 if(mesh.lt.1000)write(6,'(a32,i3,a)')'  <PP_RHOATOM type="real" size="',mesh,'" columns="4">'
 if((mesh.ge.1000).and.(mesh.lt.10000))write(6,'(a32,i4,a)')'  <PP_RHOATOM type="real" size="',mesh,'" columns="4">'
 if(mesh.ge.10000)write(6,'(a32,i5,a)')'  <PP_RHOATOM type="real" size="',mesh,'" columns="4">'
 write(6,'(4(1x,1pe22.15e3,1x))')rhoatom
 write(6,'(a)')'  </PP_RHOATOM>'
 write(6,'(a)')'</UPF>'
 close(6)
end program hgh2qe


!! LOCAL PART of PSP
subroutine vloc (mesh,nloc,rloc,zion,rr,gpot,pot_loc)
 implicit real*8 (a-h,o-z)
 dimension rr(mesh),gpot(4),pot_loc(mesh)
 pot_loc=0.d0
 do i=1,mesh
   a=rr(i)/rloc
   pot_loc(i)=-zion*derf(a/dsqrt(2.d0))/rr(i)
   factor=0.d0
   do j=1,nloc
     factor=factor+gpot(j)*a**(2.d0*j-2.d0)
   end do
   pot_loc(i)=pot_loc(i)+factor*exp(-0.5d0*a*a)
 end do
 pot_loc=pot_loc*2.d0
 if(mesh.lt.1000)write(6,'(a30,i3,a)')'  <PP_LOCAL type="real" size="',mesh,'" columns="4">'
 if((mesh.ge.1000).and.(mesh.lt.10000))write(6,'(a30,i4,a)')'  <PP_LOCAL type="real" size="',mesh,'" columns="4">'
 if(mesh.ge.10000)write(6,'(a30,i5,a)')'  <PP_LOCAL type="real" size="',mesh,'" columns="4">'
 write(6,'(4(1pe23.15e3,2x))')pot_loc
 write(6,'(a)')'  </PP_LOCAL>'
end subroutine vloc
!! End of setting Vloc


!! NLCC PART OF PSP
subroutine vnlcc (mesh,znuc,zion,rcore,gcore,rr,pot_nlcc)
 implicit real*8 (a-h,o-z)
 dimension rr(mesh),pot_nlcc(mesh),gcore(4) 
 pot_nlcc=0.d0
 pi=4.d0*datan(1.d0)
 sqrt2pi=dsqrt(2.d0*pi)
 factor=gcore(1)/(sqrt2pi*rcore)**3.d0
 !!factor=gcore(1)
 do i=1,mesh
   a=(rr(i)/rcore)**2.d0
   pot_nlcc(i)=factor*exp(-a*0.5d0)
 end do
 !!pot_nlcc=2.d0*pot_nlcc
 write(6,*)' <PP_NLCC>'
 write(6,'(4(1x,1pe22.15e3,1x))')pot_nlcc
 write(6,*)' </PP_NLCC>'
end subroutine vnlcc
!! End of setting Vnlcc






!! NONLOCAL PART OF PSP
subroutine vnonloc (mesh,nkbeta,ipspcod,lpx,psppar,r_l,rr,pot_Dij,lproj,nproj)
 implicit real*8 (a-h,o-z)
 dimension rr(mesh),psppar(6,4,2),pot_Dij(nkbeta,nkbeta),H(3,3),r_l(lpx),  &
           hsep(6,4,2),ofdcoef(3,4),lproj(nkbeta),proj(mesh,nkbeta),nproj(4),  &
           rcut(nkbeta),icut(nkbeta),pot_loc(mesh)  !! 3 projectors * 4 l values
 character(2):: label
 hsep=0.d0
 
!! Setting Up the Projectors 
 nsproj=0;npproj=0;ndproj=0;nfproj=0;jproj=0
 do iproj=1,nkbeta
   if (lproj(iproj)==0) then
      nsproj=nsproj+1
      jproj=nsproj
   else if (lproj(iproj)==1) then
      npproj=npproj+1
      jproj=npproj
   else if (lproj(iproj)==2) then
      ndproj=ndproj+1
      jproj=ndproj
   else if (lproj(iproj)==3) then
      nfproj=nfproj+1
      jproj=nfproj
   end if
   lq=lproj(iproj)
   rnrm=1.d0/dsqrt(.5d0*gamma(lq+1.5d0+2.d0*jproj-2.d0)*  &
         r_l(lq+1)**(2*lq+3+4*(jproj-1)))
   do imesh=1,mesh
       r=rr(imesh)
       pr=rnrm*r**(lq+2*(jproj-1))*exp(-.5d0*(r/r_l(lq+1))**2)
       proj(imesh,iproj)=2.d0*pr*r
   end do
   do imesh=mesh,1,-1
      if (abs(proj(imesh,iproj)).gt.1d-12)exit
   end do
   if (imesh<2) then
      write(*,*)'Error in Rcut'      
   else if (mod(imesh,2).ne.0) THEN
      ! even index
      icut(iproj) = imesh
      rcut(iproj)=rr(icut(iproj))
   else if ((imesh.lt.mesh).and.(mod(imesh,2).eq.0)) then
      ! odd index
      icut(iproj) = imesh+1
      rcut(iproj)=rr(icut(iproj))
   else
      icut(iproj) = mesh
      rcut(iproj)=rr(icut(iproj))
   end if

 end do
!! End of Setting up of Projectors

 write(6,'(a)')'  <PP_NONLOCAL>'
 nsproj=0;npproj=0;ndproj=0;nfproj=0
 do ikbeta=1,nkbeta
   if(lproj(ikbeta)==0) then 
     nsproj=nsproj+1
     write(label,'(i1,a1)')nsproj,'S'
   else if(lproj(ikbeta)==1) then
     npproj=npproj+1
     write(label,'(i1,a1)')npproj,'P'
   else if(lproj(ikbeta)==2) then
     ndproj=ndproj+1
     write(label,'(i1,a1)')ndproj,'D'
   else if(lproj(ikbeta)==3) then
     nfproj=nfproj+1
     write(label,'(i1,a1)')nfproj,'F'
   end if
   if (icut(ikbeta).lt.1000) then
     if (mesh.lt.1000) then
       55 format (a13,i1,a19,i3,a21,i1,a9,a2,a20,i1,a23,i3,a1)
       write(6,55)'<PP_BETA.',ikbeta,'type="real" size="',mesh,'" columns="4" index="',ikbeta,'" label="',&
       label,'" angular_momentum="',lproj(ikbeta),'" cutoff_radius_index="',icut(ikbeta),'"'       
     else
       56 format (a13,i1,a19,i4,a21,i1,a9,a2,a20,i1,a23,i3,a1)
       write(6,56)'<PP_BETA.',ikbeta,'type="real" size="',mesh,'" columns="4" index="',ikbeta,'" label="',&
       label,'" angular_momentum="',lproj(ikbeta),'" cutoff_radius_index="',icut(ikbeta),'"'
     end if
   else
     if (mesh.lt.10000) then
       57 format (a13,i1,a19,i4,a21,i1,a9,a2,a20,i1,a23,i4,a1)
       write(6,57)'<PP_BETA.',ikbeta,'type="real" size="',mesh,'" columns="4" index="',ikbeta,'" label="',&
       label,'" angular_momentum="',lproj(ikbeta),'" cutoff_radius_index="',icut(ikbeta),'"'
     else
       58 format (a13,i1,a19,i5,a21,i1,a9,a2,a20,i1,a23,i4,a1)
       write(6,58)'<PP_BETA.',ikbeta,'type="real" size="',mesh,'" columns="4" index="',ikbeta,'" label="',&
       label,'" angular_momentum="',lproj(ikbeta),'" cutoff_radius_index="',icut(ikbeta),'"'
    end if
   end if
   write(6,'(a15,1pe22.15e3,a)')'cutoff_radius="',rcut(ikbeta),'" ultrasoft_cutoff_radius="0.000000000000000E+000">'
   write(6,'(4(1x,1pe22.15e3,1x))')proj(:,ikbeta)
   write(6,'(a14,i1,a)')'</PP_BETA.',ikbeta,'>'
 end do


!! Setting Up the hsep  elements of HGH psp
 if (ipspcod == 2) then !GTH case
!   offdiagonal elements are zero per definition.
!   simply rearrange hij and fill zero elements
    do l=1,lpx
       hsep(1,l,1)=psppar(1,l,1)  !h11
       hsep(2,l,1)=0.0d0          !h12
       hsep(3,l,1)=psppar(2,l,1)  !h22
       hsep(4,l,1)=0.0d0          !h13
       hsep(5,l,1)=0.0d0          !h23
       hsep(6,l,1)=psppar(3,l,1)  !h33
!      in the polarized or relativistic case,
!      we assume all kij to be zero,
!      i.e. same up and down projectors
    end do
 else if (ipspcod == 3) then !HGH diagonal case
!   we need to compute the offdiagonal elements with the following coeffs
    ofdcoef(1,1)=-0.5d0*sqrt(3.d0/5.d0) !h2
    ofdcoef(2,1)=0.5d0*sqrt(5.d0/21.d0) !h4
    ofdcoef(3,1)=-0.5d0*sqrt(100.0d0/63.d0) !h5

    ofdcoef(1,2)=-0.5d0*sqrt(5.d0/7.d0) !h2
    ofdcoef(2,2)=1.d0/6.d0*sqrt(35.d0/11.d0) !h4
    ofdcoef(3,2)=-7.d0/3.d0*sqrt(1.d0/11.d0) !h5

    ofdcoef(1,3)=-0.5d0*sqrt(7.d0/9.d0) !h2
    ofdcoef(2,3)=0.5d0*sqrt(63.d0/143.d0) !h4
    ofdcoef(3,3)=-9.d0*sqrt(1.d0/143.d0) !h5

    ofdcoef(1,4)=0.0d0 !h2
    ofdcoef(2,4)=0.0d0 !h4
    ofdcoef(3,4)=0.0d0 !h5

!   this could possibly be done in a simpler way ...
    do l=1,lpx
       hsep(1,l,1)=psppar(1,l,1)
       hsep(2,l,1)=psppar(2,l,1)*ofdcoef(1,l)
       hsep(3,l,1)=psppar(2,l,1)
       hsep(4,l,1)=psppar(3,l,1)*ofdcoef(2,l)
       hsep(5,l,1)=psppar(3,l,1)*ofdcoef(3,l)
       hsep(6,l,1)=psppar(3,l,1)
    end do
 end if

 if (ipspcod>9) then !HGH-K or HGH case,
!  psppar holds hij and kij in HGHK convention
!  fill hsep(up,dn) upper diagonal col by col, as needed for the fit
! for a nonrelativistic calculation, discard the kij elements
    do l=1,lpx

       hsep(1,l,1)=psppar(1,l,1) !h11
       hsep(2,l,1)=psppar(4,l,1) !h12
       hsep(3,l,1)=psppar(2,l,1) !h22
       hsep(4,l,1)=psppar(5,l,1) !h13
       hsep(5,l,1)=psppar(6,l,1) !h23
       hsep(6,l,1)=psppar(3,l,1) !h33



!      hsep(1,l,1)=psppar(1,l,1) !h11
!      hsep(2,l,1)=psppar(4,l,1) !h12
!      hsep(3,l,1)=psppar(2,l,1) !h22
!      hsep(4,l,1)=psppar(5,l,1) !h13
!      hsep(5,l,1)=psppar(6,l,1) !h23
!      hsep(6,l,1)=psppar(3,l,1) !h33
    end do
 end if
 

 H=0.d0
 pot_Dij=0.d0
! write(2,*)"l,ix,iy,ip,jp,pot_Dij ,H"
 do l=1,lpx
    H(1,1)=hsep(1,l,1)
    H(1,2)=hsep(2,l,1)
    H(2,2)=hsep(3,l,1)
    H(1,3)=hsep(4,l,1)
    H(2,3)=hsep(5,l,1)
    H(3,3)=hsep(6,l,1)
    do ip=1,nproj(l)
      do jp=ip,nproj(l)
        ix=ip;iy=jp
        if (l==2)ix=ix+nproj(1)
        if (l==2)iy=iy+nproj(1)
        if (l==3)ix=ix+nproj(1)+nproj(2)
        if (l==3)iy=iy+nproj(1)+nproj(2)
        if (l==4)ix=ix+nproj(1)+nproj(2)+nproj(3)
        if (l==4)iy=iy+nproj(1)+nproj(2)+nproj(3)
        pot_Dij(ix,iy)=H(ip,jp)
!        write(2,*)l,ix,iy,ip,jp,pot_Dij(ix,iy),H(ip,jp)
      end do
    enddo
!   write(2,*)"   "
 end do
 pot_Dij=pot_Dij/2.d0
 do i=1,nkbeta
   do j=1,i-1
      pot_Dij(i,j)=pot_Dij(j,i)
   end do
 end do
 if ((nkbeta*nkbeta).lt.10) then
   write(6,'(a30,i1,a14)')'<PP_DIJ type="real" size="',nkbeta*nkbeta,'" columns="4">'
 else
   write(6,'(a30,i2,a14)')'<PP_DIJ type="real" size="',nkbeta*nkbeta,'" columns="4">'
 end if
 write(6,'(4(1pe23.15e3,2x))')pot_Dij
 write(6,'(a)')'    </PP_DIJ>'
 write(6,'(a)')'  </PP_NONLOCAL>'
end subroutine vnonloc



!! Reading the psppar file of HGH pseudopotential
subroutine readpsp (lpx,r_l,gpot,gcore,psppar,rcore,nloc,rloc,znuc,zion,ixc, &
      ipspcod,lproj,nproj,nkbeta)
 implicit real*8 (a-h,o-z)
 parameter ( lmx=5, lpmx= 4, nsmx=2 )
 dimension r_l2(4),r_l(4),gpot(4),gcore(4),psppar(6,4,2),&
             lproj(12),nproj(4)
 character (200) :: string
 logical exists

 inquire(file='psppar',exist=exists)
 if(.not.exists)then
   write(2,*)'No psppar file to convert'
   stop
 end if
 open(unit=11,file='psppar',form='formatted',  &
      status='unknown')
 !The first line is usually for comments only.
 gcore=0d0
 rcore=-1d0
 !Read 1st line into a string
 read(11,'(a)',iostat=ierr) string
 if(ierr/=0)then
     write(2,*)
     write(2,*)'                NOTICE'
     write(2,*)
     write(2,*)'The first line of psppar is just comment'
!    stop
     ierr=0
 end if


 read(11,*,iostat=ierr) znuc, zion
! write(2,*)int(znuc),int(zion),"znuc,zion"
 if(ierr/=0)then
     write(2,*)
     write(2,*)'             WARNING'
     write(2,*)'Could not read nuclear and valence charges'
     write(2,*)'on the second line of psppar.'
     stop
 end if


 read(11,*,iostat=ierr) ipspcod,ixc
! write(2,*)ipspcod,ixc,"ipspcod,ixc"
 if(ierr/=0)then
!    no need to call error handler, shared input file
     write(2,*)
     write(2,*)'             WARNING'
     write(2,*)'Could not read PSP format and iXC from'
     write(2,*)'the third line of psppar.'
     stop
 end if



!for convenience: convert LDA and PBE ixc from         
!abinit to libxc
 if (ixc==1) then
!     write(2,*)'LDA pade: ixc = 1 or -20 are equivalent.'
     ixc=-20
 end if
 if (ixc==11) then
!     write(2,*)'PBE: ixc = 11 or -101130 are equivalent.'
     ixc=-101130
 end if


 psppar = 0.d0
 if (ipspcod==10.or.ipspcod==12)then
!    write(2,*)'HGH matrix format'
!   ! HGH-K format: all projector elements given.
    ! dimensions explicitly defined for nonzero output.

!   ! local part
    gpot=0.d0
    read(11,*)rloc,nloc,(gpot(j),j=1,nloc)
    !write(2,*)rloc,nloc,(gpot(j),j=1,nloc)
    read(11,*)lpx
    !write(6,*)lpx,'lpx'

!   lpx is here equivalent to nsep. Previous versions used
!   it as the max l quantum number, subracting one.
!   Here, 0 does not mean s only, but a purely local psppar.
!   Negative is no longer used for local, but for r_l2.
    if (lpx-1 .gt. lmx ) then
!      write(2,*) 'array dimension problem: lpx,lpmx',lpx,lpmx
      stop
    end if
!   ! separable part
!   ! relativistic; hij are averages, kij separatons of hsep
    do l=1,lpx !l channels
       ! add some line to read r_l2 if nprl < 0
       read(11,'(a)') string
!       write(2,*)string
       read(string,*) r_l(l),nprl
       nproj(l)=nprl
       if(nprl>0)then
          read(string,*) r_l(l),nprl,  &
              psppar(1,l,1),(psppar(j+2,l,1),  &
                                    j=2,nprl)  !h_ij 1st line
          do i=2,nprl
!            spin up
             read(11,*) psppar(i,l,1),(psppar(i+j+1,l,1),  &
                                            j=i+1,nprl)!remaining h_ij 
!             write(2,*) i,psppar(i,l,1),(i+j+1, psppar(i+j+1,l,1),  &
!                                            j=i+1,nprl)!remaining h_ij 
          end do
!          do i=1,6
!            write(2,*)"l=",l,"i=",i,psppar(i,l,1)
!          end do
!         disable r_l2, i.e set it equal to r_l
          r_l2(l) = r_l(l)
       else if (nprl<0) then
!         if nprl is negative, read r_l2 from the 2nd line of hij
          nprl=-nprl
          read(string,*) r_l(l),i,  &
              psppar(1,l,1),(psppar(j+2,l,1),  &
                                    j=2,nprl)  !h_ij 1st line
          read(11,*)r_l2(l), psppar(2,l,1),(psppar(2+j+1,l,1),  &
                                            j=2+1,nprl)!2nd line
          if(nprl==3) read(11,*) psppar(3,l,1)! third line
       end if

!      there are no kij in the s-projector
       if (l==1) cycle
        do i=1,nprl
           read(11,*) psppar(i,l,2),(psppar(i+j+1,l,2),  &
                                  j=i+1,nprl)!all k_ij
!           write(2,*) psppar(i,l,2),(psppar(i+j+1,l,2),  &
!                                  j=i+1,nprl)!all k_ij
        end do
    end do ! loop over l
    do l=1,lpx
      k=nproj(l)
      do n=k,1,-1
        if (psppar(n,l,1).eq.0.d0)nproj(l)=nproj(l)-1
      end do
    end do 

    if(ipspcod==12)then
       ! this psppar uses nlcc
       read(11,*,iostat=ierr) rcore, qcore
!       write(2,*) rcore, qcore,"rcore,qcore"
       if(ierr/=0)then
!          write(2,*)' pspcod=12 implies nlcc data on the last & 
!                    line,'
!          write(2,*)' but rcore and qcore could not be read!'
!          rcore= -1d0
       else
          !compute gcore(1) from qcore. gcore(2:4) are
          !always zero, but we keep them for future testing.
          fourpi = 16.d0*datan(1.d0)
          sqrt2pi = dsqrt(fourpi*0.5d0)
          !gcore(1) = fourpi* qcore * (znuc-zion) / &
          !  (sqrt2pi*rcore)**3
          !qcore=qcore*fourpi/(sqrt2pi*rcore)**3!! qcore
          !!stores the value of constant and the qcore itself
          gcore(1)=(znuc-zion)*qcore
       end if
    end if

 elseif(ipspcod==3)then
!      write(2,*)'HGH diagonal format'
!     HGH diagonal part case
!     technically, lpx is fixed at the max value of
      lpx=4
      gpot=0.d0
      read(11,*) rloc,(gpot(j),j=1,4)
!      write(2,*) rloc,(gpot(j),j=1,4)
      read(11,*) r_l(1),psppar(1:3,1,1)
!      write(2,*) r_l(1),psppar(1:3,1,1)
      nproj(1)=3
      do i=3,1,-1
         if (psppar(i,1,1)==0.d0)&
          nproj(1)=nproj(1)-1
      end do
      do l=2,4
         read(11,*) r_l(l),psppar(1:3,l,1)
!         write(2,*) r_l(l),psppar(1:3,l,1)
         nproj(l)=3
         do i=3,1,-1
           if (psppar(i,l,1)==0.d0)&
           nproj(l)=nproj(l)-1
         end do
         read(11,*)        psppar(1:3,l,2)
!         write(2,*)        psppar(1:3,l,2)
      end do
 elseif(ipspcod==2)then
!      write(2,*)'GTH format'
!     ! GTH case
!     technically, lpx is fixed at s and p
      lpx=2
      gpot=0.d0
      read(11,*) rloc,(gpot(j),j=1,4)
!      write(2,*) rloc,(gpot(j),j=1,4)
      read(11,*) r_l(1),psppar(1:2,1,1)
      nproj(1)=2
      if (r_l(1).eq.0.d0) then
         nproj(1)=0
      else
         if (psppar(1,1,1).eq.0.d0)nproj(1)=0
         if (psppar(2,1,1).eq.0.d0)nproj(1)=1
      end if
!      write(2,*) r_l(1),psppar(1:2,1,1)
      read(11,*) r_l(2),psppar(1  ,2,1)
      nproj(2)=1
      if  (r_l(2).eq.0.d0) then
          nproj(2)=0
      else
         if (psppar(2,1,1).eq.0.d0)nproj(2)=0
      end if
!      write(2,*) r_l(2),psppar(1  ,2,1)
!     for convenience, if we have no p projector:
      if(psppar(1,2,1)<1.d-5) lpx=1
 else
!     no need to call error handler, shared input file
      write(2,*)'               WARNING'
      write(2,*)'pspcod (1st number of 3rd line) read from'
      write(2,*)'psppar is unknown or not supported.'
      write(2,*)'supported are 2,3, or 10,12 not ',ipspcod
      stop
 end if
!done with reading psppar
 close(11)
 iproj=0
 do l=1,lpx
   do i=1,nproj(l)
     iproj=iproj+1
     lproj(iproj)=l-1
   end do
 end do
 nkbeta=sum(nproj)
end subroutine readpsp
