Config = {
    Framework = 'esx', -- [ 'qb' / 'esx' ]
    MarriagePed = 'cs_priest',
    PriestName = 'Peter Churchson',
    SQL = 'oxmysql',
    PedCoords = vector4(-1684.29, -291.76, 51.89, 138.12),
    Inventory = 'ox', -- [ 'qb' / 'ox' / 'ls' ]
    InteractType = 'drawtext', -- = [ 'drawtext' / 'ox_target' / 'qb-target' ]
    RingItem = 'engagement_ring',
    ProposeItem = 'propose_box',
    CertificateItem = 'marry_certificate',

    ERPAnims = {
        {
            ['Label'] = 'Standing Blow Job',
            ['RequesterLabel'] = 'She wants to give you a blow job.',
            ['Requester'] = {
                ['Type'] = 'animation', ['Dict'] = 'misscarsteal2pimpsex', ['Anim'] = 'pimpsex_hooker', ['Flags'] = 1, ['Attach'] = {
                    ['Bone'] = 9816,
                    ['xP'] = 0.0,
                    ['yP'] = 0.65,
                    ['zP'] = 0.0,
    
                    ['xR'] = 120.0,
                    ['yR'] = 0.0,
                    ['zR'] = 180.0,
                }
            },
            ['Accepter'] = {
                ['Type'] = 'animation', ['Dict'] = 'misscarsteal2pimpsex', ['Anim'] = 'pimpsex_punter', ['Flags'] = 1,
            },
        },
        {
            ['Label'] = 'Standing Sex',
            ['RequesterLabel'] = 'Want to sex',
            ['Requester'] = {
                ['Type'] = 'animation', ['Dict'] = 'misscarsteal2pimpsex', ['Anim'] = 'shagloop_hooker', ['Flags'] = 1, ['Attach'] = {
                    ['Bone'] = 9816,
                    ['xP'] = 0.05,
                    ['yP'] = 0.4,
                    ['zP'] = 0.0,
    
                    ['xR'] = 120.0,
                    ['yR'] = 0.0,
                    ['zR'] = 180.0,
                }
            },
            ['Accepter'] = {
                ['Type'] = 'animation', ['Dict'] = 'misscarsteal2pimpsex', ['Anim'] = 'shagloop_pimp', ['Flags'] = 1,
            },
        },
        {
            ['Label'] = 'Standing Sex 2', 
            ['RequesterLabel'] = 'Want to sex',
            ['Requester'] = {
                ['Type'] = 'animation', ['Dict'] = 'rcmpaparazzo_2', ['Anim'] = 'shag_loop_a', ['Flags'] = 1,
            }, 
            ['Accepter'] = {
                ['Type'] = 'animation', ['Dict'] = 'rcmpaparazzo_2', ['Anim'] = 'shag_loop_poppy', ['Flags'] = 1, ['Attach'] = {
                    ['Bone'] = 9816,
                    ['xP'] = 0.015,
                    ['yP'] = 0.35,
                    ['zP'] = 0.0,
    
                    ['xR'] = 0.9,
                    ['yR'] = 0.3,
                    ['zR'] = 0.0,
                },
            },
        },
        {
            ['Label'] = "Vehicle Sex (Driver)", 
            ['RequesterLabel'] = 'Wants sex in the car with you',
            ['Car'] = true,
            ['Requester'] = {
                ['Type'] = 'animation', ['Dict'] = 'oddjobs@assassinate@vice@sex', ['Anim'] = 'frontseat_carsex_loop_m', ['Flags'] = 1,
            }, 
            ['Accepter'] = {
                ['Type'] = 'animation', ['Dict'] = 'oddjobs@assassinate@vice@sex', ['Anim'] = 'frontseat_carsex_loop_f', ['Flags'] = 1,
            },
        },
        {
            ['Label'] = "Vehicle Sex 2", 
            ['RequesterLabel'] = 'Wants sex in the car with you',
            ['Car'] = true,
            ['Requester'] = {
                ['Type'] = 'animation', ['Dict'] = 'random@drunk_driver_2', ['Anim'] = 'cardrunksex_loop_f', ['Flags'] = 1,
            }, 
            ['Accepter'] = {
                ['Type'] = 'animation', ['Dict'] = 'random@drunk_driver_2', ['Anim'] = 'cardrunksex_loop_m', ['Flags'] = 1,
            },
        },
        {
            ['Label'] = "Blowjob in Car (Driver)", 
            ['RequesterLabel'] = 'Wants sex in the car with you',
            ['Car'] = true,
            ['Requester'] = {
                ['Type'] = 'animation', ['Dict'] = 'oddjobs@towing', ['Anim'] = 'm_blow_job_loop', ['Flags'] = 1,
            }, 
            ['Accepter'] = {
                ['Type'] = 'animation', ['Dict'] = 'oddjobs@towing', ['Anim'] = 'f_blow_job_loop', ['Flags'] = 1,
            },
        }
    },

    AddOnAnims = {
        {
            dict = "zmdev@erotica_spooningm",
            anim = "spooningm",
            label = "Spooning Position",
            dict2 = "zmdev@erotica_spooningf",
            anim2 = "spooningf",
            AnimationOptions = {
                xPos = -0.09,
                yPos = -0.20,
                zPos = 0.0,
                xRot = 0.0,
                yRot = 0.0,
                zRot = 0.0,
            }
        },
        {
            dict = "zmdev@erotica_missionarym",
            anim = "missionarym",
            label = "Missionary Position",
            dict2 = "zmdev@erotica_missionaryf",
            anim2 = "missionaryf",
            AnimationOptions = {
                xPos = 0.08,
                yPos = 0.02,
                zPos = 0.0,
                xRot = 0.0,
                yRot = 0.0,
                zRot = 0.0,
            }
        },
        {
            dict = "zmdev@erotica_doggystyle2m",
            anim = "doggystyle2m",
            label = "Doggy Position",
            dict2 = "zmdev@erotica_doggystyle2f",
            anim2 = "doggystyle2f",
            AnimationOptions = {
                xPos = -0.39,
                yPos = 0.0,
                zPos = 0.0,
                xRot = 0.0,
                yRot = 0.0,
                zRot = 0.0,
            }
        },
        {
            dict = "zmdev@erotica_cowgirlm",
            anim = "cowgirlm",
            label = "Cowgirl",
            dict2 = "zmdev@erotica_cowgirlf",
            anim2 = "cowgirlf",
            AnimationOptions = {
                xPos = 0.0,
                yPos = 0.05,
                zPos = 0.0,
                xRot = 0.0,
                yRot = 0.0,
                zRot = 0.0,
            }
        },
        {
            dict = "zmdev@erotica_standingcowgirlm",
            anim = "standingcowgirlm",
            label = "Standing Cowgirl",
            dict2 = "zmdev@erotica_standingcowgirlf",
            anim2 = "standingcowgirlf",
            AnimationOptions = {
                xPos = 0.0,
                yPos = 0.05,
                zPos = 0.0,
                xRot = 0.0,
                yRot = 0.0,
                zRot = 0.0,
            }
        },
        {
            dict = "genesismods_kissme@kissmale8",
            anim = "kissmale8",
            label = "Kiss",
            dict2 = "genesismods_kissme@kissfemale8",
            anim2 = "kissfemale8",
            AnimationOptions = {
                xPos = -0.56,
                yPos = 0.0,
                zPos = 0.0,
                xRot = 0.0,
                yRot = 0.0,
                zRot = 0.0,
                
            }
        },
    }
}