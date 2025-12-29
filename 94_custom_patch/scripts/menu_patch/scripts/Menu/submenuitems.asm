;.submenuitems is a pointer table to the submenu items
; each submenu item must contain 20 characters, pad the rest with spaces
; modified by chaos
SubMenuItems:
.submenus    
    ;Submenu items pointer table
    dc.w    playmode-.submenus          ;playmmode menu items pointer       
    dc.w    players-.submenus           ;players menu items pointer         
    dc.w    penalties2-.submenus        ;Team 1  menu items pointer         *Not sure why it points here, but the original did. Looks like placeholder.
    dc.w    penalties2-.submenus        ;Team 2  menu items pointer         *Not sure why it points here, but the original did. Looks like placeholder.
    dc.w    PeriodLengths-.submenus     ;period lengths menu items pointer  
    dc.w    goalies-.submenus           ;goalies menu items pointer         
    dc.w    userrecords-.submenus       ;user Records menu items pointer    
    dc.w    penalties-.submenus         ;Penalties menu items pointer       
    dc.w    linechanges-.submenus       ;line changes menu items pointer    
    dc.w    fighting-.submenus          ;Fighting Menu items pointer     
playmode
    SUBMENU	'Regular Season      '
    SUBMENU	'Continue Playoffs   '
    SUBMENU	'New Playoffs        '
    SUBMENU	'New Playoffs/7 game '
    SUBMENU	'Shootout            '
players
    SUBMENU	'Demo                '
    SUBMENU	'One - Home          '
    SUBMENU	'One - Visitor       '
    SUBMENU	'Two - Teammates     '
    SUBMENU	'Two - Head to Head  '
    SUBMENU	'Two - Head to Head  '
    SUBMENU	'Two - Teammates     '
    SUBMENU	'One                 '
    SUBMENU	'Demo                '
    SUBMENU	'One - Home          '
    SUBMENU	'One - Visitor       '
    SUBMENU	'Two - Teammates     '
    SUBMENU	'Two - Head to Head  '
    SUBMENU	'Three               '
    SUBMENU	'Four                '
    SUBMENU	'Two - Head to Head  '
    SUBMENU	'Two - Teammates     '
    SUBMENU	'Three               '
    SUBMENU	'Four                '
    SUBMENU	'One                 '
PeriodLengths
    SUBMENU	'5 Minutes           '
    SUBMENU	'10 Minutes          '		
    SUBMENU	'20 Minutes          '
    IF Set99MinOvertime
    SUBMENU	'5 Minutes, 99 Min OT'
    ELSE
    SUBMENU	'30 Seconds          '
    ENDIF
goalies
    SUBMENU	'Manual Control      '
    SUBMENU	'Auto Control        '
penalties    
    SUBMENU	'Off                 '
    SUBMENU	'On                  '
penalties2    
    SUBMENU	'On, Except Off-sides'
userrecords
    SUBMENU	'On                  '
    SUBMENU	'Off                 '
linechanges
    SUBMENU	'On                  '
    SUBMENU	'Off                 '
    SUBMENU	'Auto                '
fighting    
    SUBMENU	'Off                 '
    SUBMENU	'On                  '
    SUBMENU 'On - Arcade Mode    '    ; added 3rd option