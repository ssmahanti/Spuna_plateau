subroutine goal_fun_lin(xzt,yzt,zzt, aver,goal)

real dtk(500)
integer ipskr3(500)

common/krat/nkrat,istkr(500),ipskr(500),ndrkr(500),tobkr(500),trfkr(500)

common/stations/nst,xstat(500),ystat(500),zstat(500)
common/loc_param/res_loc1,res_loc2,w_P_S_diff
common/ray/ nodes,xray(1000),yray(1000),zray(1000)


ncyc_av=5

goal=0
!write(*,*)' xzt=',xzt,' yzt=',yzt,' zzt=',zzt
do ikr=1,nkrat
	xst=xstat(istkr(ikr))
	yst=ystat(istkr(ikr))
	zst=zstat(istkr(ikr))
	ips=ipskr(ikr)
	idr=ndrkr(ikr)
	tobs=tobkr(ikr)
	dist=sqrt((xzt-xst)**2+(yzt-yst)**2+(zzt-zst)**2)
	!write(*,*)' xst=',xst,' yst=',yst,' zst=',zst
	!write(*,*)' dist=',dist
	call straight_line(xzt,yzt,zzt, xst,yst,zst, ips, tmod)

	!write(*,*)' dist=',dist,' tmod=',tmod,' tobs=',tobs
	!write(*,*)' xst=',xst,' yst=',yst,' zst=',zst

	!write(*,*)' tmod=',tmod,' tobs=',tobs,' dt=',tobs-tmod
	trfkr(ikr)=tmod
	dtk(ikr)=tobs-tmod
end do

ipskr3=ipskr
do ikr1=1,nkrat
	if(ipskr(ikr1).eq.1) then
		dtk(ikr1)=tobkr(ikr1)-trfkr(ikr1)
		ipskr3(ikr1)=1
	else
		do ikr2=1,nkrat
			if(ipskr(ikr2).eq.2) cycle
			if(istkr(ikr1).ne.istkr(ikr2)) cycle
			dtk(ikr1)=(tobkr(ikr1)-trfkr(ikr1))-(tobkr(ikr2)-trfkr(ikr2))
			ipskr3(ikr1)=3
			exit
		end do
	end if
	!write(*,*)istkr(ikr1),ipskr(ikr1),ipskr3(ikr1),(tobkr(ikr1)-trfkr(ikr1))*1000., dtk(ikr1)*1000.
end do


! Preliminary average residual :
aver0=0
avw=0
do i=1,nkrat
	if(ipskr3(i).eq.3) cycle
	bbb = 1
	aver0=aver0+dtk(i)*bbb
	avw=avw+bbb
end do
aver0=aver0/avw
!write(*,*)' aver0=',aver0*1000

! Average residual :
313 continue
do icyc_av=1,ncyc_av
	aver=0
	avw=0
	do i=1,nkrat
		if(ipskr3(i).eq.3) cycle

		dt=(dtk(i)-aver0)

		if(abs(dt).gt.res_loc2) then
			aaa=0
		else if(abs(dt).lt.res_loc1) then
			aaa=1
		else
			aaa=(abs(dt)-res_loc2)/(res_loc1-res_loc2)
		end if

		aver=aver + dt * aaa
		avw=avw + aaa
		!write(*,*)dt*1000.,aaa

	end do
	aver=aver/avw
	aver0 = aver0 + aver
	!write(*,*)' aver0=',aver0*1000.,' aver=',aver*1000.,' avw=',avw
end do
aver=aver0

! Compute goal :

goal=0
www=0
do i=1,nkrat

	dt=abs(dtk(i)-aver)
	if(ipskr3(i).eq.3)dt=abs(dtk(i)) 

	if(dt.gt.res_loc2) then
		aaa=0
	else if(dt.lt.res_loc1) then
		aaa=1
	else
		aaa=(dt-res_loc2)/(res_loc1-res_loc2)
	end if

	ccc=1
	if(ipskr3(i).eq.3) ccc = w_P_S_diff


	goal = goal + aaa*ccc
	www = www + ccc
	!write(*,'(2i4,5f9.3)')istkr(i),ipskr3(i),dt*1000.,aaa,ccc,goal
end do
goal = goal / www



return
end