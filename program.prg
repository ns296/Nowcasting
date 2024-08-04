
'Insert folder link into inverted commas as below to set your working folder
cd "H:\Surveillance\Macro-Modelling\2. Project\Nowcasting\Test"

'open dataset (no input required)
wfopen "Dataset latest.xlsx"

'Number of periods to test (no input required)
!periods=9

'how many indicators have you included (please fill)
!number=30

'Forecast Period (which quarter are you trying to forecast, please fill)
%date="2013.2"
%date2="2013q2"

'Calculate yoy growth for variable (no input required)
genr ggdp=@pcy(gdp)


'Set up results table and fill in headings (no inputs required)
table(10,10) table
table(1,1)="Forecast Period"
table(2,1)="Actual"
table(1, !periods+3)="rmse"
table(2, !periods+3)=0

'Prepare the actual values of GDP for comparison (replace 2013q2 with your forecast quarters, keep the inverted commas there)
for !k=0 to !periods
smpl {%date}-!k {%date}-!k

vector y!k
stomna(ggdp,y!k)

!fulldate=@dateval("2013q2","yyyy[q]q")
!foredate=@dateadd(!fulldate,-!k,"q")

table(1,!k+2)=@datestr(!foredate,"yyyy[q]q")
table(2,!k+2)=y!k(1)

delete y!k
next


'--------------------------------------------------------------------------------------------------------
'No further user inputs required from here onwards
'--------------------------------------------------------------------------------------------------------


'calculates yoy growth of indicators which are available, takes average if more than one month available
for !yoy=11 to 10+{!number} 

smpl {%date} {%date}
vector _1_{!yoy}_v
stomna(_1_{!yoy},_1_{!yoy}_v)
vector _2_{!yoy}_v
stomna(_2_{!yoy},_2_{!yoy}_v)
vector _3_{!yoy}_v
stomna(_3_{!yoy},_3_{!yoy}_v)
smpl @all

	if _2_{!yoy}_v(1) = NA then
	genr g_ave_{!yoy}=@pcy(_1_{!yoy})
	else
		if _3_{!yoy}_v(1) = NA then
		genr g_ave_{!yoy}=@pcy(_1_{!yoy}+_2_{!yoy})
		else
		genr g_ave_{!yoy}=@pcy(_1_{!yoy}+_2_{!yoy}+_3_{!yoy})
		endif
	endif

delete _1_{!yoy}_v _2_{!yoy}_v _3_{!yoy}_v 
next

'---------------------------------------------------------------------------------------------
'4 indicators
'---------------------------------------------------------------------------------------------
!fill=3

for !a=11 to 10+{!number}-3
for !b=!a+1 to 10+{!number}-2
for !c=!b+1 to 10+{!number}-1
for !d=!c+1 to 10+{!number}

for !k=0 to !periods
smpl 2006.2-!k {%date}-!k-1

'Estimation
equation eq{!k}{!a}{!b}{!c}{!d}
eq{!k}{!a}{!b}{!c}{!d}.ls ggdp g_ave_{!a} g_ave_{!b} g_ave_{!c} g_ave_{!d} AR(1) AR(2) AR(3) AR(4) C

'Make a model from the estimated equation
eq{!k}{!a}{!b}{!c}{!d}.makemodel(eqmod{!k}{!a}{!b}{!c}{!d})

'State the sample forecast period
smpl {%date}-!k {%date}-!k

'Solve the model for the forecast sample
solve eqmod{!k}{!a}{!b}{!c}{!d}

'Capture the forecast values
vector yf!k
stomna(ggdp_0,yf!k)


'fill in forecast values
table(!fill,1)={!a}{!b}{!c}{!d}
table(!fill,!k+2)=yf!k(1)

'Prepare the actual values of GDP for comparison
vector y!k
stomna(ggdp,y!k)

next

'after all k have been calculated, find rmse over the !periods horizon
!sqerr=0
for !k=1 to !periods
!sqerr=!sqerr+(yf{!k}(1)-y{!k}(1))^2
next

table(!fill,!periods+3)=({!sqerr}/{!periods})^0.5
table(!fill,!periods+4)={!a}
table(!fill,!periods+5)={!b}
table(!fill,!periods+6)={!c}
table(!fill,!periods+7)={!d}

'delete stuff
for !k=0 to !periods
delete eq{!k}{!a}{!b}{!c}{!d}
delete eqmod{!k}{!a}{!b}{!c}{!d}
delete y{!k}
delete yf{!k}
next

're-adjust to the full sample
Smpl @all

!fill=!fill+1

next
next
next
next

'---------------------------------------------------------------------------------------------
'3 indicators
'---------------------------------------------------------------------------------------------
!fill=!fill

for !a=11 to 10+{!number}-2
for !b=!a+1 to 10+{!number}-1
for !c=!b+1 to 10+{!number}
!d=0

for !k=0 to !periods
smpl 2006.2-!k {%date}-!k-1

'Estimation
equation eq{!k}{!a}{!b}{!c}{!d}
eq{!k}{!a}{!b}{!c}{!d}.ls ggdp g_ave_{!a} g_ave_{!b} g_ave_{!c} AR(1) AR(2) AR(3) AR(4) C

'Make a model from the estimated equation
eq{!k}{!a}{!b}{!c}{!d}.makemodel(eqmod{!k}{!a}{!b}{!c}{!d})

'State the sample forecast period
smpl {%date}-!k {%date}-!k

'Solve the model for the forecast sample
solve eqmod{!k}{!a}{!b}{!c}{!d}

'Capture the forecast values
vector yf!k
stomna(ggdp_0,yf!k)


'fill in forecast values
table(!fill,1)={!a}{!b}{!c}{!d}
table(!fill,!k+2)=yf!k(1)

'Prepare the actual values of GDP for comparison
vector y!k
stomna(ggdp,y!k)

next

'after all k have been calculated, find rmse over the !periods horizon
!sqerr=0
for !k=1 to !periods
!sqerr=!sqerr+(yf{!k}(1)-y{!k}(1))^2
next

table(!fill,!periods+3)=({!sqerr}/{!periods})^0.5
table(!fill,!periods+4)={!a}
table(!fill,!periods+5)={!b}
table(!fill,!periods+6)={!c}
table(!fill,!periods+7)={!d}

'delete stuff
for !k=0 to !periods
delete eq{!k}{!a}{!b}{!c}{!d}
delete eqmod{!k}{!a}{!b}{!c}{!d}
delete y{!k}
delete yf{!k}
next

're-adjust to the full sample
Smpl @all

!fill=!fill+1

next
next
next

'---------------------------------------------------------------------------------------------
'2 indicators
'---------------------------------------------------------------------------------------------
!fill=!fill

for !a=11 to 10+{!number}-1
for !b=!a+1 to 10+{!number}
!c=0
!d=0

for !k=0 to !periods
smpl 2006.2-!k {%date}-!k-1

'Estimation
equation eq{!k}{!a}{!b}{!c}{!d}
eq{!k}{!a}{!b}{!c}{!d}.ls ggdp g_ave_{!a} g_ave_{!b} AR(1) AR(2) AR(3) AR(4) C

'Make a model from the estimated VAR
eq{!k}{!a}{!b}{!c}{!d}.makemodel(eqmod{!k}{!a}{!b}{!c}{!d})

'State the sample forecast period
smpl {%date}-!k {%date}-!k

'Solve the model for the forecast sample
solve eqmod{!k}{!a}{!b}{!c}{!d}

'Capture the forecast values
vector yf!k
stomna(ggdp_0,yf!k)


'fill in forecast values
table(!fill,1)={!a}{!b}{!c}{!d}
table(!fill,!k+2)=yf!k(1)

'Prepare the actual values of GDP for comparison
vector y!k
stomna(ggdp,y!k)

next

'after all k have been calculated, find rmse over the !periods horizon

!sqerr=0

for !k=1 to !periods

!sqerr=!sqerr+(yf{!k}(1)-y{!k}(1))^2

next

table(!fill,!periods+3)=({!sqerr}/{!periods})^0.5
table(!fill,!periods+4)={!a}
table(!fill,!periods+5)={!b}
table(!fill,!periods+6)={!c}
table(!fill,!periods+7)={!d}

'delete stuff

for !k=0 to !periods
delete eq{!k}{!a}{!b}{!c}{!d}
delete eqmod{!k}{!a}{!b}{!c}{!d}
delete y{!k}
delete yf{!k}
next

're-adjust to the full sample
smpl @all

!fill=!fill+1

next
next

'---------------------------------------------------------------------------------------------
'1 indicator
'---------------------------------------------------------------------------------------------
!fill=!fill

for !a=11 to 10+{!number}
!b=0
!c=0
!d=0

for !k=0 to !periods
smpl 2006.2-!k {%date}-!k-1

'Estimation
equation eq{!k}{!a}{!b}{!c}{!d}
eq{!k}{!a}{!b}{!c}{!d}.ls ggdp g_ave_{!a} AR(1) AR(2) AR(3) AR(4) C

'Make a model from the estimated VAR
eq{!k}{!a}{!b}{!c}{!d}.makemodel(eqmod{!k}{!a}{!b}{!c}{!d})

'State the sample forecast period
smpl {%date}-!k {%date}-!k

'Solve the model for the forecast sample
solve eqmod{!k}{!a}{!b}{!c}{!d}

'Capture the forecast values
vector yf!k
stomna(ggdp_0,yf!k)


'fill in forecast values
table(!fill,1)={!a}{!b}{!c}{!d}
table(!fill,!k+2)=yf!k(1)

'Prepare the actual values of GDP for comparison
vector y!k
stomna(ggdp,y!k)

next

'after all k have been calculated, find rmse over the !periods horizon

!sqerr=0

for !k=1 to !periods

!sqerr=!sqerr+(yf{!k}(1)-y{!k}(1))^2

next

table(!fill,!periods+3)=({!sqerr}/{!periods})^0.5
table(!fill,!periods+4)={!a}
table(!fill,!periods+5)={!b}
table(!fill,!periods+6)={!c}
table(!fill,!periods+7)={!d}

'delete stuff

for !k=0 to !periods
delete eq{!k}{!a}{!b}{!c}{!d}
delete eqmod{!k}{!a}{!b}{!c}{!d}
delete y{!k}
delete yf{!k}
next

're-adjust to the full sample
smpl @all

!fill=!fill+1

next

'fill in remainder rows, if any
for !fill=!fill to 32000
for !abc=1 to 15
table(!fill,{!abc})="NA"
next
next

table.save(t=csv) ecmfinal
